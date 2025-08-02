# Wisme Research App - Comprehensive Screen Documentation

**Generated:** July 28, 2025  
**Version:** Production Ready  
**Total Screens:** 25+ screens across 8 major categories

---

## 📱 **CORE APP STRUCTURE**

### 1. **AppShell** (`lib/core/app_shell.dart`)
**Purpose:** Main navigation container with bottom navigation
**Key Features:**
- 5-tab bottom navigation (Home, Journeys, Progress, Profile, Feedback)
- IndexedStack for screen preservation
- App drawer with research branding
- Quick access to admin panel and research center

**Navigation Tabs:**
1. Home (ModernHomeScreen)
2. Journeys (JourneySelectionScreen) 
3. Progress (LearningProgressScreen)
4. Profile (ProfileScreen)
5. Feedback (FeedbackNavigationScreen)

---

## 🎯 **ONBOARDING & AUTHENTICATION**

### 2. **Welcome Screen** (`lib/onboarding/welcome_screen.dart`)
**Purpose:** App introduction and initial user engagement
**Key Features:**
- Modern gradient design with Wisme branding
- Research study introduction
- Call-to-action buttons for getting started
- Smooth animations and transitions

### 3. **Research Intro Screen** (`lib/onboarding/research_intro_screen.dart`)
**Purpose:** Explain the research study purpose and methodology
**Key Features:**
- Academic research context
- Study objectives and timeline
- Participant benefits explanation
- Privacy and data usage overview

### 4. **Enhanced Auth Screen** (`lib/onboarding/enhanced_auth_screen.dart`)
**Purpose:** Modern authentication with Firebase integration
**Key Features:**
- Email/password authentication
- Google Sign-In integration
- Beautiful gradient UI design
- Form validation and error handling
- Research consent integration

### 5. **Legacy Auth Screen** (`lib/onboarding/auth_screen.dart`)
**Purpose:** Backup authentication option
**Key Features:**
- Simple email/password form
- Basic Firebase authentication
- Fallback option for enhanced auth

### 6. **Consent Screen** (`lib/onboarding/consent_screen.dart`)
**Purpose:** Research study consent and privacy agreement
**Key Features:**
- Detailed consent form
- Privacy policy explanation
- Data usage transparency
- Legal compliance for research studies

### 7. **Onboarding Screen** (`lib/onboarding/onboarding_screen.dart`)
**Purpose:** Collect user demographics and learning preferences
**Key Features:**
- Multi-step form with progress indicators
- Demographics collection (age, education, occupation)
- Learning goals selection (multiple choice)
- Subject familiarity assessment (1-10 scale)
- Research metrics integration

### 8. **Learning Style Assessment** (`lib/onboarding/learning_style_assessment_screen.dart`)
**Purpose:** Assess preferred learning methods and styles
**Key Features:**
- Visual vs. Auditory preference assessment
- Learning pace preferences
- Interactive vs. Passive learning styles
- Research data collection for personalization

### 9. **Baseline Knowledge Test** (`lib/onboarding/baseline_knowledge_test_screen.dart`)
**Purpose:** Measure initial knowledge levels for research
**Key Features:**
- Subject-specific knowledge assessment
- Multiple choice questions
- Baseline measurement for learning effectiveness
- Pre/post comparison capability

### 10. **Onboarding Complete Screen** (`lib/onboarding/onboarding_complete_screen.dart`)
**Purpose:** Welcome users after successful onboarding
**Key Features:**
- Completion celebration with animations
- Summary of user profile
- Journey recommendations
- Call-to-action to start learning

---

## 🎓 **LEARNING JOURNEYS**

### 11. **Journey Selection Screen** (`lib/journeys/journey_selection_screen.dart`)
**Purpose:** Choose from 4 available learning journeys
**Key Features:**
- 4 Production Journeys:
  - **Data Structures & Algorithms** (5 episodes, 40 min)
  - **Science Mysteries & Discoveries** (5 episodes, 40 min)
  - **Psychology & Human Behavior** (5 episodes, 40 min)
  - **Personal Finance** (6 episodes, 50 min)
- Visual journey cards with progress tracking
- Difficulty indicators and time estimates
- Beautiful animations and hover effects
- Journey metadata and descriptions

### 12. **Journey Orientation Screen** (`lib/journeys/journey_orientation_screen.dart`)
**Purpose:** Introduce users to selected journey before starting
**Key Features:**
- Journey overview and learning objectives
- Episode structure explanation
- Expected time commitment
- Tips for effective learning

### 13. **Audio Player Screen** (`lib/journeys/audio_player_screen.dart`)
**Purpose:** Primary learning interface with full audio experience
**Key Features:**
- **Full Production Audio Player:**
  - Play/pause with smooth animations
  - 10-second forward/rewind controls
  - Speed control (0.5x to 2.0x)
  - Progress bar with seek functionality
  - Episode navigation (previous/next)
- **Persistence & Resume:**
  - Auto-save position every 10 seconds
  - Resume from last position on return
  - Episode completion tracking
  - Cross-session persistence via ProgressPersistenceService
