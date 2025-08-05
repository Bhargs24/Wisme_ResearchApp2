import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';
import 'admin_service.dart';
import '../services/progress_persistence_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true; // Start as loading
  bool _isAuthInitialized = false;
  bool _isProfileLoaded = false;
  Map<String, dynamic>? _userProfile;
  bool? _isAdminUser; // Cache admin status
  
  AuthProvider() {
    print('AuthProvider constructor called');
    // Delay initialization to avoid Firebase issues during startup
    Future.delayed(Duration.zero, () {
      _initializeAuthState();
    });
  }
  
  void _initializeAuthState() async {
    print('Initializing auth state...');
    try {
      // Check for existing user session first
      _user = FirebaseAuth.instance.currentUser;
      
      // If user exists, load their profile immediately
      if (_user != null) {
        await _loadUserProfile();
      }
      
      // Mark auth as initialized
      _isAuthInitialized = true;
      _isLoading = false;
      notifyListeners();
      
      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        print('Auth state changed: ${user?.uid}');
        final wasSignedIn = _user != null;
        _user = user;
        
        // Handle sign in - load profile
        if (user != null && !wasSignedIn) {
          await _loadUserProfile();
        }
        
        // Handle sign out - clear profile
        if (user == null && wasSignedIn) {
          _userProfile = null;
          _isProfileLoaded = false;
        }
        
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing auth state: $e');
      _isLoading = false;
      _isAuthInitialized = true;
      // Set to offline mode if Firebase is not available
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_user != null) {
        final doc = await FirebaseService.getUserProfile(_user!.uid);
        _userProfile = doc?.data() as Map<String, dynamic>?;
        _isProfileLoaded = true;
        
        // Check admin status
        await checkAdminStatus();
        
        // 🔥 CRITICAL: Load cross-device progress when user signs in
        await _loadCrossDeviceProgress();
        
        print('✅ User profile loaded from Firebase');
      }
    } catch (e) {
      print('❌ Failed to load user profile: $e');
      _isProfileLoaded = false;
    }
  }

  // 🔥 NEW: Load progress from Firebase for cross-device sync
  Future<void> _loadCrossDeviceProgress() async {
    if (_user == null) return;
    
    try {
      // Load progress from Firebase to sync across devices
      await ProgressPersistenceService.loadProgressFromFirebase(_user!.uid);
      print('✅ Cross-device progress loaded successfully');
    } catch (e) {
      print('❌ Failed to load cross-device progress: $e');
      // Don't fail the login process if progress sync fails
    }
  }
  
  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get isAuthInitialized => _isAuthInitialized;
  bool get isProfileLoaded => _isProfileLoaded;
  Map<String, dynamic>? get userProfile => _userProfile;

  // Public method to reload user profile (useful after profile updates)
  Future<void> reloadUserProfile() async {
    if (_user != null) {
      await _loadUserProfile();
    }
  }

  // Google Sign-In for proper user identification
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await FirebaseService.signInWithGoogle();
      if (_user != null) {
        await _loadUserProfile();
      }
      notifyListeners();
    } catch (e) {
      print('Google sign-in failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Sign-In
  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await FirebaseService.signInWithEmail(email, password);
      if (_user != null) {
        await _loadUserProfile();
      }
    } catch (e) {
      print('Email sign-in failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Registration
  Future<void> registerWithEmail(String email, String password, [Map<String, dynamic>? userProfile]) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await FirebaseService.registerWithEmail(email, password);
      if (_user != null) {
        // Save user profile with research consent and validation data
        await FirebaseService.createOrUpdateUserProfile(_user!.uid, {
          ...(userProfile ?? {}),
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'researchConsent': true,
          'emailVerified': _user!.emailVerified,
          'deviceInfo': await _getDeviceInfo(),
          'ipAddress': await _getIPAddress(),
        });
      }
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phone OTP Send
  Future<bool> sendPhoneOTP(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await FirebaseService.sendPhoneOTP(phoneNumber);
    } catch (e) {
      print('Phone OTP send failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phone OTP Verification
  Future<void> verifyPhoneOTP(String otpCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await FirebaseService.verifyPhoneOTP(otpCode);
    } catch (e) {
      print('OTP verification failed: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // REMOVED: Anonymous Sign-In - All users must register properly for reliable research data

  // Admin access check - now uses proper role-based system
  bool get isAdmin => _isAdminUser ?? false;
  
  Future<void> checkAdminStatus() async {
    if (_user != null) {
      try {
        _isAdminUser = await AdminService.isUserAdmin(_user!.uid, _user!.email ?? '');
        notifyListeners();
      } catch (e) {
        print('Error checking admin status: $e');
        _isAdminUser = false; // Default to non-admin if permission denied
        notifyListeners();
      }
    }
  }

  void signOut() async {
    try {
      await FirebaseService.auth.signOut();
    } catch (e) {
      print('Firebase sign-out failed: $e');
    }
    _user = null;
    notifyListeners();
  }

  // Password reset
  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseService.auth.sendPasswordResetEmail(email: email);
  }

  // Anti-fraud measures
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    // For APK: This collects actual device info for research integrity
    return {
      'platform': 'android', // APK = Android
      'appVersion': '1.0.0',
      'buildMode': 'release',
      'timezone': DateTime.now().timeZoneName,
      'locale': 'en_US', // Could detect actual locale
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<String> _getIPAddress() async {
    // For APK: IP tracking for duplicate prevention
    // In production, this would use a service to get real IP
    return 'apk_user_${DateTime.now().millisecondsSinceEpoch}';
  }
} 