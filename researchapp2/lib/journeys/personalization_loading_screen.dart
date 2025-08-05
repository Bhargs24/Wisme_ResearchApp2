import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/journey_models.dart';
import 'journey_episodes_overview_screen.dart';

class PersonalizationLoadingScreen extends StatefulWidget {
  final Journey journey;
  final String selectedLevel;
  final String selectedLength;
  
  const PersonalizationLoadingScreen({
    super.key,
    required this.journey,
    required this.selectedLevel,
    required this.selectedLength,
  });

  @override
  State<PersonalizationLoadingScreen> createState() => _PersonalizationLoadingScreenState();
}

class _PersonalizationLoadingScreenState extends State<PersonalizationLoadingScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  int _currentStepIndex = 0;
  
  final List<Map<String, dynamic>> _loadingSteps = [
    {
      'title': 'Analyzing your preferences...',
      'subtitle': 'Understanding your learning level and time preferences',
      'icon': Icons.psychology,
      'duration': 1500,
    },
    {
      'title': 'Generating your episodes...',
      'subtitle': 'Creating personalized content just for you',
      'icon': Icons.auto_awesome,
      'duration': 2000,
    },
    {
      'title': 'Waking up the speakers...',
      'subtitle': 'Preparing the perfect audio experience',
      'icon': Icons.volume_up,
      'duration': 1000,
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4500), // Total loading time
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut)
    );
    
    _startLoadingSequence();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startLoadingSequence() async {
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _progressController.forward();
    
    // Simulate loading steps
    for (int i = 0; i < _loadingSteps.length; i++) {
      setState(() {
        _currentStepIndex = i;
      });
      
      await Future.delayed(Duration(milliseconds: _loadingSteps[i]['duration']));
    }
    
    // Navigate to audio player after loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JourneyEpisodesOverviewScreen(
            journey: widget.journey,
            selectedLevel: widget.selectedLevel,
            selectedLength: widget.selectedLength,
          ),
        ),
      );
    }
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

  String _getLevelDisplayText() {
    switch (widget.selectedLevel) {
      case 'beginner': return 'New to this';
      case 'some_knowledge': return 'Some knowledge';
      case 'experienced': return 'Experienced';
      default: return 'Learning level';
    }
  }

  String _getLengthDisplayText() {
    switch (widget.selectedLength) {
      case '5_minutes': return '5-minute episodes';
      case '7_minutes': return '7-minute episodes';
      default: return 'Episode length';
    }
  }

  @override
  Widget build(BuildContext context) {
    final journeyColor = _getJourneyColor();
    final currentStep = _loadingSteps[_currentStepIndex];
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Progress indicator at top
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
                        color: journeyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Journey preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: journeyColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
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
                                  'Personalized for you',
                                  style: AppTextStyles.caption.copyWith(
                                    color: journeyColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Personalization summary
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLevelDisplayText(),
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getLengthDisplayText(),
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Loading animation and text
                Column(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: journeyColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentStep['icon'] as IconData,
                          color: journeyColor,
                          size: 40,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      currentStep['title'],
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      currentStep['subtitle'],
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Progress bar
                    Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: journeyColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
