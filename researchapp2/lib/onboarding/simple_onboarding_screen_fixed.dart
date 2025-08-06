import 'package:flutter/material.dart';
import '../core/research_metrics_provider.dart';
import 'package:provider/provider.dart';

class SimpleOnboardingScreen extends StatefulWidget {
  const SimpleOnboardingScreen({super.key});

  @override
  State<SimpleOnboardingScreen> createState() => _SimpleOnboardingScreenState();
}

class _SimpleOnboardingScreenState extends State<SimpleOnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _customOccupationController = TextEditingController();
  
  int _currentPage = 0;
  
  // Simplified demographic data
  String? _education;
  String? _occupation;
  String _customOccupation = '';
  String _ageRange = '';
  List<String> _learningGoals = [];
  
  // Predefined options
  final List<String> _educationOptions = [
    'High School',
    'Some College', 
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD or Higher',
    'Other'
  ];
  
  final List<String> _occupationOptions = [
    'Student',
    'Software Engineer/Developer',
    'Data Scientist/Analyst', 
    'Product Manager',
    'Designer',
    'Teacher/Educator',
    'Research Scientist',
    'Business Analyst',
    'Consultant',
    'Other'
  ];
  
  final List<String> _ageRanges = [
    '18-24', '25-34', '35-44', '45-54', '55-64', '65+'
  ];
  
  final List<String> _goalOptions = [
    'Learn new skills',
    'Advance my career',
    'Understand complex topics better',
    'Improve problem-solving abilities',
    'Explore new subjects',
    'Academic/Research purposes',
    'Personal interest and growth',
    'Professional development'
  ];

  void _nextPage() {
    if (_currentPage < 3) {
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
    // Save all collected data
    final researchMetrics = Provider.of<ResearchMetricsProvider>(context, listen: false);
    
    // Store user name
    researchMetrics.storeUserName(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );
    
    // Convert age range to approximate age number for the API
    int approximateAge = 25; // default
    switch (_ageRange) {
      case '18-24': approximateAge = 21; break;
      case '25-34': approximateAge = 29; break;
      case '35-44': approximateAge = 39; break;
      case '45-54': approximateAge = 49; break;
      case '55-64': approximateAge = 59; break;
      case '65+': approximateAge = 70; break;
    }
    
    // Store demographic data
    researchMetrics.captureUserDemographics(
      age: approximateAge,
      education: _education ?? 'Not specified',
      occupation: _occupation == 'Other' ? _customOccupation : _occupation ?? 'Not specified',
      learningGoals: _learningGoals,
    );
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding_complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentPage + 1} of 4'),
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
          _buildNamePage(),
          _buildAgePage(),
          _buildBackgroundPage(),
          _buildGoalsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Progress indicator
            Expanded(
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            // Next button
            ElevatedButton(
              onPressed: _canProceed() ? _nextPage : null,
              child: Text(_currentPage == 3 ? 'Complete' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty;
      case 1:
        return _ageRange.isNotEmpty;
      case 2:
        return _education != null && _occupation != null && 
               (_occupation != 'Other' || _customOccupation.isNotEmpty);
      case 3:
        return _learningGoals.isNotEmpty;
      default:
        return false;
    }
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Hi! What should we call you?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _firstNameController,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Last Name', 
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'What\'s your age range?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ...(_ageRanges.map((range) => 
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _ageRange = range),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _ageRange == range ? Colors.blue.withOpacity(0.1) : null,
                    foregroundColor: _ageRange == range ? Colors.blue : Colors.white,
                    side: BorderSide(
                      color: _ageRange == range ? Colors.blue : Colors.grey.withOpacity(0.3),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(range),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Tell us about your background',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Education
            const Text(
              'Education Level',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...(_educationOptions.map((option) =>
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _education = option),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _education == option ? Colors.blue.withOpacity(0.1) : null,
                    foregroundColor: _education == option ? Colors.blue : Colors.white,
                    side: BorderSide(
                      color: _education == option ? Colors.blue : Colors.grey.withOpacity(0.3),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(option),
                ),
              ),
            )),
            
            const SizedBox(height: 32),
            
            // Occupation
            const Text(
              'Current Role',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...(_occupationOptions.map((option) => 
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => setState(() => _occupation = option),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _occupation == option ? Colors.blue.withOpacity(0.1) : null,
                    foregroundColor: _occupation == option ? Colors.blue : Colors.white,
                    side: BorderSide(
                      color: _occupation == option ? Colors.blue : Colors.grey.withOpacity(0.3),
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(option),
                ),
              ),
            )),
            
            // Custom occupation field
            if (_occupation == 'Other') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customOccupationController,
                onChanged: (value) => setState(() => _customOccupation = value),
                decoration: const InputDecoration(
                  hintText: 'Please specify your role',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'What are your learning goals?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select all that apply',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ...(_goalOptions.map((goal) =>
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      if (_learningGoals.contains(goal)) {
                        _learningGoals.remove(goal);
                      } else {
                        _learningGoals.add(goal);
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _learningGoals.contains(goal) ? Colors.blue.withOpacity(0.1) : null, 
                    foregroundColor: _learningGoals.contains(goal) ? Colors.blue : Colors.white,
                    side: BorderSide(
                      color: _learningGoals.contains(goal) ? Colors.blue : Colors.grey.withOpacity(0.3),  
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _learningGoals.contains(goal) 
                          ? Icons.check_box 
                          : Icons.check_box_outline_blank,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(goal)),
                    ],
                  ),
                ),
              ),
            )),
            
            if (_learningGoals.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected goals:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _learningGoals.join(', '),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
