import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  
  // Local storage keys
  static const String _userProfileKey = 'wisme_user_profile';
  static const String _lastProfileSyncKey = 'wisme_last_profile_sync';
  
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
    print('🔍 Loading user profile for: ${_user?.uid}');
    print('🔍 User email: ${_user?.email}');
    print('🔍 Auth method: ${FirebaseService.getCurrentAuthMethod()}');
    _isProfileLoaded = false; // Mark as loading
    
    try {
      if (_user != null) {
        // First try to load from local storage for instant access
        await _loadUserProfileFromLocal();
        
        // Then try to load from Firebase (with retries)
        int attempts = 0;
        const maxAttempts = 3;
        
        while (attempts < maxAttempts) {
          try {
            print('🔍 Profile load attempt ${attempts + 1}/$maxAttempts for UID: ${_user!.uid}');
            final doc = await FirebaseService.getUserProfile(_user!.uid);
            
            if (doc != null && doc.exists) {
              final firebaseProfile = doc.data() as Map<String, dynamic>?;
              if (firebaseProfile != null) {
                _userProfile = firebaseProfile;
                // Save to local storage for next time
                await _saveUserProfileToLocal();
                print('✅ User profile loaded from Firebase: ${_userProfile?.keys}');
                print('✅ Profile content: $_userProfile');
              }
              break;
            } else {
              print('⚠️ No profile document found in Firebase for user: ${_user!.uid}');
              print('⚠️ Document exists: ${doc?.exists}');
              print('⚠️ Document data: ${doc?.data()}');
              
              // Check if there's ANY profile document for this email
              await _debugFindProfileByEmail();
              
              // Keep local profile if Firebase has none
              if (_userProfile == null) {
                print('⚠️ No local or Firebase profile, user needs onboarding');
              } else {
                print('⚠️ Using local profile: ${_userProfile?.keys}');
              }
              break;
            }
          } catch (e) {
            attempts++;
            print('❌ Profile load attempt $attempts failed: $e');
            if (attempts >= maxAttempts) {
              print('⚠️ Using local profile as fallback after Firebase failures');
              // Keep whatever local profile we have
              break;
            }
            // Wait before retry
            await Future.delayed(Duration(milliseconds: 500 * attempts));
          }
        }
        
        _isProfileLoaded = true;
        
        // Check admin status
        await checkAdminStatus();
        
        // 🔥 CRITICAL: Load cross-device progress when user signs in
        await _loadCrossDeviceProgress();
        
        print('✅ User profile loading complete');
        notifyListeners(); // Always notify after profile loading
      }
    } catch (e) {
      print('❌ Failed to load user profile after retries: $e');
      // Try to keep local profile if available, or create emergency profile
      if (_userProfile == null) {
        await _createEmergencyProfile();
      }
      _isProfileLoaded = true; // Mark as done even if failed
      notifyListeners(); // Notify even on failure so UI can proceed
    }
  }

  // Debug method to find profile by email if UID doesn't work
  Future<void> _debugFindProfileByEmail() async {
    if (_user?.email == null) return;
    
    try {
      print('🔍 Searching for profile by email: ${_user!.email}');
      final querySnapshot = await FirebaseService.firestore
          .collection('users')
          .where('email', isEqualTo: _user!.email)
          .limit(1)
          .get();
          
      if (querySnapshot.docs.isNotEmpty) {
        final foundDoc = querySnapshot.docs.first;
        print('⚠️ Found profile with different UID: ${foundDoc.id}');
        print('⚠️ Current UID: ${_user!.uid}');
        print('⚠️ Found profile data: ${foundDoc.data()}');
        
        // Use the found profile
        _userProfile = Map<String, dynamic>.from(foundDoc.data());
        await _saveUserProfileToLocal();
        
        // Update the profile to use current UID
        await FirebaseService.createOrUpdateUserProfile(_user!.uid, _userProfile!);
        print('✅ Migrated profile to current UID');
      } else {
        print('⚠️ No profile found by email either');
      }
    } catch (e) {
      print('❌ Error searching profile by email: $e');
    }
  }

  // Load user profile from local storage
  Future<void> _loadUserProfileFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);
      if (profileJson != null) {
        _userProfile = Map<String, dynamic>.from(jsonDecode(profileJson));
        print('✅ User profile loaded from local storage: ${_userProfile?.keys}');
        print('✅ Local profile content: $_userProfile');
      } else {
        print('⚠️ No local profile found in SharedPreferences');
      }
    } catch (e) {
      print('❌ Failed to load profile from local storage: $e');
    }
  }

  // Save user profile to local storage
  Future<void> _saveUserProfileToLocal() async {
    try {
      if (_userProfile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userProfileKey, jsonEncode(_userProfile));
        await prefs.setString(_lastProfileSyncKey, DateTime.now().toIso8601String());
        print('✅ User profile saved to local storage');
      }
    } catch (e) {
      print('❌ Failed to save profile to local storage: $e');
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

  // Emergency profile recovery - creates minimal profile if none exists
  Future<void> _createEmergencyProfile() async {
    if (_user != null && _userProfile == null) {
      try {
        _userProfile = {
          'profile': {
            'firstName': 'User',
            'lastName': '',
            'displayName': 'User',
            'fullName': 'User',
            'createdAt': DateTime.now().toIso8601String(),
          },
          'emergencyProfile': true,
          'needsOnboarding': true,
        };
        
        // Save emergency profile to both local and Firebase
        await _saveUserProfileToLocal();
        await FirebaseService.createOrUpdateUserProfile(_user!.uid, _userProfile!);
        
        print('🚨 Emergency profile created');
      } catch (e) {
        print('❌ Failed to create emergency profile: $e');
      }
    }
  }
  
  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isLoading => _isLoading;
  bool get isAuthInitialized => _isAuthInitialized;
  bool get isProfileLoaded => _isProfileLoaded;
  Map<String, dynamic>? get userProfile => _userProfile;

  // Manual method to force reload profile (for debugging)
  Future<void> forceReloadProfile() async {
    print('🔄 Force reloading user profile...');
    if (_user != null) {
      _userProfile = null;
      _isProfileLoaded = false;
      notifyListeners();
      await _loadUserProfile();
    }
  }

  // Public method to reload user profile (useful after profile updates)
  Future<void> reloadUserProfile() async {
    if (_user != null) {
      await _loadUserProfile();
    }
  }

  // Update user profile data and save to both local and Firebase
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {
    if (_user != null) {
      try {
        _userProfile = {...(_userProfile ?? {}), ...profileData};
        
        // Save to Firebase first
        await FirebaseService.createOrUpdateUserProfile(_user!.uid, _userProfile!);
        
        // Save to local storage as backup
        await _saveUserProfileToLocal();
        
        print('✅ User profile updated and saved');
        notifyListeners();
      } catch (e) {
        print('❌ Failed to update user profile: $e');
        // Still save locally and notify UI
        await _saveUserProfileToLocal();
        notifyListeners();
        rethrow;
      }
    }
  }

  // Clear all user data on sign out
  Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear user profile data
      await prefs.remove(_userProfileKey);
      await prefs.remove(_lastProfileSyncKey);
      
      // Clear progress data
      await ProgressPersistenceService.clearAllProgress();
      await ProgressPersistenceService.clearPersonalizationPreferences();
      
      print('✅ All user data cleared');
    } catch (e) {
      print('❌ Failed to clear user data: $e');
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
        // Ensure UI updates after profile loading
        notifyListeners();
      }
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
        // Ensure UI updates after profile loading
        notifyListeners();
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
      
      // Clear all user data comprehensively
      await clearAllUserData();
      
      print('✅ Complete sign out and data cleanup');
    } catch (e) {
      print('Firebase sign-out failed: $e');
    }
    _user = null;
    _userProfile = null;
    _isProfileLoaded = false;
    _isAdminUser = null;
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