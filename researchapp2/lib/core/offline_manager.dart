import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    
    // Import services dynamically to avoid circular dependencies
    switch (actionType) {
      case 'save_progress':
        // Process progress save
        final progressService = await _getProgressService();
        await progressService.syncToFirebase(data);
        break;
        
      case 'submit_feedback':
        // Process feedback submission
        final researchService = await _getResearchService();
        await researchService.submitFeedback(data);
        break;
        
      case 'update_profile':
        // Process profile update
        final authService = await _getAuthService();
        await authService.updateProfile(data);
        break;
        
      default:
        print('Unknown action type: $actionType');
    }
  }
  
  /// Dynamic service getters to avoid circular imports
  static Future<dynamic> _getProgressService() async {
    // Return progress persistence service instance
    throw UnimplementedError('Progress service integration needed');
  }
  
  static Future<dynamic> _getResearchService() async {
    // Return research metrics service instance
    throw UnimplementedError('Research service integration needed');
  }
  
  static Future<dynamic> _getAuthService() async {
    // Return auth service instance
    throw UnimplementedError('Auth service integration needed');
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
