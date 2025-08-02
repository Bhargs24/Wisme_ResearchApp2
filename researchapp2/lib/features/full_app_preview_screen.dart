import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FullAppPreviewScreen extends StatefulWidget {
  const FullAppPreviewScreen({super.key});

  @override
  State<FullAppPreviewScreen> createState() => _FullAppPreviewScreenState();
}

class _FullAppPreviewScreenState extends State<FullAppPreviewScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _featurePages = [
    {
      'title': 'Full Wisme: AI-Powered Learning',
      'subtitle': 'Beyond this demo',
      'description': 'The complete Wisme platform will feature advanced AI and ML models that learn with you, adapting to your learning style and creating personalized conversational content.',
      'features': [
        'AI models that understand your learning style',
        'ML algorithms that adapt content difficulty',
        'Personalized conversational explanations',
        'Smart pacing based on your progress'
      ],
      'icon': Icons.psychology_outlined,
      'gradient': [AppColors.primaryBlue, AppColors.accentGreen],
    },
    {
      'title': 'Learn Anything You Want',
      'subtitle': 'Open search-based learning',
      'description': 'Unlike this demo with fixed topics, the full Wisme will let you search and learn about anything - from quantum physics to cooking, all in conversational style.',
      'features': [
        'Search any topic you want to learn',
        'AI generates conversational explanations instantly',
        'No predefined courses or limits',
        'Personalized to your knowledge level'
      ],
      'icon': Icons.search_outlined,
      'gradient': [AppColors.accentGreen, AppColors.primaryBlue],
    },
    {
      'title': 'AI That Learns With You',
      'subtitle': 'Adaptive ML models',
      'description': 'Our AI will remember your learning patterns, preferences, and knowledge gaps to create better explanations over time.',
      'features': [
        'Remembers your learning style',
        'Adapts explanations to your pace',
        'Identifies and fills knowledge gaps',
        'Gets better the more you use it'
      ],
      'icon': Icons.auto_awesome_outlined,
      'gradient': [AppColors.accentRed, AppColors.accentGreen],
    },
    {
      'title': 'Enhanced Conversational Experience',
      'subtitle': 'Better than podcasts',
      'description': 'The full app will have interactive elements, visual aids, and dynamic conversations that adapt in real-time to your understanding.',
      'features': [
        'Interactive conversational elements',
        'Visual aids and diagrams',
        'Real-time adaptation to your questions',
        'Multiple explanation styles'
      ],
      'icon': Icons.chat_bubble_outline,
      'gradient': [AppColors.primaryBlue, AppColors.accentRed],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundCard.withOpacity(0.8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        title: Text(
          'Full App Preview',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(
                _featurePages.length,
                (index) => Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: index < _featurePages.length - 1 ? 8 : 0),
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
              itemCount: _featurePages.length,
              itemBuilder: (context, index) {
                final page = _featurePages[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Feature icon with gradient background
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: page['gradient'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page['icon'],
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Text(
                        page['title'],
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        page['subtitle'],
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.accentGreen,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        page['description'],
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Feature list
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Key Features:',
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...page['features'].map<Widget>((feature) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.accentGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  const SizedBox.shrink(),

                Text(
                  '${_currentPage + 1} of ${_featurePages.length}',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),

                if (_currentPage < _featurePages.length - 1)
                  ElevatedButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Back to Demo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
