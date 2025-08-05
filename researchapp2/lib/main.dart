import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'core/auth_provider.dart';
import 'core/research_metrics_provider.dart';
import 'gamification/gamification_provider.dart'; // ADD MISSING GAMIFICATION PROVIDER
import 'core/initial_admin_setup.dart';
import 'theme/app_theme.dart';
import 'onboarding/research_intro_screen.dart';
import 'onboarding/auth_screen.dart';
import 'onboarding/enhanced_auth_screen.dart';
import 'onboarding/welcome_screen.dart';
import 'features/full_app_preview_screen.dart';
import 'onboarding/consent_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'onboarding/learning_style_assessment_screen.dart';
import 'onboarding/onboarding_complete_screen.dart';
import 'journeys/journey_orientation_screen.dart';
import 'journeys/journey_selection_screen.dart';
import 'journeys/audio_player_screen.dart';
import 'progress/learning_progress_screen.dart';
import 'progress/progress_visualization_screen.dart';
import 'feedback/feedback_navigation_screen.dart';
import 'feedback/journey_completion_screen.dart';
import 'feedback/simple_episode_feedback_screen.dart';
import 'feedback/third_episode_feedback_screen.dart';
import 'feedback/journey_pmf_validation_screen.dart';
import 'research/research_analytics_dashboard.dart';
import 'feedback/learning_method_comparison_screen.dart';
import 'feedback/product_interest_screen.dart';
import 'feedback/final_research_survey_screen.dart';
import 'feedback/study_completion_screen.dart';
import 'research/research_center_screen.dart';
import 'gamification/profile_screen.dart'; // ADD MISSING PROFILE IMPORT
import 'home/modern_home_screen.dart';
import 'community/topic_suggestion_screen.dart';
import 'community/community_requests_screen.dart';
import 'core/app_shell.dart';
import 'admin/admin_login_screen.dart';
import 'services/progress_persistence_service.dart'; // ADD MISSING IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Starting Wisme Research Demo App...');
  
  // Wrap everything in try-catch to prevent crashes
  try {
    // Initialize Firebase
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    
    // 🔥 CRITICAL: Initialize Progress Persistence Service for cross-device sync
    print('Initializing Progress Persistence Service...');
    await ProgressPersistenceService.initialize();
    print('Progress Persistence Service initialized successfully');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Set up initial admin configuration
    print('Setting up initial admin configuration...');
    await InitialAdminSetup.setupInitialAdmin();
    print('✅ Admin setup complete');
    
    print('Creating providers...');
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            print('Creating AuthProvider');
            return AuthProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            print('Creating ResearchMetricsProvider');
            return ResearchMetricsProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            print('Creating GamificationProvider');
            return GamificationProvider();
          }),
        ],
        child: const WismeResearchDemoApp(),
      ),
    );
  } catch (e) {
    print('Critical error in main: $e');
    // Create a basic app that shows an error message
    runApp(
      MaterialApp(
        title: 'Wisme Research Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: Colors.grey[900],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text('App initialization failed', 
                     style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(height: 8),
                Text('Error: $e', 
                     style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WismeResearchDemoApp extends StatelessWidget {
  const WismeResearchDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building WismeResearchDemoApp...');
    
    return Consumer2<AuthProvider, ResearchMetricsProvider>(
      builder: (context, auth, research, _) {
        print('Consumer builder called - Auth signed in: ${auth.isSignedIn}');
        
        // Show loading screen while auth is initializing
        if (!auth.isAuthInitialized) {
          return MaterialApp(
            title: 'Wisme Research Demo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: Scaffold(
              backgroundColor: Colors.grey[900],
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text('Loading...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          );
        }
        
        // Initialize research metrics with user ID when signed in (deferred to avoid setState during build)
        if (auth.user != null && research.userId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              research.setUserId(auth.user!.uid);
            } catch (e) {
              print('Error setting user ID: $e');
            }
          });
        }
        
        print('Creating MaterialApp...');
        
        // FIXED: Determine correct home screen based on user profile completion
        Widget homeScreen;
        if (auth.isSignedIn) {
          // Check if user has completed onboarding
          if (auth.userProfile != null && auth.userProfile!['onboardingComplete'] == true) {
            homeScreen = const AppShell(); // User has completed all setup - use AppShell with navigation
          } else if (auth.userProfile != null && auth.userProfile!['demographics'] != null) {
            homeScreen = const AppShell(); // User has basic profile, skip re-asking - use AppShell
          } else {
            homeScreen = const ConsentScreen(); // First time user, need onboarding
          }
        } else {
          homeScreen = const ResearchIntroScreen(); // Not signed in
        }
        
        return MaterialApp(
          title: 'Wisme Research Demo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: homeScreen,
          routes: {
            '/auth': (context) => const EnhancedAuthScreen(),
            '/auth_legacy': (context) => const AuthScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/home': (context) => const ModernHomeScreen(),
            '/consent': (context) => const ConsentScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/onboarding_complete': (context) => const OnboardingCompleteScreen(),
            '/learning_style': (context) => const LearningStyleAssessmentScreen(),
            '/journey_orientation': (context) => const JourneyOrientationScreen(),
            '/journeys': (context) => const JourneySelectionScreen(),
            '/journey_selection': (context) => const JourneySelectionScreen(), // Added missing route
            '/journey_completion': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              return JourneyCompletionScreen(completedJourney: args ?? {});
            },
            '/first_episode_feedback': (context) => const SimpleEpisodeFeedbackScreen(episodeNumber: "1"),
            '/third_episode_feedback': (context) => const ThirdEpisodeFeedbackScreen(),
            '/journey_pmf_validation': (context) => const JourneyPMFValidationScreen(),
            '/research_analytics': (context) => const ResearchAnalyticsDashboard(),
            '/profile': (context) => const ProfileScreen(), // ADD MISSING PROFILE ROUTE
            '/app': (context) => const AppShell(),
            '/audio_player': (context) => const AudioPlayerScreen(),
            '/progress_dashboard': (context) => const LearningProgressScreen(),
            '/progress_visualization': (context) => const ProgressVisualizationScreen(),
            '/feedback_hub': (context) => const FeedbackNavigationScreen(),
            '/suggest_topic': (context) => const TopicSuggestionScreen(),
            '/community_requests': (context) => const CommunityRequestsScreen(),
            '/research_center': (context) => const ResearchCenterScreen(),
            '/learning_method_comparison': (context) => const LearningMethodComparisonScreen(),
            '/product_interest': (context) => const ProductInterestScreen(),
            '/final_research_survey': (context) => const FinalResearchSurveyScreen(),
            '/study_completion': (context) => const StudyCompletionScreen(),
            '/admin': (context) => const AdminLoginScreen(),
            '/full_app_preview': (context) => const FullAppPreviewScreen(),
          },
        );
      },
    );
  }
}
