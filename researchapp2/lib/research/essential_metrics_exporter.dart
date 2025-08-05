import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../core/firebase_service.dart';

/// 🎯 ESSENTIAL METRICS EXPORTER
/// 
/// Exports only the CRITICAL metrics needed to validate conversational learning method.
/// Focused on research validation, not comprehensive tracking.
class EssentialMetricsExporter {
  
  /// 📊 CORE VALIDATION METRICS
  /// These are the metrics that actually matter for proving your method works
  static Future<Map<String, dynamic>> getEssentialMetrics() async {
    try {
      final firestore = FirebaseService.firestore;
      
      // Get all research data
      final researchSnapshot = await firestore.collection('research_metrics').get();
      final userSnapshot = await firestore.collection('users').get();
      final progressSnapshot = await firestore.collection('user_progress').get();
      
      final researchData = researchSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      final userData = userSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      final progressData = progressSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
      
      return {
        'exportedAt': DateTime.now().toIso8601String(),
        'totalUsers': userData.length,
        
        // 🎯 1. LEARNING EFFECTIVENESS VALIDATION
        'learningEffectiveness': _calculateLearningEffectiveness(researchData),
        
        // 🎯 2. ENGAGEMENT & COMPLETION VALIDATION  
        'engagementMetrics': _calculateEngagementMetrics(researchData, progressData),
        
        // 🎯 3. COMMERCIAL VALIDATION (PMF)
        'commercialValidation': _calculateCommercialValidation(researchData),
        
        // 🎯 4. USER SATISFACTION & NPS
        'satisfactionMetrics': _calculateSatisfactionMetrics(researchData),
        
        // 🎯 5. COMPARATIVE ADVANTAGE
        'comparativeAnalysis': _calculateComparativeAnalysis(researchData),
        
        // 🎯 6. USER DEMOGRAPHICS (for segmentation)
        'demographicInsights': _calculateDemographicInsights(userData),
        
        // 📈 Raw data for detailed analysis
        'rawData': {
          'research': researchData,
          'users': userData.map((user) => {
            // Remove sensitive data but keep research-relevant info
            'age': user['demographics']?['age'],
            'education': user['demographics']?['education'],
            'occupation': user['demographics']?['occupation'],
            'learningGoals': user['demographics']?['learningGoals'],
            'subjectFamiliarity': user['baseline']?['subjectFamiliarity'],
            'signupDate': user['createdAt'],
          }).where((user) => user['age'] != null).toList(),
          'progress': progressData,
        }
      };
    } catch (e) {
      print('Error getting essential metrics: $e');
      rethrow;
    }
  }
  
  /// 🎯 1. LEARNING EFFECTIVENESS VALIDATION
  /// This is THE most important metric - does your method actually work?
  static Map<String, dynamic> _calculateLearningEffectiveness(List<Map<String, dynamic>> data) {
    final engagementData = data.where((d) => d['type'] == 'engagement_validation').toList();
    final episodeFeedback = data.where((d) => d['type'] == 'episode_feedback').toList();
    
    if (engagementData.isEmpty && episodeFeedback.isEmpty) {
      return {
        'error': 'No learning effectiveness data available',
        'sampleSize': 0
      };
    }
    
    // Calculate learning confidence improvement
    List<double> clarityRatings = [];
    List<double> confidenceRatings = [];
    List<double> effectivenessRatings = [];
    
    for (final feedback in episodeFeedback) {
      final feedbackData = feedback['data'] as Map<String, dynamic>?;
      if (feedbackData != null) {
        if (feedbackData['conceptClarity'] != null) {
          clarityRatings.add(feedbackData['conceptClarity'].toDouble());
        }
        if (feedbackData['confidenceIncrease'] != null) {
          confidenceRatings.add(feedbackData['confidenceIncrease'].toDouble());
        }
        if (feedbackData['learningEffectiveness'] != null) {
          effectivenessRatings.add(feedbackData['learningEffectiveness'].toDouble());
        }
      }
    }
    
    return {
      'sampleSize': episodeFeedback.length,
      'averageConceptClarity': _average(clarityRatings),
      'averageConfidenceIncrease': _average(confidenceRatings),
      'averageLearningEffectiveness': _average(effectivenessRatings),
      'clarityDistribution': _distribution(clarityRatings),
      'effectivenessDistribution': _distribution(effectivenessRatings),
      'percentAbove7': clarityRatings.where((r) => r >= 7.0).length / clarityRatings.length * 100,
      'percentAbove8': effectivenessRatings.where((r) => r >= 8.0).length / effectivenessRatings.length * 100,
    };
  }
  
