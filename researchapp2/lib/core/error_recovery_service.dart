import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backup_service.dart';
import 'offline_manager.dart';

class ErrorRecoveryService {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  /// Execute operation with automatic retry and recovery
  static Future<T> executeWithRecovery<T>(
    Future<T> Function() operation,
    String operationName, {
    int retries = maxRetries,
    bool requiresAuth = false,
    bool requiresNetwork = false,
  }) async {
    Exception? lastError;
    
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        // Pre-flight checks
        if (requiresNetwork && !await OfflineManager.isOnline()) {
          throw NetworkException('No internet connection available');
        }
        
        if (requiresAuth && FirebaseAuth.instance.currentUser == null) {
          throw AuthException('User not authenticated');
        }
        
        // Execute operation
        final result = await operation();
        
        if (attempt > 1) {
          print('✅ $operationName succeeded on attempt $attempt');
        }
        
        return result;
        
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        
        print('❌ $operationName failed on attempt $attempt: $e');
        
        // Handle specific error types
        if (e is NetworkException && !requiresNetwork) {
          // Queue for offline processing
          await OfflineManager.queueAction(operationName, {'error': e.toString()});
          throw OfflineException('Operation queued for when online');
        }
        
        if (e is AuthException) {
          // Try to recover authentication
          final recovered = await _recoverAuthentication();
          if (!recovered && attempt == retries) {
            throw AuthRecoveryFailedException('Authentication recovery failed');
          }
        }
        
        // Wait before retry (exponential backoff)
        if (attempt < retries) {
          await Future.delayed(retryDelay * attempt);
        }
      }
    }
    
    // All retries failed
    throw OperationFailedException('$operationName failed after $retries attempts: $lastError');
  }
  
  /// Recover from authentication errors
  static Future<bool> _recoverAuthentication() async {
    try {
      print('🔄 Attempting authentication recovery...');
      
      // Try to refresh current user
      await FirebaseAuth.instance.currentUser?.reload();
      
      if (FirebaseAuth.instance.currentUser != null) {
        print('✅ Authentication recovered');
        return true;
      }
      
      print('❌ Authentication recovery failed');
      return false;
      
    } catch (e) {
      print('❌ Authentication recovery error: $e');
      return false;
    }
  }
  
  /// Handle app crashes and recovery
  static Future<void> handleAppCrash(String userId, dynamic error, StackTrace stackTrace) async {
    try {
      print('🚨 App crash detected: $error');
      
      // Create emergency backup
      try {
        final offlineData = await OfflineManager.getOfflineData();
        await BackupService.createLocalBackup(userId, {
          'crash_backup': true,
          'error': error.toString(),
          'stack_trace': stackTrace.toString(),
          'offline_data': offlineData,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (backupError) {
        print('❌ Failed to create crash backup: $backupError');
      }
      
      // Queue crash report
      await OfflineManager.queueAction('crash_report', {
        'error': error.toString(),
        'stack_trace': stackTrace.toString(),
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      print('❌ Failed to handle app crash: $e');
    }
  }
  
  /// Show user-friendly error dialog with recovery options
  static void showErrorDialog(BuildContext context, String title, String message, {
    VoidCallback? onRetry,
    VoidCallback? onRecover,
    bool canDismiss = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: canDismiss,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text(
              'Your progress has been saved locally and will sync when connection is restored.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (onRecover != null)
            TextButton(
              onPressed: onRecover,
              child: const Text('Recover Data'),
            ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          if (canDismiss)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }
  
  /// Recovery workflow for corrupted state
  static Future<bool> performEmergencyRecovery(String userId) async {
    try {
      print('🚨 Starting emergency recovery workflow...');
      
      // Step 1: Try data recovery
      final dataRecovered = await BackupService.emergencyDataRecovery(userId);
      
      // Step 2: Clear corrupted offline data
      await OfflineManager.clearOfflineData();
      
      // Step 3: Reinitialize offline manager
      await OfflineManager.initialize();
      
      // Step 4: Process any pending actions
      if (await OfflineManager.isOnline()) {
        await OfflineManager.processPendingActions();
      }
      
      print(dataRecovered ? '✅ Emergency recovery successful' : '⚠️ Partial recovery completed');
      return true;
      
    } catch (e) {
      print('❌ Emergency recovery failed: $e');
      return false;
    }
  }
}

// Custom Exception Classes
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

class OfflineException implements Exception {
  final String message;
  OfflineException(this.message);
  @override
  String toString() => 'OfflineException: $message';
}

class AuthRecoveryFailedException implements Exception {
  final String message;
  AuthRecoveryFailedException(this.message);
  @override
  String toString() => 'AuthRecoveryFailedException: $message';
}

class OperationFailedException implements Exception {
  final String message;
  OperationFailedException(this.message);
  @override
  String toString() => 'OperationFailedException: $message';
}
