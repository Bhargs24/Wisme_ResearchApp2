import 'package:flutter/material.dart';
import '../core/bottom_nav_bar.dart';
import '../home/modern_home_screen.dart';
import '../journeys/journey_selection_screen.dart';
import '../progress/learning_progress_screen.dart';
import '../gamification/profile_screen.dart';
import '../feedback/feedback_navigation_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ModernHomeScreen(),
    const JourneySelectionScreen(),
    const LearningProgressScreen(),
    const ProfileScreen(),
    const FeedbackNavigationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      drawer: _buildAppDrawer(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.accentGreen],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wisme Research',
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Demo Experience',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(
                    icon: Icons.analytics,
                    title: 'Research Center',
                    subtitle: 'Explore research insights',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/research_center');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.lightbulb_outline,
                    title: 'Suggest Topics',
                    subtitle: 'Help shape content',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/suggest_topic');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.trending_up,
                    title: 'Community Requests',
                    subtitle: 'Popular learning topics',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/community_requests');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.app_shortcut,
                    title: 'Full App Preview',
                    subtitle: 'See the complete Wisme vision',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/full_app_preview');
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildDrawerItem(
                    icon: Icons.bug_report,
                    title: 'Debug Profile',
                    subtitle: 'Profile debugging info',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/debug_profile');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      Navigator.pop(context);
                      _showSettingsDialog(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About Research',
                    subtitle: 'Study information',
                    onTap: () {
                      Navigator.pop(context);
                      _showResearchInfoDialog(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Sign Out
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildDrawerItem(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Exit research study',
                onTap: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  auth.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                },
                isDestructive: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive 
                ? AppColors.accentRed.withOpacity(0.2)
                : AppColors.backgroundCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.accentRed : Colors.white70,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.heading2.copyWith(
            color: isDestructive ? AppColors.accentRed : Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: isDestructive ? AppColors.accentRed.withOpacity(0.7) : Colors.white60,
            fontSize: 12,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text(
          'Settings',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.white70),
              title: Text(
                'Notifications',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.accentGreen,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.white70),
              title: Text(
                'Dark Mode',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.accentGreen,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Colors.white70),
              title: Text(
                'Sound Effects',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.accentGreen,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showResearchInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Text(
          'About This Research',
          style: AppTextStyles.heading2.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Educational Learning Research Study',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• You are participating in a research study about learning preferences\n'
              '• Your interactions help us understand effective educational methods\n'
              '• All data is anonymized and used for research purposes only\n'
              '• You can complete journeys and provide valuable feedback',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'Thank you for contributing to educational research!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(color: AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }
} 