- **Research Integration:**
  - Comprehensive analytics tracking
  - Engagement score calculation
  - Learning behavior measurement
  - Real-time research metrics collection
- **Beautiful UI:**
  - Journey-themed colors
  - Episode thumbnails and metadata
  - Progress indicators and completion status
  - Responsive design with animations

---

## 🏠 **HOME & DASHBOARD**

### 14. **Modern Home Screen** (`lib/home/modern_home_screen.dart`)
**Purpose:** Main dashboard with learning overview and quick actions
**Key Features:**
- **Learning Progress Overview:**
  - Current journey status
  - Recently played episodes
  - Completion statistics
  - Learning streak tracking
- **Quick Actions:**
  - Resume last episode with auto-position
  - Start new journey
  - View progress details
  - Access research center
- **Personalized Recommendations:**
  - Next episode suggestions
  - Journey recommendations based on progress
  - Learning goal alignment
- **Research Participation Status:**
  - Study progress indicators
  - Feedback opportunities
  - Research milestones

---

## 📊 **PROGRESS & ANALYTICS**

### 15. **Learning Progress Screen** (`lib/progress/learning_progress_screen.dart`)
**Purpose:** Detailed progress visualization and statistics
**Key Features:**
- **Journey Progress:**
  - Individual journey completion rates
  - Episode-by-episode progress
  - Time spent learning
  - Completion dates and milestones
- **Learning Statistics:**
  - Total listening time
  - Episodes completed
  - Learning streak tracking
  - Speed preferences and patterns
- **Visual Progress Charts:**
  - Progress bars and completion indicators
  - Time-based learning charts
  - Engagement score visualizations

### 16. **Progress Visualization Screen** (`lib/progress/progress_visualization_screen.dart`)
**Purpose:** Advanced analytics and data visualization
**Key Features:**
- **Interactive Charts:**
  - Learning progress over time
  - Subject mastery visualization
  - Engagement pattern analysis
- **Research Insights:**
  - Learning effectiveness metrics
  - Comparative performance data
  - Personalized insights and recommendations

---

## 📝 **FEEDBACK & RESEARCH**

### 17. **Feedback Navigation Screen** (`lib/feedback/feedback_navigation_screen.dart`)
**Purpose:** Central hub for all feedback and research participation
**Key Features:**
- Available feedback surveys
- Research milestone tracking
- Feedback history and status
- Research contribution overview

### 18. **First Episode Feedback** (`lib/feedback/first_episode_feedback_screen.dart`)
**Purpose:** Collect initial impressions after first episode
**Key Features:**
- Learning experience assessment
- Audio quality feedback
- Content difficulty evaluation
- Initial satisfaction measurement

### 19. **Third Episode Feedback** (`lib/feedback/third_episode_feedback_screen.dart`)
**Purpose:** Mid-journey feedback for learning pattern analysis
**Key Features:**
- Learning pattern assessment
- Content preference evaluation
- Engagement level measurement
- Improvement suggestions

### 20. **Journey Completion Screen** (`lib/feedback/journey_completion_screen.dart`)
**Purpose:** Celebrate and collect feedback on completed journeys
**Key Features:**
- Completion celebration with animations
- Journey effectiveness assessment
- Knowledge gain evaluation
- Next journey recommendations

### 21. **Journey PMF Validation** (`lib/feedback/journey_pmf_validation_screen.dart`)
**Purpose:** Product-market fit assessment for research validation
**Key Features:**
- Learning method effectiveness
- Product satisfaction measurement
- Feature importance ranking
- Investment validation metrics

### 22. **Modern Journey Comparison** (`lib/feedback/modern_journey_comparison_screen.dart`)
**Purpose:** Compare different learning approaches for research
**Key Features:**
- Cross-journey effectiveness comparison
- Learning preference analysis
- Method effectiveness ranking
- Research-driven insights

### 23. **Product Interest Screen** (`lib/feedback/product_interest_screen.dart`)
**Purpose:** Assess market interest and product viability
**Key Features:**
- Feature interest assessment
- Pricing sensitivity analysis
- Market demand evaluation
- Investment decision support

### 24. **Final Research Survey** (`lib/feedback/final_research_survey_screen.dart`)
**Purpose:** Comprehensive study conclusion survey
**Key Features:**
- Overall experience evaluation
- Learning effectiveness assessment
- Research study feedback
- Future participation interest

### 25. **Study Completion Screen** (`lib/feedback/study_completion_screen.dart`)
**Purpose:** Thank participants and provide study results
**Key Features:**
- Study completion celebration
- Participant appreciation
- Research results preview
- Future opportunities

---

## 🎮 **GAMIFICATION & PROFILE**

### 26. **Profile Screen** (`lib/gamification/profile_screen.dart`)
**Purpose:** User profile with achievements and statistics
**Key Features:**
- User profile information
- Learning achievements and badges
- Progress statistics
- Research participation status

### 27. **Badge Unlocked Screen** (`lib/gamification/badge_unlocked_screen.dart`)
**Purpose:** Celebrate achievement unlocks
**Key Features:**
- Achievement celebration animations
- Badge details and requirements
- Progress motivation
- Social sharing options

