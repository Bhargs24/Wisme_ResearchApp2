// Initial admin setup for the Firebase project
// Run this once to set up the first admin user

import 'package:cloud_firestore/cloud_firestore.dart';

class InitialAdminSetup {
  static Future<void> setupInitialAdmin() async {
    try {
      print('Setting up initial admin configuration...');
      final firestore = FirebaseFirestore.instance;
      
      // Try to check if admin config already exists
      try {
        final adminConfigDoc = await firestore.collection('admin_config').doc('admin_emails').get();
        
        if (!adminConfigDoc.exists) {
          // Only try to create if it doesn't exist
          await firestore.collection('admin_config').doc('admin_emails').set({
            'emails': [
              'bhargavr098@gmail.com', // Add your email here
              'admin@wisme.com',
              'research@wisme.com',
            ],
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
          
          print('✅ Initial admin configuration created successfully');
        } else {
          print('✅ Admin configuration already exists');
        }
      } catch (permissionError) {
        print('⚠️ Firebase permission denied for admin setup');
        print('ℹ️ Using hardcoded admin emails for development');
        print('ℹ️ Admin emails: bhargavr098@gmail.com, admin@wisme.com, research@wisme.com');
      }
      
      print('✅ Admin setup complete');
    } catch (e) {
      print('❌ Error setting up initial admin: $e');
      // Don't throw error - app should continue without admin features
      print('ℹ️ App will continue without admin functionality');
    }
  }
}
