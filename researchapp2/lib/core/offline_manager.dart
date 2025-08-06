import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class OfflineManager {
  static const String _offlineDataKey = 'offline_data';
  static const String _pendingActionsKey = 'pending_actions';
  
  /// Check if device is online
  static Future<bool> isOnline() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
      return result != ConnectivityResult.none;
    } catch (e) {
      return false; // Assume offline on error
    }
  }
  
  /// Save data for offline use
  static Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = await getOfflineData();
      
      existingData[key] = {
        ...data,
        'cached_at': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_offlineDataKey, jsonEncode(existingData));
    } catch (e) {
      print('Failed to save offline data: $e');
    }
  }
  
  /// Get offline data
  static Future<Map<String, dynamic>> getOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataJson = prefs.getString(_offlineDataKey);
      
      if (dataJson != null) {
        return jsonDecode(dataJson) as Map<String, dynamic>;
      }
      
      return {};
    } catch (e) {
      print('Failed to get offline data: $e');
      return {};
    }
  }
  
  /// Queue action for when online
  static Future<void> queueAction(String action, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingActions = await getPendingActions();
      
      existingActions.add({
        'action': action,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      await prefs.setString(_pendingActionsKey, jsonEncode(existingActions));
      print('✅ Action queued for sync: $action');
    } catch (e) {
      print('Failed to queue action: $e');
    }
  }
  
  /// Get pending actions
  static Future<List<Map<String, dynamic>>> getPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actionsJson = prefs.getString(_pendingActionsKey);
      
      if (actionsJson != null) {
        final List<dynamic> decoded = jsonDecode(actionsJson);
        return decoded.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('Failed to get pending actions: $e');
      return [];
    }
  }
  
  /// Process all pending actions when online
  static Future<void> processPendingActions() async {
    try {
      if (!await isOnline()) {
        print('Still offline, cannot process pending actions');
        return;
      }
      
      final actions = await getPendingActions();
      final processedIds = <String>[];
      
      for (final action in actions) {
        try {
          await _processAction(action);
          processedIds.add(action['id'] as String);
          print('✅ Processed action: ${action['action']}');
        } catch (e) {
          print('❌ Failed to process action ${action['action']}: $e');
        }
      }
      
      // Remove processed actions
      if (processedIds.isNotEmpty) {
        final remainingActions = actions.where((action) => 
          !processedIds.contains(action['id'] as String)).toList();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_pendingActionsKey, jsonEncode(remainingActions));
        
        print('✅ Processed ${processedIds.length} pending actions');
      }
      
    } catch (e) {
      print('Failed to process pending actions: $e');
    }
  }
  
  /// Process individual action
  static Future<void> _processAction(Map<String, dynamic> action) async {
    final actionType = action['action'] as String;
    final data = action['data'] as Map<String, dynamic>;
    
    // Import dynamically to avoid circular dependencies
    switch (actionType) {
      case 'save_progress':
        // Process progress save directly to Firebase
        await _syncProgressDirectly(data);
        break;
        
      case 'submit_feedback':
        // Process feedback submission directly to Firebase
        await _submitFeedbackDirectly(data);
        break;
        
      case 'update_profile':
        // Process profile update directly to Firebase
        await _updateProfileDirectly(data);
        break;
        
      default:
        print('Unknown action type: $actionType');
    }
  }
  
  /// Direct Firebase progress sync
  static Future<void> _syncProgressDirectly(Map<String, dynamic> data) async {
    try {
      // Check if user is authenticated before syncing
      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        print('Sync skipped: No authenticated user');
        return;
      }
      
      final episodeId = data['episodeId'] as String?;
      final progressData = data['progressData'] as Map<String, dynamic>?;
      
      if (episodeId != null && progressData != null) {
        // Include user ID in the data and use user-scoped document path
        final enhancedProgressData = {
          ...progressData,
          'userId': user.uid,
          'episodeId': episodeId,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        // Use Firebase service directly with user-scoped document
        await FirebaseService.firestore
            .collection('episode_progress')
            .doc('${user.uid}_$episodeId')
            .set(enhancedProgressData, SetOptions(merge: true));
        print('✅ Offline sync successful: $episodeId for user ${user.uid}');
      }
    } catch (e) {
      print('Failed to sync progress directly: $e');
      rethrow;
    }
  }
  
  /// Direct Firebase feedback submission
  static Future<void> _submitFeedbackDirectly(Map<String, dynamic> data) async {
    try {
      // Check if user is authenticated before submitting
      final user = FirebaseService.auth.currentUser;
      if (user == null) {
        print('Feedback submission skipped: No authenticated user');
        return;
      }
      
      await FirebaseService.firestore
          .collection('feedback')
          .add(data);
    } catch (e) {
      print('Failed to submit feedback directly: $e');
      rethrow;
    }
  }
  
  /// Direct Firebase profile update
  static Future<void> _updateProfileDirectly(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'] as String?;
      if (userId != null) {
        await FirebaseService.firestore
            .collection('users')
            .doc(userId)
            .set(data, SetOptions(merge: true));
      }
    } catch (e) {
      print('Failed to update profile directly: $e');
      rethrow;
    }
  }
  
  /// Initialize offline manager
  static Future<void> initialize() async {
    // Set up connectivity listener
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      if (result != ConnectivityResult.none) {
        print('📶 Connection restored, processing pending actions...');
        await processPendingActions();
      } else {
        print('📵 Connection lost, entering offline mode');
      }
    });
    
    // Process any pending actions on startup if online
    if (await isOnline()) {
      await processPendingActions();
    }
  }
  
  /// Clear all offline data (for testing/reset)
  static Future<void> clearOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_offlineDataKey);
      await prefs.remove(_pendingActionsKey);
      print('✅ Offline data cleared');
    } catch (e) {
      print('Failed to clear offline data: $e');
    }
  }
}
