import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/journey_models.dart';

class AudioManifestService {
  static Map<String, dynamic>? _manifestData;
  
  static Future<void> _loadManifest() async {
    if (_manifestData != null) return;
    
    try {
      final String manifestContent = await rootBundle.loadString('assets/audio/journeys/audio_manifest.json');
      _manifestData = json.decode(manifestContent);
    } catch (e) {
      print('Error loading audio manifest: $e');
      _manifestData = {};
    }
  }
  
  static Future<List<Journey>> getJourneys() async {
    await _loadManifest();
    
    if (_manifestData == null || !_manifestData!.containsKey('journeys')) {
      return [];
    }
    
    final journeys = <Journey>[];
    final journeysData = _manifestData!['journeys'] as Map<String, dynamic>;
    
    journeysData.forEach((journeyId, journeyData) {
      final episodes = journeyData['episodes'] as List? ?? [];
      final episodeIds = episodes.map((ep) => ep['id'] as String? ?? '').toList();
      
      final journey = Journey(
        id: journeyId,
        title: journeyData['title'] ?? '',
        description: journeyData['description'] ?? '',
        category: journeyData['category'] ?? '',
        episodeIds: episodeIds,
        totalDuration: _calculateTotalDuration(episodes),
        iconName: _getIconForCategory(journeyData['category'] ?? ''),
        colorHex: _getColorForCategory(journeyData['category'] ?? ''),
      );
      journeys.add(journey);
    });
    
    return journeys;
  }
  
  static Future<List<Episode>> getEpisodesByJourneyId(String journeyId) async {
    await _loadManifest();
    
    if (_manifestData == null || !_manifestData!.containsKey('journeys')) {
      return [];
    }
    
    final journeysData = _manifestData!['journeys'] as Map<String, dynamic>;
    final journeyData = journeysData[journeyId];
    
    if (journeyData == null || !journeyData.containsKey('episodes')) {
      return [];
    }
    
    final episodes = <Episode>[];
    final episodesData = journeyData['episodes'] as List;
    
    for (int i = 0; i < episodesData.length; i++) {
      final episodeData = episodesData[i];
      final episode = Episode(
        id: episodeData['id'] ?? '',
        journeyId: journeyId,
        title: episodeData['title'] ?? '',
        description: episodeData['description'] ?? '',
        audioUrl: episodeData['audioPath'] ?? '',
        duration: _parseDuration(episodeData['duration'] ?? '0:00'),
        order: i + 1,
        transcript: '', // Will be loaded separately if needed
        keyPoints: List<String>.from(episodeData['topics'] ?? []),
      );
      episodes.add(episode);
    }
    
    return episodes;
  }
  
  static int _calculateTotalDuration(List? episodes) {
    if (episodes == null) return 0;
    
    int total = 0;
    for (final episode in episodes) {
      total += _parseDuration(episode['duration'] ?? '0:00');
    }
    return total;
  }
  
  static int _parseDuration(String duration) {
    try {
      final parts = duration.split(':');
      if (parts.length == 2) {
        final minutes = int.parse(parts[0]);
        final seconds = int.parse(parts[1]);
        return minutes * 60 + seconds;
      }
    } catch (e) {
      print('Error parsing duration: $duration');
    }
    return 0;
  }
  
  static Future<Episode?> getEpisodeById(String episodeId) async {
    final journeys = await getJourneys();
    
    for (final journey in journeys) {
      final episodes = await getEpisodesByJourneyId(journey.id);
      for (final episode in episodes) {
        if (episode.id == episodeId) {
          return episode;
        }
      }
    }
    
    return null;
  }
  
  static String _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'computer science':
        return 'code';
      case 'psychology':
        return 'psychology';
      case 'science':
        return 'science';
      case 'life skills':
        return 'money';
      default:
        return 'school';
    }
  }
  
  static String _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'computer science':
        return '#2196F3';
      case 'psychology':
        return '#9C27B0';
      case 'science':
        return '#FF9800';
      case 'life skills':
        return '#4CAF50';
      default:
        return '#607D8B';
    }
  }
}
