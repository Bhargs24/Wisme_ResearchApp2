import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/firebase_service.dart';
import '../core/error_recovery_service.dart';
import '../core/offline_manager.dart';
import '../core/backup_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive progress persistence service for mobile app deployment
/// Handles episode positions, journey progress, completion tracking, and offline resilience
class ProgressPersistenceService {
  static const String _keyPrefix = 'wisme_';
  static const String _episodeProgressKey = '${_keyPrefix}episode_progress';
  static const String _journeyProgressKey = '${_keyPrefix}journey_progress';
  static const String _completedEpisodesKey = '${_keyPrefix}completed_episodes';
  static const String _lastPlayedKey = '${_keyPrefix}last_played';
  static const String _lastSyncKey = '${_keyPrefix}last_sync';
  
  // SharedPreferences instance for persistent storage
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  
  /// Initialize the persistence service
  static Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        _prefs = await SharedPreferences.getInstance();
        _isInitialized = true;
      }
      debugPrint('✅ ProgressPersistenceService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize ProgressPersistenceService: $e');
      rethrow;
    }
  }
  
  /// Save episode playback position for resume functionality
  static Future<void> saveEpisodePosition({
    required String episodeId,
    required String journeyId,
    required int positionSeconds,
    required int durationSeconds,
    required DateTime timestamp,
  }) async {
    await ErrorRecoveryService.executeWithRecovery(
      () async {
        if (!_isInitialized) await initialize();
        
        final progressData = await getEpisodeProgressData();
        progressData[episodeId] = {
          'journeyId': journeyId,
          'positionSeconds': positionSeconds,
          'durationSeconds': durationSeconds,
          'progressPercentage': durationSeconds > 0 ? (positionSeconds / durationSeconds * 100).round() : 0,
          'lastPlayed': timestamp.toIso8601String(),
          'isCompleted': positionSeconds >= (durationSeconds * 0.9), // 90% = completed
        };
        
        await _prefs?.setString(_episodeProgressKey, jsonEncode(progressData));
        debugPrint('💾 Saved episode position: $episodeId at ${positionSeconds}s');
        debugPrint('🔍 PROGRESS DATA: ${progressData[episodeId]}');
        
        // Auto-sync to Firebase with offline support
        if (await OfflineManager.isOnline()) {
          print('🔍 SYNCING TO FIREBASE: $episodeId');
          _syncProgressToFirebase(episodeId, progressData[episodeId]!);
        } else {
          print('🔍 OFFLINE: Queuing progress for sync');
          await OfflineManager.queueAction('save_progress', {
            'episodeId': episodeId,
            'progressData': progressData[episodeId]!,
          });
        }
        
        // Create backup if needed
        if (await BackupService.needsBackup()) {
          await BackupService.createLocalBackup(episodeId, progressData);
        }
      },
      'save_episode_position',
      requiresNetwork: false,
    );
  }
  
  /// Get episode playback position for resume functionality
  static Future<Map<String, dynamic>?> getEpisodePosition(String episodeId) async {
    try {
      if (!_isInitialized) await initialize();
      
      final progressData = await getEpisodeProgressData();
      return progressData[episodeId];
    } catch (e) {
      debugPrint('❌ Failed to get episode position: $e');
      return null;
    }
  }
  
  /// Mark episode as completed
  static Future<void> markEpisodeCompleted({
    required String episodeId,
    required String journeyId,
    required Duration listenTime,
    required double engagementScore,
    required DateTime completedAt,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      
      // Update episode progress
      final progressData = await getEpisodeProgressData();
      progressData[episodeId] = {
        'journeyId': journeyId,
        'positionSeconds': progressData[episodeId]?['durationSeconds'] ?? 0,
        'durationSeconds': progressData[episodeId]?['durationSeconds'] ?? 0,
        'progressPercentage': 100,
        'lastPlayed': completedAt.toIso8601String(),
        'isCompleted': true,
        'completedAt': completedAt.toIso8601String(),
        'listenTime': listenTime.inSeconds,
        'engagementScore': engagementScore,
      };
      await _prefs?.setString(_episodeProgressKey, jsonEncode(progressData));
      
      // Update completed episodes list
      final completedEpisodes = await getCompletedEpisodes();
      if (!completedEpisodes.contains(episodeId)) {
        completedEpisodes.add(episodeId);
        await _prefs?.setString(_completedEpisodesKey, jsonEncode(completedEpisodes));
      }
      
      // Update journey progress
      await _updateJourneyProgress(journeyId);
      
      debugPrint('✅ Marked episode completed: $episodeId');
      
      // Sync to Firebase
      _syncCompletionToFirebase(episodeId, progressData[episodeId]!);
    } catch (e) {
      debugPrint('❌ Failed to mark episode completed: $e');
    }
  }
  
  /// Get all episode progress data
  static Future<Map<String, dynamic>> getEpisodeProgressData() async {
    try {
      if (!_isInitialized) await initialize();
      
      final progressJson = _prefs?.getString(_episodeProgressKey);
      if (progressJson != null) {
        return Map<String, dynamic>.from(jsonDecode(progressJson));
      }
      return {};
    } catch (e) {
      debugPrint('❌ Failed to get episode progress data: $e');
      return {};
    }
  }
  
  /// Get completed episodes list
  static Future<List<String>> getCompletedEpisodes() async {
    try {
      if (!_isInitialized) await initialize();
      final completedJson = _prefs?.getString(_completedEpisodesKey);
      if (completedJson != null) {
        return List<String>.from(jsonDecode(completedJson));
      }
      return [];
    } catch (e) {
      debugPrint('❌ Failed to get completed episodes: $e');
      return [];
    }
  }
  
  /// Save last played episode for quick resume
  static Future<void> saveLastPlayedEpisode({
    required String episodeId,
    required String journeyId,
    required String episodeTitle,
    required int position,
    required DateTime timestamp,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      
      final lastPlayedData = {
        'episodeId': episodeId,
        'journeyId': journeyId,
        'episodeTitle': episodeTitle,
        'position': position,
        'timestamp': timestamp.toIso8601String(),
      };
      
      await _prefs?.setString(_lastPlayedKey, jsonEncode(lastPlayedData));
      debugPrint('💾 Saved last played episode: $episodeTitle');
    } catch (e) {
      debugPrint('❌ Failed to save last played episode: $e');
    }
  }
  
  /// Get last played episode for quick resume
  static Future<Map<String, dynamic>?> getLastPlayedEpisode() async {
    try {
      if (!_isInitialized) await initialize();
      
      final lastPlayedJson = _prefs?.getString(_lastPlayedKey);
      if (lastPlayedJson != null) {
        return Map<String, dynamic>.from(jsonDecode(lastPlayedJson));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Failed to get last played episode: $e');
      return null;
    }
  }
  
  /// Get journey progress statistics
  static Future<Map<String, dynamic>> getJourneyProgress(String journeyId) async {
    try {
      if (!_isInitialized) await initialize();
      
      final progressData = await getJourneyProgressData();
      return progressData[journeyId] ?? {
        'completedEpisodes': 0,
        'totalEpisodes': 0,
        'progressPercentage': 0,
        'totalListenTime': 0,
        'averageEngagement': 0.0,
        'lastActivity': null,
      };
    } catch (e) {
      debugPrint('❌ Failed to get journey progress: $e');
      return {};
    }
  }
  
  /// Get all journey progress data
  static Future<Map<String, dynamic>> getJourneyProgressData() async {
    try {
      if (!_isInitialized) await initialize();
      
      final journeyJson = _prefs?.getString(_journeyProgressKey);
      if (journeyJson != null) {
        return Map<String, dynamic>.from(jsonDecode(journeyJson));
      }
      return {};
    } catch (e) {
      debugPrint('❌ Failed to get journey progress data: $e');
      return {};
    }
  }
  
  /// Check if episode is completed
  static Future<bool> isEpisodeCompleted(String episodeId) async {
    try {
      final completedEpisodes = await getCompletedEpisodes();
      return completedEpisodes.contains(episodeId);
    } catch (e) {
      debugPrint('❌ Failed to check episode completion: $e');
      return false;
    }
  }
  
  /// Get episode progress percentage (0-100)
  static Future<int> getEpisodeProgressPercentage(String episodeId) async {
    try {
      final progressData = await getEpisodeProgressData();
      return progressData[episodeId]?['progressPercentage'] ?? 0;
    } catch (e) {
      debugPrint('❌ Failed to get episode progress percentage: $e');
      return 0;
    }
  }
  
  /// Clear all progress data (for testing or reset)
  static Future<void> clearAllProgress() async {
    try {
      if (!_isInitialized) await initialize();
      
      await _prefs?.remove(_episodeProgressKey);
      await _prefs?.remove(_journeyProgressKey);
      await _prefs?.remove(_completedEpisodesKey);
      await _prefs?.remove(_lastPlayedKey);
      
      debugPrint('🧹 Cleared all progress data');
    } catch (e) {
      debugPrint('❌ Failed to clear progress data: $e');
    }
  }
  
  /// Sync local progress to Firebase
  static Future<void> syncProgressToFirebase(String userId) async {
    try {
      final episodeProgress = await getEpisodeProgressData();
      final journeyProgress = await getJourneyProgressData();
      
      final syncData = {
        'userId': userId,
        'episodeProgress': episodeProgress,
        'journeyProgress': journeyProgress,
        'lastSync': DateTime.now().toIso8601String(),
        'deviceInfo': {
          'platform': defaultTargetPlatform.name,
          'timestamp': DateTime.now().toIso8601String(),
        }
      };
      
      await FirebaseService.updateUserProgress('${userId}_progress_sync', syncData);
      await _prefs?.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      debugPrint('☁️ Synced progress to Firebase');
    } catch (e) {
      debugPrint('❌ Failed to sync progress to Firebase: $e');
    }
  }
  
  /// Load progress from Firebase (for cross-device sync)
  static Future<void> loadProgressFromFirebase(String userId) async {
    try {
      final doc = await FirebaseService.getUserProfile(userId);
      if (doc?.exists == true) {
        final data = doc!.data() as Map<String, dynamic>?;
        final syncData = data?['progressSync'] as Map<String, dynamic>?;
        
        if (syncData != null) {
          final episodeProgress = syncData['episodeProgress'] as Map<String, dynamic>?;
          final journeyProgress = syncData['journeyProgress'] as Map<String, dynamic>?;
          
          if (episodeProgress != null) {
            await _prefs?.setString(_episodeProgressKey, jsonEncode(episodeProgress));
          }
          if (journeyProgress != null) {
            await _prefs?.setString(_journeyProgressKey, jsonEncode(journeyProgress));
          }
          
          debugPrint('📥 Loaded progress from Firebase');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load progress from Firebase: $e');
    }
  }
  
  /// Update journey progress based on episode completions
  static Future<void> _updateJourneyProgress(String journeyId) async {
    try {
      final progressData = await getEpisodeProgressData();
      final journeyProgressData = await getJourneyProgressData();
      
      // Count episodes for this journey
      final journeyEpisodes = progressData.entries
          .where((entry) => entry.value['journeyId'] == journeyId)
          .toList();
      
      final completedJourneyEpisodes = journeyEpisodes
          .where((entry) => entry.value['isCompleted'] == true)
          .toList();
      
      final totalListenTime = journeyEpisodes
          .map((entry) => (entry.value['listenTime'] ?? 0) as int)
          .fold<int>(0, (a, b) => a + b);
      
      final averageEngagement = journeyEpisodes.isNotEmpty
          ? journeyEpisodes
              .map((entry) => (entry.value['engagementScore'] ?? 0.0) as double)
              .fold(0.0, (a, b) => a + b) / journeyEpisodes.length
          : 0.0;
      
      journeyProgressData[journeyId] = {
        'completedEpisodes': completedJourneyEpisodes.length,
        'totalEpisodes': journeyEpisodes.length,
        'progressPercentage': journeyEpisodes.isNotEmpty
            ? ((completedJourneyEpisodes.length / journeyEpisodes.length) * 100).round()
            : 0,
        'totalListenTime': totalListenTime,
        'averageEngagement': averageEngagement,
        'lastActivity': DateTime.now().toIso8601String(),
        'isCompleted': completedJourneyEpisodes.length == journeyEpisodes.length && journeyEpisodes.isNotEmpty,
      };
      
      await _prefs?.setString(_journeyProgressKey, jsonEncode(journeyProgressData));
    } catch (e) {
      debugPrint('❌ Failed to update journey progress: $e');
    }
  }
  
  /// Background sync to Firebase
  static void _syncProgressToFirebase(String episodeId, Map<String, dynamic> data) {
    // Fire and forget sync to prevent blocking UI
    () async {
      try {
        await FirebaseService.firestore
            .collection('episode_progress')
            .doc(episodeId)
            .set(data, SetOptions(merge: true));
      } catch (e) {
        debugPrint('❌ Background sync failed: $e');
      }
    }();
  }
  
  /// Background completion sync to Firebase
  static void _syncCompletionToFirebase(String episodeId, Map<String, dynamic> data) {
    // Fire and forget sync to prevent blocking UI
    () async {
      try {
        await FirebaseService.firestore
            .collection('episode_completions')
            .add({
          'episodeId': episodeId,
          'completedAt': DateTime.now().toIso8601String(),
          ...data,
        });
      } catch (e) {
        debugPrint('❌ Background completion sync failed: $e');
      }
    }();
  }

  /// Check if third episode feedback has been shown (should only show once)
  static Future<bool> hasShownThirdEpisodeFeedback() async {
    try {
      if (!_isInitialized) await initialize();
      return _prefs?.getBool('${_keyPrefix}third_episode_feedback_shown') ?? false;
    } catch (e) {
      debugPrint('❌ Error checking third episode feedback status: $e');
      return false;
    }
  }

  /// Mark that third episode feedback has been shown
  static Future<void> markThirdEpisodeFeedbackShown() async {
    try {
      if (!_isInitialized) await initialize();
      await _prefs?.setBool('${_keyPrefix}third_episode_feedback_shown', true);
      debugPrint('✅ Third episode feedback marked as shown');
    } catch (e) {
      debugPrint('❌ Error marking third episode feedback as shown: $e');
    }
  }
}
