import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StreakReminderPopup extends StatelessWidget {
  final int streak;
  const StreakReminderPopup({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.backgroundCard,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accentOrange, AppColors.primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text('You’re on a $streak-day streak!', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
            const SizedBox(height: 12),
            Text('Keep it up for a bonus badge!', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Close', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
} 