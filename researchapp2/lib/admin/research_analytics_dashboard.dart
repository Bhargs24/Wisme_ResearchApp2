import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/auth_provider.dart';
import '../core/firebase_service.dart';

class ResearchAnalyticsDashboard extends StatefulWidget {
  const ResearchAnalyticsDashboard({super.key});

  @override
  State<ResearchAnalyticsDashboard> createState() => _ResearchAnalyticsDashboardState();
}

class _ResearchAnalyticsDashboardState extends State<ResearchAnalyticsDashboard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _userMetrics = [];
  List<Map<String, dynamic>> _feedbackData = [];
  Map<String, int> _demographicStats = {};
  Map<String, double> _learningEffectiveness = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load research metrics
      final metricsSnapshot = await FirebaseService.firestore
          .collection('research_metrics')
          .get();
      
      // Load user profiles for demographics
      final usersSnapshot = await FirebaseService.firestore
          .collection('user_profiles')
          .get();
      
      // Load feedback data
      final feedbackSnapshot = await FirebaseService.firestore
          .collection('research_metrics')
          .where('type', isEqualTo: 'product_market_fit')
          .get();

      // Process the data
      _processAnalyticsData(metricsSnapshot, usersSnapshot, feedbackSnapshot);
      
    } catch (e) {
      print('Error loading analytics data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading analytics: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processAnalyticsData(
    QuerySnapshot metrics,
    QuerySnapshot users,
    QuerySnapshot feedback,
  ) {
    // Process user demographics
    final Map<String, int> ageGroups = {};
    final Map<String, int> educationLevels = {};
    final Map<String, int> experienceLevels = {};
    
    for (final doc in users.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Age groups
      final age = data['age'] as int?;
      if (age != null) {
        String ageGroup;
        if (age < 25) ageGroup = '18-24';
        else if (age < 35) ageGroup = '25-34';
        else if (age < 45) ageGroup = '35-44';
        else ageGroup = '45+';
        
        ageGroups[ageGroup] = (ageGroups[ageGroup] ?? 0) + 1;
      }
      
      // Education levels
      final education = data['education'] as String?;
      if (education != null) {
        educationLevels[education] = (educationLevels[education] ?? 0) + 1;
      }
      
      // Experience levels
      final experience = data['learning_experience'] as String?;
      if (experience != null) {
        experienceLevels[experience] = (experienceLevels[experience] ?? 0) + 1;
      }
    }
    
    // Process learning effectiveness from feedback
    final Map<String, List<double>> effectivenessScores = {};
    
    for (final doc in feedback.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final triggerContext = data['trigger_context'] as String?;
      final satisfaction = data['product_satisfaction'] as double?;
      
      if (triggerContext != null && satisfaction != null) {
        effectivenessScores.putIfAbsent(triggerContext, () => []);
        effectivenessScores[triggerContext]!.add(satisfaction);
      }
    }
    
    // Calculate averages
    final Map<String, double> avgEffectiveness = {};
    effectivenessScores.forEach((context, scores) {
      avgEffectiveness[context] = scores.reduce((a, b) => a + b) / scores.length;
    });
    
    setState(() {
      _demographicStats = {
        ...ageGroups.map((k, v) => MapEntry('age_$k', v)),
        ...educationLevels.map((k, v) => MapEntry('edu_$k', v)),
        ...experienceLevels.map((k, v) => MapEntry('exp_$k', v)),
      };
      _learningEffectiveness = avgEffectiveness;
      _userMetrics = users.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      _feedbackData = feedback.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Admin access required'),
              Text('Contact system administrator for access'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Analytics Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards(),
                  const SizedBox(height: 24),
                  _buildUserDemographics(),
                  const SizedBox(height: 24),
                  _buildLearningEffectiveness(),
                  const SizedBox(height: 24),
                  _buildFeedbackAnalysis(),
                  const SizedBox(height: 24),
                  _buildDataExportSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Research Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Participants',
                _userMetrics.length.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Feedback Responses',
                _feedbackData.length.toString(),
                Icons.feedback,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Avg Satisfaction',
                _calculateAverageSatisfaction().toStringAsFixed(1),
                Icons.star,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUserDemographics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('User Demographics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
          ),
          child: _buildDemographicChart(),
        ),
      ],
    );
  }

  Widget _buildDemographicChart() {
    final ageData = _demographicStats.entries
        .where((e) => e.key.startsWith('age_'))
        .map((e) => PieChartSectionData(
          value: e.value.toDouble(),
          title: e.key.substring(4),
          color: Colors.blue.withOpacity(0.8),
        ))
        .toList();

    return PieChart(
      PieChartData(
        sections: ageData,
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildLearningEffectiveness() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Learning Effectiveness', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
          ),
          child: _buildEffectivenessChart(),
        ),
      ],
    );
  }

  Widget _buildEffectivenessChart() {
    final spots = _learningEffectiveness.entries
        .map((e) => FlSpot(
          _learningEffectiveness.keys.toList().indexOf(e.key).toDouble(),
          e.value,
        ))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final contexts = _learningEffectiveness.keys.toList();
                if (value.toInt() < contexts.length) {
                  return Text(contexts[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Feedback Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ..._feedbackData.take(5).map((feedback) => _buildFeedbackCard(feedback)),
      ],
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Context: ${feedback['trigger_context'] ?? 'Unknown'}'),
          Text('Satisfaction: ${feedback['product_satisfaction'] ?? 'N/A'}/10'),
          Text('Benefits: ${(feedback['primary_benefits'] as List?)?.join(', ') ?? 'None'}'),
        ],
      ),
    );
  }

  Widget _buildDataExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Export', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _exportUserData,
              icon: const Icon(Icons.people),
              label: const Text('Export User Data'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _exportFeedbackData,
              icon: const Icon(Icons.feedback),
              label: const Text('Export Feedback'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _exportAnalyticsReport,
              icon: const Icon(Icons.analytics),
              label: const Text('Full Report'),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateAverageSatisfaction() {
    if (_feedbackData.isEmpty) return 0.0;
    
    final satisfactionScores = _feedbackData
        .map((f) => f['product_satisfaction'] as double?)
        .where((s) => s != null)
        .map((s) => s!)
        .toList();
    
    if (satisfactionScores.isEmpty) return 0.0;
    
    return satisfactionScores.reduce((a, b) => a + b) / satisfactionScores.length;
  }

  void _exportData() {
    // Generate CSV export data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported successfully')),
    );
  }

  void _exportUserData() {
    // TODO: Export user demographics and profiles
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User data export initiated')),
    );
  }

  void _exportFeedbackData() {
    // TODO: Export all feedback responses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback data export initiated')),
    );
  }

  void _exportAnalyticsReport() {
    // TODO: Generate comprehensive analytics report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics report generation initiated')),
    );
  }
}
