import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/journey_models.dart';
import 'personalization_loading_screen.dart';

class EpisodeLengthPreferenceScreen extends StatefulWidget {
  final Journey journey;
  final String selectedLevel;
  
  const EpisodeLengthPreferenceScreen({
    super.key,
    required this.journey,
    required this.selectedLevel,
  });

  @override
  State<EpisodeLengthPreferenceScreen> createState() => _EpisodeLengthPreferenceScreenState();
}

class _EpisodeLengthPreferenceScreenState extends State<EpisodeLengthPreferenceScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _selectedLength;
  
  final List<Map<String, dynamic>> _lengthOptions = [
    {
      'id': '5_minutes',
      'title': '5 minutes',
      'description': 'Quick, focused sessions that fit into busy schedules',
      'icon': Icons.flash_on,
      'color': Colors.green,
      'duration': '5 min',
      'benefit': 'Perfect for commutes',
    },
    {
      'id': '7_minutes',
      'title': '7 minutes',
      'description': 'More comprehensive coverage with deeper explanations',
      'icon': Icons.hourglass_bottom,
      'color': Colors.blue,
      'duration': '7 min',
      'benefit': 'Ideal for focus time',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onLengthSelected(String length) {
    setState(() {
      _selectedLength = length;
    });
  }

  void _continueToLoadingScreen() {
    if (_selectedLength == null) return;
    
    // Navigate to personalization loading screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalizationLoadingScreen(
          journey: widget.journey,
          selectedLevel: widget.selectedLevel,
          selectedLength: _selectedLength!,
        ),
      ),
    );
  }

  Color _getJourneyColor() {
    return Color(int.parse(widget.journey.colorHex.replaceFirst('#', '0xFF')));
  }

  IconData _getJourneyIcon() {
    switch (widget.journey.iconName) {
      case 'code': return Icons.code;              // Computer Science
      case 'psychology': return Icons.psychology;  // Psychology  
      case 'science': return Icons.science;        // Science
      case 'money': return Icons.attach_money;     // Life Skills (Personal Finance)
      default: return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final journeyColor = _getJourneyColor();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and progress
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        decoration: BoxDecoration(
                          color: AppColors.hoverLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    // Progress indicator
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: journeyColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: journeyColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Journey context
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: journeyColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getJourneyIcon(),
                        color: journeyColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.journey.title,
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Almost ready to start learning',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Main question
                Text(
                  'What episode length',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'do you prefer?',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Choose what fits your schedule best. You can always change this later.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Length options
                Expanded(
                  child: ListView.builder(
                    itemCount: _lengthOptions.length,
                    itemBuilder: (context, index) {
                      final option = _lengthOptions[index];
                      final isSelected = _selectedLength == option['id'];
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () => _onLengthSelected(option['id']),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? journeyColor.withOpacity(0.15)
                                  : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected 
                                    ? journeyColor.withOpacity(0.6)
                                    : Colors.white.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? journeyColor.withOpacity(0.2)
                                            : (option['color'] as Color).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        option['icon'] as IconData,
                                        color: isSelected 
                                            ? journeyColor
                                            : option['color'] as Color,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                option['title'],
                                                style: AppTextStyles.heading1.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (isSelected) ...[
                                                Icon(
                                                  Icons.check_circle,
                                                  color: journeyColor,
                                                  size: 28,
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (option['color'] as Color).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              option['benefit'],
                                              style: AppTextStyles.caption.copyWith(
                                                color: option['color'] as Color,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  option['description'],
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white70,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLength != null ? _continueToLoadingScreen : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: journeyColor,
                      disabledBackgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Generate My Episodes',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
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
