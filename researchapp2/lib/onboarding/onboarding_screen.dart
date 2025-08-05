import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  final TextEditingController _customOccupationController = TextEditingController();
  int _currentPage = 0;
  
  // Research data collection (Strategic: Non-boring demographic collection)
  int _age = 25;
  String _education = '';
  String _occupation = '';
  String _customOccupation = ''; // For custom profession input
  List<String> _learningGoals = [];
  Map<String, int> _subjectFamiliarity = {}; // Will be initialized with defaults

  final List<String> _educationOptions = [
    'High School',
    'Undergraduate',
    'Graduate/Masters',
    'PhD/Research',
  ];

  final List<String> _occupationOptions = [
    'Student',
    'Software Engineer',
    'Product Manager',
    'Entrepreneur',
    'Consultant',
    'Other',
  ];

  final List<String> _goalOptions = [
    'Career advancement',
    'Interview preparation',
    'Personal knowledge',
    'Academic requirements',
    'Skill development',
    'Entrepreneurial growth',
  ];

  final Map<String, String> _subjects = {
    'data_structures_algorithms': 'Data Structures & Algorithms',
    'psychology': 'Psychology & Human Behavior',
    'science_mysteries': 'Science Mysteries & Discoveries',
    'personal_finance': 'Personal Finance',
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    
    // Initialize subject familiarity with default values of 5 (moderate)
    _subjectFamiliarity = {
      for (String subjectId in _subjects.keys) subjectId: 5
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _customOccupationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    // Strategic Research Data Collection
    final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
    final finalOccupation = _occupation == 'Other' && _customOccupation.isNotEmpty 
        ? _customOccupation 
        : _occupation;
        
    // Capture comprehensive user profile
    research.captureUserDemographics(
      age: _age,
      education: _education,
      occupation: finalOccupation,
      learningGoals: _learningGoals,
      subjectFamiliarity: _subjectFamiliarity,
    );
    
    // Continue to learning style assessment (EXISTING FLOW!)
    Navigator.pushReplacementNamed(
      context,
      '/learning_style',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildAgePage(),
                  _buildEducationPage(),
                  _buildOccupationPage(),
                  _buildGoalsPage(),
                  _buildSubjectFamiliarityPage(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Let\'s personalize your experience',
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us understand learning preferences better',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentPage 
                    ? AppColors.primaryBlue 
                    : AppColors.primaryBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAgePage() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(
                    Icons.cake,
                    size: 80,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'What\'s your age?',
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$_age',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 48,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: AppColors.primaryBlue.withOpacity(0.2),
                      thumbColor: AppColors.primaryBlue,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: _age.toDouble(),
                      min: 13,
                      max: 65,
                      divisions: 52,
                      onChanged: (value) {
                        setState(() => _age = value.round());
                      },
                    ),
                  ),
                  Text(
                    'Age range: 13-65',
                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEducationPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Add some top padding
            Icon(
              Icons.school,
              size: 80,
              color: AppColors.primaryBlue,
            ),
          const SizedBox(height: 40),
          Text(
            'What\'s your education background?',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...List.generate(_educationOptions.length, (index) {
            final option = _educationOptions[index];
            final isSelected = _education == option;
            
            return GestureDetector(
              onTap: () {
                setState(() => _education = option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primaryBlue.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primaryBlue 
                        : AppColors.primaryBlue.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      option,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
      ),
    );
  }

  Widget _buildOccupationPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Add some top padding
            Icon(
              Icons.work,
              size: 80,
              color: AppColors.primaryBlue,
            ),
          const SizedBox(height: 40),
          Text(
            'What describes your current role?',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 240, // Fixed height instead of Expanded
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _occupationOptions.length,
              itemBuilder: (context, index) {
                final option = _occupationOptions[index];
                final isSelected = _occupation == option;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _occupation = option;
                      if (option != 'Other') {
                        _customOccupation = '';
                        _customOccupationController.clear();
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? AppColors.primaryBlue.withOpacity(0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primaryBlue 
                            : AppColors.primaryBlue.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Custom occupation input when "Other" is selected
          if (_occupation == 'Other') ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                controller: _customOccupationController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _customOccupation = value.trim());
                },
                decoration: InputDecoration(
                  labelText: 'Please specify your profession',
                  labelStyle: TextStyle(color: Colors.white70),
                  hintText: 'e.g. Graphic Designer, Teacher, etc.',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.backgroundCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 20), // Add some bottom padding
        ],
      ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Add some top padding
            Icon(
              Icons.flag,
              size: 80,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 40),
            Text(
              'Why do you want to learn?',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select all that apply',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ...List.generate(_goalOptions.length, (index) {
              final goal = _goalOptions[index];
              final isSelected = _learningGoals.contains(goal);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _learningGoals.remove(goal);
                    } else {
                      _learningGoals.add(goal);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryBlue.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primaryBlue 
                          : AppColors.primaryBlue.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          goal,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 40), // Extra bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectFamiliarityPage() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.psychology,
              size: 80,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 40),
            Text(
              'How familiar are you with these topics?',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rate from 1 (beginner) to 10 (expert). Default is 5 (moderate knowledge).',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 40),
          ..._subjects.entries.map((entry) {
            final subjectId = entry.key;
            final subjectName = entry.value;
            final currentValue = _subjectFamiliarity[subjectId]!; // Now guaranteed to exist
            
            return Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subjectName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          border: Border.all(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$currentValue',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: AppColors.primaryBlue.withOpacity(0.2),
                      thumbColor: AppColors.primaryBlue,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: currentValue.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          _subjectFamiliarity[subjectId] = value.round();
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 40), // Extra bottom padding
        ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentPage < 4 ? 'Continue' : 'Start Learning',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: return true; // Age is always set
      case 1: return _education.isNotEmpty;
      case 2: 
        if (_occupation.isEmpty) return false;
        if (_occupation == 'Other') return _customOccupation.isNotEmpty;
        return true;
      case 3: return _learningGoals.isNotEmpty;
      case 4: return _subjectFamiliarity.length == _subjects.length;
      default: return false;
    }
  }
}
