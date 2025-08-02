# 🏗️ **TECHNICAL ARCHITECTURE**

## 📱 **App Technology Stack**

### **Frontend**
- **Framework**: Flutter (Dart)
- **Platform**: Android, iOS
- **UI Components**: Material Design 3.0
- **State Management**: Provider/Riverpod
- **Navigation**: GoRouter

### **Backend Services**
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Analytics**: Firebase Analytics
- **Hosting**: Firebase Hosting

### **Audio Streaming**
- **Player**: just_audio package
- **Buffering**: Progressive download
- **Offline**: Local storage caching
- **Quality**: 128kbps MP3

## 🗄️ **Database Schema**

### **Users Collection**
```dart
{
  "uid": "user_unique_id",
  "email": "user@example.com",
  "displayName": "User Name",
  "createdAt": timestamp,
  "demographics": {
    "age": 22,
    "education": "Engineering",
    "experience": "Beginner"
  },
  "preferences": {
    "playbackSpeed": 1.0,
    "autoplay": true,
    "notifications": true
  }
}
```

### **Journeys Collection**
```dart
{
  "journeyId": "dsa_journey",
  "title": "Data Structures & Algorithms",
  "description": "Master DSA through conversations",
  "category": "Technical",
  "episodes": ["ep1_id", "ep2_id", ...],
  "totalDuration": 3600, // seconds
  "difficulty": "Intermediate",
  "isActive": true
}
```

### **Episodes Collection**
```dart
{
  "episodeId": "dsa_ep1_big_o",
  "journeyId": "dsa_journey",
  "title": "Big O Notation Mastery",
  "description": "Understanding algorithm efficiency",
  "audioUrl": "https://storage.../audio.mp3",
  "duration": 600, // seconds
  "order": 1,
  "transcript": "Full episode transcript...",
  "keyPoints": ["O(1)", "O(n)", "O(log n)"]
}
```

### **User Progress Collection**
```dart
{
  "userJourneyId": "uid_journeyId",
  "userId": "user_uid",
  "journeyId": "dsa_journey",
  "startedAt": timestamp,
  "completedAt": timestamp,
  "currentEpisodeId": "dsa_ep3",
  "completedEpisodes": ["ep1_id", "ep2_id"],
  "progressPercentage": 40,
  "totalListeningTime": 1200 // seconds
}
```

### **Episode Interactions Collection**
```dart
{
  "interactionId": "unique_id",
  "userId": "user_uid",
  "episodeId": "dsa_ep1",
  "sessionId": "session_unique_id",
  "startTime": timestamp,
  "endTime": timestamp,
  "playbackEvents": [
    {
      "action": "play",
      "timestamp": timestamp,
      "position": 120 // seconds
    },
    {
      "action": "pause", 
      "timestamp": timestamp,
      "position": 180
    }
  ],
  "completionPercentage": 85,
  "engagementScore": 8.5
}
```

### **Feedback Collection**
```dart
{
  "feedbackId": "unique_id",
  "userId": "user_uid",
  "episodeId": "dsa_ep1",
  "journeyId": "dsa_journey",
  "submittedAt": timestamp,
  "responses": {
    "engagement": 9,
    "comprehension": 8,
    "retention": 7,
    "preference": 9
  },
  "openFeedback": "This was much better than textbooks!",
  "wouldRecommend": true
}
```

## 🔧 **Key Services Architecture**

### **Audio Service**
```dart
class AudioService {
  late AudioPlayer _player;
  
  // Progressive loading with buffering
  Future<void> loadEpisode(Episode episode) async {
    await _player.setUrl(episode.audioUrl);
  }
  
  // Analytics tracking
  void trackPlaybackEvent(String action, int position) {
    FirebaseAnalytics.instance.logEvent(
      name: 'audio_interaction',
      parameters: {
        'action': action,
        'position': position,
        'episode_id': currentEpisode.id,
      },
    );
  }
}
```

### **Progress Tracking Service**
```dart
class ProgressService {
  // Real-time progress updates
  void updateProgress(String episodeId, double percentage) {
    FirebaseFirestore.instance
        .collection('user_progress')
        .doc('${currentUser.uid}_$episodeId')
        .update({
      'progressPercentage': percentage,
      'lastPosition': _player.position.inSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Completion tracking
  void markEpisodeComplete(String episodeId) {
    // Update completion status
    // Unlock next episode
    // Update journey progress
  }
}
```

### **Analytics Service**
```dart
class ResearchAnalytics {
  // Engagement metrics
  void trackEngagement(String episodeId, double engagementScore) {
    // Track listening patterns
    // Calculate attention metrics
    // Store engagement data
  }
  
  // Learning effectiveness
  void trackLearningOutcome(String journeyId, Map<String, dynamic> assessment) {
    // Pre/post knowledge assessment
    // Retention testing results
    // Comparative analysis
  }
}
```

## 🔒 **Security & Privacy**

### **Data Protection**
- **Encryption**: All user data encrypted at rest
- **Authentication**: Firebase Auth with email/social login
- **Authorization**: Role-based access control
- **Privacy**: GDPR compliant data handling

### **Research Ethics**
- **Consent**: Explicit user consent for research participation
- **Anonymization**: Personal data anonymized for research
- **Opt-out**: Easy withdrawal from research study
- **Transparency**: Clear data usage explanation

## 📊 **Performance Requirements**

### **Response Times**
- **App Launch**: < 3 seconds
- **Episode Loading**: < 5 seconds
- **Navigation**: < 1 second
- **Offline Mode**: Full functionality without internet

### **Scalability**
- **Users**: 10,000+ concurrent users
- **Storage**: Unlimited audio content scaling
- **Analytics**: Real-time data processing
- **Backup**: Daily automated backups

---

## 🎮 Gamification & Notification Technical Hooks
- **Gamification:**
  - XP and badge state stored in user profile (Firestore or local DB).
  - Badge/XP logic triggered on journey completion, feedback, streaks.
  - Leaderboard data (if used) stored in a separate collection.
- **Notifications:**
  - In-app notification system for reminders, streaks, and new content.
  - Optional push notification integration for mobile.
- **Analytics:**
  - Track badge unlocks, XP earned, notification click-throughs.

---

## 🔊 Audio Content Sourcing for Demo App
- **Audio for episodes:**
  - Use AI voice generation, in-house recording, or freelancers.
  - Scripts from 'LEARNING_JOURNEYS_PLAN.md' or '04_LEARNING_JOURNEYS.md'.
  - Mark all demo audio as 'Sample Content – Not Final'.

---
