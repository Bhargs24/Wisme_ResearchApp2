import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import 'package:provider/provider.dart';

class ModernJourneyComparisonScreen extends StatefulWidget {
  const ModernJourneyComparisonScreen({super.key});

  @override
  State<ModernJourneyComparisonScreen> createState() => _ModernJourneyComparisonScreenState();
}

class _ModernJourneyComparisonScreenState extends State<ModernJourneyComparisonScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int? _effectivenessComparison;
  int? _engagementComparison;
  int? _futurePreference;
  String _comparisonFeedback = '';
  
  final Map<String, double> _conversationalRatings = {};
  final Map<String, double> _traditionalRatings = {};
  
  final List<String> _comparisonAttributes = [
    'Easy to follow',
    'Helped me understand concepts',
    'Kept my attention',
    'Made learning enjoyable',
    'Helped me remember information',
    'Felt personalized to me',
    'Made complex topics simple',
    'Motivated me to continue learning',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeRatings();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
  }

  void _initializeRatings() {
    for (String attribute in _comparisonAttributes) {
      _conversationalRatings[attribute] = 5.0;
      _traditionalRatings[attribute] = 5.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submitComparison() async {
    if (_effectivenessComparison == null || _engagementComparison == null || _futurePreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all comparison questions')),
      );
      return;
    }

    try {
      final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      // Submit through research metrics provider for proper data collection
      research.captureFeatureInterest(
        featureInterest: {
          'effectiveness_comparison': (_effectivenessComparison ?? 0).toDouble(),
          'engagement_comparison': (_engagementComparison ?? 0).toDouble(),
          'future_preference': (_futurePreference ?? 0).toDouble(),
          ..._conversationalRatings,
          ..._traditionalRatings,
        },
        priorityFeatures: ['modern_journey_comparison'],
        triggerContext: 'modern_journey_comparison_screen',
      );

      // Show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Comparison submitted! Thank you for your insights 🚀'),
          backgroundColor: AppColors.accentGreen,
        ),
      );

      Navigator.pushReplacementNamed(context, '/product_interest');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting comparison: $e'),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildComparisonQuestions(),
                    const SizedBox(height: 32),
                    _buildAttributeComparison(),
                    const SizedBox(height: 32),
                    _buildOpenFeedback(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Compare Learning Methods',
          style: AppTextStyles.heading2.copyWith(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBlue.withOpacity(0.3),
                AppColors.backgroundDark,
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundCard.withOpacity(0.8),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.accentGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Method Comparison',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'Help us understand which approach works better',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your comparison helps validate our learning method effectiveness for research publication',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentGreen,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Comparison',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        
        _buildComparisonQuestion(
          'Which learning method felt more effective overall?',
          [
            'Conversational method was much better',
            'Conversational method was slightly better',
            'Both methods were equally effective',
            'Traditional method was slightly better',
            'Traditional method was much better',
          ],
          _effectivenessComparison,
          (value) => setState(() => _effectivenessComparison = value),
        ),
        
        const SizedBox(height: 24),
        
        _buildComparisonQuestion(
          'Which method kept you more engaged?',
          [
            'Conversational was much more engaging',
            'Conversational was slightly more engaging',
            'Both were equally engaging',
            'Traditional was slightly more engaging',
            'Traditional was much more engaging',
          ],
          _engagementComparison,
          (value) => setState(() => _engagementComparison = value),
        ),
        
        const SizedBox(height: 24),
        
        _buildComparisonQuestion(
          'Which method would you choose for future learning?',
          [
            'Definitely the conversational method',
            'Probably the conversational method',
            'I\'m not sure / No preference',
            'Probably the traditional method',
            'Definitely the traditional method',
          ],
          _futurePreference,
          (value) => setState(() => _futurePreference = value),
        ),
      ],
    );
  }

  Widget _buildComparisonQuestion(
    String question,
    List<String> options,
    int? selectedValue,
    ValueChanged<int?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<int>(
                value: index + 1,
                groupValue: selectedValue,
                onChanged: onChanged,
                title: Text(
                  option,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                  ),
                ),
                activeColor: AppColors.accentGreen,
                dense: true,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAttributeComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Attribute Comparison',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rate each method on specific aspects (1 = Poor, 10 = Excellent)',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 20),
        
        ..._comparisonAttributes.map((attribute) {
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attribute,
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Conversational Method Rating
                _buildMethodRating(
                  'Conversational Method',
                  AppColors.primaryBlue,
                  _conversationalRatings[attribute] ?? 5.0,
                  (value) => setState(() => _conversationalRatings[attribute] = value),
                ),
                
                const SizedBox(height: 16),
                
                // Traditional Method Rating
                _buildMethodRating(
                  'Traditional Method',
                  Colors.grey,
                  _traditionalRatings[attribute] ?? 5.0,
                  (value) => setState(() => _traditionalRatings[attribute] = value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMethodRating(String methodName, Color color, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              methodName,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value.toInt().toString(),
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withOpacity(0.3),
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenFeedback() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Feedback',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What made one method better than the other? Any specific moments that stood out?',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            maxLines: 4,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: AppTextStyles.caption.copyWith(color: Colors.white38),
              filled: true,
              fillColor: AppColors.backgroundDark.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accentGreen),
              ),
            ),
            onChanged: (value) => _comparisonFeedback = value,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitComparison,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentGreen],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send, size: 18),
                const SizedBox(width: 12),
                Text(
                  'Submit Comparison',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
