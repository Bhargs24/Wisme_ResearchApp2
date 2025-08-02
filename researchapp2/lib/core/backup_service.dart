import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class BackupService {
  static const String _backupKey = 'local_backup_data';
  static const String _lastBackupKey = 'last_backup_timestamp';
  
  /// Create local backup of critical user data
  static Future<void> createLocalBackup(String userId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final backup = {
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data,
        'version': '1.0',
      };
      
      await prefs.setString(_backupKey, jsonEncode(backup));
      await prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
      
      print('✅ Local backup created successfully');
    } catch (e) {
      print('❌ Failed to create local backup: $e');
      throw Exception('Backup creation failed: $e');
    }
  }
  
  /// Restore data from local backup
  static Future<Map<String, dynamic>?> restoreFromLocalBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(_backupKey);
      
      if (backupJson != null) {
        final backup = jsonDecode(backupJson) as Map<String, dynamic>;
        print('✅ Local backup restored successfully');
        return backup['data'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      print('❌ Failed to restore from local backup: $e');
      return null;
    }
  }
  
  /// Sync local data to Firebase with conflict resolution
  static Future<void> syncToFirebase(String userId, Map<String, dynamic> localData) async {
    try {
      // Get current Firebase data
      final firebaseDoc = await FirebaseService.getUserProfile(userId);
      final firebaseData = firebaseDoc?.data() as Map<String, dynamic>?;
      
      if (firebaseData == null) {
        // No Firebase data, upload local data
        await FirebaseService.createOrUpdateUserProfile(userId, localData);
        print('✅ Local data synced to Firebase (initial upload)');
        return;
      }
      
      // Conflict resolution: merge data with timestamp priority
      final mergedData = _mergeDataWithConflictResolution(localData, firebaseData);
      
      await FirebaseService.createOrUpdateUserProfile(userId, mergedData);
      print('✅ Data synced to Firebase with conflict resolution');
      
    } catch (e) {
      print('❌ Failed to sync to Firebase: $e');
      throw Exception('Firebase sync failed: $e');
    }
  }
  
  /// Merge data with conflict resolution (newer timestamp wins)
  static Map<String, dynamic> _mergeDataWithConflictResolution(
    Map<String, dynamic> localData,
    Map<String, dynamic> firebaseData,
  ) {
    final merged = Map<String, dynamic>.from(firebaseData);
    
    localData.forEach((key, value) {
      if (key.endsWith('_timestamp')) {
        // Compare timestamps for conflict resolution
        final localTimestamp = DateTime.tryParse(value.toString());
        final firebaseTimestamp = DateTime.tryParse(merged[key]?.toString() ?? '');
        
        if (localTimestamp != null && 
            (firebaseTimestamp == null || localTimestamp.isAfter(firebaseTimestamp))) {
          // Local data is newer, use it
          final dataKey = key.replaceAll('_timestamp', '');
          merged[key] = value;
          if (localData.containsKey(dataKey)) {
            merged[dataKey] = localData[dataKey];
          }
        }
      } else if (!merged.containsKey('${key}_timestamp')) {
        // No timestamp conflict, merge normally
        merged[key] = value;
      }
    });
    
    return merged;
  }
  
  /// Emergency data recovery
  static Future<bool> emergencyDataRecovery(String userId) async {
    try {
      print('🚨 Starting emergency data recovery...');
      
      // Try local backup first
      final localBackup = await restoreFromLocalBackup();
      if (localBackup != null) {
        await syncToFirebase(userId, localBackup);
        print('✅ Emergency recovery successful from local backup');
        return true;
      }
      
      // Try Firebase recovery
      final firebaseDoc = await FirebaseService.getUserProfile(userId);
      if (firebaseDoc != null && firebaseDoc.exists) {
        print('✅ Emergency recovery successful from Firebase');
        return true;
      }
      
      print('❌ No recoverable data found');
      return false;
      
    } catch (e) {
      print('❌ Emergency recovery failed: $e');
      return false;
    }
  }
  
  /// Check if backup is needed (older than 24 hours)
  static Future<bool> needsBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastBackupStr = prefs.getString(_lastBackupKey);
      
      if (lastBackupStr == null) return true;
      
      final lastBackup = DateTime.parse(lastBackupStr);
      final now = DateTime.now();
      
      return now.difference(lastBackup).inHours >= 24;
    } catch (e) {
      return true; // If we can't check, assume backup is needed
    }
  }
}
