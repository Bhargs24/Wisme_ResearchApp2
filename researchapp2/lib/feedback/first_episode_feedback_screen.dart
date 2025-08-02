import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/research_metrics_provider.dart';

class FirstEpisodeFeedbackScreen extends StatefulWidget {
  const FirstEpisodeFeedbackScreen({super.key});

  @override
  State<FirstEpisodeFeedbackScreen> createState() => _FirstEpisodeFeedbackScreenState();
}

class _FirstEpisodeFeedbackScreenState extends State<FirstEpisodeFeedbackScreen> {
  int _overallSatisfaction = 5;
  Map<String, double> _featureInterest = {
    'interactive_notes': 5.0,
    'progress_tracking': 5.0,
    'offline_download': 5.0,
    'speed_control': 5.0,
    'bookmarks': 5.0,
    'community_discussion': 5.0,
    'personalized_recommendations': 5.0,
    'skill_assessments': 5.0,
  };
  Map<String, int> _painPointSeverity = {
    'finding_quality_content': 5,
    'staying_motivated': 5,
    'tracking_progress': 5,
    'applying_knowledge': 5,
    'time_management': 5,
  };
  List<String> _currentSolutions = [];
  double _problemFrequency = 5.0;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Feedback'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Congratulations Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.celebration, size: 48, color: Colors.blue),
                  SizedBox(height: 12),
                  Text(
                    'Congratulations! 🎉',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You just completed your first episode! Help us make your learning experience even better.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Overall Experience
            const Text('How was your first experience?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildSatisfactionSlider(),
            
            const SizedBox(height: 32),
            
            // Feature Interest
            const Text('What features would make this even better?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildFeatureInterestSection(),
            
            const SizedBox(height: 32),
            
            // Pain Point Validation
            const Text('What learning challenges do you face?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildPainPointSection(),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Continue Learning →'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Skip Option
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip for now', style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionSlider() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Not great', style: TextStyle(color: Colors.grey)),
            Text('Amazing!', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(
          value: _overallSatisfaction.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() {
              _overallSatisfaction = value.round();
            });
          },
        ),
        Text(
          'Rating: $_overallSatisfaction/10',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFeatureInterestSection() {
    final features = {
      'interactive_notes': 'Interactive Notes & Highlights',
      'progress_tracking': 'Detailed Progress Tracking',
      'offline_download': 'Offline Downloads',
      'speed_control': 'Advanced Speed Control',
      'bookmarks': 'Smart Bookmarks',
      'community_discussion': 'Community Discussions',
      'personalized_recommendations': 'Personalized Recommendations',
      'skill_assessments': 'Skill Assessments',
    };

    return Column(
      children: features.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('${_featureInterest[entry.key]!.round()}/10', 
                       style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _featureInterest[entry.key]!,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _featureInterest[entry.key] = value;
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPainPointSection() {
    final painPoints = {
      'finding_quality_content': 'Finding quality learning content',
      'staying_motivated': 'Staying motivated to learn',
      'tracking_progress': 'Tracking learning progress',
      'applying_knowledge': 'Applying knowledge practically',
      'time_management': 'Managing learning time',
    };

    return Column(
      children: painPoints.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('Problem: ${_painPointSeverity[entry.key]!}/10',
                       style: TextStyle(
                         color: _painPointSeverity[entry.key]! > 7 ? Colors.red : Colors.blue,
                         fontWeight: FontWeight.w600,
                       )),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Not a problem', style: TextStyle(color: Colors.grey)),
                  Text('Major problem', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Slider(
                value: _painPointSeverity[entry.key]!.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: _painPointSeverity[entry.key]! > 7 ? Colors.red : Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _painPointSeverity[entry.key] = value.round();
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _submitFeedback() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final researchProvider = Provider.of<ResearchMetricsProvider>(context, listen: false);

      // Capture feature interest
      researchProvider.captureFeatureInterest(
        featureInterest: _featureInterest,
        priorityFeatures: _featureInterest.entries
            .where((entry) => entry.value >= 8.0)
            .map((entry) => entry.key)
            .toList(),
        triggerContext: 'first_episode',
      );

      // Capture pain point validation
      researchProvider.capturePainPointValidation(
        painPointSeverity: _painPointSeverity,
        currentSolutions: _currentSolutions,
        problemFrequency: _problemFrequency,
        triggerContext: 'first_episode',
      );

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback! 🙏'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting feedback. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
