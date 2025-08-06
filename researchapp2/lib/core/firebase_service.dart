import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Disabled - upgrade plan required
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  // static FirebaseStorage? _storage; // Disabled - upgrade plan required
  static FirebaseAnalytics? _analytics;
  static GoogleSignIn? _googleSignIn;
  
  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }
  
  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }
  
  // Firebase Storage disabled - upgrade plan required
  // static FirebaseStorage get storage {
  //   _storage ??= FirebaseStorage.instance;
  //   return _storage!;
  // }
  
  static FirebaseAnalytics get analytics {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  static GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      // Use the new project configuration - will be auto-configured for web
      scopes: ['email', 'profile'],
    );
    return _googleSignIn!;
  }

  // Google Sign-In Implementation
  static Future<User?> signInWithGoogle() async {
    try {
      print('Starting Google sign-in...');
      
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        return null;
      }

      print('Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Got Google auth tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Created Firebase credential');

      // Sign in to Firebase with the Google credential
      final UserCredential result = await auth.signInWithCredential(credential);
      
      print('Firebase sign-in successful: ${result.user?.email}');
      
      // Update user profile in Firestore
      if (result.user != null) {
        try {
          await createOrUpdateUserProfile(result.user!.uid, {
            'email': result.user!.email,
            'displayName': result.user!.displayName,
            'photoURL': result.user!.photoURL,
            'signInMethod': 'google',
            'lastSignIn': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
          print('User profile updated in Firestore');
        } catch (firestoreError) {
          print('Failed to update Firestore profile: $firestoreError');
          // Continue anyway - authentication still succeeded
        }
      }
      
      return result.user;
    } catch (e) {
      print('Google sign-in failed: $e');
      rethrow;
    }
  }

  // Sign out from Google
  static Future<void> signOutGoogle() async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
    } catch (e) {
      print('Google sign-out failed: $e');
    }
  }

  // Email/Password Authentication
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      print('Attempting email sign-in for: $email');
      
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Email sign-in successful: ${result.user?.email}');
      
      // Update last sign-in time
      if (result.user != null) {
        try {
          await createOrUpdateUserProfile(result.user!.uid, {
            'lastSignIn': FieldValue.serverTimestamp(),
            'emailVerified': result.user!.emailVerified,
          });
          print('Updated user profile after email sign-in');
        } catch (firestoreError) {
          print('Failed to update Firestore profile after email sign-in: $firestoreError');
          // Continue anyway - authentication still succeeded
        }
      }
      
      return result.user;
    } catch (e) {
      print('Email sign-in failed: $e');
      rethrow;
    }
  }

  static Future<User?> registerWithEmail(String email, String password) async {
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send verification email
      await result.user?.sendEmailVerification();
      
      // Update user profile in Firestore
      if (result.user != null) {
        await createOrUpdateUserProfile(result.user!.uid, {
          'email': result.user!.email,
          'signInMethod': 'email',
          'emailVerified': result.user!.emailVerified,
          'lastSignIn': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return result.user;
    } catch (e) {
      print('Email registration failed: $e');
      rethrow;
    }
  }

  // Phone Authentication Implementation
  static String? _verificationId;
  static int? _resendToken;

  // Send OTP to phone number
  static Future<bool> sendPhoneOTP(String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          try {
            await auth.signInWithCredential(credential);
          } catch (e) {
            print('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          print('OTP sent to $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      return true;
    } catch (e) {
      print('Phone OTP send failed: $e');
      rethrow;
    }
  }

  // Verify OTP and sign in
  static Future<User?> verifyPhoneOTP(String otp) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification ID found. Please request OTP first.');
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final UserCredential result = await auth.signInWithCredential(credential);
      
      // Update user profile in Firestore
      if (result.user != null) {
        await createOrUpdateUserProfile(result.user!.uid, {
          'phoneNumber': result.user!.phoneNumber,
          'signInMethod': 'phone',
          'lastSignIn': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return result.user;
    } catch (e) {
      print('Phone OTP verification failed: $e');
      rethrow;
    }
  }

  // Resend OTP
  static Future<bool> resendPhoneOTP(String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);
          } catch (e) {
            print('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          print('OTP resent to $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
      return true;
    } catch (e) {
      print('Phone OTP resend failed: $e');
      rethrow;
    }
  }

  // REMOVED: Anonymous sign-in - All users must register properly for reliable research data

  // Universal sign out method
  static Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      // Sign out from Firebase
      await auth.signOut();
    } catch (e) {
      print('Sign out failed: $e');
    }
  }

  // Get current authentication method
  static String getCurrentAuthMethod() {
    final user = auth.currentUser;
    if (user == null) return 'none';
    
    if (user.providerData.isNotEmpty) {
      final providerId = user.providerData.first.providerId;
      switch (providerId) {
        case 'google.com':
          return 'google';
        case 'phone':
          return 'phone';
        case 'password':
          return 'email';
        default:
          return 'unknown';
      }
    }
    
    if (user.isAnonymous) return 'anonymous';
    return 'email';
  }

  // User profile CRUD with improved error handling
  static Future<void> createOrUpdateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Failed to update user profile: $e');
      // Don't rethrow - allow app to continue functioning
    }
  }
  
  static Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      print('✅ User profile retrieved: ${doc.exists}');
      return doc;
    } catch (e) {
      print('❌ Failed to get user profile: $e');
      return null; // Return null instead of crashing
    }
  }

  // Fetch journeys/episodes
  static Future<QuerySnapshot?> getJourneys() async {
    try {
      return await firestore.collection('journeys').where('isActive', isEqualTo: true).get();
    } catch (e) {
      print('Failed to get journeys: $e');
      return null;
    }
  }
  static Future<QuerySnapshot?> getEpisodes(String journeyId) async {
    try {
      return await firestore.collection('episodes').where('journeyId', isEqualTo: journeyId).get();
    } catch (e) {
      print('Failed to get episodes: $e');
      return null;
    }
  }

  // Progress update
  static Future<void> updateUserProgress(String userJourneyId, Map<String, dynamic> data) async {
    try {
      await firestore.collection('user_progress').doc(userJourneyId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Failed to update progress: $e');
    }
  }

  // Feedback submission
  static Future<void> submitFeedback(Map<String, dynamic> data) async {
    try {
      await firestore.collection('feedback').add(data);
    } catch (e) {
      print('Failed to submit feedback: $e');
    }
  }

  // Analytics event logging
  static Future<void> logEvent(String name, Map<String, dynamic> params) async {
    try {
      // Convert dynamic values to supported types for Firebase Analytics
      final convertedParams = <String, Object>{};
      params.forEach((key, value) {
        if (value is String || value is int || value is double || value is bool) {
          convertedParams[key] = value;
        } else {
          convertedParams[key] = value.toString();
        }
      });
      await analytics.logEvent(name: name, parameters: convertedParams);
    } catch (e) {
      print('Failed to log analytics event: $e');
    }
  }

  // Data Validation & Anti-Fraud Methods
  static Future<void> submitValidatedFeedback(Map<String, dynamic> data, String userId) async {
    try {
      // Add validation metadata
      final validatedData = {
        ...data,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _generateSessionId(),
        'deviceFingerprint': await _getDeviceFingerprint(),
        'timeSpentMs': data['timeSpentMs'] ?? 0,
        'validated': true,
      };

      // Check for suspicious patterns
      if (_isDataSuspicious(validatedData)) {
        validatedData['flagged'] = true;
        validatedData['flagReason'] = 'Suspicious timing or patterns';
      }

      await firestore.collection('validated_feedback').add(validatedData);
    } catch (e) {
      print('Failed to submit validated feedback: $e');
    }
  }

  static Future<void> logUserActivity(String userId, String activity, Map<String, dynamic> context) async {
    try {
      await firestore.collection('user_activity_log').add({
        'userId': userId,
        'activity': activity,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
        'sessionId': _getCurrentSessionId(),
        'deviceInfo': await _getDeviceFingerprint(),
      });
    } catch (e) {
      print('Failed to log user activity: $e');
    }
  }

  // Anti-fraud validation
  static bool _isDataSuspicious(Map<String, dynamic> data) {
    // Check for impossibly fast completion
    final timeSpent = data['timeSpentMs'] as int? ?? 0;
    final minExpectedTime = 30000; // 30 seconds minimum
    if (timeSpent < minExpectedTime) return true;

    // Check for pattern matching (all same answers)
    final answers = data['answers'] as List<dynamic>? ?? [];
    if (answers.length > 3 && answers.every((a) => a == answers.first)) return true;

    return false;
  }

  static String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String _getCurrentSessionId() {
    // This would track the current session
    return _generateSessionId();
  }

  static Future<Map<String, dynamic>> _getDeviceFingerprint() async {
    return {
      'userAgent': 'browser_user_agent', // Would be detected
      'screenSize': '1920x1080', // Would be detected
      'timezone': DateTime.now().timeZoneName,
      'language': 'en', // Would be detected
    };
  }

  // Analytics Dashboard Data
  static Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      // Get user metrics
      final userSnapshot = await firestore.collection('users').get();
      final feedbackSnapshot = await firestore.collection('user_feedback').get();
      final activitiesSnapshot = await firestore.collection('user_activities').get();

      // Calculate metrics
      int totalUsers = userSnapshot.docs.length;
      int totalFeedback = feedbackSnapshot.docs.length;
      int totalActivities = activitiesSnapshot.docs.length;

      // Calculate engagement metrics
      Map<String, int> dailyActivity = {};
      for (var doc in activitiesSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          dailyActivity[dateKey] = (dailyActivity[dateKey] ?? 0) + 1;
        }
      }

      // Calculate retention rates
      Map<String, double> retentionRates = {
        'Week 1': _calculateRetentionRate(userSnapshot.docs, 7),
        'Week 2': _calculateRetentionRate(userSnapshot.docs, 14),
        'Week 3': _calculateRetentionRate(userSnapshot.docs, 21),
        'Month 1': _calculateRetentionRate(userSnapshot.docs, 30),
      };

      // Calculate user demographics
      Map<String, int> demographics = {};
      for (var doc in userSnapshot.docs) {
        final data = doc.data();
        final journey = data['user_journey'] ?? 'Unknown';
        demographics[journey] = (demographics[journey] ?? 0) + 1;
      }

      return {
        'totalUsers': totalUsers,
        'totalFeedback': totalFeedback,
        'totalActivities': totalActivities,
        'dailyActivity': dailyActivity,
        'retentionRates': retentionRates,
        'demographics': demographics,
        'avgSessionDuration': _calculateAverageSessionDuration(activitiesSnapshot.docs),
        'conversionRate': totalFeedback > 0 ? (totalUsers / totalFeedback * 100).round() : 0,
        'monthlyRevenue': _calculateMonthlyRevenue(),
        'userGrowth': _calculateUserGrowth(userSnapshot.docs),
      };
    } catch (e) {
      print('Error getting dashboard analytics: $e');
      return {
        'totalUsers': 0,
        'totalFeedback': 0,
        'totalActivities': 0,
        'dailyActivity': <String, int>{},
        'retentionRates': <String, double>{},
        'demographics': <String, int>{},
        'avgSessionDuration': 0.0,
        'conversionRate': 0,
        'monthlyRevenue': <String, double>{},
        'userGrowth': <String, int>{},
      };
    }
  }

  static double _calculateRetentionRate(List<QueryDocumentSnapshot> users, int days) {
    if (users.isEmpty) return 0.0;
    
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    int retainedUsers = 0;
    
    for (var doc in users) {
      final data = doc.data() as Map<String, dynamic>;
      final lastActivity = data['last_activity'] as Timestamp?;
      if (lastActivity != null && lastActivity.toDate().isAfter(cutoffDate)) {
        retainedUsers++;
      }
    }
    
    return (retainedUsers / users.length) * 100;
  }

  static double _calculateAverageSessionDuration(List<QueryDocumentSnapshot> activities) {
    if (activities.isEmpty) return 0.0;
    
    double totalDuration = 0;
    int sessionCount = 0;
    
    for (var doc in activities) {
      final data = doc.data() as Map<String, dynamic>;
      final duration = data['session_duration'] as double?;
      if (duration != null) {
        totalDuration += duration;
        sessionCount++;
      }
    }
    
    return sessionCount > 0 ? totalDuration / sessionCount : 0.0;
  }

  static Map<String, double> _calculateMonthlyRevenue() {
    // Return empty revenue data - no hardcoded simulation
    return <String, double>{};
  }

  static Map<String, int> _calculateUserGrowth(List<QueryDocumentSnapshot> users) {
    Map<String, int> growth = {};
    
    for (var doc in users) {
      final data = doc.data() as Map<String, dynamic>;
      final createdAt = data['created_at'] as Timestamp?;
      if (createdAt != null) {
        final date = createdAt.toDate();
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        growth[monthKey] = (growth[monthKey] ?? 0) + 1;
      }
    }
    
    return growth;
  }
} 