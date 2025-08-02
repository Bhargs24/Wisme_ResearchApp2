import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class XPLevelUpScreen extends StatelessWidget {
  final int newLevel;
  final int xp;
  final int xpToNext;
  const XPLevelUpScreen({super.key, required this.newLevel, required this.xp, required this.xpToNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Confetti animation placeholder
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.trending_up, size: 56, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text('Level Up!', style: AppTextStyles.heading1.copyWith(fontSize: 28)),
                const SizedBox(height: 16),
                Text('You reached Level $newLevel', style: AppTextStyles.heading2.copyWith(fontSize: 22, color: AppColors.accentGreen)),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('XP Progress', style: AppTextStyles.caption),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: xp / xpToNext,
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
                Text('Keep going! Next reward at Level ${newLevel + 1}', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 