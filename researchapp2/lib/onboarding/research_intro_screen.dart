import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ResearchIntroScreen extends StatefulWidget {
  const ResearchIntroScreen({super.key});

  @override
  State<ResearchIntroScreen> createState() => _ResearchIntroScreenState();
}

class _ResearchIntroScreenState extends State<ResearchIntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _introPages = [
    {
      'title': 'Welcome to Wisme Research',
      'subtitle': 'Help us validate conversational learning',
      'description': 'You\'re about to experience Wisme\'s conversational learning method. Learn through engaging conversational-style content that feels like listening to an educational podcast.',
      'icon': Icons.psychology_outlined,
    },
    {
      'title': 'This is a Research Demo',
      'subtitle': 'Testing pure conversational learning',
      'description': 'This demo focuses only on conversational learning to scientifically validate its effectiveness. The full Wisme app will have AI/ML models that learn with you and much more content.',
      'icon': Icons.science_outlined,
    },
    {
      'title': 'Your Privacy Matters',
      'subtitle': 'Secure and anonymous research',
      'description': 'We collect minimal learning data purely for research. All data is anonymized. No personal information is shared. You can withdraw anytime.',
      'icon': Icons.security_outlined,
    },
    {
      'title': 'What We\'re Validating',
      'subtitle': 'Conversational vs traditional learning',
      'description': 'We\'re testing if conversational-style explanations deliver better engagement and knowledge retention compared to traditional lecture-based methods.',
      'icon': Icons.insights_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(
                  _introPages.length,
                  (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: EdgeInsets.only(right: index < _introPages.length - 1 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage 
                          ? AppColors.accentGreen 
                          : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _introPages.length,
                itemBuilder: (context, index) {
                  final page = _introPages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page['icon'],
                          size: 80,
                          color: AppColors.accentGreen,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['title'],
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle'],
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.accentGreen,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page['description'],
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _introPages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _currentPage < _introPages.length - 1 ? 'Continue' : 'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
