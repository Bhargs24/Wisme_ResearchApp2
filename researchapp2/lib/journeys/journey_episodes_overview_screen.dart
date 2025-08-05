import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/journey_models.dart';
import '../services/audio_manifest_service.dart';
import 'audio_player_screen.dart';

class JourneyEpisodesOverviewScreen extends StatefulWidget {
  final Journey journey;
  final String selectedLevel;
  final String selectedLength;
  
  const JourneyEpisodesOverviewScreen({
    super.key,
    required this.journey,
    required this.selectedLevel,
    required this.selectedLength,
  });

  @override
  State<JourneyEpisodesOverviewScreen> createState() => _JourneyEpisodesOverviewScreenState();
}

class _JourneyEpisodesOverviewScreenState extends State<JourneyEpisodesOverviewScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<Episode> _episodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut)
    );
    
    _loadEpisodes();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    try {
      final episodes = await AudioManifestService.getEpisodesByJourneyId(widget.journey.id);
      setState(() {
        _episodes = episodes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading episodes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startJourney() {
    // Navigate to audio player to start the first episode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AudioPlayerScreen(),
        settings: RouteSettings(
          name: '/audio_player',
          arguments: widget.journey,
        ),
      ),
    );
  }

  void _playSpecificEpisode(Episode episode) {
    // Navigate to audio player with specific episode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AudioPlayerScreen(),
        settings: RouteSettings(
          name: '/audio_player',
          arguments: {
            'journey': widget.journey,
            'startWithEpisode': episode.id,
          },
        ),
      ),
    );
  }

  Color _getJourneyColor() {
    return Color(int.parse(widget.journey.colorHex.replaceFirst('#', '0xFF')));
  }

  IconData _getJourneyIcon() {
    switch (widget.journey.iconName) {
      case 'code': return Icons.code;              // Computer Science
      case 'psychology': return Icons.psychology;  // Psychology  
      case 'science': return Icons.science;        // Science
      case 'money': return Icons.attach_money;     // Life Skills (Personal Finance)
      default: return Icons.school;
    }
  }

  String _getLevelDisplayText() {
    switch (widget.selectedLevel) {
      case 'beginner': return 'New to this';
      case 'some_knowledge': return 'Some knowledge';
      case 'experienced': return 'Experienced';
      default: return 'Learning level';
    }
  }

  String _getLengthDisplayText() {
    switch (widget.selectedLength) {
      case '5_minutes': return '5 min';
      case '7_minutes': return '7 min';
      default: return 'Episode length';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final journeyColor = _getJourneyColor();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Back button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            decoration: BoxDecoration(
                              color: AppColors.hoverLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        // Personalization indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: journeyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: journeyColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, color: journeyColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Personalized',
                                style: AppTextStyles.caption.copyWith(
                                  color: journeyColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Journey header
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: journeyColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getJourneyIcon(),
                            color: journeyColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.journey.title,
                                style: AppTextStyles.heading1.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getLevelDisplayText(),
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_getLengthDisplayText()} episodes',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Journey description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: journeyColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About This Journey',
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.journey.description,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.schedule, color: journeyColor, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${_episodes.length} episodes • ~${(widget.journey.totalDuration / 60).round()} minutes total',
                                style: AppTextStyles.caption.copyWith(
                                  color: journeyColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Episodes list
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Episodes',
                            style: AppTextStyles.heading2.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _startJourney,
                            icon: Icon(Icons.play_arrow, color: journeyColor, size: 18),
                            label: Text(
                              'Start from beginning',
                              style: AppTextStyles.caption.copyWith(
                                color: journeyColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Episodes list
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: _episodes.length,
                                itemBuilder: (context, index) {
                                  final episode = _episodes[index];
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () => _playSpecificEpisode(episode),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBackground,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Episode number
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: journeyColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${episode.order}',
                                                  style: AppTextStyles.heading2.copyWith(
                                                    color: journeyColor,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(width: 16),
                                            
                                            // Episode details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    episode.title,
                                                    style: AppTextStyles.heading2.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    episode.description,
                                                    style: AppTextStyles.caption.copyWith(
                                                      color: Colors.white70,
                                                      height: 1.3,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    _formatDuration(episode.duration),
                                                    style: AppTextStyles.caption.copyWith(
                                                      color: journeyColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            // Play button
                                            Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: journeyColor.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: journeyColor,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom action button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startJourney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: journeyColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Start Learning Journey',
                          style: AppTextStyles.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
