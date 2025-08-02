import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/journey_models.dart';
import '../core/research_metrics_provider.dart';
import '../services/audio_manifest_service.dart';
import '../core/firebase_service.dart';
import 'package:provider/provider.dart';

class JourneySelectionScreen extends StatefulWidget {
  const JourneySelectionScreen({super.key});

  @override
  State<JourneySelectionScreen> createState() => _JourneySelectionScreenState();
}

class _JourneySelectionScreenState extends State<JourneySelectionScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<Journey> _journeys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadJourneys();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadJourneys() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load journeys from audio manifest
      _journeys = await AudioManifestService.getJourneys();
    } catch (e) {
      print('Error loading journeys: $e');
      _journeys = [];
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Color _getColorFromHex(String colorHex) {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'code': return Icons.code;
      case 'psychology': return Icons.psychology;
      case 'science': return Icons.science;
      case 'money': return Icons.attach_money;
      case 'computer': return Icons.computer;
      case 'storage': return Icons.storage;
      case 'account_balance': return Icons.account_balance;
      default: return Icons.school;
    }
  }

  void _onJourneySelected(Journey journey) {
    // Navigate to audio player with journey data
    Navigator.pushNamed(
      context, 
      '/audio_player',
      arguments: journey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern app bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.backgroundDark,
              leading: Builder(
                builder: (context) => IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    decoration: BoxDecoration(
                      color: AppColors.hoverLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Choose Your Journey',
                  style: AppTextStyles.heading2.copyWith(fontSize: 18),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryBlueLight,
                        AppColors.backgroundDark,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Continue Learning Section
            Consumer<ResearchMetricsProvider>(
              builder: (context, research, _) {
                if (research.completedJourneys.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: AppColors.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continue Exploring',
                              style: AppTextStyles.heading2.copyWith(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              if (research.completedJourneys.length < 4) ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lightbulb_outline,
                                        color: AppColors.primaryBlue,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Try a different learning method',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Each journey uses a unique approach - discover what works best for you',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.celebration,
                                        color: AppColors.primaryBlue,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Research Explorer!',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'You\'ve tried all available learning methods. Your insights are valuable!',
                                            style: AppTextStyles.caption.copyWith(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Smart Recommendations Section
            // Journey grid
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: _isLoading 
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSkeletonCard(index),
                        childCount: 4, // Show 4 skeleton cards
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= _journeys.length) return null;
                          
                          final journey = _journeys[index];
                          return _buildJourneyListCard(journey, index);
                        },
                        childCount: _journeys.length,
                      ),
                    ),
            ),

            // Research exploration indicator
            SliverToBoxAdapter(
              child: Consumer<ResearchMetricsProvider>(
                builder: (context, research, _) {
                  final exploredCount = research.completedJourneys.length;
                  return Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Learning Exploration',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.explore,
                              color: AppColors.primaryBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exploredCount == 0 
                                  ? 'Choose any journey to start exploring different learning methods'
                                  : exploredCount == 1
                                    ? 'Great start! Try another journey to compare learning methods'
                                    : 'Excellent! You\'re helping us understand learning preferences',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (exploredCount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$exploredCount journey${exploredCount == 1 ? '' : 's'} explored',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Research Contribution: Active',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),

            // Request New Content Section (Research Interest Tracking)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Want to learn something else?',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showRequestNewJourneyDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryBlue.withOpacity(0.2),
                              AppColors.primaryBlue.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Request a new learning journey',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Tell us what you\'d like to learn next',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primaryBlue,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlueLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon skeleton
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 16),
            // Content skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueVeryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueVeryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow skeleton
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyListCard(Journey journey, int index) {
    final color = _getColorFromHex(journey.colorHex);
    final icon = _getIconFromName(journey.iconName);
    
    return Semantics(
      label: 'Journey card: ${journey.title}, ${journey.description}',
      button: true,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Fixed opacity calculation to ensure valid range [0.0, 1.0]
          final rawValue = _animationController.value - (index * 0.1);
          final clampedValue = rawValue.clamp(0.0, 1.0);
          final animationValue = Curves.easeOutBack.transform(clampedValue);
          final safeOpacity = animationValue.clamp(0.0, 1.0);
          
          return Transform.scale(
            scale: animationValue,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: safeOpacity,
                child: GestureDetector(
                  onTap: () => _showJourneyDetails(journey),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Icon section
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, size: 30, color: color),
                          ),
                          const SizedBox(width: 16),
                          // Content section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  journey.title,
                                  style: AppTextStyles.heading2.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  journey.description,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 14, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${journey.episodeIds.length} episodes',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Arrow
                          Icon(
                            Icons.arrow_forward_ios,
                            color: color,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showJourneyDetails(Journey journey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _getColorFromHex(journey.colorHex).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _getIconFromName(journey.iconName),
                                size: 30,
                                color: _getColorFromHex(journey.colorHex),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    journey.title,
                                    style: AppTextStyles.heading1.copyWith(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${journey.episodeIds.length} episodes',
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'About this Journey',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          journey.description,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Episodes (${journey.episodeIds.length})',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...journey.episodeIds.asMap().entries.map((entry) {
                          final index = entry.key;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getColorFromHex(journey.colorHex).withOpacity(0.3),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getColorFromHex(journey.colorHex).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: AppTextStyles.heading2.copyWith(
                                      color: _getColorFromHex(journey.colorHex),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                'Episode ${index + 1}',
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Learning content for ${journey.title}',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white70,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _onJourneySelected(journey);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _onJourneySelected(journey);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getColorFromHex(journey.colorHex),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Start Journey',
                              style: AppTextStyles.heading2.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRequestNewJourneyDialog() {
    final TextEditingController requestController = TextEditingController();
    bool isAnonymous = true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Request New Journey',
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What would you like to learn next? Your suggestion will be visible to the community.',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: requestController,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., React.js, Machine Learning, Investment Basics...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Anonymity toggle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAnonymous ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAnonymous ? 'Submit anonymously' : 'Show your name',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            isAnonymous 
                                ? 'Your request will appear as "Anonymous"'
                                : 'Your name will be visible with the request',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !isAnonymous,
                      onChanged: (value) => setState(() => isAnonymous = !value),
                      activeColor: AppColors.primaryBlue,
                      activeTrackColor: AppColors.primaryBlue.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (requestController.text.trim().isNotEmpty) {
                  _submitJourneyRequest(requestController.text.trim(), isAnonymous);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thank you! Your request has been added to the community board.'),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Submit',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitJourneyRequest(String requestedContent, bool isAnonymous) {
    // Track user interest in new content (feeds research metrics)
    final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
    
    // Save to Firebase for community display with anonymity option
    final suggestionData = {
      'topic': requestedContent,
      'requesterName': isAnonymous ? 'Anonymous' : 'Community User',
      'isAnonymous': isAnonymous,
      'timestamp': DateTime.now().toIso8601String(),
      'userId': research.userId,
    };
    
    // Save directly to Firebase
    FirebaseService.firestore
        .collection('topic_suggestions')
        .add(suggestionData);
    
    // Also track as journey interest for research metrics
    research.captureJourneyInterest(
      journeyId: 'user_request_${DateTime.now().millisecondsSinceEpoch}',
      interestLevel: 10.0, // High interest since they actively requested
      selectionTime: DateTime.now(),
    );
}
    }