  /// 🎯 2. ENGAGEMENT & COMPLETION VALIDATION
  /// Proves users actually engage with and complete the content
  static Map<String, dynamic> _calculateEngagementMetrics(
    List<Map<String, dynamic>> researchData,
    List<Map<String, dynamic>> progressData
  ) {
    final engagementData = researchData.where((d) => d['type'] == 'engagement_validation').toList();
    
    // Calculate completion rates
    Map<String, int> episodeCompletions = {};
    Map<String, int> journeyCompletions_map = {};
    
    for (final progress in progressData) {
      if (progress['completedEpisodes'] != null) {
        final episodes = List<String>.from(progress['completedEpisodes']);
        for (final episode in episodes) {
          episodeCompletions[episode] = (episodeCompletions[episode] ?? 0) + 1;
        }
      }
      if (progress['journeyId'] != null) {
        final journeyId = progress['journeyId'] as String;
        journeyCompletions_map[journeyId] = (journeyCompletions_map[journeyId] ?? 0) + 1;
      }
    }
    
    // Calculate engagement scores
    List<double> engagementScores = [];
    for (final engagement in engagementData) {
      final score = engagement['data']?['engagementScore'];
      if (score != null) {
        engagementScores.add(score.toDouble());
      }
    }
    
    return {
      'sampleSize': progressData.length,
      'totalEpisodeCompletions': episodeCompletions.values.fold(0, (a, b) => a + b),
      'totalJourneyCompletions': journeyCompletions_map.values.fold(0, (a, b) => a + b),
      'averageEngagementScore': _average(engagementScores),
      'completionRateByJourney': journeyCompletions_map,
      'engagementScoreDistribution': _distribution(engagementScores),
      'highEngagementPercentage': engagementScores.where((s) => s >= 8.0).length / engagementScores.length * 100,
    };
  }
  
  /// 🎯 3. COMMERCIAL VALIDATION (PMF)
  /// Critical for investor validation and business viability
  static Map<String, dynamic> _calculateCommercialValidation(List<Map<String, dynamic>> data) {
    final pmfData = data.where((d) => d['type'] == 'product_market_fit').toList();
    final pricingData = data.where((d) => d['type'] == 'pricing_feedback').toList();
    
    if (pmfData.isEmpty) {
      return {
        'error': 'No PMF data available',
        'sampleSize': 0
      };
    }
    
    // Calculate PMF Score (% "Very Disappointed")
    int veryDisappointed = 0;
    int totalPMFResponses = 0;
    List<int> npsScores = [];
    List<double> willingnessToPayAmounts = [];
    
    for (final pmf in pmfData) {
      final pmfFeedback = pmf['data'] as Map<String, dynamic>?;
      if (pmfFeedback != null) {
        // PMF disappointment level
        final disappointment = pmfFeedback['disappointmentLevel'];
        if (disappointment != null) {
          totalPMFResponses++;
          if (disappointment == 4) { // "Very disappointed"
            veryDisappointed++;
          }
        }
        
        // NPS Score
        final nps = pmfFeedback['recommendationScore'];
        if (nps != null) {
          npsScores.add(nps as int);
        }
      }
    }
    
    // Process pricing data
    for (final pricing in pricingData) {
      final pricingFeedback = pricing['data'] as Map<String, dynamic>?;
      if (pricingFeedback != null) {
        final amount = pricingFeedback['willingnessToPayMonthly'];
        if (amount != null) {
          willingnessToPayAmounts.add(amount.toDouble());
        }
      }
    }
    
    // Calculate NPS
    final promoters = npsScores.where((s) => s >= 9).length;
    final detractors = npsScores.where((s) => s <= 6).length;
    final npsScore = npsScores.isNotEmpty 
        ? ((promoters - detractors) / npsScores.length * 100).round()
        : 0;
    
    return {
      'sampleSize': totalPMFResponses,
      'pmfScore': totalPMFResponses > 0 ? (veryDisappointed / totalPMFResponses * 100) : 0,
      'npsScore': npsScore,
      'averageWillingnessToPayMonthly': _average(willingnessToPayAmounts),
      'percentWillingToPay': willingnessToPayAmounts.where((amount) => amount > 0).length / willingnessToPayAmounts.length * 100,
      'willingnessToPayDistribution': _priceDistribution(willingnessToPayAmounts),
      'npsDistribution': {
        'promoters': promoters,
        'passives': npsScores.where((s) => s == 7 || s == 8).length,
        'detractors': detractors,
      },
    };
  }
  
