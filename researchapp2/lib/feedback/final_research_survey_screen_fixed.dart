import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';

class FinalResearchSurveyScreen extends StatefulWidget {
  const FinalResearchSurveyScreen({super.key});

  @override
  State<FinalResearchSurveyScreen> createState() => _FinalResearchSurveyScreenState();
}

class _FinalResearchSurveyScreenState extends State<FinalResearchSurveyScreen> {
  int? _overallExperienceRating;
  int? _researchValueRating;
  int? _overallMethodComparison;
  int? _futureMethodPreference;
  int? _learningFrequency;
  int? _learningBudget;

  bool _isFinalSurveyComplete() {
    return _overallExperienceRating != null && _researchValueRating != null && _overallMethodComparison != null && _futureMethodPreference != null && _learningFrequency != null && _learningBudget != null;
  }

  void _submitFinalSurvey() async {
    try {
      final researchProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      // Submit the final survey data
      researchProvider.captureProductMarketFit(
        productSatisfaction: (_overallExperienceRating ?? 0).toDouble(),
        howDisappointedIfGone: (_researchValueRating ?? 0).toDouble(),
        primaryBenefits: ['research_participation'],
        improvementSuggestions: ['user_feedback'],
        triggerContext: 'final_research_survey',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Research survey submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamed(context, '/study_completion');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting survey. Please try again.'),
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
      appBar: AppBar(title: const Text('Final Research Survey')),
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
                        Text('Complete Your Research Participation', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text('These final questions help us analyze the research results', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFinalSurveyQuestion(
                  'How would you rate your overall experience with our learning journeys?',
                  _overallExperienceRating,
                  (value) => setState(() => _overallExperienceRating = value),
                  ['Very Poor', 'Poor', 'Fair', 'Good', 'Excellent']
                ),
                _buildFinalSurveyQuestion(
                  'How valuable did you find this research method for learning?',
                  _researchValueRating,
                  (value) => setState(() => _researchValueRating = value),
                  ['Not valuable', 'Slightly valuable', 'Moderately valuable', 'Very valuable', 'Extremely valuable']
                ),
                _buildFinalSurveyQuestion(
                  'Compared to traditional learning methods, how would you rate this approach?',
                  _overallMethodComparison,
                  (value) => setState(() => _overallMethodComparison = value),
                  ['Much worse', 'Worse', 'About the same', 'Better', 'Much better']
                ),
                _buildFinalSurveyQuestion(
                  'Would you choose this learning method in the future?',
                  _futureMethodPreference,
                  (value) => setState(() => _futureMethodPreference = value),
                  ['Definitely not', 'Probably not', 'Might or might not', 'Probably yes', 'Definitely yes']
                ),
                _buildFinalSurveyQuestion(
                  'How often do you typically engage in learning activities?',
                  _learningFrequency,
                  (value) => setState(() => _learningFrequency = value),
                  ['Rarely', 'Monthly', 'Weekly', 'Daily', 'Multiple times daily']
                ),
                _buildFinalSurveyQuestion(
                  'What is your typical monthly learning/education budget?',
                  _learningBudget,
                  (value) => setState(() => _learningBudget = value),
                  ['\$0', '\$1-25', '\$26-50', '\$51-100', '\$100+']
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isFinalSurveyComplete() ? _submitFinalSurvey : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Complete Research Study', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: "final_survey_fab",
              onPressed: _isFinalSurveyComplete() ? _submitFinalSurvey : null,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.assignment_turned_in, color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSurveyQuestion(String question, int? selectedValue, ValueChanged<int?> onChanged, List<String> options) {
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
