import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';
import '../core/research_metrics_provider.dart';
import '../theme/app_colors.dart';

class DebugProfileScreen extends StatelessWidget {
  const DebugProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Debug Profile State'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer2<AuthProvider, ResearchMetricsProvider>(
        builder: (context, auth, research, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Auth State', [
                  'Is Signed In: ${auth.isSignedIn}',
                  'Is Auth Initialized: ${auth.isAuthInitialized}',
                  'Is Profile Loaded: ${auth.isProfileLoaded}',
                  'User UID: ${auth.user?.uid ?? 'null'}',
                  'User Email: ${auth.user?.email ?? 'null'}',
                  'Profile Null: ${auth.userProfile == null}',
                ]),
                
                const SizedBox(height: 20),
                
                _buildSection('Profile Content', [
                  'Profile Keys: ${auth.userProfile?.keys.toList() ?? 'null'}',
                  'Has Demographics: ${auth.userProfile?['demographics'] != null}',
                  'Has Profile: ${auth.userProfile?['profile'] != null}',
                  'Onboarding Complete: ${auth.userProfile?['onboardingComplete']}',
                  'Emergency Profile: ${auth.userProfile?['emergencyProfile']}',
                ]),
                
                const SizedBox(height: 20),
                
                _buildSection('Research State', [
                  'Research User ID: ${research.userId ?? 'null'}',
                  'Has Completed Demographics: ${research.hasCompletedDemographics}',
                  'Is Onboarding Complete: ${research.isOnboardingComplete}',
                ]),
                
                const SizedBox(height: 20),
                
                if (auth.userProfile != null) ...[
                  _buildSection('Raw Profile Data', [
                    auth.userProfile.toString(),
                  ]),
                  const SizedBox(height: 20),
                ],
                
                ElevatedButton(
                  onPressed: () async {
                    await auth.forceReloadProfile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile reloaded')),
                    );
                  },
                  child: const Text('Force Reload Profile'),
                ),
                
                const SizedBox(height: 10),
                
                ElevatedButton(
                  onPressed: () async {
                    await auth.clearAllUserData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data cleared')),
                    );
                  },
                  child: const Text('Clear All Data'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          )),
        ],
      ),
    );
  }
}
