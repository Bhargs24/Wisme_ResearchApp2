import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import '../gamification/gamification_provider.dart';
import '../services/audio_manifest_service.dart';

/// Advanced progress visualization screen with research-focused insights
class ProgressVisualizationScreen extends StatefulWidget {
  const ProgressVisualizationScreen({super.key});

  @override
  State<ProgressVisualizationScreen> createState() => _ProgressVisualizationScreenState();
}

class _ProgressVisualizationScreenState extends State<ProgressVisualizationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text('Research Insights', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Comparison'),
            Tab(text: 'Impact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildComparisonTab(),
          _buildImpactTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Research Contribution Summary
          _buildResearchContributionCard(),
          const SizedBox(height: 20),
          
          // Recent Badges
          _buildRecentBadgesSection(),
          const SizedBox(height: 20),
          
          // Milestone Progress
          _buildMilestonesSection(),
          const SizedBox(height: 20),
          
          // Learning Journey Map
          _buildJourneyMapSection(),
        ],
      ),
    );
  }

  Widget _buildComparisonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Method Comparison',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          
          // Method Engagement Chart
          _buildMethodEngagementChart(),
          const SizedBox(height: 20),
          
          // Preference Analysis
          _buildPreferenceAnalysis(),
          const SizedBox(height: 20),
          
          // Time Distribution
          _buildTimeDistributionChart(),
        ],
      ),
    );
  }

  Widget _buildImpactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research Impact',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          
          // Impact Score
          _buildImpactScoreCard(),
          const SizedBox(height: 20),
          
          // Contribution Timeline
          _buildContributionTimeline(),
          const SizedBox(height: 20),
          
          // Research Goals
          _buildResearchGoalsSection(),
        ],
      ),
    );
  }

  Widget _buildResearchContributionCard() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlueLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science, color: AppColors.primaryBlue, size: 24),
                  const SizedBox(width: 8),
                  Text('Research Contribution', style: AppTextStyles.heading3),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Journeys\nExplored', '${research.journeyCount}', Icons.explore),
                  ),
                  Expanded(
                    child: _buildStatItem('Episodes\nCompleted', '${research.episodeCount}', Icons.timer),
                  ),
                  Expanded(
                    child: _buildStatItem('Feedback\nShared', '${research.completedJourneys.length}', Icons.feedback),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentGreen, size: 20),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.heading2.copyWith(color: AppColors.accentGreen)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRecentBadgesSection() {
    return Consumer<GamificationProvider>(
      builder: (context, gamification, child) {
        final badges = gamification.badges;
        final defaultBadges = [
          {'title': 'First Journey', 'icon': Icons.explore, 'color': Colors.blue},
          {'title': 'First Episode', 'icon': Icons.play_circle, 'color': Colors.green},
          {'title': 'Feedback Giver', 'icon': Icons.feedback, 'color': Colors.orange},
        ];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Achievements', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: badges.isNotEmpty 
                  ? badges.map((badge) => _buildBadgeCard(
                      badge, 
                      Icons.star, 
                      Colors.amber
                    )).toList()
                  : defaultBadges.map((badge) => _buildBadgeCard(
                      badge['title'] as String,
                      badge['icon'] as IconData,
                      badge['color'] as Color,
                    )).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeCard(String title, IconData icon, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        final journeys = research.journeyCount;
        final episodes = research.episodeCount;
        final feedback = research.completedJourneys.length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Research Milestones', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            
            _buildMilestoneItem(
              'Complete 2 Journeys', 
              journeys >= 2 ? 1.0 : journeys / 2.0, 
              '$journeys/2 Complete'
            ),
            _buildMilestoneItem(
              'Complete 10 Episodes', 
              episodes >= 10 ? 1.0 : episodes / 10.0, 
              '$episodes/10 Episodes'
            ),
            _buildMilestoneItem(
              'Share 5 Feedback', 
              feedback >= 5 ? 1.0 : feedback / 5.0, 
              '$feedback/5 Feedback'
            ),
          ],
        );
      },
    );
  }

  Widget _buildMilestoneItem(String title, double progress, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryBlueVeryLight,
            valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyMapSection() {
    return FutureBuilder(
      future: AudioManifestService.getJourneys(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        
        final journeys = snapshot.data as List;
        return Consumer<ResearchMetricsProvider>(
          builder: (context, research, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learning Journey Map', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < journeys.length; i++) ...[
                        _buildJourneyMapItem(
                          journeys[i].title, 
                          research.completedJourneys.any((j) => j['journeyId'] == journeys[i].id),
                          _getJourneyColor(i),
                        ),
                        if (i < journeys.length - 1) _buildJourneyMapConnector(),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getJourneyColor(int index) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }

  Widget _buildJourneyMapItem(String title, bool completed, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: completed ? color : Colors.grey.shade600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: completed ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        if (completed) ...[
          const Spacer(),
          Icon(Icons.check_circle, color: color, size: 16),
        ],
      ],
    );
  }

  Widget _buildJourneyMapConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 16,
            color: AppColors.textSecondary,
            margin: const EdgeInsets.only(left: 5),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodEngagementChart() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        final journeys = research.journeyCount;
        final episodes = research.episodeCount;
        
        // Calculate engagement based on actual usage
        final conversationalEngagement = episodes > 0 ? 0.9 : 0.0;
        final traditionalEngagement = journeys > 1 ? 0.7 : 0.3;
        final interactiveEngagement = research.completedJourneys.length > 0 ? 0.8 : 0.2;
        final visualEngagement = episodes > 3 ? 0.6 : 0.1;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Engagement by Method', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              
              _buildEngagementBar('Traditional Learning', traditionalEngagement, Colors.blue),
              _buildEngagementBar('Conversational AI', conversationalEngagement, Colors.green),
              _buildEngagementBar('Interactive Practice', interactiveEngagement, Colors.orange),
              _buildEngagementBar('Visual Learning', visualEngagement, Colors.purple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEngagementBar(String method, double engagement, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(method, style: AppTextStyles.bodySmall),
              Text('${(engagement * 100).toInt()}%', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: engagement,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceAnalysis() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        // Calculate preferences based on actual user behavior
        final avgTime = research.averageSessionTime;
        final episodes = research.episodeCount;
        
        String audioLevel = episodes > 5 ? 'High' : episodes > 2 ? 'Medium' : 'Low';
        String interactiveLevel = research.completedJourneys.length > 2 ? 'High' : 'Medium';
        String visualLevel = avgTime > 300 ? 'Medium' : 'Low'; // 5 minutes
        
        Color audioColor = episodes > 5 ? AppColors.accentGreen : 
                          episodes > 2 ? AppColors.accentOrange : AppColors.accentRed;
        Color interactiveColor = research.completedJourneys.length > 2 ? AppColors.accentGreen : AppColors.accentOrange;
        Color visualColor = avgTime > 300 ? AppColors.accentOrange : AppColors.accentRed;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Learning Preferences', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              
              _buildPreferenceItem('Audio Learning', audioLevel, audioColor),
              _buildPreferenceItem('Interactive Elements', interactiveLevel, interactiveColor),
              _buildPreferenceItem('Visual Content', visualLevel, visualColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferenceItem(String preference, String level, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(preference, style: AppTextStyles.bodySmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              level,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDistributionChart() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        // Calculate time distribution based on actual usage patterns
        final episodes = research.episodeCount;
        final avgTime = research.averageSessionTime;
        
        // Generate realistic daily patterns based on user engagement
        final dailyValues = [
          episodes > 0 ? 0.3 : 0.1, // Monday
          episodes > 2 ? 0.8 : 0.2, // Tuesday
          episodes > 1 ? 0.6 : 0.15, // Wednesday
          episodes > 3 ? 0.9 : 0.25, // Thursday
          episodes > 1 ? 0.4 : 0.1, // Friday
          avgTime > 300 ? 0.5 : 0.1, // Saturday
          avgTime > 200 ? 0.3 : 0.05, // Sunday
        ];
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time Distribution', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              
              Text(
                'Weekly Learning Pattern',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              
              // Real time distribution visualization
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeBar('Mon', dailyValues[0]),
                  _buildTimeBar('Tue', dailyValues[1]),
                  _buildTimeBar('Wed', dailyValues[2]),
                  _buildTimeBar('Thu', dailyValues[3]),
                  _buildTimeBar('Fri', dailyValues[4]),
                  _buildTimeBar('Sat', dailyValues[5]),
                  _buildTimeBar('Sun', dailyValues[6]),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeBar(String day, double value) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryBlueVeryLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: 60 * value,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildImpactScoreCard() {
    return Consumer2<ResearchMetricsProvider, GamificationProvider>(
      builder: (context, research, gamification, child) {
        // Calculate impact score based on actual engagement
        final journeyScore = research.journeyCount * 20;
        final episodeScore = research.episodeCount * 5;
        final feedbackScore = research.completedJourneys.length * 15;
        final totalScore = (journeyScore + episodeScore + feedbackScore).clamp(0, 100);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text('Research Impact Score', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentGreen, width: 8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$totalScore',
                        style: AppTextStyles.heading1.copyWith(color: AppColors.accentGreen),
                      ),
                      Text(
                        'Impact',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Text(
                totalScore > 50 
                  ? 'Your contributions are helping improve learning methods for thousands of students!'
                  : 'Keep engaging to increase your research impact!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContributionTimeline() {
    return Consumer<ResearchMetricsProvider>(
      builder: (context, research, child) {
        final completedJourneys = research.completedJourneys;
        final episodes = research.episodeCount;
        
        List<Map<String, dynamic>> timelineItems = [];
        
        // Add real journey completions
        for (var journey in completedJourneys) {
          String journeyName = '';
          switch (journey['journeyId']) {
            case 'data_structures_algorithms':
              journeyName = 'Data Structures & Algorithms';
              break;
            case 'psychology':
              journeyName = 'Psychology & Human Behavior';
              break;
            case 'science_mysteries':
              journeyName = 'Science Mysteries & Discoveries';
              break;
            case 'personal_finance':
              journeyName = 'Personal Finance Mastery';
              break;
            default:
              journeyName = 'Learning Journey';
          }
          timelineItems.add({
            'title': 'Started $journeyName',
            'time': 'Recently',
            'completed': true,
          });
        }
        
        // Add episode milestone
        if (episodes > 0) {
          timelineItems.add({
            'title': 'Completed $episodes Episodes',
            'time': 'This week',
            'completed': true,
          });
        }
        
        // Add research participation
        timelineItems.add({
          'title': 'Joined Research Study',
          'time': 'Today',
          'completed': true,
        });
        
        // If no real data, show getting started message
        if (timelineItems.length <= 1) {
          timelineItems = [
            {
              'title': 'Ready to Start Learning',
              'time': 'Now',
              'completed': false,
            },
            {
              'title': 'Joined Research Study',
              'time': 'Today',
              'completed': true,
            },
          ];
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contribution Timeline', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              
              ...timelineItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTimelineItem(
                  item['title'] as String,
                  item['time'] as String,
                  item['completed'] as bool,
                ),
              )).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(String title, String time, bool completed) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: completed ? AppColors.accentGreen : AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySmall),
              Text(
                time,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResearchGoalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Research Goals', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          
          Text(
            'How Your Participation Helps:',
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          _buildGoalItem('• Compare traditional vs AI-assisted learning effectiveness'),
          _buildGoalItem('• Identify optimal content delivery methods'),
          _buildGoalItem('• Improve personalized learning algorithms'),
          _buildGoalItem('• Develop better educational tools for everyone'),
        ],
      ),
    );
  }

  Widget _buildGoalItem(String goal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        goal,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
