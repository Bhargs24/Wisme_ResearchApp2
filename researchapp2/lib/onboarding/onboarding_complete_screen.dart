import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/auth_provider.dart';
import '../core/firebase_service.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.accentGreen.withOpacity(0.3),
              AppColors.primaryBlue.withOpacity(0.2),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSuccessIcon(),
                          const SizedBox(height: 32),
                          _buildWelcomeMessage(),
                          const SizedBox(height: 48),
                          _buildFeaturePreview(),
                          const SizedBox(height: 48),
                          _buildResearchDisclaimer(),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildGetStartedButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentGreen, AppColors.primaryBlue],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 60,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'You\'re All Set! 🎉',
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your learning profile has been created. Now let\'s explore the future of conversational education.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturePreview() {
    final features = [
      {
        'icon': Icons.headphones,
        'title': 'Interactive Audio',
        'description': 'Learn through engaging conversations',
        'color': AppColors.primaryBlue,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Smart Progress',
        'description': 'Track your learning journey',
        'color': AppColors.accentGreen,
      },
      {
        'icon': Icons.people_outline,
        'title': 'Community Ideas',
        'description': 'Suggest and discover new topics',
        'color': AppColors.accentRed,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Inside',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 200)),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (feature['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (feature['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: feature['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature['title'] as String,
                                style: AppTextStyles.heading2.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                feature['description'] as String,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildResearchDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.science,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Research Demo',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'This demo helps validate our learning approach with real user data for investors',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Mark onboarding as complete in user profile
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.user != null) {
            await FirebaseService.createOrUpdateUserProfile(
              authProvider.user!.uid, 
              {'onboardingComplete': true}
            );
            
            // Reload user profile to get updated data
            await authProvider.reloadUserProfile();
          }
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/app');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentGreen],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start Your Journey',
                  style: AppTextStyles.heading2.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
