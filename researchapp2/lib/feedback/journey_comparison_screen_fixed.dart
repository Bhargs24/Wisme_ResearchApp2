import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import '../core/firebase_service.dart';

class JourneyComparisonScreen extends StatefulWidget {
  const JourneyComparisonScreen({super.key});

  @override
  State<JourneyComparisonScreen> createState() => _JourneyComparisonScreenState();
}

class _JourneyComparisonScreenState extends State<JourneyComparisonScreen> {
  int? _effectivenessComparison;
  int? _engagementComparison;
  int? _futurePreference;
  String _comparisonFeedback = '';
  final Map<String, double> _conversationalRatings = {};
  final Map<String, double> _traditionalRatings = {};
  final List<String> _attributes = [
    'Easy to follow',
    'Helped me understand concepts',
    'Kept my attention',
    'Made learning enjoyable',
    'Helped me remember information',
    'Felt personalized to me',
    'Made complex topics simple',
    'Motivated me to continue learning',
  ];

  bool _isComplete() {
    return _effectivenessComparison != null && _engagementComparison != null && _futurePreference != null;
  }

  void _submitComparison() async {
    try {
      final researchProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      // Submit journey comparison data
      researchProvider.captureFeatureInterest(
        featureInterest: {
          'effectiveness_comparison': (_effectivenessComparison ?? 0).toDouble(),
          'engagement_comparison': (_engagementComparison ?? 0).toDouble(),
          'future_preference': (_futurePreference ?? 0).toDouble(),
          ..._conversationalRatings,
          ..._traditionalRatings,
        },
        priorityFeatures: ['journey_comparison'],
        triggerContext: 'journey_comparison_screen',
      );

      // Submit additional text feedback if provided
      if (_comparisonFeedback.isNotEmpty) {
        FirebaseService.submitFeedback({
          'type': 'journey_comparison_text',
          'userId': researchProvider.userId,
          'data': {
            'timestamp': DateTime.now().toIso8601String(),
            'feedback': _comparisonFeedback,
            'triggerContext': 'journey_comparison_screen',
          },
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journey comparison submitted successfully!'),
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
      appBar: AppBar(title: const Text('Compare Your Journeys')),
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
                        Text('Journey Comparison', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text('Help us understand how different journeys compare', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildComparisonQuestion(
                  'Which journeys were most effective for learning?',
                  _effectivenessComparison,
                  (value) => setState(() => _effectivenessComparison = value),
                  ['DSA was much better', 'DSA was better', 'About equal', 'Psychology was better', 'Psychology was much better']
                ),
                _buildComparisonQuestion(
                  'Which journeys kept you more engaged?',
                  _engagementComparison,
                  (value) => setState(() => _engagementComparison = value),
                  ['DSA was much more engaging', 'DSA was more engaging', 'About equal', 'Psychology was more engaging', 'Psychology was much more engaging']
                ),
                _buildComparisonQuestion(
                  'For future learning, you would prefer:',
                  _futurePreference,
                  (value) => setState(() => _futurePreference = value),
                  ['Only DSA-style', 'Mostly DSA-style', 'Mixed approach', 'Mostly Psychology-style', 'Only Psychology-style']
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
                        Text('Additional Feedback', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                        const SizedBox(height: 16),
                        TextFormField(
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Any other thoughts about comparing your learning journeys?',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => setState(() => _comparisonFeedback = value),
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
              heroTag: "journey_comparison_fab",
              onPressed: _isComplete() ? _submitComparison : null,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.compare, color: Colors.white),
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
