import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/research_metrics_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SimpleEpisodeFeedbackScreen extends StatefulWidget {
  final String episodeNumber;
  
  const SimpleEpisodeFeedbackScreen({
    super.key,
    required this.episodeNumber,
  });

  @override
  State<SimpleEpisodeFeedbackScreen> createState() => _SimpleEpisodeFeedbackScreenState();
}

class _SimpleEpisodeFeedbackScreenState extends State<SimpleEpisodeFeedbackScreen> {
  String? _effectiveness;
  String? _featureValue;
  String? _usageIntent;
  bool _isSubmitting = false;

  final List<Map<String, String>> _effectivenessOptions = [
    {
      'value': 'not_effective',
      'title': 'Not effective',
      'subtitle': 'I didn\'t learn much, wouldn\'t work for real topics I need',
    },
    {
      'value': 'somewhat_effective',
      'title': 'Somewhat effective',
      'subtitle': 'Learned a few things, might work for some topics',
    },
    {
      'value': 'very_effective',
      'title': 'Very effective',
      'subtitle': 'Learned significantly more than usual, would use for many topics',
    },
    {
      'value': 'extremely_effective',
      'title': 'Extremely effective',
      'subtitle': 'Best learning method I\'ve experienced, would use for all topics',
    },
  ];

  final List<Map<String, String>> _featureValueOptions = [
    {
      'value': 'instant_episodes',
      'title': 'Instant audio episodes on any topic',
      'subtitle': 'Like what you just tried, but for unlimited subjects',
    },
    {
      'value': 'interactive_conversations',
      'title': 'Interactive conversations with AI mentors',
      'subtitle': 'Ask questions and get real-time teaching responses',
    },
    {
      'value': 'personalized_paths',
      'title': 'Personalized learning paths',
      'subtitle': 'AI remembers what you\'ve learned and suggests next steps',
    },
    {
      'value': 'voice_text_input',
      'title': 'Voice + text input for hands-free learning',
      'subtitle': 'Learn while commuting, exercising, or doing other tasks',
    },
    {
      'value': 'custom_ai_voices',
      'title': 'Custom AI voices and personalities',
      'subtitle': 'Choose teaching styles that match your learning preferences',
    },
  ];

  final List<Map<String, String>> _usageIntentOptions = [
    {
      'value': 'wouldnt_replace',
      'title': 'Wouldn\'t replace my current methods',
      'subtitle': 'Prefer traditional learning approaches',
    },
    {
      'value': 'use_occasionally',
      'title': 'Would use occasionally',
      'subtitle': 'For specific topics or situations',
    },
    {
      'value': 'use_regularly',
      'title': 'Would use regularly',
      'subtitle': 'Alongside other learning methods',
    },
    {
      'value': 'primary_method',
      'title': 'Would make it my primary learning method',
      'subtitle': 'For most topics I want to learn',
    },
    {
      'value': 'completely_replace',
      'title': 'Would completely replace other resources',
      'subtitle': 'This would be my main way to learn new things',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text('Episode ${widget.episodeNumber} Feedback'),
        backgroundColor: AppColors.cardBackground,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Congratulations Header
            _buildCelebrationHeader(),
            
            const SizedBox(height: 32),
            
            // Question 1: Effectiveness
            _buildQuestionSection(
              'How effective was this conversational learning style for you?',
              'In the full Wisme app, you\'ll have an AI study buddy that creates personalized episodes on ANY topic and interactive conversations where you can ask questions.',
              _effectivenessOptions,
              _effectiveness,
              (value) => setState(() => _effectiveness = value),
            ),
            
            const SizedBox(height: 32),
            
            // Question 2: Feature Value
            _buildQuestionSection(
              'Which Wisme feature would be most valuable for your learning?',
              'The full app will offer these capabilities based on what you just experienced:',
              _featureValueOptions,
              _featureValue,
              (value) => setState(() => _featureValue = value),
            ),
            
            const SizedBox(height: 32),
            
            // Question 3: Usage Intent
            _buildQuestionSection(
              'How would you use Wisme compared to your current learning methods?',
              'Imagine Wisme works for ANY topic with both audio episodes and interactive AI tutoring:',
              _usageIntentOptions,
              _usageIntent,
              (value) => setState(() => _usageIntent = value),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.celebration, size: 48, color: AppColors.primaryBlue),
          const SizedBox(height: 12),
          Text(
            'Episode ${widget.episodeNumber} Complete! 🎉',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.primaryBlue,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Quick check-in: How did that feel?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSection(
    String question,
    String context,
    List<Map<String, String>> options,
    String? selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) => _buildOptionCard(
          option['value']!,
          option['title']!,
          option['subtitle']!,
          selectedValue == option['value'],
          () => onSelect(option['value']!),
        )),
      ],
    );
  }

  Widget _buildOptionCard(
    String value,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withOpacity(0.2) : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 12)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _effectiveness != null && 
        _featureValue != null && 
        _usageIntent != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit && !_isSubmitting ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Continue Learning',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    try {
      final metricsProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      // Create enhanced feedback data for Phase 2 validation
      final feedbackData = {
        'episode_number': widget.episodeNumber,
        'learning_effectiveness': _effectiveness,
        'most_valuable_feature': _featureValue,
        'usage_intent': _usageIntent,
        'timestamp': DateTime.now().toIso8601String(),
        'feedback_version': 'phase2_validation_v1',
        // Critical research metrics preserved
        'research_context': 'conversational_learning_effectiveness',
        'business_context': 'phase2_feature_validation',
      };

      // Record simple feedback
      metricsProvider.captureMicroFeedback(
        episodeId: 'episode_${widget.episodeNumber}',
        trigger: 'simple_feedback_completion',
        feedback: feedbackData,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting feedback: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
