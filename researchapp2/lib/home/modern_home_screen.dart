import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/auth_provider.dart';
import '../core/research_metrics_provider.dart';
import '../services/progress_persistence_service.dart';
import '../features/full_app_preview_screen.dart';
import '../admin/research_analytics_dashboard.dart';
import 'package:provider/provider.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardController;
  late AnimationController _floatingController;
  late Animation<double> _heroAnimation;
  late Animation<double> _cardStaggerAnimation;
  late Animation<Offset> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _cardStaggerAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );
    
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.elasticOut,
    ));
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0), // Static position
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _heroController.forward();
    _cardController.forward();
    // _floatingController.repeat(reverse: true); // REMOVED: No more bouncing
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroSection(),
                  const SizedBox(height: 32),
                  _buildContinueListening(),
                  const SizedBox(height: 32),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  _buildTrendingTopics(),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
                  const SizedBox(height: 32),
                  _buildFullAppTeaser(),
                  const SizedBox(height: 100), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSmartFAB(),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.9),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Wisme',
                            style: AppTextStyles.heading1.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Research Demo Experience',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Admin Analytics Button - Only for specific admin email
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              if (auth.user?.email == 'bhargavr098@gmail.com') {
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ResearchAnalyticsDashboard(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGreen,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentGreen.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.analytics,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pushNamed(context, '/profile'),
                              icon: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _heroAnimation,
      child: SlideTransition(
        position: _floatingAnimation,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue.withOpacity(0.2),
                AppColors.accentGreen.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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
                        colors: [AppColors.primaryBlue, AppColors.accentGreen],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Learning',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'The future of conversational education',
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
              Text(
                'Experience AI-powered learning through interactive audio conversations. This research demo showcases the next generation of personalized education.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildHeroStat('4', 'Demo Journeys', Icons.school),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildHeroStat('24', 'Audio Episodes', Icons.headphones),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildHeroStat('∞', 'Possibilities', Icons.auto_awesome),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueListening() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ProgressPersistenceService.getLastPlayedEpisode(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        
        final lastPlayed = snapshot.data!;
        final episodeTitle = lastPlayed['episodeTitle'] ?? 'Unknown Episode';
        final positionSeconds = lastPlayed['position'] as int? ?? 0;
        // For duration, we need to estimate or default to a reasonable value
        final durationSeconds = 1800; // Default 30 minutes for estimation
        
        if (positionSeconds <= 30 || durationSeconds <= 0) {
          return const SizedBox.shrink();
        }
        
        final progressPercentage = (positionSeconds / durationSeconds * 100).round();
        final positionDuration = Duration(seconds: positionSeconds);
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.2),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _cardController,
            curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _cardController,
              curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.15),
                    AppColors.accentGreen.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue Listening',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    episodeTitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${positionDuration.inMinutes}:${(positionDuration.inSeconds % 60).toString().padLeft(2, '0')} • $progressPercentage% complete',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressPercentage / 100,
                    backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to audio player with last played episode
                        Navigator.pushNamed(
                          context,
                          '/audio_player',
                          arguments: {
                            'journey': {'id': lastPlayed['journeyId']},
                            'autoResume': true,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: Text(
                        'Resume',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        final actions = [
          {
            'title': 'Explore Journeys',
            'subtitle': 'Start learning now',
            'icon': Icons.rocket_launch,
            'gradient': [AppColors.primaryBlue, AppColors.accentGreen],
            'route': '/journeys',
          },
          // Show feedback option if user has completed episodes
          if (research.episodeCount > 0) {
            'title': 'Share Feedback',
            'subtitle': 'Help improve Wisme',
            'icon': Icons.feedback_outlined,
            'gradient': [AppColors.accentGreen, AppColors.primaryBlue],
            'route': '/feedback_hub',
          },
          {
            'title': 'Progress Tracking',
            'subtitle': 'View your journey',
            'icon': Icons.trending_up,
            'gradient': [AppColors.accentRed, AppColors.primaryBlue],
            'route': '/progress_dashboard',
          },
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            ...actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              
              return AnimatedBuilder(
                animation: _cardStaggerAnimation,
                builder: (context, child) {
                  final animationValue = Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _cardController,
                      curve: Interval(
                        (index * 0.2).clamp(0.0, 1.0),
                        ((index * 0.2) + 0.4).clamp(0.0, 1.0),
                        curve: Curves.easeOut,
                      ),
                    ),
                  );
                  
                  return Transform.translate(
                    offset: Offset(50 * (1 - animationValue.value), 0),
                    child: Opacity(
                      opacity: animationValue.value,
                      child: _buildQuickActionCard(action),
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
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
                color: (action['gradient'] as List<Color>)[0].withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: action['gradient'] as List<Color>,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'] as String,
                        style: AppTextStyles.heading2.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        action['subtitle'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: (action['gradient'] as List<Color>)[0],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTopics() {
    final topics = [
      'Machine Learning',
      'Public Speaking',
      'Blockchain',
      'Photography',
      'Digital Marketing'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Trending Topics',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.local_fire_department,
              color: AppColors.accentRed,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'What the community wants most',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: index == topics.length - 1 ? 0 : 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.3),
                        AppColors.accentGreen.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.accentGreen,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        topics[index],
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        final metrics = research.getInvestorMetrics();
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundCard.withOpacity(0.3),
                AppColors.backgroundCard.withOpacity(0.1),
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
                  Icon(
                    Icons.analytics,
                    color: AppColors.accentGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Research Insights',
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time engagement metrics',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 20),
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
                      'Avg. Time',
                      '${((metrics['averageSessionDuration'] ?? 0) / 60).toStringAsFixed(1)}m',
                      Icons.timer_outlined,
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullAppTeaser() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FullAppPreviewScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.15),
              AppColors.accentGreen.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentGreen.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch_outlined,
                  color: AppColors.accentGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Preview: Full Wisme Platform',
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.accentGreen,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This research demo tests conversational learning. The full Wisme will let you search and learn anything with AI:',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeatureIcon(Icons.psychology_outlined, 'AI Learning'),
                _buildFeatureIcon(Icons.search_outlined, 'Search Anything'),
                _buildFeatureIcon(Icons.auto_awesome_outlined, 'Adaptive'),
                _buildFeatureIcon(Icons.chat_bubble_outline, 'Interactive'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tap to explore full features →',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.accentGreen,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white70,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSmartFAB() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: "home_fab",
        onPressed: () => Navigator.pushNamed(context, '/journeys'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentGreen],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