  /// 🎯 4. USER SATISFACTION & NPS
  static Map<String, dynamic> _calculateSatisfactionMetrics(List<Map<String, dynamic>> data) {
    final journeyFeedback = data.where((d) => d['type'] == 'journey_feedback').toList();
    final episodeFeedback = data.where((d) => d['type'] == 'episode_feedback').toList();
    
    List<double> satisfactionRatings = [];
    List<double> difficultyRatings = [];
    List<double> engagementRatings = [];
    
    // Journey-level satisfaction
    for (final feedback in journeyFeedback) {
      final data = feedback['data'] as Map<String, dynamic>?;
      if (data != null) {
        if (data['overallSatisfaction'] != null) {
          satisfactionRatings.add(data['overallSatisfaction'].toDouble());
        }
      }
    }
    
    // Episode-level feedback
    for (final feedback in episodeFeedback) {
      final data = feedback['data'] as Map<String, dynamic>?;
      if (data != null) {
        if (data['satisfaction'] != null) {
          satisfactionRatings.add(data['satisfaction'].toDouble());
        }
        if (data['difficulty'] != null) {
          difficultyRatings.add(data['difficulty'].toDouble());
        }
        if (data['engagement'] != null) {
          engagementRatings.add(data['engagement'].toDouble());
        }
      }
    }
    
    return {
      'sampleSize': satisfactionRatings.length,
      'averageSatisfaction': _average(satisfactionRatings),
      'averageDifficulty': _average(difficultyRatings),
      'averageEngagement': _average(engagementRatings),
      'highSatisfactionPercentage': satisfactionRatings.where((r) => r >= 8.0).length / satisfactionRatings.length * 100,
      'satisfactionDistribution': _distribution(satisfactionRatings),
    };
  }
  
  /// 🎯 5. COMPARATIVE ADVANTAGE
  static Map<String, dynamic> _calculateComparativeAnalysis(List<Map<String, dynamic>> data) {
    final comparisonData = data.where((d) => d['type'] == 'learning_method_comparison').toList();
    
    if (comparisonData.isEmpty) {
      return {
        'error': 'No comparison data available',
        'sampleSize': 0
      };
    }
    
    int preferConversational = 0;
    int preferTraditional = 0;
    List<double> wismeVsCompetitorRatings = [];
    
    for (final comparison in comparisonData) {
      final data = comparison['data'] as Map<String, dynamic>?;
      if (data != null) {
        final preference = data['preferredMethod'];
        if (preference == 'conversational') {
          preferConversational++;
        } else if (preference == 'traditional') {
          preferTraditional++;
        }
        
        final rating = data['wismeVsCompetitorRating'];
        if (rating != null) {
          wismeVsCompetitorRatings.add(rating.toDouble());
        }
      }
    }
    
    return {
      'sampleSize': comparisonData.length,
      'conversationalPreferencePercentage': (preferConversational / (preferConversational + preferTraditional) * 100),
      'averageWismeVsCompetitorRating': _average(wismeVsCompetitorRatings),
      'percentPreferWisme': wismeVsCompetitorRatings.where((r) => r > 5.0).length / wismeVsCompetitorRatings.length * 100,
    };
  }
  
