import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BadgeUnlockedScreen extends StatelessWidget {
  final String badgeName;
  final String badgeDescription;
  const BadgeUnlockedScreen({super.key, required this.badgeName, required this.badgeDescription});

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
                  height: 120,
                  width: 120,
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
                  child: const Icon(Icons.emoji_events, size: 64, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Text('Badge Unlocked!', style: AppTextStyles.heading1.copyWith(fontSize: 28)),
                const SizedBox(height: 16),
                Text(badgeName, style: AppTextStyles.heading2.copyWith(fontSize: 22, color: AppColors.accentGreen)),
                const SizedBox(height: 8),
                Text(badgeDescription, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 