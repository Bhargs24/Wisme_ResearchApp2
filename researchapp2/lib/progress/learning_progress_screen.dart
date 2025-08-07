import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import 'package:provider/provider.dart';

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: const Text('Your Learning Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.pushNamed(context, '/progress_visualization');
            },
          ),
        ],
      ),
      body: Consumer<ResearchMetricsProvider>(
        builder: (context, research, child) {
          // Use data from research metrics for basic progress tracking
          final completedJourneys = research.completedJourneys.length;
          final totalJourneys = 4; // We have 4 journeys in the app

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Learning Progress Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Semantics(
                              label: 'Progress: $completedJourneys of $totalJourneys journeys completed',
                              child: CircularProgressIndicator(
                                value: totalJourneys > 0 ? completedJourneys / totalJourneys : 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                strokeWidth: 8,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Semantics(
                              label: '$completedJourneys of $totalJourneys journeys completed',
                              child: Text(
                                '$completedJourneys of $totalJourneys journeys completed', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('You\'re doing great! Keep going to complete your learning journey!', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Continue Your Learning', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.play_circle_fill, color: AppColors.primaryBlue),
                              title: const Text('Continue Learning Journeys'),
                              subtitle: const Text('Explore more learning content'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => Navigator.pushNamed(context, '/journeys'),
                            ),
                            ListTile(
                              leading: const Icon(Icons.assignment, color: AppColors.accentOrange),
                              title: const Text('Provide Additional Feedback'),
                              subtitle: const Text('Help us understand your learning experience'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => Navigator.pushNamed(context, '/feedback_hub'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  heroTag: "progress_fab",
                  onPressed: () {
                    // Navigate to journey selection to continue learning
                    Navigator.pushNamed(context, '/journeys');
                  },
                  backgroundColor: AppColors.primaryBlue,
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 