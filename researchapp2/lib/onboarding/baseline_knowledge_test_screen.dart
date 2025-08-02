import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BaselineKnowledgeTestScreen extends StatefulWidget {
  const BaselineKnowledgeTestScreen({super.key});

  @override
  State<BaselineKnowledgeTestScreen> createState() => _BaselineKnowledgeTestScreenState();
}

class _BaselineKnowledgeTestScreenState extends State<BaselineKnowledgeTestScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': "What's the time complexity of finding an element in an unsorted array?",
      'options': ['O(1)', 'O(log n)', 'O(n)', 'O(n^2)'],
    },
    {
      'question': "Why would you choose a linked list over an array for a music playlist?",
      'options': ['Faster access', 'Dynamic size', 'Less memory', 'Easier sorting'],
    },
    {
      'question': "What is ACID in databases?",
      'options': ['A type of query', 'A transaction property', 'A storage engine', 'A programming language'],
    },
  ];
  List<int?> _answers = [null, null, null];
  double _overallConfidence = 5;

  bool _isBaselineComplete() {
    return _answers.every((a) => a != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Knowledge Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Baseline Assessment', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text("Quick check of your current knowledge in today's learning topics\n(Don't worry about getting everything right!)", style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ...List.generate(_questions.length, (index) {
              final q = _questions[index];
              return Semantics(
                label: 'Question ${index + 1}: ${q['question']}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Q${index + 1}: ${q['question']}', style: AppTextStyles.heading2.copyWith(fontSize: 16)),
                    const SizedBox(height: 8),
                    ...List.generate(q['options'].length, (optIdx) => Semantics(
                      label: 'Option: ${q['options'][optIdx]}',
                      child: RadioListTile<int>(
                        value: optIdx,
                        groupValue: _answers[index],
                        onChanged: (val) => setState(() => _answers[index] = val),
                        title: Text(q['options'][optIdx]),
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }),
            // Confidence self-assessment
            Align(
              alignment: Alignment.centerLeft,
              child: Text('How confident are you about these topics overall?', style: AppTextStyles.heading2.copyWith(fontSize: 18)),
            ),
            Slider(
              value: _overallConfidence,
              min: 0,
              max: 10,
              divisions: 10,
              label: _overallConfidence.round().toString(),
              onChanged: (val) => setState(() => _overallConfidence = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Not confident'),
                Text('Very confident'),
              ],
            ),
            const SizedBox(height: 32),
            Semantics(
              button: true,
              label: 'Continue to Learning Journeys',
              child: ElevatedButton(
                onPressed: _isBaselineComplete() ? () => Navigator.pushNamed(context, '/journeys') : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
                child: const Text('Begin Learning Journeys', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 