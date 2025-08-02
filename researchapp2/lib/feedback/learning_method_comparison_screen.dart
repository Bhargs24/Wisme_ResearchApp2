import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import '../core/firebase_service.dart';

class LearningMethodComparisonScreen extends StatefulWidget {
  const LearningMethodComparisonScreen({super.key});

  @override
  State<LearningMethodComparisonScreen> createState() => _LearningMethodComparisonScreenState();
}

class _LearningMethodComparisonScreenState extends State<LearningMethodComparisonScreen> {
  int? _engagementComparison;
  int? _retentionComparison;
  int? _enjoymentComparison;
  int? _futurePreference;
  String _additionalFeedback = '';

  bool _isComplete() {
    return _engagementComparison != null && 
           _retentionComparison != null && 
           _enjoymentComparison != null && 
           _futurePreference != null;
  }

  void _submitComparison() async {
    try {
      final researchProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      // Submit learning method comparison data
      researchProvider.captureFeatureInterest(
        featureInterest: {
          'engagement_vs_traditional': (_engagementComparison ?? 0).toDouble(),
          'retention_vs_traditional': (_retentionComparison ?? 0).toDouble(),
          'enjoyment_vs_traditional': (_enjoymentComparison ?? 0).toDouble(),
          'future_preference_conversational': (_futurePreference ?? 0).toDouble(),
        },
        priorityFeatures: ['conversational_learning_method'],
        triggerContext: 'learning_method_comparison',
      );

      // Submit additional text feedback if provided
      if (_additionalFeedback.isNotEmpty) {
        FirebaseService.submitFeedback({
          'type': 'learning_method_comparison_text',
          'userId': researchProvider.userId,
          'data': {
            'timestamp': DateTime.now().toIso8601String(),
            'feedback': _additionalFeedback,
            'triggerContext': 'learning_method_comparison',
          },
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Method comparison submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamed(context, '/feedback_hub');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting comparison. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Method Comparison')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text('Conversational vs Traditional Learning', 
                             style: AppTextStyles.heading1.copyWith(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text('Help us understand how conversational learning compares to your previous learning methods', 
                             style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildComparisonQuestion(
                  'How engaging was conversational learning compared to traditional methods (textbooks, lectures)?',
                  _engagementComparison,
                  (value) => setState(() => _engagementComparison = value),
                  ['Much less engaging', 'Less engaging', 'About the same', 'More engaging', 'Much more engaging']
                ),
                _buildComparisonQuestion(
                  'How well do you think you retained information with conversational learning vs traditional methods?',
                  _retentionComparison,
                  (value) => setState(() => _retentionComparison = value),
                  ['Much worse retention', 'Worse retention', 'About the same', 'Better retention', 'Much better retention']
                ),
                _buildComparisonQuestion(
                  'How enjoyable was conversational learning compared to traditional methods?',
                  _enjoymentComparison,
                  (value) => setState(() => _enjoymentComparison = value),
                  ['Much less enjoyable', 'Less enjoyable', 'About the same', 'More enjoyable', 'Much more enjoyable']
                ),
                _buildComparisonQuestion(
                  'For future learning, would you prefer conversational learning over traditional methods?',
                  _futurePreference,
                  (value) => setState(() => _futurePreference = value),
                  ['Strongly prefer traditional', 'Prefer traditional', 'No preference', 'Prefer conversational', 'Strongly prefer conversational']
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Additional Thoughts (Optional)', 
                             style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                        const SizedBox(height: 16),
                        TextFormField(
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Any other thoughts about conversational vs traditional learning methods?',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() => _additionalFeedback = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isComplete() ? _submitComparison : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                  child: const Text('Submit Comparison', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: "method_comparison_fab",
              onPressed: _isComplete() ? _submitComparison : null,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.psychology, color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonQuestion(String question, int? selectedValue, ValueChanged<int?> onChanged, List<String> options) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            ...List.generate(options.length, (index) {
              return RadioListTile<int>(
                title: Text(options[index]),
                value: index + 1,
                groupValue: selectedValue,
                onChanged: onChanged,
                activeColor: AppColors.primaryBlue,
              );
            }),
          ],
        ),
      ),
    );
  }
}
