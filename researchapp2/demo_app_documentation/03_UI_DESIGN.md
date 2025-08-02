# 📱 **USER INTERFACE DESIGN**

## 🎨 **Design System**

### **Color Palette**
```dart
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);
  
  // Neutral Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

### **Typography**
```dart
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
```

## 📱 **Screen Components**

### **1. Welcome Screen**
```dart
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and branding
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.headphones,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),
              
              // Title
              Text(
                "Welcome to Wisme Research",
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              
              // Subtitle
              Text(
                "Experience revolutionary conversational learning",
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48),
              
              // CTA Button
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/consent'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Start Learning Journey",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
```

### **2. Journey Selection Screen**
```dart
class JourneySelectionScreen extends StatelessWidget {
  final List<Journey> journeys = [
    Journey(
      id: 'dsa',
      title: 'Data Structures & Algorithms',
      subtitle: '5 episodes • 45 minutes',
      icon: Icons.code,
      color: AppColors.primaryBlue,
      difficulty: 'Intermediate',
    ),
    Journey(
      id: 'os',
      title: 'Operating Systems',
      subtitle: '6 episodes • 54 minutes', 
      icon: Icons.computer,
      color: AppColors.accentOrange,
      difficulty: 'Advanced',
    ),
    // ... other journeys
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Your Journey"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: journeys.length,
          itemBuilder: (context, index) {
            final journey = journeys[index];
            return JourneyCard(journey: journey);
          },
        ),
      ),
    );
  }
}

class JourneyCard extends StatelessWidget {
  final Journey journey;
  
  const JourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JourneyDetailScreen(journey: journey),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: journey.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: journey.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              journey.icon,
              size: 40,
              color: journey.color,
            ),
            Spacer(),
            Text(
              journey.title,
              style: AppTextStyles.heading2.copyWith(fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              journey.subtitle,
              style: AppTextStyles.caption,
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: journey.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                journey.difficulty,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **3. Audio Player Screen**
```dart
class AudioPlayerScreen extends StatefulWidget {
  final Episode episode;
  
  const AudioPlayerScreen({required this.episode});

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with episode info
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryBlue, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.headphones,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    widget.episode.title,
                    style: AppTextStyles.heading2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.episode.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            Spacer(),
            
            // Progress bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: AppColors.primaryBlue,
                      overlayColor: AppColors.primaryBlue.withAlpha(32),
                    ),
                    child: Slider(
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _player.seek(position);
                        // Track user interaction
                        _trackSeekEvent(position);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _skipBackward(),
                  icon: Icon(Icons.replay_10, color: Colors.white, size: 36),
                ),
                GestureDetector(
                  onTap: () => _togglePlayback(),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _skipForward(),
                  icon: Icon(Icons.forward_10, color: Colors.white, size: 36),
                ),
              ],
            ),
            
            SizedBox(height: 40),
            
            // Speed control
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Speed: ", style: TextStyle(color: Colors.white70)),
                  DropdownButton<double>(
                    value: 1.0,
                    dropdownColor: AppColors.backgroundDark,
                    style: TextStyle(color: Colors.white),
                    items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        .map((speed) => DropdownMenuItem(
                              value: speed,
                              child: Text("${speed}x"),
                            ))
                        .toList(),
                    onChanged: (speed) => _setPlaybackSpeed(speed!),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  void _trackSeekEvent(Duration position) {
    // Track user seeking behavior for engagement analysis
    FirebaseAnalytics.instance.logEvent(
      name: 'audio_seek',
      parameters: {
        'episode_id': widget.episode.id,
        'position': position.inSeconds,
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      },
    );
  }
}
```

## 🎨 **Visual Design Principles**

### **Clean & Modern**
- Minimal interface focusing on content
- Generous white space
- Clear visual hierarchy
- Professional appearance for research credibility

### **Audio-First Design**
- Large, prominent audio controls
- Visual feedback for playback state
- Easy-to-read progress indicators
- Distraction-free listening environment

### **Accessibility**
- High contrast colors
- Large touch targets (minimum 44px)
- Screen reader support
- Keyboard navigation support

### **Research-Focused**
- Subtle data collection (no intrusive surveys during listening)
- Clear consent and privacy information
- Professional branding building trust
- Smooth user experience encouraging completion

---

## 🎮 Gamification UI Elements
- **Badge Widget:** Icon, name, and description. Appears on unlock and in profile.
- **XP Bar:** Shows progress to next level. Animated on XP gain.
- **Streak Indicator:** Flame or calendar icon with current streak count.
- **Notification Banner:** Top-of-screen banner for reminders, new content, or rewards.

---

## 🔊 Audio Content Sourcing for Demo App
- Use AI voice, in-house, or freelance voiceover for episode audio.
- Scripts from 'LEARNING_JOURNEYS_PLAN.md' or '04_LEARNING_JOURNEYS.md'.
- All demo audio labeled as 'Sample Content – Not Final'.

---
