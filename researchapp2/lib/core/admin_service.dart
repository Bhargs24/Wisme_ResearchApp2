import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AdminService {
  static const String _adminCollection = 'admin_users';
  static const String _adminConfigCollection = 'admin_config';
  
  /// Check if user has admin privileges
  static Future<bool> isUserAdmin(String userId, String email) async {
    // Development/Demo hardcoded admin emails - bypass Firebase for now
    const List<String> ADMIN_EMAILS = [
      'bhargavr098@gmail.com',
      'admin@wisme.com',
      'research@wisme.com',
    ];
    
    // Check hardcoded admin list first (for development)
    if (ADMIN_EMAILS.contains(email)) {
      print('✅ Admin access granted via hardcoded list: $email');
      return true;
    }
    
    try {
      // Check admin_users collection
      final adminDoc = await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(userId)
          .get();
      
      if (adminDoc.exists) {
        final data = adminDoc.data()!;
        return data['is_admin'] == true && 
               data['email'] == email &&
               data['status'] == 'active';
      }
      
      // Fallback: Check if user is in admin emails list (for initial setup)
      final configDoc = await FirebaseService.firestore
          .collection(_adminConfigCollection)
          .doc('admin_emails')
          .get();
      
      if (configDoc.exists) {
        final adminEmails = List<String>.from(configDoc.data()?['emails'] ?? []);
        return adminEmails.contains(email);
      }
      
      return false;
    } catch (e) {
      print('Firebase admin check failed, checking hardcoded list: $e');
      return ADMIN_EMAILS.contains(email);
    }
  }
  
  /// Grant admin privileges to a user
  static Future<void> grantAdminAccess(String userId, String email, String grantedBy) async {
    try {
      await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(userId)
          .set({
        'user_id': userId,
        'email': email,
        'is_admin': true,
        'status': 'active',
        'granted_by': grantedBy,
        'granted_at': FieldValue.serverTimestamp(),
        'permissions': {
          'view_analytics': true,
          'export_data': true,
          'manage_users': true,
          'manage_content': false, // Can be expanded
        }
      });
      
      print('✅ Admin access granted to $email');
    } catch (e) {
      print('❌ Failed to grant admin access: $e');
      throw Exception('Failed to grant admin access: $e');
    }
  }
  
  /// Revoke admin privileges
  static Future<void> revokeAdminAccess(String userId, String revokedBy) async {
    try {
      await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(userId)
          .update({
        'status': 'revoked',
        'revoked_by': revokedBy,
        'revoked_at': FieldValue.serverTimestamp(),
      });
      
      print('✅ Admin access revoked for user $userId');
    } catch (e) {
      print('❌ Failed to revoke admin access: $e');
      throw Exception('Failed to revoke admin access: $e');
    }
  }
  
  /// Get admin permissions for user
  static Future<Map<String, bool>> getAdminPermissions(String userId) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(_adminCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final permissions = doc.data()?['permissions'] as Map<String, dynamic>?;
        return permissions?.cast<String, bool>() ?? {};
      }
      
      return {};
    } catch (e) {
      print('Error getting admin permissions: $e');
      return {};
    }
  }
  
  /// List all admin users
  static Future<List<Map<String, dynamic>>> listAdminUsers() async {
    try {
      final snapshot = await FirebaseService.firestore
          .collection(_adminCollection)
          .where('status', isEqualTo: 'active')
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error listing admin users: $e');
      return [];
    }
  }
  
  /// Initialize admin system with first admin user
  static Future<void> initializeAdminSystem(String firstAdminEmail) async {
    try {
      // Check if already initialized
      final configDoc = await FirebaseService.firestore
          .collection(_adminConfigCollection)
          .doc('admin_emails')
          .get();
      
      if (!configDoc.exists) {
        // Create initial configuration
        await FirebaseService.firestore
            .collection(_adminConfigCollection)
            .doc('admin_emails')
            .set({
          'emails': [firstAdminEmail],
          'initialized_at': FieldValue.serverTimestamp(),
          'version': '1.0',
        });
        
        print('✅ Admin system initialized with email: $firstAdminEmail');
      }
    } catch (e) {
      print('❌ Failed to initialize admin system: $e');
      throw Exception('Failed to initialize admin system: $e');
    }
  }
  
  /// Add email to admin allowlist (for initial setup)
  static Future<void> addAdminEmail(String email) async {
    try {
      await FirebaseService.firestore
          .collection(_adminConfigCollection)
          .doc('admin_emails')
          .update({
        'emails': FieldValue.arrayUnion([email]),
      });
      
      print('✅ Added $email to admin allowlist');
    } catch (e) {
      print('❌ Failed to add admin email: $e');
      throw Exception('Failed to add admin email: $e');
    }
  }
  
  /// Remove email from admin allowlist
  static Future<void> removeAdminEmail(String email) async {
    try {
      await FirebaseService.firestore
          .collection(_adminConfigCollection)
          .doc('admin_emails')
          .update({
        'emails': FieldValue.arrayRemove([email]),
      });
      
      print('✅ Removed $email from admin allowlist');
    } catch (e) {
      print('❌ Failed to remove admin email: $e');
      throw Exception('Failed to remove admin email: $e');
    }
  }
  
  /// Log admin action for audit trail
  static Future<void> logAdminAction(String adminUserId, String action, Map<String, dynamic> details) async {
    try {
      await FirebaseService.firestore
          .collection('admin_audit_log')
          .add({
        'admin_user_id': adminUserId,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'ip_address': 'unknown', // TODO: Add IP detection
      });
    } catch (e) {
      print('Failed to log admin action: $e');
    }
  }
}