### 28. **XP Level Up Screen** (`lib/gamification/xp_levelup_screen.dart`)
**Purpose:** Celebrate level progression
**Key Features:**
- Level up animations
- New feature unlocks
- Progress celebration
- Motivation enhancement

### 29. **Streak Reminder Popup** (`lib/gamification/streak_reminder_popup.dart`)
**Purpose:** Encourage consistent learning habits
**Key Features:**
- Learning streak tracking
- Reminder notifications
- Habit formation support
- Engagement maintenance

---

## 🏛️ **ADMIN & RESEARCH ANALYTICS**

### 30. **Admin Login Screen** (`lib/admin/admin_login_screen.dart`)
**Purpose:** Secure admin access for researchers
**Key Features:**
- Admin authentication
- Research team access
- Security validation
- Role-based permissions

### 31. **Research Analytics Dashboard** (`lib/admin/research_analytics_dashboard.dart`)
**Purpose:** Comprehensive research data analysis and export
**Key Features:**
- **User Demographics Analysis:**
  - Age group distributions
  - Education level breakdown
  - Experience level analysis
  - Geographic data (if available)
- **Learning Effectiveness Metrics:**
  - Journey completion rates
  - Episode engagement scores
  - Learning speed analysis
  - Knowledge retention measurement
- **Feedback Analysis:**
  - Satisfaction score trends
  - Feature importance ranking
  - User preference patterns
  - Market validation data
- **Data Visualization:**
  - Interactive charts and graphs
  - Progress visualization
  - Trend analysis
  - Comparative statistics
- **Data Export Functions:**
  - User data export (CSV)
  - Feedback data export
  - Comprehensive analytics reports
  - Research publication data

---

## 🌐 **COMMUNITY & RESEARCH CENTER**

### 32. **Research Center Screen** (`lib/research/research_center_screen.dart`)
**Purpose:** Central hub for research participation and insights
**Key Features:**
- Research study information
- Participation status tracking
- Research insights and findings
- Academic publication access

### 33. **Topic Suggestion Screen** (`lib/community/topic_suggestion_screen.dart`)
**Purpose:** Allow users to suggest new learning topics
**Key Features:**
- Topic suggestion form
- Community voting system
- Research interest tracking
- Content development pipeline

### 34. **Community Requests Screen** (`lib/community/community_requests_screen.dart`)
**Purpose:** Community-driven content requests and prioritization
**Key Features:**
- Content request submission
- Community upvoting system
- Development roadmap
- User engagement tracking

---

## 🔧 **UTILITY & PREVIEW SCREENS**

### 35. **Full App Preview Screen** (`lib/features/full_app_preview_screen.dart`)
**Purpose:** Showcase complete app functionality for investors/stakeholders
**Key Features:**
- Feature demonstration
- App capability overview
- Investment presentation support
- Stakeholder engagement

### 36. **Modern Splash Screen** (`lib/core/modern_splash_screen.dart`)
**Purpose:** App initialization and branding
**Key Features:**
- Wisme branding display
- App initialization
- Loading states
- Smooth app entry

---

## 🔄 **NAVIGATION & ROUTING**

The app uses a comprehensive routing system in `main.dart` with 20+ defined routes:

**Core Routes:**
- `/` - Dynamic home based on auth state
- `/auth` - Enhanced authentication
- `/home` - Main dashboard
- `/app` - App shell with navigation

**Onboarding Routes:**
- `/welcome` - Welcome screen
- `/consent` - Research consent
- `/onboarding` - Demographics collection
- `/learning_style` - Learning assessment
- `/baseline_knowledge` - Knowledge test
- `/onboarding_complete` - Completion celebration

**Learning Routes:**
- `/journeys` - Journey selection
- `/audio_player` - Audio learning interface
- `/journey_completion` - Journey celebration

**Feedback Routes:**
- `/first_episode_feedback` - Initial feedback
- `/third_episode_feedback` - Mid-journey feedback
- `/journey_pmf_validation` - PMF assessment
- `/product_interest` - Market interest
- `/final_research_survey` - Study conclusion

**Admin Routes:**
- `/admin` - Admin login
- `/research_analytics` - Analytics dashboard

---

## 📊 **DATA ARCHITECTURE**

The app implements a sophisticated data layer:

**Core Services:**
- `ProgressPersistenceService` (417 lines) - Comprehensive progress tracking
- `ResearchMetricsProvider` (906 lines) - Advanced analytics
- `LocalAudioManager` - Audio file management
- `FirebaseService` - Backend integration

**State Management:**
- Provider pattern throughout
- AuthProvider for authentication
- ResearchMetricsProvider for analytics
- Real-time data synchronization

**Offline Capabilities:**
- Local progress persistence
- Offline queue management
- Background sync when online
- Error recovery systems

---

This comprehensive documentation covers all 35+ screens and their detailed functionality. Each screen is production-ready with proper error handling, analytics integration, and research data collection capabilities.
