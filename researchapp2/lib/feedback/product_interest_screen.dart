import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import 'final_research_survey_screen.dart';

class ProductInterestScreen extends StatefulWidget {
  const ProductInterestScreen({super.key});

  @override
  State<ProductInterestScreen> createState() => _ProductInterestScreenState();
}

class _ProductInterestScreenState extends State<ProductInterestScreen> {
  int? _usageLikelihood;
  int? _recommendationLikelihood;
  int? _acceptablePrice;
  int? _customPrice;
  List<String> _interestedFeatures = [];
  int? _enterpriseInterest;
  String _enterpriseUseCase = '';
  int? _enterprisePricing;
  String _userRole = ''; // Will be populated from user onboarding data

  bool _isComplete() {
    return _usageLikelihood != null && _recommendationLikelihood != null && (_acceptablePrice != null || _customPrice != null);
  }

  final List<Map<String, dynamic>> _pricePoints = [
    {'value': 1, 'amount': '199', 'description': 'Basic access'},
    {'value': 2, 'amount': '499', 'description': 'Good value for regular use'},
    {'value': 3, 'amount': '999', 'description': 'Premium features included'},
    {'value': 4, 'amount': '1999', 'description': 'Professional/power user'},
    {'value': 5, 'amount': '2999+', 'description': 'Premium enterprise features'},
    {'value': 0, 'amount': '0', 'description': 'I would only use it if free'},
  ];

  final List<Map<String, String>> _potentialFeatures = [
    {'id': 'offline', 'title': 'Offline listening', 'description': 'Download episodes for offline use'},
    {'id': 'personalization', 'title': 'Personalized journeys', 'description': 'AI recommends content for you'},
    {'id': 'certificates', 'title': 'Completion certificates', 'description': 'Earn certificates for completed journeys'},
    {'id': 'community', 'title': 'Community features', 'description': 'Discuss and learn with others'},
    {'id': 'ai_buddy', 'title': 'AI Study Buddy', 'description': 'Conversational AI assistant for learning'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interest in Wisme')),
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
                        Text('Future Product Interest', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text('Based on your research experience, tell us about your interest in the full Wisme app', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💰 Pricing & Value Assessment', style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                        const SizedBox(height: 16),
                        Text('If Wisme offered the conversational learning experience you just tried, what would you consider a fair monthly price?'),
                        const SizedBox(height: 16),
                        ...List.generate(_pricePoints.length, (index) {
                          final price = _pricePoints[index];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.0, end: _acceptablePrice == price['value'] ? 1.1 : 1.0),
                            duration: const Duration(milliseconds: 150),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: RadioListTile<int>(
                                  value: price['value'],
                                  groupValue: _acceptablePrice,
                                  onChanged: (value) => setState(() => _acceptablePrice = value),
                                  title: Text('₹${price['amount']} per month'),
                                  subtitle: Text(price['description']),
                                ),
                              );
                            },
                          );
                        }),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Or suggest your own price (₹ per month)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => _customPrice = int.tryParse(value)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildFeatureInterestSection(),
                const SizedBox(height: 32),
                _buildEnterpriseInterestSection(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isComplete() ? _submitInterestSurvey : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                  child: const Text('Submit Interest Survey', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: "product_interest_fab",
              onPressed: () {
                // Navigate to final survey
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinalResearchSurveyScreen()),
                );
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.star, color: Colors.white),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInterestQuestion(String question, int? selectedValue, ValueChanged<int?> onChanged) {
    final options = [
      'Extremely likely',
      'Very likely',
      'Somewhat likely',
      'Not very likely',
      'Not at all likely',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        ...List.generate(options.length, (i) => RadioListTile<int>(
          value: i + 1,
          groupValue: selectedValue,
          onChanged: onChanged,
          title: Text(options[i]),
        )),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFeatureInterestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Feature Interest', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Which additional features would make Wisme more valuable to you?'),
            const SizedBox(height: 16),
            ..._potentialFeatures.map((feature) => CheckboxListTile(
              value: _interestedFeatures.contains(feature['id']),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _interestedFeatures.add(feature['id']!);
                  } else {
                    _interestedFeatures.remove(feature['id']!);
                  }
                });
              },
              title: Text(feature['title']!),
              subtitle: Text(feature['description']!),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterpriseInterestSection() {
    if (_userRole != 'professional' && _userRole != 'entrepreneur') return const SizedBox.shrink();
    return Card(
      color: AppColors.primaryBlue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏢 Enterprise/Team Interest', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            _buildProductInterestQuestion('Would your organization be interested in Wisme for team learning?', _enterpriseInterest, (val) => setState(() => _enterpriseInterest = val)),
            if (_enterpriseInterest != null && _enterpriseInterest! >= 3) ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'What would your organization want to use Wisme for?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => setState(() => _enterpriseUseCase = value),
              ),
              const SizedBox(height: 16),
              _buildProductInterestQuestion('What would be an acceptable annual price for your organization (per user)?', _enterprisePricing, (val) => setState(() => _enterprisePricing = val)),
            ],
          ],
        ),
      ),
    );
  }

  void _submitInterestSurvey() async {
    try {
      final researchProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      // Save all the collected data to Firebase
      researchProvider.captureFeatureInterest(
        featureInterest: {
          'usage_likelihood': (_usageLikelihood ?? 0).toDouble(),
          'recommendation_likelihood': (_recommendationLikelihood ?? 0).toDouble(),
          'acceptable_price': (_acceptablePrice ?? 0).toDouble(),
          'enterprise_interest': (_enterpriseInterest ?? 0).toDouble(),
        },
        priorityFeatures: _interestedFeatures,
        triggerContext: 'product_interest_survey',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interest survey submitted successfully! Thank you.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
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
} 