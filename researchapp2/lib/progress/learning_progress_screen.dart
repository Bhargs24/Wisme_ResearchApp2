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
          // Use REAL data from research metrics
          final completedJourneys = research.completedJourneys.length;
          final totalJourneys = 4; // We have 4 journeys in the app
          final completedEpisodes = research.episodeCount;
          final totalEpisodes = 21; // Total episodes across all journeys (DSA:5, Finance:6, Psychology:5, Science:5)

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.volunteer_activism, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your learning journey is powering real research. Thank you for making a difference!',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Visual research impact/progress - NOW USES REAL DATA
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Research Impact', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _impactStat(Icons.map, 'Journeys', '$completedJourneys/$totalJourneys'),
                                _impactStat(Icons.headphones, 'Episodes', '$completedEpisodes/$totalEpisodes'),
                                _impactStat(Icons.feedback, 'Feedback', '${research.completedJourneys.length}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: totalJourneys > 0 ? completedJourneys / totalJourneys : 0.0,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              completedJourneys == totalJourneys 
                                ? 'Study Complete! Thank you for your participation in this research.'
                                : 'Continue participating to help complete this educational research study.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            Text('You\'re doing great! Keep going to complete the study', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInsightCard('Research Contribution', 'You\'ve provided valuable learning data for our study.', Icons.science, AppColors.primaryBlue),
                    _buildInsightCard('Engagement Patterns', 'Your usage patterns help us understand effective learning.', Icons.trending_up, AppColors.accentGreen),
                    _buildInsightCard('Study Progress', 'You\'re helping validate new educational approaches.', Icons.psychology, AppColors.accentOrange),
                    const SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Continue Your Participation', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.play_circle_fill, color: AppColors.primaryBlue),
                              title: const Text('Continue Learning Journeys'),
                              subtitle: const Text('More content available for the study'),
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
  }  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        subtitle: Text(value, style: AppTextStyles.bodyLarge),
      ),
    );
  }
}

Widget _impactStat(IconData icon, String label, String value) {
  return Column(
    children: [
      Icon(icon, color: Colors.blueAccent, size: 28),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
} 