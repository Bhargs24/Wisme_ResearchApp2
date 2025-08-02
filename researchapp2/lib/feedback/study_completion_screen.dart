import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'package:flutter/services.dart';

class StudyCompletionScreen extends StatelessWidget {
  const StudyCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final completedJourneys = 4;
    final totalLearningTime = 180;
    final completedSurveys = 5;
    final feedbackResponses = 12;
    return Scaffold(
      appBar: AppBar(title: const Text('Study Complete')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Congratulations! You are now a certified Research Contributor. Thank you for shaping the future of learning.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Digital certificate visual
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary, size: 48),
                    const SizedBox(height: 12),
                    Text('Research Contributor Certificate', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Awarded to:', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text('You', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('For valuable participation in the Wisme Research Study', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text('Date: ${DateTime.now().toLocal().toString().split(' ')[0]}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final shareText = 'I just completed the Wisme Research Study and earned my Research Contributor certificate! Proud to help shape the future of learning.';
                        await Clipboard.setData(ClipboardData(text: shareText));
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Share'),
                            content: const Text('Share message copied to clipboard! You can now paste it on LinkedIn, Twitter, or anywhere you like.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Exclusive reward code section
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.card_giftcard, color: Theme.of(context).colorScheme.primary, size: 36),
                    const SizedBox(height: 12),
                    Text('Exclusive Reward for Research Participants', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('As a thank you, you’ll get early access and a special reward in the main Wisme app!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Text('Your Reward Code:', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    SelectableText('RESEARCH-XXXX-YYYY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text('Redeem this code in the main app for your exclusive benefit. Codes are single-use and only for research participants.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Your Research Contribution', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                    const SizedBox(height: 20),
                    _buildStatRow('Learning journeys completed', '$completedJourneys'),
                    _buildStatRow('Total learning time', '$totalLearningTime minutes'),
                    _buildStatRow('Surveys completed', '$completedSurveys'),
                    _buildStatRow('Feedback responses', '$feedbackResponses'),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Your data will help validate new learning methods and improve education for millions of learners!', style: TextStyle(color: Colors.green[800]), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.card_membership, size: 50, color: AppColors.primaryBlue),
                    const SizedBox(height: 16),
                    Text('Research Participation Certificate', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Download your official certificate of participation', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show snackbar for certificate download
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Certificate download feature coming soon!'),
                            backgroundColor: Colors.blue,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Certificate'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What\'s Next?', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                    const SizedBox(height: 16),
                    _buildNextStepItem('📊', 'Research Analysis', 'We\'ll analyze all participant data to understand learning effectiveness'),
                    _buildNextStepItem('📝', 'Results Publication', 'Findings will be published in academic journals and conferences'),
                    _buildNextStepItem('🚀', 'Product Development', 'Your feedback will directly influence the development of Wisme'),
                    _buildNextStepItem('📧', 'Follow-up (Optional)', 'If you opted in, we may contact you for future research'),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Interested in the full Wisme app? We\'ll notify you when it launches!', style: TextStyle(color: Colors.orange[800]), textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Colors.green,
              ),
              child: const Text('Complete & Exit Study', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Show share dialog or copy link
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Research sharing feature coming soon!'),
                    backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Share this research with others'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "study_completion_fab",
        onPressed: () {
          // Navigate back to home screen
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.share, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(description, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 