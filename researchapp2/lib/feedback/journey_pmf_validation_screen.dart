import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/research_metrics_provider.dart';

class JourneyPMFValidationScreen extends StatefulWidget {
  const JourneyPMFValidationScreen({super.key});

  @override
  State<JourneyPMFValidationScreen> createState() => _JourneyPMFValidationScreenState();
}

class _JourneyPMFValidationScreenState extends State<JourneyPMFValidationScreen> {
  double _researchValueScore = 5.0; // Research effectiveness metric
  double _productSatisfaction = 5.0;
  double _recommendationScore = 5.0; // NPS
  List<String> _primaryBenefits = [];
  List<String> _improvementSuggestions = [];
  Map<String, double> _featureImportance = {
    'content_quality': 5.0,
    'learning_effectiveness': 5.0,
    'convenience': 5.0,
    'engagement': 5.0,
    'time_efficiency': 5.0,
  };
  double _willingnessToPayMonthly = 0.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Complete'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.workspace_premium, size: 48, color: Colors.green),
                  SizedBox(height: 12),
                  Text(
                    'Journey Complete! 🎓',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ve completed your first learning journey! Your insights will help shape the future of conversational learning.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Research Validation Assessment
            const Text('📊 Research Validation Assessment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'How valuable do you find this learning approach for educational research?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildDisappointmentSlider(),
            
            const SizedBox(height: 32),
            
            // Overall Satisfaction
            const Text('Overall Learning Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildSatisfactionSlider(),
            
            const SizedBox(height: 32),
            
            // Recommendation Score (NPS)
            const Text('Recommendation Likelihood', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildRecommendationSlider(),
            
            const SizedBox(height: 32),
            
            // Primary Benefits
            const Text('What were the main benefits of this learning journey?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildBenefitsSection(),
            
            const SizedBox(height: 32),
            
            // Feature Importance
            const Text('What aspects were most valuable to you?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildFeatureImportanceSection(),
            
            const SizedBox(height: 32),
            
            // Commercial Validation
            const Text('💰 Commercial Interest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildCommercialSection(),
            
            const SizedBox(height: 32),
            
            // Improvement Suggestions
            const Text('How could we improve your experience?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildImprovementSection(),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
                    : const Text('Complete Assessment →'),
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

  Widget _buildDisappointmentSlider() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Not valuable', style: TextStyle(color: Colors.grey)),
            Text('Very valuable', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: _researchValueScore,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: _researchValueScore >= 7.0 ? Colors.green : Colors.orange,
          onChanged: (value) {
            setState(() {
              _researchValueScore = value;
            });
          },
        ),
        Column(
          children: [
            Text(
              'Score: ${_researchValueScore.round()}/10',
              style: TextStyle(
                color: _researchValueScore >= 7.0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_researchValueScore >= 7.0)
              const Text(
                '✅ High Research Value!',
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSatisfactionSlider() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Poor', style: TextStyle(color: Colors.grey)),
            Text('Excellent', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: _productSatisfaction,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _productSatisfaction = value;
            });
          },
        ),
        Text(
          'Satisfaction: ${_productSatisfaction.round()}/10',
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRecommendationSlider() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Not likely', style: TextStyle(color: Colors.grey)),
            Text('Extremely likely', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: _recommendationScore,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() {
              _recommendationScore = value;
            });
          },
        ),
        Column(
          children: [
            Text(
              'NPS Score: ${_recommendationScore.round()}/10',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
            Text(
              _getNPSCategory(_recommendationScore),
              style: TextStyle(
                color: _getNPSColor(_recommendationScore),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getNPSCategory(double score) {
    if (score >= 9) return 'Promoter 🌟';
    if (score >= 7) return 'Passive 😐';
    return 'Detractor 😞';
  }

  Color _getNPSColor(double score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildBenefitsSection() {
    final benefitOptions = [
      'Learned effectively while multitasking',
      'Better retention than traditional methods',
      'More engaging and enjoyable',
      'Convenient and flexible timing',
      'Felt more personal and human',
      'Complex topics were easier to understand',
      'Increased motivation to continue learning',
      'Improved focus and concentration',
      'Time-efficient learning',
      'Accessible learning format',
    ];

    return Column(
      children: benefitOptions.map((benefit) {
        final isSelected = _primaryBenefits.contains(benefit);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: Text(benefit),
            value: isSelected,
            activeColor: Colors.green,
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

  Widget _buildFeatureImportanceSection() {
    final features = {
      'content_quality': 'Quality of Content',
      'learning_effectiveness': 'Learning Effectiveness',
      'convenience': 'Convenience & Flexibility',
      'engagement': 'Engagement Level',
      'time_efficiency': 'Time Efficiency',
    };

    return Column(
      children: features.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${_featureImportance[entry.key]!.round()}/10', 
                       style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _featureImportance[entry.key]!,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    _featureImportance[entry.key] = value;
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommercialSection() {
    return Column(
      children: [
        const Text('How much would you be willing to pay monthly for this learning experience?'),
        const SizedBox(height: 16),
        Column(
          children: [
            RadioListTile<double>(
              title: const Text('Free only'),
              value: 0.0,
              groupValue: _willingnessToPayMonthly,
              activeColor: Colors.green,
              onChanged: (value) => setState(() => _willingnessToPayMonthly = value!),
            ),
            RadioListTile<double>(
              title: const Text('\$4.99/month'),
              value: 4.99,
              groupValue: _willingnessToPayMonthly,
              activeColor: Colors.green,
              onChanged: (value) => setState(() => _willingnessToPayMonthly = value!),
            ),
            RadioListTile<double>(
              title: const Text('\$9.99/month'),
              value: 9.99,
              groupValue: _willingnessToPayMonthly,
              activeColor: Colors.green,
              onChanged: (value) => setState(() => _willingnessToPayMonthly = value!),
            ),
            RadioListTile<double>(
              title: const Text('\$19.99/month'),
              value: 19.99,
              groupValue: _willingnessToPayMonthly,
              activeColor: Colors.green,
              onChanged: (value) => setState(() => _willingnessToPayMonthly = value!),
            ),
            RadioListTile<double>(
              title: const Text('\$29.99/month or more'),
              value: 29.99,
              groupValue: _willingnessToPayMonthly,
              activeColor: Colors.green,
              onChanged: (value) => setState(() => _willingnessToPayMonthly = value!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImprovementSection() {
    final improvementOptions = [
      'More interactive elements',
      'Better personalization',
      'Shorter episodes',
      'Longer episodes',
      'More topics available',
      'Better progress tracking',
      'Social features',
      'Offline capabilities',
      'Better audio quality',
      'More practice exercises',
    ];

    return Column(
      children: improvementOptions.map((improvement) {
        final isSelected = _improvementSuggestions.contains(improvement);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: Text(improvement),
            value: isSelected,
            activeColor: Colors.green,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _improvementSuggestions.add(improvement);
                } else {
                  _improvementSuggestions.remove(improvement);
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

      // Capture Research Validation data (learning approach effectiveness)
      researchProvider.captureProductMarketFit(
        productSatisfaction: _productSatisfaction,
        howDisappointedIfGone: _researchValueScore,
        primaryBenefits: _primaryBenefits,
        improvementSuggestions: _improvementSuggestions,
        triggerContext: 'journey_completion',
      );

      // Capture commercial validation data
      researchProvider.captureCommercialIntent(
        willingnessToPayMonthly: _willingnessToPayMonthly,
        perceivedValue: _productSatisfaction,
        preferredFeatures: _featureImportance.entries
            .where((entry) => entry.value >= 8.0)
            .map((entry) => entry.key)
            .toList(),
        recommendationScore: _recommendationScore,
        competitiveComparison: {}, // Could be expanded later
      );

      // Mark journey completion feedback shown
      researchProvider.markFirstJourneyCompletionShown();

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _researchValueScore >= 7.0 
                ? 'Excellent! Your input validates this learning approach! 🎓' 
                : 'Thank you for your valuable research contribution! 🙏'
            ),
            backgroundColor: _researchValueScore >= 7.0 ? Colors.green : Colors.blue,
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
