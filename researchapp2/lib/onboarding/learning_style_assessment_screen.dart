import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LearningStyleAssessmentScreen extends StatefulWidget {
  const LearningStyleAssessmentScreen({super.key});

  @override
  State<LearningStyleAssessmentScreen> createState() => _LearningStyleAssessmentScreenState();
}

class _LearningStyleAssessmentScreenState extends State<LearningStyleAssessmentScreen> {
  final Map<String, int> _currentLearningMethods = {
    'Reading articles/books': 3, // Start with default middle values instead of 0
    'Watching video tutorials': 3,
    'Taking online courses': 3,
    'Hands-on practice': 3,
    'Group discussions': 3,
    'AI-powered learning buddy': 3,
  };
  int _contentPreference = 3;
  String? _sessionDuration;
  List<String> _learningChallenges = [];

  bool _isAssessmentComplete() {
    // Now that we start with valid defaults, we only need to check required selections
    return _sessionDuration != null && _learningChallenges.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Learning Style')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Understanding Your Learning Preferences', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text('Help us understand how you currently learn best', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            // Current learning methods
            Semantics(
              label: 'How do you typically learn new topics?',
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How do you typically learn new topics?', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Rate each method from 1 (never use) to 5 (use frequently). Default is 3 (moderate use).',
                         style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._currentLearningMethods.keys.map((method) => Semantics(
              label: 'Rate $method from 1 to 5',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(method)),
                      Text('${_currentLearningMethods[method]}', 
                           style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('1', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Expanded(
                        child: Slider(
                          value: _currentLearningMethods[method]!.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _currentLearningMethods[method]!.toString(),
                          onChanged: (val) {
                            setState(() {
                              _currentLearningMethods[method] = val.toInt();
                            });
                          },
                        ),
                      ),
                      Text('5', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )),
            const SizedBox(height: 24),
            // Content preference
            Align(
              alignment: Alignment.centerLeft,
              child: Text('How do you prefer to consume learning content?', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _contentPreference.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: ['Text Heavy', '', 'Balanced', '', 'Audio Heavy'][_contentPreference - 1],
              onChanged: (val) => setState(() => _contentPreference = val.toInt()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Text Heavy'),
                Text('Balanced'),
                Text('Audio Heavy'),
              ],
            ),
            const SizedBox(height: 24),
            // Session duration
            Align(
              alignment: Alignment.centerLeft,
              child: Text('What\'s your typical learning session duration?', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                {'label': '5-10 minutes', 'value': '5-10'},
                {'label': '15-30 minutes', 'value': '15-30'},
                {'label': '45-60 minutes', 'value': '45-60'},
                {'label': '60+ minutes', 'value': '60+'},
              ].map((option) => ChoiceChip(
                label: Text(option['label']!),
                selected: _sessionDuration == option['value'],
                onSelected: (_) => setState(() => _sessionDuration = option['value']),
              )).toList(),
            ),
            const SizedBox(height: 24),
            // Learning challenges
            Align(
              alignment: Alignment.centerLeft,
              child: Text('What are your biggest challenges with learning? (Select all that apply)', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'Hard to stay focused/engaged',
                'Information overload',
                'Boring delivery methods',
                'Hard to retain information',
                'No personalization',
                'Need shorter sessions',
                'Lack of interactive elements',
                'No progress tracking',
              ].map((challenge) => FilterChip(
                label: Text(challenge),
                selected: _learningChallenges.contains(challenge),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _learningChallenges.add(challenge);
                    } else {
                      _learningChallenges.remove(challenge);
                    }
                  });
                },
              )).toList(),
            ),
            const SizedBox(height: 32),
            Semantics(
              button: true,
              label: 'Start Baseline Assessment',
              child: ElevatedButton(
                onPressed: _isAssessmentComplete() ? () => Navigator.pushNamed(context, '/onboarding_complete') : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Start Baseline Assessment', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 