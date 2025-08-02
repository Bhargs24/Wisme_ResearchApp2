import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/journey_models.dart';
import '../services/progress_persistence_service.dart';
import '../services/audio_manifest_service.dart';
import 'package:provider/provider.dart';
import '../core/research_metrics_provider.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> 
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _fadeController;
  late AnimationController _pulseController; // Keep for disposal
  late Animation<double> _fadeAnimation;
  // Removed _pulseAnimation - not needed for professional UI
  Journey? _journey; // Remove 'late' keyword since it can be null
  List<Episode> _episodes = [];
  Episode? _currentEpisode;
  int _currentEpisodeIndex = 0;
  bool _isLoading = true;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _autoResumeRequested = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayerListeners();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    // Removed pulse animation for professional look
    
    _fadeController.forward();
    // _pulseController.repeat(reverse: true); // REMOVED: No more pulsing animation
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    
    if (arguments is Journey) {
      // Standard journey argument
      if (_journey == null || arguments != _journey) {
        _journey = arguments;
        _loadJourneyContent();
      }
    } else if (arguments is Map<String, dynamic>) {
      // Resume functionality with specific episode
      final journey = arguments['journey'] as Journey?;
      final autoResume = arguments['autoResume'] as bool? ?? false;
      
      if (journey != null && (_journey == null || journey != _journey)) {
        _journey = journey;
        _autoResumeRequested = autoResume;
        _loadJourneyContent();
      }
    }
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
      
      // Auto-save position every 10 seconds for resume functionality
      if (_currentEpisode != null && position.inSeconds % 10 == 0) {
        _saveProgress();
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
      
      // Handle episode completion
      if (state.processingState == ProcessingState.completed && _currentEpisode != null) {
        _handleEpisodeCompletion();
      }
    });
  }

  Future<void> _loadJourneyContent() async {
    if (_journey == null) return;
    
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Load episodes from audio manifest
      _episodes = await AudioManifestService.getEpisodesByJourneyId(_journey!.id);
      
      if (_episodes.isEmpty) {
        print('❌ No episodes found for journey: ${_journey!.id}');
        return;
      }

      if (_episodes.isNotEmpty) {
        _currentEpisode = _episodes[0];
        await _loadEpisode(_currentEpisode!);
        
        // Handle auto-resume if requested
        if (_autoResumeRequested) {
          await _attemptAutoResume();
        }
      }
    } catch (e) {
      print('Error loading journey content: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEpisode(Episode episode) async {
    if (_journey == null) return;
    
    try {
      print('DEBUG: Attempting to load audio from path: ${episode.audioUrl}');
      
      // Use only asset loading with proper error handling
      await _audioPlayer.setAsset(episode.audioUrl);
      print('DEBUG: Successfully loaded audio asset: ${episode.audioUrl}');
      
      _currentEpisode = episode;
      _currentEpisodeIndex = _episodes.indexOf(episode);
      
      // Track episode start for research
      final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
      research.trackAudioEngagement(
        episodeId: episode.id,
        action: 'play',
        position: 0,
        speed: _playbackSpeed,
        additionalData: {
          'journeyId': _journey!.id,
          'audioLength': _duration.inSeconds,
        },
      );
    } catch (e) {
      print('ERROR loading episode: $e');
      print('DEBUG: Failed path was: ${episode.audioUrl}');
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio file not found: ${episode.title}')),
      );
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _trackAudioAction('pause');
    } else {
      await _audioPlayer.play();
      _trackAudioAction('play');
    }
  }

  void _trackAudioAction(String action) {
    if (_currentEpisode != null && _journey != null) {
      final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
      research.trackAudioEngagement(
        episodeId: _currentEpisode!.id,
        action: action,
        position: _position.inSeconds,
        speed: _playbackSpeed,
        additionalData: {
          'journeyId': _journey!.id,
          'totalDuration': _duration.inSeconds,
        },
      );
    }
  }

  void _skipToNext() {
    if (_currentEpisodeIndex < _episodes.length - 1) {
      final nextEpisode = _episodes[_currentEpisodeIndex + 1];
      _loadEpisode(nextEpisode);
    }
  }

  void _skipToPrevious() {
    if (_currentEpisodeIndex > 0) {
      final previousEpisode = _episodes[_currentEpisodeIndex - 1];
      _loadEpisode(previousEpisode);
    }
  }
  
  void _rewind10Seconds() {
    final newPosition = Duration(seconds: (_position.inSeconds - 10).clamp(0, _duration.inSeconds));
    _audioPlayer.seek(newPosition);
    _trackAudioAction('rewind_10');
  }
  
  void _forward10Seconds() {
    final newPosition = Duration(seconds: (_position.inSeconds + 10).clamp(0, _duration.inSeconds));
    _audioPlayer.seek(newPosition);
    _trackAudioAction('forward_10');
  }

  void _changePlaybackSpeed() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentIndex = speeds.indexOf(_playbackSpeed);
    final nextIndex = (currentIndex + 1) % speeds.length;
    _playbackSpeed = speeds[nextIndex];
    _audioPlayer.setSpeed(_playbackSpeed);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _saveProgress(); // Save final position on dispose
    
    // Stop the audio player and clear any pending callbacks
    _audioPlayer.stop();
    
    // Dispose of the audio player (this cancels all streams)
    _audioPlayer.dispose();
    
    // Dispose animation controllers
    _fadeController.dispose();
    _pulseController.dispose();
    
    super.dispose();
  }
  
  // ============================================================================
  // PERSISTENCE METHODS (Critical for Production)
  // ============================================================================
  
  Future<void> _saveProgress() async {
    if (_currentEpisode == null || _journey == null) return;
    
    try {
      await ProgressPersistenceService.saveEpisodePosition(
        episodeId: _currentEpisode!.id,
        journeyId: _journey!.id,
        positionSeconds: _position.inSeconds,
        durationSeconds: _duration.inSeconds,
        timestamp: DateTime.now(),
      );
      
      await ProgressPersistenceService.saveLastPlayedEpisode(
        episodeId: _currentEpisode!.id,
        journeyId: _journey!.id,
        episodeTitle: _currentEpisode!.title,
        position: _position.inSeconds,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('Error saving progress: $e');
    }
  }
  
  Future<void> _attemptAutoResume() async {
    if (_currentEpisode == null) return;
    
    try {
      final savedPosition = await ProgressPersistenceService.getEpisodePosition(_currentEpisode!.id);
      if (savedPosition != null) {
        final positionSeconds = savedPosition['positionSeconds'] as int? ?? 0;
        final isCompleted = savedPosition['isCompleted'] as bool? ?? false;
        
        // Don't resume if episode was completed or position is too close to end
        if (!isCompleted && positionSeconds > 30) {
          await _audioPlayer.seek(Duration(seconds: positionSeconds));
          
          // Show resume notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resumed from ${_formatDuration(Duration(seconds: positionSeconds))}'),
              backgroundColor: AppColors.accentGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error resuming playback: $e');
    }
  }
  
  Future<void> _handleEpisodeCompletion() async {
    if (_currentEpisode == null || _journey == null) return;
    
    try {
      // Calculate engagement score based on interaction data
      final engagementScore = _calculateEngagementScore();
      
      // Mark episode as completed
      await ProgressPersistenceService.markEpisodeCompleted(
        episodeId: _currentEpisode!.id,
        journeyId: _journey!.id,
        listenTime: _duration,
        engagementScore: engagementScore,
        completedAt: DateTime.now(),
      );
      
      // Track completion for research
      final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
      research.markEpisodeCompleted(
        _currentEpisode!.id,
        engagementScore: engagementScore,
        listenTime: _duration,
        completedFully: true,
      );
      
      // 🔥 Check if this is the 1st episode completion and show feedback (ONCE only)
      if (_currentEpisode!.order == 1) {
        if (research.shouldShowFirstEpisodeFeedback) {
          research.markFirstEpisodeFeedbackShown();
          // Navigate to first episode feedback screen
          Navigator.pushNamed(context, '/first_episode_feedback');
          return; // Don't auto-advance if showing feedback
        }
      }

      // 🔥 Check if this is the 3rd episode completion and show feedback (ONCE only)
      if (_currentEpisode!.order == 3) {
        final hasShownThirdEpisodeFeedback = await ProgressPersistenceService.hasShownThirdEpisodeFeedback();
        if (!hasShownThirdEpisodeFeedback) {
          await ProgressPersistenceService.markThirdEpisodeFeedbackShown();
          // Navigate to third episode feedback screen
          Navigator.pushNamed(context, '/third_episode_feedback');
          return; // Don't auto-advance if showing feedback
        }
      }
      
      // Auto-advance to next episode after a brief pause
      Future.delayed(const Duration(seconds: 2), () {
        if (_currentEpisodeIndex < _episodes.length - 1) {
          _skipToNext();
        }
      });
      
    } catch (e) {
      print('Error handling episode completion: $e');
    }
  }
  
  double _calculateEngagementScore() {
    // Simple engagement calculation based on completion and seek behavior
    final completionRate = _duration.inSeconds > 0 ? _position.inSeconds / _duration.inSeconds : 0.0;
    return (completionRate * 10).clamp(0.0, 10.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _journey == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentGreen),
        ),
      );
    }

    final journey = _journey!; // Safe to use after null check

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimary,
        title: Text(journey.title),
        actions: [
          IconButton(
            icon: Icon(Icons.speed),
            onPressed: _changePlaybackSpeed,
            tooltip: '${_playbackSpeed}x',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Episode info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
              // Journey artwork - static and professional
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Color(int.parse(journey.colorHex.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(int.parse(journey.colorHex.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _getIconFromName(journey.iconName),
                  size: 80,
                  color: Colors.white,
                ),
              ),                  const SizedBox(height: 24),
                  
                  // Episode title
                  Text(
                    _currentEpisode?.title ?? 'Loading...',
                    style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Journey title
                  Text(
                    journey.title,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Progress bar
                  Column(
                    children: [
                      Slider(
                        value: _position.inMilliseconds.toDouble(),
                        max: _duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                          _trackAudioAction('seek');
                        },
                        activeColor: AppColors.accentGreen,
                        inactiveColor: AppColors.textSecondary.withOpacity(0.3),
                      ),
                      
                      // Time labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Player controls with 10-second skip buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Main controls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _currentEpisodeIndex > 0 ? _skipToPrevious : null,
                      icon: const Icon(Icons.skip_previous, size: 32),
                      color: AppColors.textPrimary,
                    ),
                    
                    IconButton(
                      onPressed: _rewind10Seconds,
                      icon: const Icon(Icons.replay_10, size: 32),
                      color: AppColors.textPrimary,
                    ),
                    
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 64,
                      ),
                      color: AppColors.accentGreen,
                    ),
                    
                    IconButton(
                      onPressed: _forward10Seconds,
                      icon: const Icon(Icons.forward_10, size: 32),
                      color: AppColors.textPrimary,
                    ),
                    
                    IconButton(
                      onPressed: _currentEpisodeIndex < _episodes.length - 1 ? _skipToNext : null,
                      icon: const Icon(Icons.skip_next, size: 32),
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                
                // Episode completion indicator
                if (_position.inSeconds > 0 && _duration.inSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      '${((_position.inSeconds / _duration.inSeconds) * 100).round()}% complete',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Episode list
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _episodes.length,
              itemBuilder: (context, index) {
                final episode = _episodes[index];
                final isActive = episode == _currentEpisode;
                
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => _loadEpisode(episode),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.accentGreen : AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: isActive ? Colors.white : AppColors.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            episode.title,
                            style: AppTextStyles.caption.copyWith(
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'code': return Icons.code;
      case 'computer': return Icons.computer;
      case 'storage': return Icons.storage;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      default: return Icons.school;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
