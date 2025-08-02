import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/research_metrics_provider.dart';
import '../core/firebase_service.dart';
import 'package:provider/provider.dart';

class TopicSuggestionScreen extends StatefulWidget {
  const TopicSuggestionScreen({super.key});

  @override
  State<TopicSuggestionScreen> createState() => _TopicSuggestionScreenState();
}

class _TopicSuggestionScreenState extends State<TopicSuggestionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  String _selectedCategory = 'Technical';
  bool _isSubmitting = false;
  bool _showSuccess = false;
  
  final List<String> _categories = [
    'Technical',
    'Business',
    'Creative',
    'Life Skills',
    'Science',
    'Languages',
    'Other'
  ];
  
  final List<String> _popularSuggestions = [
    'Machine Learning',
    'Blockchain',
    'Mobile Development',
    'UI/UX Design',
    'Digital Marketing',
    'Photography',
    'Cooking',
    'Public Speaking'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _topicController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submitSuggestion() async {
    if (_topicController.text.trim().isEmpty) {
      _showSnackBar('Please enter a topic name', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final research = Provider.of<ResearchMetricsProvider>(context, listen: false);
      
      await FirebaseService.submitFeedback({
        'type': 'topic_suggestion',
        'userId': research.userId,
        'data': {
          'topic': _topicController.text.trim(),
          'category': _selectedCategory,
          'reason': _reasonController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
          'userProfile': research.userProfile,
        }
      });

      // Track this as a research metric
      research.captureTopicSuggestion(
        topic: _topicController.text.trim(),
        category: _selectedCategory,
        reason: _reasonController.text.trim(),
      );

      setState(() {
        _isSubmitting = false;
        _showSuccess = true;
      });

      // Show success animation and reset form
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccess = false;
            _topicController.clear();
            _reasonController.clear();
            _selectedCategory = 'Technical';
          });
        }
      });

      _showSnackBar('Thanks for your suggestion! 🚀');
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar('Error submitting suggestion. Please try again.', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.accentRed : AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addPopularSuggestion(String suggestion) {
    setState(() {
      _topicController.text = suggestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildSuggestionForm(),
                    const SizedBox(height: 32),
                    _buildPopularSuggestions(),
                    const SizedBox(height: 32),
                    _buildWantMoreSection(),
                    const SizedBox(height: 100), // Bottom padding
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.backgroundCard.withOpacity(0.8),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Suggest a Topic',
          style: AppTextStyles.heading2.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryBlue.withOpacity(0.3),
                AppColors.backgroundDark,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.accentGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.accentGreen],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shape the Future',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Your suggestions help us create content you actually want',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentGreen,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is demo research data - suggestions help validate user interest in conversational learning',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentGreen,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionForm() {
    if (_showSuccess) {
      return _buildSuccessAnimation();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you love to learn?',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            
            // Topic input field
            _buildModernTextField(
              controller: _topicController,
              label: 'Topic Name',
              hint: 'e.g., Machine Learning, Public Speaking...',
              icon: Icons.school_outlined,
            ),
            
            const SizedBox(height: 20),
            
            // Category selection
            Text(
              'Category',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [AppColors.primaryBlue, AppColors.accentGreen],
                            )
                          : null,
                      color: isSelected ? null : AppColors.backgroundCard.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Reason field
            _buildModernTextField(
              controller: _reasonController,
              label: 'Why this topic? (Optional)',
              hint: 'Tell us why you want to learn this...',
              icon: Icons.chat_bubble_outline,
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitSuggestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Send Suggestion',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.caption.copyWith(color: Colors.white38),
              prefixIcon: Icon(icon, color: AppColors.primaryBlue),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGreen.withOpacity(0.2),
            AppColors.primaryBlue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 1),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Suggestion Submitted! 🎉',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Thanks for helping shape the future of learning!',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Ideas',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to add these popular suggestions',
          style: AppTextStyles.caption.copyWith(
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSuggestions.map((suggestion) {
            return GestureDetector(
              onTap: () => _addPopularSuggestion(suggestion),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      suggestion,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWantMoreSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch,
            color: AppColors.accentGreen,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Want More Topics?',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The full Wisme app will have AI-powered content generation that creates personalized learning journeys based on your suggestions and interests.',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/community_requests');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentGreen),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See What Others Want',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: AppColors.accentGreen,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
