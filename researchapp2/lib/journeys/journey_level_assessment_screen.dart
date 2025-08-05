import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/journey_models.dart';
import 'episode_length_preference_screen.dart';

class JourneyLevelAssessmentScreen extends StatefulWidget {
  final Journey journey;
  
  const JourneyLevelAssessmentScreen({
    super.key,
    required this.journey,
  });

  @override
  State<JourneyLevelAssessmentScreen> createState() => _JourneyLevelAssessmentScreenState();
}

class _JourneyLevelAssessmentScreenState extends State<JourneyLevelAssessmentScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _selectedLevel;
  
  final List<Map<String, dynamic>> _levelOptions = [
    {
      'id': 'beginner',
      'title': 'New to this',
      'description': 'I\'m just starting to learn about this topic',
      'icon': Icons.auto_awesome,
      'color': Colors.green,
    },
    {
      'id': 'some_knowledge',
      'title': 'I know a bit',
      'description': 'I have some basic understanding but want to learn more',
      'icon': Icons.trending_up,
      'color': Colors.orange,
    },
    {
      'id': 'experienced',
      'title': 'I\'m experienced',
      'description': 'I know this well but want to fill in gaps or refresh',
      'icon': Icons.star,
      'color': Colors.blue,
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

  void _onLevelSelected(String level) {
    setState(() {
      _selectedLevel = level;
    });
  }

  void _continueToNextStep() {
    if (_selectedLevel == null) return;
    
    // Navigate to episode length preference
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodeLengthPreferenceScreen(
          journey: widget.journey,
          selectedLevel: _selectedLevel!,
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
                // Back button
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
                            color: Colors.white30,
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
                            'Personalizing your experience',
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
                  'What\'s your level in',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                Text(
                  widget.journey.title.toLowerCase(),
                  style: AppTextStyles.heading1.copyWith(
                    color: journeyColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '?',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'This helps us match the right learning approach for you.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Level options
                Expanded(
                  child: ListView.builder(
                    itemCount: _levelOptions.length,
                    itemBuilder: (context, index) {
                      final option = _levelOptions[index];
                      final isSelected = _selectedLevel == option['id'];
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _onLevelSelected(option['id']),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? journeyColor.withOpacity(0.15)
                                  : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? journeyColor.withOpacity(0.6)
                                    : Colors.white.withOpacity(0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? journeyColor.withOpacity(0.2)
                                        : (option['color'] as Color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    option['icon'] as IconData,
                                    color: isSelected 
                                        ? journeyColor
                                        : option['color'] as Color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['title'],
                                        style: AppTextStyles.heading2.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option['description'],
                                        style: AppTextStyles.caption.copyWith(
                                          color: Colors.white70,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.check_circle,
                                    color: journeyColor,
                                    size: 24,
                                  ),
                                ],
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
                    onPressed: _selectedLevel != null ? _continueToNextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: journeyColor,
                      disabledBackgroundColor: Colors.white24,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
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
