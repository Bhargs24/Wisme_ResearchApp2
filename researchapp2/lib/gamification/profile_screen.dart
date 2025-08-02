import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'gamification_provider.dart';
import '../core/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.displayName ?? 'User'; // Get real user name
    final gamification = Provider.of<GamificationProvider>(context);
    final xp = gamification.xp;
    final xpToNext = ((xp ~/ 1000) + 1) * 1000; // Simple level logic: 1000 XP per level
    final badges = gamification.badges;
    // TODO: Get real journey count from progress service
    final journeys = 4; // Will be replaced with actual count from ProgressPersistenceService
    final streak = gamification.streak;
    final level = (xp ~/ 1000) + 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Show settings bottom sheet
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.backgroundDark,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      ListTile(
                        leading: const Icon(Icons.info, color: Colors.white),
                        title: const Text('About Research', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.backgroundDark,
                              title: const Text('About This Research', style: TextStyle(color: Colors.white)),
                              content: const Text(
                                'This app is part of a research study on conversational learning methods. Your participation helps us understand how people learn better through interactive audio experiences.',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK', style: TextStyle(color: AppColors.primaryBlue)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(color: Colors.white24),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.backgroundDark,
                              title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                              content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Provider.of<AuthProvider>(context, listen: false).signOut();
                                  },
                                  child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: const CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 56, color: AppColors.primaryBlue),
              ),
            ),
            const SizedBox(height: 16),
            Text(userName, style: AppTextStyles.heading1.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            // XP bar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('XP', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: xpToNext > 0 ? xp / xpToNext : 0.0,
                      minHeight: 12,
                      backgroundColor: AppColors.backgroundCard,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                    ),
                    const SizedBox(height: 8),
                    Text('$xp / $xpToNext XP', style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Badges
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Badges', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  avatar: Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary, size: 20),
                  label: Text('Research Contributor', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.amber.withOpacity(0.18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                ...badges.map((badge) => Chip(
                  avatar: const Icon(Icons.emoji_events, color: AppColors.primaryBlue, size: 20),
                  label: Text(badge),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                )),
              ],
            ),
            const SizedBox(height: 24),
            // Stats
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat('Journeys', journeys.toString(), Icons.map),
                    _buildStat('Streak', '$streak days', Icons.local_fire_department),
                    _buildStat('Level', '$level', Icons.trending_up),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 28),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
} 