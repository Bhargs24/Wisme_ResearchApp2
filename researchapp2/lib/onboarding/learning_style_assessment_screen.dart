import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LearningStyleAssessmentScreen extends StatefulWidget {
  const LearningStyleAssessmentScreen({super.key});

  @override
  State<LearningStyleAssessmentScreen> createState() => _LearningStyleAssessmentScreenState();
}

class _LearningStyleAssessmentScreenState extends State<LearningStyleAssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;
  
  // Learning style preferences
  String _preferredPace = '';
  String _learningMethod = '';
  String _contentDepth = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Style Assessment'),
        leading: _currentPage > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _previousPage,
            )
          : null,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildPacePreferencePage(),
          _buildMethodPreferencePage(),
          _buildDepthPreferencePage(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _canProceed() ? _nextPage : null,
              child: Text(_currentPage == _totalPages - 1 ? 'Complete' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: return _preferredPace.isNotEmpty;
      case 1: return _learningMethod.isNotEmpty;
      case 2: return _contentDepth.isNotEmpty;
      default: return false;
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeAssessment();
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

  void _completeAssessment() {
    // Save learning style preferences and navigate to next screen
    Navigator.pushReplacementNamed(context, '/journey_orientation');
  }

  Widget _buildPacePreferencePage() {
    final options = [
      {'value': 'quick', 'title': 'Quick Overview', 'description': 'Fast-paced, key concepts only'},
      {'value': 'moderate', 'title': 'Balanced Pace', 'description': 'Good mix of theory and examples'},
      {'value': 'detailed', 'title': 'Detailed Exploration', 'description': 'In-depth coverage with examples'},
    ];

    return _buildOptionPage(
      title: 'What\'s your preferred learning pace?',
      options: options,
      selectedValue: _preferredPace,
      onChanged: (value) => setState(() => _preferredPace = value),
    );
  }

  Widget _buildMethodPreferencePage() {
    final options = [
      {'value': 'visual', 'title': 'Visual Learning', 'description': 'Diagrams, charts, and visual aids'},
      {'value': 'auditory', 'title': 'Auditory Learning', 'description': 'Listening and verbal explanations'},
      {'value': 'interactive', 'title': 'Interactive Learning', 'description': 'Hands-on practice and exercises'},
    ];

    return _buildOptionPage(
      title: 'How do you learn best?',
      options: options,
      selectedValue: _learningMethod,
      onChanged: (value) => setState(() => _learningMethod = value),
    );
  }

  Widget _buildDepthPreferencePage() {
    final options = [
      {'value': 'conceptual', 'title': 'Conceptual Understanding', 'description': 'Focus on big picture and concepts'},
      {'value': 'practical', 'title': 'Practical Application', 'description': 'Focus on real-world usage'},
      {'value': 'theoretical', 'title': 'Theoretical Depth', 'description': 'Deep dive into underlying theory'},
    ];

    return _buildOptionPage(
      title: 'What content depth do you prefer?',
      options: options,
      selectedValue: _contentDepth,
      onChanged: (value) => setState(() => _contentDepth = value),
    );
  }

  Widget _buildOptionPage({
    required String title,
    required List<Map<String, String>> options,
    required String selectedValue,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            title,
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: options.map((option) {
                final isSelected = selectedValue == option['value'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: OutlinedButton(
                    onPressed: () => onChanged(option['value']!),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : null,
                      foregroundColor: isSelected ? AppColors.primaryBlue : Colors.white,
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.3),
                      ),
                      minimumSize: const Size(double.infinity, 80),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['title']!,
                            style: AppTextStyles.heading2.copyWith(
                              color: isSelected ? AppColors.primaryBlue : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['description']!,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.8) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
