import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/research_metrics_provider.dart';

class ThirdEpisodeFeedbackScreen extends StatefulWidget {
  const ThirdEpisodeFeedbackScreen({super.key});

  @override
  State<ThirdEpisodeFeedbackScreen> createState() => _ThirdEpisodeFeedbackScreenState();
}

class _ThirdEpisodeFeedbackScreenState extends State<ThirdEpisodeFeedbackScreen> {
  int _learningEffectiveness = 5;
  int _engagementLevel = 5;
  Map<String, double> _advancedFeatureInterest = {
    'ai_personalization': 5.0,
    'collaborative_learning': 5.0,
    'adaptive_difficulty': 5.0,
    'voice_interaction': 5.0,
    'real_time_feedback': 5.0,
    'learning_analytics': 5.0,
    'social_features': 5.0,
    'integration_tools': 5.0,
  };
  Map<String, int> _contentPreferences = {
    'conversation_style': 5,
    'episode_length': 5,
    'difficulty_progression': 5,
    'topic_variety': 5,
    'interactive_elements': 5,
  };
  List<String> _primaryBenefits = [];
  List<String> _improvementSuggestions = [];
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Experience Feedback'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.trending_up, size: 48, color: Colors.orange),
                  SizedBox(height: 12),
                  Text(
                    'Great Progress! 📈',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ve completed 3 episodes! Help us understand how your learning experience is evolving.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Learning Effectiveness
            const Text('How effective has your learning been so far?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildEffectivenessSlider(),
            
            const SizedBox(height: 32),
            
            // Engagement Level
            const Text('How engaged do you feel during episodes?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildEngagementSlider(),
            
            const SizedBox(height: 32),
            
            // Advanced Feature Interest
            const Text('What advanced features would enhance your experience?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildAdvancedFeatureSection(),
            
            const SizedBox(height: 32),
            
            // Content Preferences
            const Text('How would you rate the current content format?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildContentPreferencesSection(),
            
            const SizedBox(height: 32),
            
            // Primary Benefits
            const Text('What are the main benefits you\'ve experienced?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildBenefitsSection(),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Continue Your Journey →'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Skip Option
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectivenessSlider() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Not effective', style: TextStyle(color: Colors.grey)),
            Text('Highly effective', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: _learningEffectiveness.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              _learningEffectiveness = value.round();
            });
          },
        ),
        Text(
          'Effectiveness: $_learningEffectiveness/10',
          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEngagementSlider() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low engagement', style: TextStyle(color: Colors.grey)),
            Text('Highly engaged', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: _engagementLevel.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              _engagementLevel = value.round();
            });
          },
        ),
        Text(
          'Engagement: $_engagementLevel/10',
          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAdvancedFeatureSection() {
    final features = {
      'ai_personalization': 'AI-Powered Personalization',
      'collaborative_learning': 'Collaborative Learning Spaces',
      'adaptive_difficulty': 'Adaptive Difficulty System',
      'voice_interaction': 'Voice-Based Interaction',
      'real_time_feedback': 'Real-Time Learning Feedback',
      'learning_analytics': 'Advanced Learning Analytics',
      'social_features': 'Social Learning Features',
      'integration_tools': 'Integration with Other Tools',
    };

    return Column(
      children: features.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${_advancedFeatureInterest[entry.key]!.round()}/10', 
                       style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _advancedFeatureInterest[entry.key]!,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    _advancedFeatureInterest[entry.key] = value;
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContentPreferencesSection() {
    final preferences = {
      'conversation_style': 'Conversational Style',
      'episode_length': 'Episode Length',
      'difficulty_progression': 'Difficulty Progression',
      'topic_variety': 'Topic Variety',
      'interactive_elements': 'Interactive Elements',
    };

    return Column(
      children: preferences.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${_contentPreferences[entry.key]!}/10', 
                       style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Needs work', style: TextStyle(color: Colors.grey)),
                  Text('Perfect', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Slider(
                value: _contentPreferences[entry.key]!.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.orange,
                onChanged: (value) {
                  setState(() {
                    _contentPreferences[entry.key] = value.round();
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefitsSection() {
    final benefitOptions = [
      'Better focus and concentration',
      'Improved knowledge retention',
      'More engaging than traditional methods',
      'Convenient for multitasking',
      'Feels more personal and human',
      'Easier to understand complex topics',
      'Better motivation to continue learning',
      'More flexible learning schedule',
    ];

    return Column(
      children: benefitOptions.map((benefit) {
        final isSelected = _primaryBenefits.contains(benefit);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: Text(benefit),
            value: isSelected,
            activeColor: Colors.orange,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _primaryBenefits.add(benefit);
                } else {
                  _primaryBenefits.remove(benefit);
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

  void _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final researchProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);

      // Capture advanced feature interest
      researchProvider.captureFeatureInterest(
        featureInterest: _advancedFeatureInterest,
        priorityFeatures: _advancedFeatureInterest.entries
            .where((entry) => entry.value >= 8.0)
            .map((entry) => entry.key)
            .toList(),
        triggerContext: 'third_episode',
      );

      // Capture learning effectiveness data and advanced features
      researchProvider.captureProductMarketFit(
        productSatisfaction: _learningEffectiveness.toDouble(),
        howDisappointedIfGone: _engagementLevel.toDouble(),
        primaryBenefits: _primaryBenefits,
        improvementSuggestions: _improvementSuggestions,
        triggerContext: 'third_episode',
      );

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your detailed feedback! 🚀'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting feedback. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
