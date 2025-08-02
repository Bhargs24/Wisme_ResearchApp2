import '../core/research_metrics_provider.dart';
import '../models/journey_models.dart';

class SmartRecommendationsService {
  static const int _maxRecommendations = 3;

  /// Generate personalized journey recommendations based on user behavior
  static List<JourneyRecommendation> generateRecommendations({
    required ResearchMetricsProvider metricsProvider,
    required List<Journey> allJourneys,
    List<String>? completedJourneyIds,
  }) {
    final userProfile = metricsProvider.userProfile;
    final List<JourneyRecommendation> recommendations = [];

    // 1. Based on learning goals and subject familiarity
    recommendations.addAll(_getGoalBasedRecommendations(userProfile, allJourneys));

    // 2. Based on engagement patterns
    recommendations.addAll(_getEngagementBasedRecommendations(metricsProvider, allJourneys));

    // 3. Based on similar user patterns (if available)
    recommendations.addAll(_getSimilarUserRecommendations(userProfile, allJourneys));

    // Remove completed journeys and duplicates
    final filteredRecommendations = recommendations
        .where((rec) => !(completedJourneyIds?.contains(rec.journey.id) ?? false))
        .toSet()
        .toList();

    // Sort by confidence score and return top recommendations
    filteredRecommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return filteredRecommendations.take(_maxRecommendations).toList();
  }

  /// Get recommendations based on user's stated learning goals
  static List<JourneyRecommendation> _getGoalBasedRecommendations(
    Map<String, dynamic> userProfile,
    List<Journey> allJourneys,
  ) {
    final demographics = userProfile['demographics'] as Map<String, dynamic>?;
    if (demographics == null) return [];

    final learningGoals = List<String>.from(demographics['learningGoals'] ?? []);
    final subjectFamiliarity = Map<String, int>.from(demographics['subjectFamiliarity'] ?? {});

    final recommendations = <JourneyRecommendation>[];

    for (final journey in allJourneys) {
      double confidence = 0.0;
      String reason = '';

      // Match learning goals to journey topics
      if (learningGoals.any((goal) => 
          journey.title.toLowerCase().contains(goal.toLowerCase()) ||
          journey.description.toLowerCase().contains(goal.toLowerCase()))) {
        confidence += 0.8;
        reason = 'Matches your learning goal: ${learningGoals.first}';
      }

      // Consider subject familiarity
      final familiarityLevel = subjectFamiliarity[journey.title] ?? 0;
      if (familiarityLevel <= 2) { // Beginner level
        confidence += 0.6;
        reason = reason.isEmpty ? 'Perfect for beginners' : '$reason • Great starting point';
      } else if (familiarityLevel >= 4) { // Advanced level
        confidence += 0.4;
        reason = reason.isEmpty ? 'Advanced content to challenge you' : '$reason • Advanced level';
      }

      if (confidence > 0) {
        recommendations.add(JourneyRecommendation(
          journey: journey,
          confidenceScore: confidence,
          reason: reason,
          type: RecommendationType.goalBased,
        ));
      }
    }

    return recommendations;
  }

  /// Get recommendations based on user engagement patterns
  static List<JourneyRecommendation> _getEngagementBasedRecommendations(
    ResearchMetricsProvider metricsProvider,
    List<Journey> allJourneys,
  ) {
    // For demo research app: just recommend unplayed journeys
    return allJourneys.map((journey) => JourneyRecommendation(
      journey: journey,
      confidenceScore: 0.4,
      reason: 'Continue your learning journey',
      type: RecommendationType.engagementBased,
    )).take(1).toList();
  }

  /// Get recommendations based on similar users (just return unplayed journeys)
  static List<JourneyRecommendation> _getSimilarUserRecommendations(
    Map<String, dynamic> userProfile,
    List<Journey> allJourneys,
  ) {
    // For demo research app: just recommend unplayed journeys
    return allJourneys.map((journey) => JourneyRecommendation(
      journey: journey,
      confidenceScore: 0.5,
      reason: 'Available journey to explore',
      type: RecommendationType.collaborative,
    )).take(2).toList();
  }

  /// Generate trending topics based on user requests
  static List<String> getTrendingTopics(ResearchMetricsProvider metricsProvider) {
    // Demo research app: return fixed trending topics
    return [
      'Machine Learning Basics',
      'Cryptocurrency Understanding',
      'Time Management',
      'Public Speaking',
      'Data Structures Advanced',
    ];
  }

  /// Get smart continue suggestions
  static List<ContinueSuggestion> getContinueSuggestions(
    ResearchMetricsProvider metricsProvider,
    List<Journey> allJourneys,
  ) {
    final suggestions = <ContinueSuggestion>[];
    
    // This would analyze incomplete sessions and suggest optimal continue points
    // For now, create placeholder suggestions
    suggestions.add(ContinueSuggestion(
      journeyId: 'dsa',
      episodeIndex: 0,
      progressPercent: 0.0,
      lastPlayedAt: DateTime.now().subtract(const Duration(hours: 2)),
      suggestion: 'Great time to continue your DSA journey!',
    ));

    return suggestions;
  }
}

/// Data models for recommendations
class JourneyRecommendation {
  final Journey journey;
  final double confidenceScore;
  final String reason;
  final RecommendationType type;

  JourneyRecommendation({
    required this.journey,
    required this.confidenceScore,
    required this.reason,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JourneyRecommendation && other.journey.id == journey.id;
  }

  @override
  int get hashCode => journey.id.hashCode;
}

enum RecommendationType {
  goalBased,
  engagementBased,
  collaborative,
  trending,
}

class ContinueSuggestion {
  final String journeyId;
  final int episodeIndex;
  final double progressPercent;
  final DateTime lastPlayedAt;
  final String suggestion;

  ContinueSuggestion({
    required this.journeyId,
    required this.episodeIndex,
    required this.progressPercent,
    required this.lastPlayedAt,
    required this.suggestion,
  });
}
