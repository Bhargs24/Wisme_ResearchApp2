import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'firebase_service.dart';

class ResearchMetricsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _userId;
  Map<String, dynamic> _userProfile = {};
  Map<String, dynamic> _currentSession = {};
  List<Map<String, dynamic>> _completedJourneys = [];
  Map<String, double> _engagementScores = {};
  int _episodeCount = 0;
  int _journeyCount = 0;
  bool _hasShownFirstEpisodeFeedback = false;
  bool _hasShownThirdEpisodeFeedback = false;
  bool _hasShownFirstJourneyCompletion = false;
  bool _hasShownMultipleJourneyComparison = false;
  
  // Getters
  String? get userId => _userId;
  Map<String, dynamic> get userProfile => _userProfile;
  List<Map<String, dynamic>> get completedJourneys => _completedJourneys;
  
  // Progressive Research State Getters
  int get episodeCount => _episodeCount;
  int get journeyCount => _journeyCount;
  double get averageSessionTime => _getAverageSessionTime();
  bool get shouldShowFirstEpisodeFeedback => _episodeCount == 1 && !_hasShownFirstEpisodeFeedback;
  bool get shouldShowThirdEpisodeFeedback => _episodeCount == 3 && !_hasShownThirdEpisodeFeedback;
  bool get shouldShowFirstJourneyCompletion => _journeyCount == 1 && !_hasShownFirstJourneyCompletion;
  bool get shouldShowMultipleJourneyComparison => _journeyCount >= 2 && !_hasShownMultipleJourneyComparison;
  
  // User Profile Helper Getters
  String get userDisplayName => _userProfile['profile']?['displayName'] ?? 'User';
  String get userFirstName => _userProfile['profile']?['firstName'] ?? '';
  String get userFullName => _userProfile['profile']?['fullName'] ?? '';
  int get userAge => _userProfile['demographics']?['age'] ?? 0;
  String get userEducation => _userProfile['demographics']?['education'] ?? '';
  String get userOccupation => _userProfile['demographics']?['occupation'] ?? '';
  List<String> get userLearningGoals => List<String>.from(_userProfile['demographics']?['learningGoals'] ?? []);
  Map<String, int> get userSubjectFamiliarity => Map<String, int>.from(_userProfile['baseline']?['subjectFamiliarity'] ?? {});

  // CRITICAL: Profile completion status checks
  bool get hasCompletedDemographics => _userProfile['demographics'] != null;
  bool get hasCompletedBaseline => _userProfile['baseline'] != null;
  bool get hasName => _userProfile['profile']?['firstName'] != null;
  bool get isOnboardingComplete => hasCompletedDemographics && hasCompletedBaseline;

  void setUserId(String uid) {
    _userId = uid;
    _initializeSession();
    
    // FIXED: Load existing user profile from Firebase asynchronously
    _loadUserProfileAsync();
    
    notifyListeners();
  }

  // Separate async method to avoid blocking
  Future<void> _loadUserProfileAsync() async {
    try {
      await _loadUserProfile();
      notifyListeners(); // Notify after profile is loaded
    } catch (e) {
      print('❌ Failed to load user profile async: $e');
    }
  }

  void _initializeSession() {
    _currentSession = {
      'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
      'startTime': DateTime.now().toIso8601String(),
      'interactions': [],
      'engagementEvents': [],
    };
  }

  // MISSING CRITICAL METHOD: Load user profile from Firebase
  Future<void> _loadUserProfile() async {
    if (_userId == null) return;
    
    try {
      final userDoc = await FirebaseService.getUserProfile(_userId!);
      if (userDoc != null && userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          // Load the complete user profile from Firebase
          _userProfile = Map<String, dynamic>.from(data);
          print('✅ User profile loaded from Firebase: ${_userProfile.keys}');
        }
      }
    } catch (e) {
      print('❌ Failed to load user profile: $e');
    }
  }

  // ============================================================================
  // STRATEGIC RESEARCH DATA COLLECTION
  // ============================================================================

  // PHASE 1: DEMOGRAPHIC & BASELINE (Non-boring, integrated into onboarding)
  void captureUserDemographics({
    required int age,
    required String education,
    required String occupation,
    required List<String> learningGoals,
    required Map<String, int> subjectFamiliarity,
  }) {
    _userProfile.addAll({
      'demographics': {
        'age': age,
        'education': education,
        'occupation': occupation,
        'learningGoals': learningGoals,
        'capturedAt': DateTime.now().toIso8601String(),
      },
      'baseline': {
        'subjectFamiliarity': subjectFamiliarity,
        'overallLearningExperience': 0, // Will be set during onboarding
      }
    });
    _saveUserProfile();
    notifyListeners();
  }

  // Store user name for personalization
  void storeUserName({
    required String firstName,
    String lastName = '',
  }) {
    _userProfile['profile'] = {
      'firstName': firstName,
      'lastName': lastName,
      'displayName': '$firstName ${lastName.isNotEmpty ? lastName[0] : ''}',
      'fullName': '$firstName $lastName'.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    _saveUserProfile();
    notifyListeners();
  }

  // COMPLETE USER PROFILE (Including name for personalization)
  Future<void> captureUserProfile({
    required String firstName,
    required String lastName,
    required int age,
    required String education,
    required String occupation,
    required List<String> learningGoals,
    required Map<String, int> subjectFamiliarity,
  }) async {
    _userProfile.addAll({
      'profile': {
        'firstName': firstName,
        'lastName': lastName,
        'displayName': '$firstName ${lastName.isNotEmpty ? lastName[0] : ''}',
        'fullName': '$firstName $lastName'.trim(),
      },
      'demographics': {
        'age': age,
        'education': education,
        'occupation': occupation,
        'learningGoals': learningGoals,
        'capturedAt': DateTime.now().toIso8601String(),
      },
      'baseline': {
        'subjectFamiliarity': subjectFamiliarity,
        'overallLearningExperience': 0,
      }
    });
    _saveUserProfile();
    notifyListeners();
  }

  // Journey interest tracking (called when user browses/selects journeys)
  void captureJourneyInterest({
    required String journeyId,
    required double interestLevel,
    required DateTime selectionTime,
  }) {
    final interest = {
      'timestamp': selectionTime.toIso8601String(),
      'journeyId': journeyId,
      'interestLevel': interestLevel,
      'sessionId': _currentSession['sessionId'],
    };
    
    FirebaseService.submitFeedback({
      'type': 'journey_interest',
      'userId': _userId,
      'data': interest,
    });
  }

  // PHASE 2: REAL-TIME ENGAGEMENT TRACKING (Invisible, automatic)
  void trackAudioEngagement({
    required String episodeId,
    required String action, // play, pause, seek, complete
    required int position,
    required double speed,
    Map<String, dynamic>? additionalData,
  }) {
    final engagement = {
      'timestamp': DateTime.now().toIso8601String(),
      'episodeId': episodeId,
      'action': action,
      'position': position,
      'speed': speed,
      'sessionTime': DateTime.now().difference(
        DateTime.parse(_currentSession['startTime'])
      ).inSeconds,
      ...?additionalData,
    };
    
    _currentSession['interactions'].add(engagement);
    
    // Calculate engagement score in real-time
    _updateEngagementScore(episodeId);
    
    // Auto-save every 10 interactions
    if (_currentSession['interactions'].length % 10 == 0) {
      _saveSessionData();
    }
  }

  void _updateEngagementScore(String episodeId) {
    final episodeInteractions = _currentSession['interactions']
        .where((i) => i['episodeId'] == episodeId)
        .toList();
    
    if (episodeInteractions.isEmpty) return;
    
    // Proprietary engagement algorithm for investor validation
    double score = 0.0;
    int totalTime = 0;
    int pauseCount = 0;
    int seekCount = 0;
    
    for (var interaction in episodeInteractions) {
      switch (interaction['action']) {
        case 'play':
          score += 1.0;
          break;
        case 'pause':
          pauseCount++;
          if (pauseCount > 5) score -= 0.2; // Too many pauses = distraction
          break;
        case 'seek':
          seekCount++;
          if (seekCount > 3) score -= 0.1; // Too much seeking = confusion
          break;
        case 'complete':
          score += 5.0; // Big bonus for completion
          break;
        case 'replay':
          score += 2.0; // Replay indicates high engagement
          break;
      }
      totalTime = interaction['sessionTime'];
    }
    
    // Normalize and store
    final normalizedScore = (score / (totalTime / 60)).clamp(0.0, 10.0);
    _engagementScores[episodeId] = normalizedScore;
  }

  // PHASE 3: MICRO-FEEDBACK (Smart, contextual, non-intrusive)
  void captureMicroFeedback({
    required String episodeId,
    required String trigger, // end_episode, high_engagement, confusion_detected
    required Map<String, dynamic> feedback,
  }) {
    final microFeedback = {
      'timestamp': DateTime.now().toIso8601String(),
      'episodeId': episodeId,
      'trigger': trigger,
      'feedback': feedback,
      'engagementScore': _engagementScores[episodeId] ?? 0.0,
    };
    
    FirebaseService.submitFeedback({
      'type': 'micro_feedback',
      'userId': _userId,
      'data': microFeedback,
    });
  }

  // PHASE 4: COMPARATIVE ANALYSIS (Journey-to-journey comparison)
  void captureJourneyCompletion({
    required String journeyId,
    required String method, // 'conversational' or 'traditional'
    required Duration totalTime,
    required List<String> completedEpisodes,
    required double overallSatisfaction,
    required Map<String, double> skillConfidence,
  }) {
    final journeyData = {
      'journeyId': journeyId,
      'method': method,
      'completedAt': DateTime.now().toIso8601String(),
      'totalTime': totalTime.inSeconds,
      'completedEpisodes': completedEpisodes,
      'overallSatisfaction': overallSatisfaction,
      'skillConfidence': skillConfidence,
      'engagementScores': _engagementScores.entries
          .where((e) => e.key.startsWith(journeyId))
          .map((e) => {'episodeId': e.key, 'score': e.value})
          .toList(),
    };
    
    _completedJourneys.add(journeyData);
    _journeyCount++;
    _saveJourneyData(journeyData);
    notifyListeners();
  }

  // PHASE 5: COMMERCIAL VALIDATION (Strategic, post-experience)
  void captureCommercialIntent({
    required double willingnessToPayMonthly,
    required double perceivedValue,
    required List<String> preferredFeatures,
    required double recommendationScore,
    required Map<String, double> competitiveComparison,
  }) {
    final commercial = {
      'timestamp': DateTime.now().toIso8601String(),
      'willingnessToPayMonthly': willingnessToPayMonthly,
      'perceivedValue': perceivedValue,
      'preferredFeatures': preferredFeatures,
      'npsScore': recommendationScore,
      'competitiveComparison': competitiveComparison,
      'totalJourneysCompleted': _completedJourneys.length,
      'avgEngagementScore': _getAverageEngagementScore(),
    };
    
    FirebaseService.submitFeedback({
      'type': 'commercial_validation',
      'userId': _userId,
      'data': commercial,
    });
  }

  // ============================================================================
  // PROGRESSIVE FEEDBACK SYSTEM (STRATEGIC TIMING)
  // ============================================================================

  // Track episode completion and trigger strategic feedback
  void markEpisodeCompleted(String episodeId, {
    required double engagementScore,
    required Duration listenTime,
    required bool completedFully,
  }) {
    _episodeCount++;
    
    // Store episode completion data
    final episodeData = {
      'episodeId': episodeId,
      'completedAt': DateTime.now().toIso8601String(),
      'engagementScore': engagementScore,
      'listenTime': listenTime.inSeconds,
      'completedFully': completedFully,
      'episodeNumber': _episodeCount,
    };
    
    _saveEpisodeCompletion(episodeData);
    notifyListeners();
  }

  // Mark feedback as shown to prevent duplicate presentations
  void markFirstEpisodeFeedbackShown() {
    _hasShownFirstEpisodeFeedback = true;
    notifyListeners();
  }

  void markThirdEpisodeFeedbackShown() {
    _hasShownThirdEpisodeFeedback = true;
    notifyListeners();
  }

  void markFirstJourneyCompletionShown() {
    _hasShownFirstJourneyCompletion = true;
    notifyListeners();
  }

  void markMultipleJourneyComparisonShown() {
    _hasShownMultipleJourneyComparison = true;
    notifyListeners();
  }

  // Commercial validation research questions (asked at optimal moments)
  void captureFeatureInterest({
    required Map<String, double> featureInterest,
    required List<String> priorityFeatures,
    required String triggerContext, // 'first_episode', 'third_episode', 'journey_complete', etc.
  }) {
    final featureData = {
      'timestamp': DateTime.now().toIso8601String(),
      'featureInterest': featureInterest,
      'priorityFeatures': priorityFeatures,
      'triggerContext': triggerContext,
      'userJourneyStage': {
        'episodeCount': _episodeCount,
        'journeyCount': _journeyCount,
      },
    };
    
    FirebaseService.submitFeedback({
      'type': 'feature_interest',
      'userId': _userId,
      'data': featureData,
    });
  }

  void capturePainPointValidation({
    required Map<String, int> painPointSeverity,
    required List<String> currentSolutions,
    required double problemFrequency,
    required String triggerContext,
  }) {
    final painPointData = {
      'timestamp': DateTime.now().toIso8601String(),
      'painPointSeverity': painPointSeverity,
      'currentSolutions': currentSolutions,
      'problemFrequency': problemFrequency,
      'triggerContext': triggerContext,
      'userJourneyStage': {
        'episodeCount': _episodeCount,
        'journeyCount': _journeyCount,
      },
    };
    
    FirebaseService.submitFeedback({
      'type': 'pain_point_validation',
      'userId': _userId,
      'data': painPointData,
    });
  }

  void captureProductMarketFit({
    required double productSatisfaction,
    required double howDisappointedIfGone, // Sean Ellis PMF metric
    required List<String> primaryBenefits,
    required List<String> improvementSuggestions,
    required String triggerContext,
  }) {
    final pmfData = {
      'timestamp': DateTime.now().toIso8601String(),
      'productSatisfaction': productSatisfaction,
      'disappointmentScore': howDisappointedIfGone,
      'primaryBenefits': primaryBenefits,
      'improvementSuggestions': improvementSuggestions,
      'triggerContext': triggerContext,
      'seanEllisScore': howDisappointedIfGone >= 7.0 ? 'strong_pmf' : 'needs_work',
      'userJourneyStage': {
        'episodeCount': _episodeCount,
        'journeyCount': _journeyCount,
      },
    };
    
    FirebaseService.submitFeedback({
      'type': 'product_market_fit',
      'userId': _userId,
      'data': pmfData,
    });
  }

  // ============================================================================
  // INVESTOR-CRITICAL METRICS CALCULATION
  // ============================================================================

  double _getAverageEngagementScore() {
    if (_engagementScores.isEmpty) return 0.0;
    return _engagementScores.values.reduce((a, b) => a + b) / _engagementScores.length;
  }

  double _getAverageSessionTime() {
    if (_currentSession['interactions'] == null) return 0.0;
    final interactions = _currentSession['interactions'] as List;
    if (interactions.isEmpty) return 0.0;
    
    double totalTime = 0.0;
    for (var interaction in interactions) {
      if (interaction['sessionTime'] != null) {
        totalTime += interaction['sessionTime'];
      }
    }
    return interactions.isNotEmpty ? totalTime / interactions.length : 0.0;
  }

  Map<String, dynamic> getInvestorMetrics() {
    return {
      'userProfile': _userProfile,
      'totalJourneys': _completedJourneys.length,
      'avgEngagementScore': _getAverageEngagementScore(),
      'completionRate': _calculateCompletionRate(),
      'retentionIndicators': _calculateRetentionIndicators(),
      'commercialViability': _calculateCommercialViability(),
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  double _calculateCompletionRate() {
    if (_completedJourneys.isEmpty) return 0.0;
    
    int totalEpisodes = 0;
    int completedEpisodes = 0;
    
    for (var journey in _completedJourneys) {
      final episodes = journey['completedEpisodes'] as List<String>;
      completedEpisodes += episodes.length;
      
      // Assume each journey has these episode counts based on documentation
      switch (journey['journeyId']) {
        case 'dsa': totalEpisodes += 5; break;
        case 'os': totalEpisodes += 6; break;
        case 'dbms': totalEpisodes += 7; break;
        case 'finance': totalEpisodes += 6; break;
      }
    }
    
    return totalEpisodes > 0 ? (completedEpisodes / totalEpisodes) : 0.0;
  }

  Map<String, dynamic> _calculateRetentionIndicators() {
    if (_completedJourneys.isEmpty) return {};
    
    final journeyTimes = _completedJourneys.map((j) => 
      DateTime.parse(j['completedAt'])).toList()..sort();
    
    return {
      'sessionConsistency': _calculateSessionConsistency(),
      'journeySpacing': _calculateJourneySpacing(journeyTimes),
      'engagementTrend': _calculateEngagementTrend(),
    };
  }

  double _calculateSessionConsistency() {
    if (_currentSession['interactions'] == null) return 0.0;
    final interactions = _currentSession['interactions'] as List;
    if (interactions.length < 2) return 0.0;
    
    // Calculate consistency based on interaction patterns
    List<int> sessionTimes = [];
    for (var interaction in interactions) {
      if (interaction['sessionTime'] != null) {
        sessionTimes.add(interaction['sessionTime'] as int);
      }
    }
    
    if (sessionTimes.length < 2) return 0.0;
    
    // Calculate coefficient of variation (lower = more consistent)
    double mean = sessionTimes.reduce((a, b) => a + b) / sessionTimes.length;
    double variance = sessionTimes.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / sessionTimes.length;
    double stdDev = sqrt(variance);
    double cv = stdDev / mean;
    
    // Convert to consistency score (0-1, higher = more consistent)
    return (1.0 - cv.clamp(0.0, 1.0)).clamp(0.0, 1.0);
  }

  double _calculateJourneySpacing(List<DateTime> times) {
    if (times.length < 2) return 0.0;
    
    // Calculate time intervals between journeys
    List<Duration> intervals = [];
    for (int i = 1; i < times.length; i++) {
      intervals.add(times[i].difference(times[i-1]));
    }
    
    // Calculate average interval in days
    double avgIntervalDays = intervals.map((d) => d.inDays).reduce((a, b) => a + b) / intervals.length;
    
    // Optimal spacing is 3-7 days (based on learning research)
    // Score based on how close to optimal
    if (avgIntervalDays >= 3 && avgIntervalDays <= 7) {
      return 1.0; // Perfect spacing
    } else if (avgIntervalDays < 3) {
      return (avgIntervalDays / 3.0).clamp(0.0, 1.0); // Too frequent
    } else {
      return (7.0 / avgIntervalDays).clamp(0.0, 1.0); // Too infrequent
    }
  }

  double _calculateEngagementTrend() {
    if (_engagementScores.isEmpty) return 0.0;
    
    final scores = _engagementScores.values.toList();
    if (scores.length < 2) return scores.isNotEmpty ? scores.first / 10.0 : 0.0;
    
    // Calculate trend using linear regression
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int n = scores.length;
    
    for (int i = 0; i < n; i++) {
      double x = i.toDouble();
      double y = scores[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    // Calculate slope (trend)
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Normalize slope to 0-1 range
    // Positive slope = improving engagement, negative = declining
    return (slope + 1.0).clamp(0.0, 1.0);
  }

  Map<String, dynamic> _calculateCommercialViability() {
    // Calculate based on actual submitted commercial validation data
    return {
      'estimatedLTV': _calculateEstimatedLTV(),
      'conversionProbability': _calculateConversionProbability(),
      'priceAcceptance': _calculatePriceAcceptance(),
      'marketSizeIndicator': _calculateMarketSizeIndicator(),
    };
  }

  double _calculateEstimatedLTV() {
    // Base LTV calculation on user engagement and journey completion
    double baseLTV = 0.0;
    
    if (_completedJourneys.isNotEmpty) {
      double avgEngagement = _getAverageEngagementScore();
      double completionRate = _calculateCompletionRate();
      int totalEpisodes = _episodeCount;
      
      // LTV formula based on engagement and usage
      // High engagement + completion = higher willingness to pay
      baseLTV = (avgEngagement * 100) + // Base value from engagement (0-1000)
                (completionRate * 500) + // Completion bonus (0-500)
                (totalEpisodes * 50); // Episode value (50 per episode)
      
      // Apply retention multiplier based on journey spacing
      if (_completedJourneys.length > 1) {
        final journeyTimes = _completedJourneys.map((j) => 
          DateTime.parse(j['completedAt'])).toList()..sort();
        double spacingScore = _calculateJourneySpacing(journeyTimes);
        baseLTV *= (1.0 + spacingScore); // Up to 2x multiplier for good spacing
      }
    }
    
    return baseLTV.clamp(0.0, 1500.0); // Cap at ₹1,500 - realistic pricing for Indian market
  }

  double _calculateConversionProbability() {
    if (_episodeCount == 0) return 0.0;
    
    // Factors that indicate conversion likelihood
    double probability = 0.0;
    
    // Episode completion rate (max 0.4)
    if (_episodeCount > 0) {
      double episodeEngagement = _getAverageEngagementScore() / 10.0;
      probability += episodeEngagement * 0.4;
    }
    
    // Journey completion bonus (max 0.3)
    if (_completedJourneys.isNotEmpty) {
      double journeyCompletionRate = _completedJourneys.length / (_episodeCount / 5.0).ceil();
      probability += journeyCompletionRate.clamp(0.0, 1.0) * 0.3;
    }
    
    // Session consistency bonus (max 0.2)
    probability += _calculateSessionConsistency() * 0.2;
    
    // Engagement trend bonus (max 0.1)
    probability += (_calculateEngagementTrend() - 0.5) * 0.2; // Only positive trends add value
    
    return probability.clamp(0.0, 1.0);
  }

  Map<String, double> _calculatePriceAcceptance() {
    double conversionProb = _calculateConversionProbability();
    double avgEngagement = _getAverageEngagementScore() / 10.0;
    int completedJourneys = _completedJourneys.length;
    
    // Price acceptance based on value demonstrated
    Map<String, double> priceAcceptance = {};
    
    // Base acceptance rates by price tier - Realistic Indian market pricing
    double baseAcceptance = (conversionProb + avgEngagement) / 2.0;
    
    priceAcceptance['₹299'] = (baseAcceptance * 0.9).clamp(0.0, 1.0);
    priceAcceptance['₹399'] = (baseAcceptance * 0.8).clamp(0.0, 1.0);
    priceAcceptance['₹499'] = (baseAcceptance * 0.6).clamp(0.0, 1.0);
    priceAcceptance['₹599'] = (baseAcceptance * 0.4).clamp(0.0, 1.0);
    
    // Journey completion bonus
    if (completedJourneys > 0) {
      double bonus = (completedJourneys * 0.1).clamp(0.0, 0.3);
      priceAcceptance.updateAll((key, value) => (value + bonus).clamp(0.0, 1.0));
    }
    
    return priceAcceptance;
  }

  double _calculateMarketSizeIndicator() {
    // Based on user demographics and engagement patterns
    double marketIndicator = 0.0;
    
    // Age-based market size (18-35 = larger market)
    int age = userAge;
    if (age >= 18 && age <= 35) {
      marketIndicator += 0.3;
    } else if (age >= 36 && age <= 45) {
      marketIndicator += 0.2;
    } else {
      marketIndicator += 0.1;
    }
    
    // Education-based market (higher education = larger market)
    String education = userEducation.toLowerCase();
    if (education.contains('engineer') || education.contains('graduate') || education.contains('master')) {
      marketIndicator += 0.3;
    } else if (education.contains('bachelor') || education.contains('college')) {
      marketIndicator += 0.2;
    } else {
      marketIndicator += 0.1;
    }
    
    // Engagement-based expansion (high engagement = viral potential)
    double avgEngagement = _getAverageEngagementScore() / 10.0;
    marketIndicator += avgEngagement * 0.4;
    
    return marketIndicator.clamp(0.0, 1.0);
  }

  // ============================================================================
  // DATA PERSISTENCE
  // ============================================================================

  void _saveUserProfile() {
    if (_userId != null) {
      FirebaseService.createOrUpdateUserProfile(_userId!, _userProfile);
    }
  }

  void _saveSessionData() {
    if (_userId != null) {
      FirebaseService.firestore
          .collection('research_sessions')
          .doc('${_userId}_${_currentSession['sessionId']}')
          .set(_currentSession, SetOptions(merge: true));
    }
  }

  void _saveJourneyData(Map<String, dynamic> journeyData) {
    if (_userId != null) {
      FirebaseService.firestore
          .collection('completed_journeys')
          .add({
        'userId': _userId,
        ...journeyData,
      });
    }
  }

  void _saveEpisodeCompletion(Map<String, dynamic> episodeData) {
    if (_userId != null) {
      FirebaseService.firestore
          .collection('episode_completions')
          .add({
        'userId': _userId,
        ...episodeData,
      });
    }
  }

  // Topic suggestion tracking for community features
  void captureTopicSuggestion({
    required String topic,
    required String category,
    String? reason,
  }) {
    final suggestionData = {
      'topic': topic,
      'category': category,
      'reason': reason,
      'userId': _userId,
      'timestamp': DateTime.now().toIso8601String(),
      'userProfile': _userProfile,
    };

    // Add to current session
    _currentSession['interactions'] = _currentSession['interactions'] ?? [];
    _currentSession['interactions'].add({
      'type': 'topic_suggestion',
      'data': suggestionData,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Save to Firebase for community feature
    _saveTopicSuggestion(suggestionData);
    _saveSessionData();
    notifyListeners();
  }

  void _saveTopicSuggestion(Map<String, dynamic> suggestionData) {
    if (_userId != null) {
      FirebaseService.firestore
          .collection('topic_suggestions')
          .add(suggestionData);
    }
  }

  // Export all research data for analysis
  Future<Map<String, dynamic>> exportResearchData() async {
    return {
      'userId': _userId,
      'userProfile': _userProfile,
      'completedJourneys': _completedJourneys,
      'engagementScores': _engagementScores,
      'currentSession': _currentSession,
      'investorMetrics': getInvestorMetrics(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  // Analytics methods for dashboard
  Future<Map<String, dynamic>> getResearchAnalytics() async {
    try {
      final querySnapshot = await _firestore.collection('research_data').get();
      final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      
      // Get unique users
      final uniqueUsers = allData.map((data) => data['userId']).toSet().length;
      
      // Calculate PMF metrics
      final pmfData = allData.where((data) => data['type'] == 'product_market_fit').toList();
      final pmfScore = _calculatePMFScore(pmfData);
      final pmfDistribution = _calculatePMFDistribution(pmfData);
      
      // Calculate NPS
      final averageNPS = _calculateAverageNPS(pmfData);
      
      // Calculate engagement metrics
      final journeyCompletionRate = _calculateJourneyCompletionRate(allData);
      final averageEpisodesPerUser = _calculateAverageEpisodesPerUser(allData);
      final averageSessionDuration = _calculateAverageSessionDuration(allData);
      
      // Feature interest analysis
      final featureInterestData = allData.where((data) => data['type'] == 'feature_interest').toList();
      final averageFeatureInterest = _calculateAverageFeatureInterest(featureInterestData);
      
      // Learning effectiveness
      final engagementData = allData.where((data) => data['type'] == 'engagement_validation').toList();
      final averageLearningEffectiveness = _calculateAverageLearningEffectiveness(engagementData);
      
      // Commercial validation
      final willingToPayPercentage = _calculateWillingToPayPercentage(pmfData);
      final painPointData = allData.where((data) => data['type'] == 'pain_point_validation').toList();
      final averagePainPointSeverity = _calculateAveragePainPointSeverity(painPointData);
      
      // Top features
      final topFeatures = _getTopRequestedFeatures(featureInterestData);
      
      // Journey progress
      final journeyProgress = _calculateJourneyProgress(allData);
      
      return {
        'totalUsers': uniqueUsers,
        'pmfScore': pmfScore,
        'pmfDistribution': pmfDistribution,
        'averageNPS': averageNPS,
        'journeyCompletionRate': journeyCompletionRate,
        'averageEpisodesPerUser': averageEpisodesPerUser,
        'averageSessionDuration': averageSessionDuration,
        'averageFeatureInterest': averageFeatureInterest,
        'averageLearningEffectiveness': averageLearningEffectiveness,
        'willingToPayPercentage': willingToPayPercentage,
        'averagePainPointSeverity': averagePainPointSeverity,
        'topFeatures': topFeatures,
        'journeyProgress': journeyProgress,
      };
    } catch (e) {
      print('Error getting research analytics: $e');
      rethrow;
    }
  }

  double _calculatePMFScore(List<Map<String, dynamic>> pmfData) {
    if (pmfData.isEmpty) return 0.0;
    
    int veryDisappointed = 0;
    int total = 0;
    
    for (final data in pmfData) {
      final disappointment = data['data']['disappointmentLevel'] as int?;
      if (disappointment != null) {
        total++;
        if (disappointment >= 7) {
          veryDisappointed++;
        }
      }
    }
    
    return total > 0 ? (veryDisappointed / total) * 100 : 0.0;
  }

  Map<String, int> _calculatePMFDistribution(List<Map<String, dynamic>> pmfData) {
    int veryDisappointed = 0;
    int somewhatDisappointed = 0;
    int notDisappointed = 0;
    
    for (final data in pmfData) {
      final disappointment = data['data']['disappointmentLevel'] as int?;
      if (disappointment != null) {
        if (disappointment >= 7) {
          veryDisappointed++;
        } else if (disappointment >= 4) {
          somewhatDisappointed++;
        } else {
          notDisappointed++;
        }
      }
    }
    
    return {
      'Very Disappointed': veryDisappointed,
      'Somewhat Disappointed': somewhatDisappointed,
      'Not Disappointed': notDisappointed,
    };
  }

  double _calculateAverageNPS(List<Map<String, dynamic>> pmfData) {
    if (pmfData.isEmpty) return 0.0;
    
    final npsScores = pmfData
        .map((data) => data['data']['npsScore'] as int?)
        .where((score) => score != null)
        .cast<int>()
        .toList();
    
    if (npsScores.isEmpty) return 0.0;
    
    return npsScores.reduce((a, b) => a + b) / npsScores.length;
  }

  double _calculateJourneyCompletionRate(List<Map<String, dynamic>> allData) {
    final journeyCompletions = allData.where((data) => data['type'] == 'product_market_fit').length;
    final totalUsers = allData.map((data) => data['userId']).toSet().length;
    
    return totalUsers > 0 ? (journeyCompletions / totalUsers) * 100 : 0.0;
  }

  double _calculateAverageEpisodesPerUser(List<Map<String, dynamic>> allData) {
    final userEpisodeCounts = <String, int>{};
    
    for (final data in allData) {
      final userId = data['userId'] as String?;
      final episodeCount = data['episodeCount'] as int?;
      
      if (userId != null && episodeCount != null) {
        userEpisodeCounts[userId] = episodeCount;
      }
    }
    
    if (userEpisodeCounts.isEmpty) return 0.0;
    
    final totalEpisodes = userEpisodeCounts.values.reduce((a, b) => a + b);
    return totalEpisodes / userEpisodeCounts.length;
  }

  double _calculateAverageSessionDuration(List<Map<String, dynamic>> allData) {
    // Calculate based on actual session data
    if (allData.isEmpty) return 0.0;
    
    double totalDuration = 0.0;
    int sessionCount = 0;
    
    for (final session in allData) {
      final startTime = session['startTime'];
      final endTime = session['endTime'];
      
      if (startTime != null && endTime != null) {
        final sessionDuration = DateTime.parse(endTime).difference(DateTime.parse(startTime)).inMinutes.toDouble();
        totalDuration += sessionDuration;
        sessionCount++;
      }
    }
    
    return sessionCount > 0 ? totalDuration / sessionCount : 0.0;
  }

  double _calculateAverageFeatureInterest(List<Map<String, dynamic>> featureData) {
    if (featureData.isEmpty) return 0.0;
    
    double totalInterest = 0.0;
    int totalRatings = 0;
    
    for (final data in featureData) {
      final interests = data['data'] as Map<String, dynamic>?;
      if (interests != null) {
        for (final rating in interests.values) {
          if (rating is int) {
            totalInterest += rating;
            totalRatings++;
          }
        }
      }
    }
    
    return totalRatings > 0 ? totalInterest / totalRatings : 0.0;
  }

  double _calculateAverageLearningEffectiveness(List<Map<String, dynamic>> engagementData) {
    if (engagementData.isEmpty) return 0.0;
    
    final effectiveness = engagementData
        .map((data) => data['data']['learningEffectiveness'] as int?)
        .where((rating) => rating != null)
        .cast<int>()
        .toList();
    
    if (effectiveness.isEmpty) return 0.0;
    
    return effectiveness.reduce((a, b) => a + b) / effectiveness.length;
  }

  double _calculateWillingToPayPercentage(List<Map<String, dynamic>> pmfData) {
    if (pmfData.isEmpty) return 0.0;
    
    int willingToPay = 0;
    int total = 0;
    
    for (final data in pmfData) {
      final willingness = data['data']['willingToPay'] as bool?;
      if (willingness != null) {
        total++;
        if (willingness) {
          willingToPay++;
        }
      }
    }
    
    return total > 0 ? (willingToPay / total) * 100 : 0.0;
  }

  double _calculateAveragePainPointSeverity(List<Map<String, dynamic>> painPointData) {
    if (painPointData.isEmpty) return 0.0;
    
    double totalSeverity = 0.0;
    int totalRatings = 0;
    
    for (final data in painPointData) {
      final painPoints = data['data'] as Map<String, dynamic>?;
      if (painPoints != null) {
        for (final severity in painPoints.values) {
          if (severity is int) {
            totalSeverity += severity;
            totalRatings++;
          }
        }
      }
    }
    
    return totalRatings > 0 ? totalSeverity / totalRatings : 0.0;
  }

  List<String> _getTopRequestedFeatures(List<Map<String, dynamic>> featureData) {
    final featureScores = <String, double>{};
    
    for (final data in featureData) {
      final interests = data['data'] as Map<String, dynamic>?;
      if (interests != null) {
        for (final entry in interests.entries) {
          final feature = entry.key;
          final score = entry.value as int? ?? 0;
          
          featureScores[feature] = (featureScores[feature] ?? 0.0) + score;
        }
      }
    }
    
    final sortedFeatures = featureScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedFeatures.map((entry) => entry.key).toList();
  }

  Map<String, double> _calculateJourneyProgress(List<Map<String, dynamic>> allData) {
    final userProgress = <String, Set<String>>{};
    
    for (final data in allData) {
      final userId = data['userId'] as String?;
      final type = data['type'] as String?;
      
      if (userId != null && type != null) {
        userProgress.putIfAbsent(userId, () => <String>{}).add(type);
      }
    }
    
    final totalUsers = userProgress.length.toDouble();
    if (totalUsers == 0) return {};
    
    return {
      'First Episode Completed': (userProgress.values.where((stages) => stages.contains('feature_interest')).length / totalUsers) * 100,
      'Third Episode Completed': (userProgress.values.where((stages) => stages.contains('engagement_validation')).length / totalUsers) * 100,
      'Journey Completed': (userProgress.values.where((stages) => stages.contains('product_market_fit')).length / totalUsers) * 100,
    };
  }

  void captureProductInterest({
    required Map<String, int> productInterest,
    required List<String> desiredFeatures,
    required String triggerContext,
  }) {
    final productData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'productInterest': productInterest,
      'desiredFeatures': desiredFeatures,
      'triggerContext': triggerContext,
      'userJourneyStage': {
        'episodeCount': _episodeCount,
        'journeyCount': _journeyCount,
      },
    };
    
    FirebaseService.submitFeedback({
      'type': 'product_interest',
      'userId': _userId,
      'data': productData,
    });
  }
}
