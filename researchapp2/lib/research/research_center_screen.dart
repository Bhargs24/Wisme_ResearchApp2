import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import 'package:provider/provider.dart';

class ResearchCenterScreen extends StatefulWidget {
  const ResearchCenterScreen({super.key});

  @override
  State<ResearchCenterScreen> createState() => _ResearchCenterScreenState();
}

class _ResearchCenterScreenState extends State<ResearchCenterScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _cardStaggerAnimation;

  int _selectedCategory = 0;
  final List<String> _categories = [
    'All Research',
    'Pre-Study',
    'During Learning',
    'Post-Study',
    'Comparative',
    'Advanced'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _cardStaggerAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
    _cardController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.primaryBlue.withOpacity(0.2),
              AppColors.backgroundDark,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                _buildModernAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildCategoryFilter(),
                      const SizedBox(height: 32),
                      _buildResearchCards(),
                      const SizedBox(height: 32),
                      _buildCommunitySection(),
                      const SizedBox(height: 32),
                      _buildProgressInsights(),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentGreen.withOpacity(0.1),
                    AppColors.primaryBlue.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Research Center',
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
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
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentGreen, AppColors.primaryBlue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.science,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Research Participation Hub',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Your feedback shapes the future of education',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Research Impact',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your participation helps validate revolutionary learning methods and contributes to IEEE conference papers on educational innovation.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Research Categories',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = index == _selectedCategory;
              
              return Padding(
                padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [AppColors.accentGreen, AppColors.primaryBlue],
                            )
                          : null,
                      color: isSelected ? null : AppColors.backgroundCard.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.accentGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _categories[index],
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResearchCards() {
    final researchItems = _getFilteredResearchItems();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Research Surveys',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        ...researchItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return AnimatedBuilder(
            animation: _cardStaggerAnimation,
            builder: (context, child) {
              final animationValue = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _cardController,
                  curve: Interval(
                    (index * 0.1).clamp(0.0, 1.0),
                    ((index * 0.1) + 0.4).clamp(0.0, 1.0),
                    curve: Curves.easeOut,
                  ),
                ),
              );
              
              return Transform.translate(
                offset: Offset(50 * (1 - animationValue.value), 0),
                child: Opacity(
                  opacity: animationValue.value,
                  child: _buildResearchCard(item, index),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredResearchItems() {
    final allItems = [
      // Pre-Study Surveys
      {
        'title': 'Pre-Learning Assessment',
        'description': 'Help us understand your learning background and preferences',
        'category': 'Pre-Study',
        'duration': '5 min',
        'icon': Icons.school_outlined,
        'color': AppColors.primaryBlue,
        'route': '/onboarding',
        'completed': false,
        'priority': 'High'
      },
      
      // During Learning Surveys
      {
        'title': 'Episode Micro-Feedback',
        'description': 'Quick 30-second feedback after each episode',
        'category': 'During Learning',
        'duration': '30 sec',
        'icon': Icons.feedback_outlined,
        'color': AppColors.accentGreen,
        'route': '/episode_feedback',
        'completed': false,
        'priority': 'Medium'
      },
      {
        'title': 'Real-time Engagement',
        'description': 'Automatic tracking of your listening patterns',
        'category': 'During Learning',
        'duration': 'Auto',
        'icon': Icons.analytics_outlined,
        'color': AppColors.primaryBlue,
        'route': null, // Automatic
        'completed': true,
        'priority': 'Low'
      },
      
      // Post-Study Surveys
      {
        'title': 'Journey Completion Survey',
        'description': 'Comprehensive feedback after finishing a learning journey',
        'category': 'Post-Study',
        'duration': '10 min',
        'icon': Icons.assignment_turned_in_outlined,
        'color': AppColors.accentRed,
        'route': '/journey_completion',
        'completed': false,
        'priority': 'High'
      },
      {
        'title': 'Knowledge Retention Test',
        'description': 'Test what you remember 1 week after learning',
        'category': 'Post-Study',
        'duration': '7 min',
        'icon': Icons.psychology_outlined,
        'color': AppColors.accentGreen,
        'route': '/retention_test',
        'completed': false,
        'priority': 'High'
      },
      
      // Comparative Studies
      {
        'title': 'Learning Method Comparison',
        'description': 'Compare conversational vs traditional learning methods',
        'category': 'Comparative',
        'duration': '12 min',
        'icon': Icons.compare_arrows_outlined,
        'color': AppColors.primaryBlue,
        'route': '/learning_method_comparison',
        'completed': false,
        'priority': 'Critical'
      },
      {
        'title': 'Product Interest Assessment',
        'description': 'Tell us about your interest in the full Wisme platform',
        'category': 'Comparative',
        'duration': '6 min',
        'icon': Icons.star_outline,
        'color': AppColors.accentRed,
        'route': '/product_interest',
        'completed': false,
        'priority': 'Medium'
      },
      
      // Advanced Research
      {
        'title': 'Final Research Survey',
        'description': 'Comprehensive survey for academic paper contribution',
        'category': 'Advanced',
        'duration': '15 min',
        'icon': Icons.article_outlined,
        'color': AppColors.accentGreen,
        'route': '/final_research_survey',
        'completed': false,
        'priority': 'Critical'
      },
      {
        'title': 'Study Completion Certificate',
        'description': 'Get your research participation certificate',
        'category': 'Advanced',
        'duration': '2 min',
        'icon': Icons.workspace_premium_outlined,
        'color': AppColors.primaryBlue,
        'route': '/study_completion',
        'completed': false,
        'priority': 'Low'
      },
    ];

    if (_selectedCategory == 0) return allItems; // All Research
    
    final categoryName = _categories[_selectedCategory];
    return allItems.where((item) => item['category'] == categoryName).toList();
  }

  Widget _buildResearchCard(Map<String, dynamic> item, int index) {
    final isCompleted = item['completed'] as bool;
    final priority = item['priority'] as String;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item['route'] != null 
              ? () => Navigator.pushNamed(context, item['route'] as String)
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.backgroundCard.withOpacity(0.4),
                  AppColors.backgroundCard.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (item['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'] as String,
                                  style: AppTextStyles.heading2.copyWith(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Done',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accentGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['description'] as String,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(priority).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: AppTextStyles.caption.copyWith(
                          color: _getPriorityColor(priority),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      color: Colors.white38,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['duration'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    if (item['route'] != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: item['color'] as Color,
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical': return AppColors.accentRed;
      case 'High': return Colors.orange;
      case 'Medium': return AppColors.accentGreen;
      case 'Low': return Colors.grey;
      default: return AppColors.primaryBlue;
    }
  }

  Widget _buildCommunitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.accentGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                color: AppColors.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Community Research',
                style: AppTextStyles.heading2.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCommunityCard(
                  'Suggest Topics',
                  'Shape future content',
                  Icons.lightbulb_outline,
                  AppColors.accentGreen,
                  () => Navigator.pushNamed(context, '/suggest_topic'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCommunityCard(
                  'Trending Requests',
                  'See what others want',
                  Icons.trending_up,
                  AppColors.accentRed,
                  () => Navigator.pushNamed(context, '/community_requests'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white60,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInsights() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        final metrics = research.getInvestorMetrics();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentRed.withOpacity(0.1),
                AppColors.primaryBlue.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentRed.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insights,
                    color: AppColors.accentRed,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Your Research Impact',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Sessions',
                      '${metrics['totalSessions'] ?? 0}',
                      Icons.play_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Completion',
                      '${((metrics['journeyCompletionRate'] ?? 0) * 100).toStringAsFixed(0)}%',
                      Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Engagement',
                      '${((metrics['averageEngagement'] ?? 0) * 10).toStringAsFixed(1)}/10',
                      Icons.favorite_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Your participation contributes to research that will be published in IEEE conferences and helps validate innovative learning methods.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentRed,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentRed.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentRed, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
