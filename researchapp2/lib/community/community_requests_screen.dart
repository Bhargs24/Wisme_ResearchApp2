import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityRequestsScreen extends StatefulWidget {
  const CommunityRequestsScreen({super.key});

  @override
  State<CommunityRequestsScreen> createState() => _CommunityRequestsScreenState();
}

class _CommunityRequestsScreenState extends State<CommunityRequestsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildRequestsList(),
                    const SizedBox(height: 100), // Bottom padding
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
          'Community Requests',
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
                AppColors.accentGreen.withOpacity(0.3),
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
            AppColors.accentGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentGreen, AppColors.primaryBlue],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Requests',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'See what topics the community wants to learn',
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
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Community learning requests - Help shape what gets created next',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryBlue,
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

  Widget _buildRequestsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadCommunityRequests(),
          builder: (context, communitySnapshot) {
            if (communitySnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            
            // Get community requests
            final communityRequests = communitySnapshot.data ?? [];
            final realRequests = snapshot.hasData 
                ? _processFirebaseRequests(snapshot.data!.docs)
                : <Map<String, dynamic>>[];
            
            // Combine real requests with community requests
            final allRequests = [...realRequests, ...communityRequests];
            
            // Sort by timestamp (most recent first)
            allRequests.sort((a, b) => 
              (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
            
            if (allRequests.isEmpty) {
              return _buildEmptyState();
            }
            
            return Column(
              children: allRequests.asMap().entries.map((entry) {
                final index = entry.key;
                final request = entry.value;
                
                return AnimatedBuilder(
                  animation: _staggerController,
                  builder: (context, child) {
                    final animationValue = Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _staggerController,
                        curve: Interval(
                          (index * 0.1).clamp(0.0, 1.0),
                          ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                          curve: Curves.easeOut,
                        ),
                      ),
                    );
                    
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - animationValue.value)),
                      child: Opacity(
                        opacity: animationValue.value,
                        child: _buildSimpleRequestCard(request, index),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _processFirebaseRequests(List<DocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'topic': data['topic'] ?? 'Unknown Topic',
        'requesterName': data['requesterName'] ?? 'Anonymous',
        'isAnonymous': data['isAnonymous'] ?? true,
        'timestamp': data['timestamp'] != null 
            ? DateTime.parse(data['timestamp'] as String)
            : DateTime.now(),
        'isUserGenerated': true,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadCommunityRequests() async {
    try {
      // Load real community requests from Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('community_requests')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      
      if (snapshot.docs.isEmpty) {
        // If no requests exist yet, return empty list
        return [];
      }
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'topic': data['topic'] ?? 'Unknown Topic',
          'requesterName': data['requesterName'] ?? 'Anonymous',
          'isAnonymous': data['isAnonymous'] ?? true,
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'isUserGenerated': data['isUserGenerated'] ?? true,
          'description': data['description'] ?? '',
          'category': data['category'] ?? 'General',
          'votes': data['votes'] ?? 0,
          'status': data['status'] ?? 'pending',
        };
      }).toList();
    } catch (e) {
      debugPrint('Failed to load community requests: $e');
      // Return empty list instead of hardcoded demo data
      return [];
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.white38,
          ),
          const SizedBox(height: 24),
          Text(
            'No requests yet',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to suggest a learning topic!',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getRequestsStream() {
    return FirebaseService.firestore
        .collection('topic_suggestions')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accentGreen,
                strokeWidth: 2,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSimpleRequestCard(Map<String, dynamic> request, int index) {
    final timestamp = request['timestamp'] is DateTime 
        ? request['timestamp'] as DateTime
        : DateTime.parse(request['timestamp'] as String);
    
    final timeAgo = _getTimeAgo(timestamp);
    final isAnonymous = request['isAnonymous'] ?? true;
    final requesterName = request['requesterName'] ?? 'Anonymous';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundCard.withOpacity(0.4),
            AppColors.backgroundCard.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Topic content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['topic'] as String,
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isAnonymous ? Icons.person_outline : Icons.person,
                        color: Colors.white60,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAnonymous ? 'Anonymous' : requesterName,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status indicator
            if (request['isUserGenerated'] == true) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Live',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      heroTag: "community_fab",
      onPressed: () => Navigator.pushNamed(context, '/suggest_topic'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.accentGreen],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Suggest Topic',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