  /// 🎯 6. USER DEMOGRAPHICS (for research segmentation)
  static Map<String, dynamic> _calculateDemographicInsights(List<Map<String, dynamic>> userData) {
    Map<String, int> ageGroups = {};
    Map<String, int> educationLevels = {};
    Map<String, int> occupations = {};
    Map<String, int> learningGoals = {};
    
    for (final user in userData) {
      // Age groups
      final age = user['demographics']?['age'];
      if (age != null) {
        String ageGroup;
        if (age < 25) ageGroup = '18-24';
        else if (age < 35) ageGroup = '25-34';
        else if (age < 45) ageGroup = '35-44';
        else ageGroup = '45+';
        ageGroups[ageGroup] = (ageGroups[ageGroup] ?? 0) + 1;
      }
      
      // Education
      final education = user['demographics']?['education'];
      if (education != null) {
        educationLevels[education] = (educationLevels[education] ?? 0) + 1;
      }
      
      // Occupation
      final occupation = user['demographics']?['occupation'];
      if (occupation != null) {
        occupations[occupation] = (occupations[occupation] ?? 0) + 1;
      }
      
      // Learning goals
      final goals = user['demographics']?['learningGoals'];
      if (goals != null && goals is List) {
        for (final goal in goals) {
          learningGoals[goal] = (learningGoals[goal] ?? 0) + 1;
        }
      }
    }
    
    return {
      'totalUsers': userData.length,
      'ageDistribution': ageGroups,
      'educationDistribution': educationLevels,
      'occupationDistribution': occupations,
      'learningGoalsDistribution': learningGoals,
    };
  }
  
  /// 📁 EXPORT TO CSV/JSON
  static Future<String> exportToCSV() async {
    final metrics = await getEssentialMetrics();
    
    // Create CSV content
    final csvContent = StringBuffer();
    csvContent.writeln('Metric Category,Metric Name,Value,Sample Size');
    
    // Learning Effectiveness
    final learning = metrics['learningEffectiveness'] as Map<String, dynamic>;
    csvContent.writeln('Learning Effectiveness,Average Concept Clarity,${learning['averageConceptClarity']},${learning['sampleSize']}');
    csvContent.writeln('Learning Effectiveness,Average Learning Effectiveness,${learning['averageLearningEffectiveness']},${learning['sampleSize']}');
    csvContent.writeln('Learning Effectiveness,Percent Above 7 (Clarity),${learning['percentAbove7']},${learning['sampleSize']}');
    
    // Commercial Validation
    final commercial = metrics['commercialValidation'] as Map<String, dynamic>;
    csvContent.writeln('Commercial Validation,PMF Score,${commercial['pmfScore']},${commercial['sampleSize']}');
    csvContent.writeln('Commercial Validation,NPS Score,${commercial['npsScore']},${commercial['sampleSize']}');
    csvContent.writeln('Commercial Validation,Average Willingness to Pay,${commercial['averageWillingnessToPayMonthly']},${commercial['sampleSize']}');
    
    // Engagement
    final engagement = metrics['engagementMetrics'] as Map<String, dynamic>;
    csvContent.writeln('Engagement,Average Engagement Score,${engagement['averageEngagementScore']},${engagement['sampleSize']}');
    csvContent.writeln('Engagement,High Engagement Percentage,${engagement['highEngagementPercentage']},${engagement['sampleSize']}');
    
    return csvContent.toString();
  }
  
  /// Save to file
  static Future<String> saveToFile() async {
    final metrics = await getEssentialMetrics();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/wisme_essential_metrics_$timestamp.json';
    
    final file = File(filePath);
    await file.writeAsString(jsonEncode(metrics));
    
    return filePath;
  }
  
  // Helper functions
  static double _average(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  static Map<String, int> _distribution(List<double> values) {
    Map<String, int> dist = {};
    for (final value in values) {
      final range = '${(value.floor())}-${(value.floor() + 1)}';
      dist[range] = (dist[range] ?? 0) + 1;
    }
    return dist;
  }
  
  static Map<String, int> _priceDistribution(List<double> amounts) {
    Map<String, int> dist = {
      '\$0': 0,
      '\$1-5': 0,
      '\$6-10': 0,
      '\$11-20': 0,
      '\$21+': 0,
    };
    
    for (final amount in amounts) {
      if (amount == 0) dist['\$0'] = dist['\$0']! + 1;
      else if (amount <= 5) dist['\$1-5'] = dist['\$1-5']! + 1;
      else if (amount <= 10) dist['\$6-10'] = dist['\$6-10']! + 1;
      else if (amount <= 20) dist['\$11-20'] = dist['\$11-20']! + 1;
      else dist['\$21+'] = dist['\$21+']! + 1;
    }
    
    return dist;
  }
}
