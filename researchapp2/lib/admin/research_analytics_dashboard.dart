import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../core/auth_provider.dart';
import '../core/firebase_service.dart';
import '../research/essential_metrics_exporter.dart';

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
          // 🎯 ESSENTIAL METRICS EXPORT - Admin Only
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: _handleExport,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'essential_json',
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 16),
                    SizedBox(width: 8),
                    Text('Essential Metrics (JSON)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'essential_csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 16),
                    SizedBox(width: 8),
                    Text('Essential Metrics (CSV)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'research_summary',
                child: Row(
                  children: [
                    Icon(Icons.summarize, size: 16),
                    SizedBox(width: 8),
                    Text('Research Summary'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'raw_data',
                child: Row(
                  children: [
                    Icon(Icons.data_object, size: 16),
                    SizedBox(width: 8),
                    Text('Raw Data Export'),
                  ],
                ),
              ),
            ],
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
        const Text('🎯 Essential Research Metrics Export', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Export only the critical metrics needed to validate your conversational learning method.', 
                   style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        
        // Essential Metrics Preview Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📊 Available Exports:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                _buildExportOption(
                  icon: Icons.analytics,
                  title: 'Essential Metrics (JSON)',
                  description: 'Complete dataset for research analysis',
                  action: () => _handleExport('essential_json'),
                ),
                
                _buildExportOption(
                  icon: Icons.table_chart,
                  title: 'Essential Metrics (CSV)',
                  description: 'Spreadsheet-friendly format',
                  action: () => _handleExport('essential_csv'),
                ),
                
                _buildExportOption(
                  icon: Icons.summarize,
                  title: 'Research Summary',
                  description: 'Key findings and conclusions',
                  action: () => _handleExport('research_summary'),
                ),
                
                _buildExportOption(
                  icon: Icons.data_object,
                  title: 'Raw Data Export',
                  description: 'All collected data for deep analysis',
                  action: () => _handleExport('raw_data'),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Metrics are copied to clipboard. Paste into your research documents or analysis tools.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback action,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: action,
            child: const Text('Export'),
          ),
        ],
      ),
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

  // 🎯 ESSENTIAL METRICS EXPORT METHODS - Admin Only
  Future<void> _handleExport(String exportType) async {
    try {
      switch (exportType) {
        case 'essential_json':
          await _exportEssentialMetricsJSON();
          break;
        case 'essential_csv':
          await _exportEssentialMetricsCSV();
          break;
        case 'research_summary':
          await _exportResearchSummary();
          break;
        case 'raw_data':
          await _exportRawData();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  /// 📊 Export Essential Metrics as JSON
  Future<void> _exportEssentialMetricsJSON() async {
    final metrics = await EssentialMetricsExporter.getEssentialMetrics();
    
    // Copy to clipboard for now (file download requires platform-specific implementation)
    final jsonString = const JsonEncoder.withIndent('  ').convert(metrics);
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Essential metrics JSON copied to clipboard!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    // Show summary dialog
    _showMetricsSummary(metrics);
  }

  /// 📊 Export Essential Metrics as CSV
  Future<void> _exportEssentialMetricsCSV() async {
    final csvContent = await EssentialMetricsExporter.exportToCSV();
    await Clipboard.setData(ClipboardData(text: csvContent));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Essential metrics CSV copied to clipboard!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 📋 Export Research Summary
  Future<void> _exportResearchSummary() async {
    final metrics = await EssentialMetricsExporter.getEssentialMetrics();
    final summary = _generateResearchSummary(metrics);
    
    await Clipboard.setData(ClipboardData(text: summary));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Research summary copied to clipboard!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 📋 Generate Research Summary Text
  String _generateResearchSummary(Map<String, dynamic> metrics) {
    final learning = metrics['learningEffectiveness'] as Map<String, dynamic>;
    final commercial = metrics['commercialValidation'] as Map<String, dynamic>;
    final engagement = metrics['engagementMetrics'] as Map<String, dynamic>;
    final satisfaction = metrics['satisfactionMetrics'] as Map<String, dynamic>;
    
    return '''
🔬 WISME CONVERSATIONAL LEARNING - RESEARCH SUMMARY
Generated: ${DateTime.now().toString()}

📊 SAMPLE SIZE: ${metrics['totalUsers']} users

🎯 KEY FINDINGS:

1. LEARNING EFFECTIVENESS
   • Average Learning Effectiveness: ${learning['averageLearningEffectiveness']?.toStringAsFixed(1) ?? 'N/A'}/10
   • Average Concept Clarity: ${learning['averageConceptClarity']?.toStringAsFixed(1) ?? 'N/A'}/10
   • Users Rating 8+ (Effective): ${learning['percentAbove8']?.toStringAsFixed(1) ?? 'N/A'}%

2. COMMERCIAL VALIDATION
   • Product-Market Fit Score: ${commercial['pmfScore']?.toStringAsFixed(1) ?? 'N/A'}% (Target: >40%)
   • Net Promoter Score: ${commercial['npsScore'] ?? 'N/A'} (Target: >50)
   • Avg Willingness to Pay: \$${commercial['averageWillingnessToPayMonthly']?.toStringAsFixed(2) ?? 'N/A'}/month

3. USER ENGAGEMENT
   • Average Engagement Score: ${engagement['averageEngagementScore']?.toStringAsFixed(1) ?? 'N/A'}/10
   • High Engagement Rate: ${engagement['highEngagementPercentage']?.toStringAsFixed(1) ?? 'N/A'}%
   • Total Episode Completions: ${engagement['totalEpisodeCompletions'] ?? 'N/A'}

4. SATISFACTION
   • Average Satisfaction: ${satisfaction['averageSatisfaction']?.toStringAsFixed(1) ?? 'N/A'}/10
   • High Satisfaction Rate: ${satisfaction['highSatisfactionPercentage']?.toStringAsFixed(1) ?? 'N/A'}%

🎯 RESEARCH CONCLUSION:
${_getResearchConclusion(learning, commercial, engagement, satisfaction)}

📈 INVESTOR METRICS:
• PMF Score: ${commercial['pmfScore']?.toStringAsFixed(1) ?? 'N/A'}% ${(commercial['pmfScore'] ?? 0) > 40 ? '✅ STRONG' : '⚠️ NEEDS IMPROVEMENT'}
• NPS: ${commercial['npsScore'] ?? 'N/A'} ${(commercial['npsScore'] ?? 0) > 50 ? '✅ EXCELLENT' : (commercial['npsScore'] ?? 0) > 0 ? '⚠️ GOOD' : '❌ POOR'}
• Learning Effectiveness: ${learning['averageLearningEffectiveness']?.toStringAsFixed(1) ?? 'N/A'}/10 ${(learning['averageLearningEffectiveness'] ?? 0) > 7.5 ? '✅ STRONG' : '⚠️ MODERATE'}

📋 Next Steps: ${_getNextSteps(metrics)}
    ''';
  }

  String _getResearchConclusion(Map<String, dynamic> learning, Map<String, dynamic> commercial, Map<String, dynamic> engagement, Map<String, dynamic> satisfaction) {
    final learningScore = learning['averageLearningEffectiveness'] ?? 0;
    final pmfScore = commercial['pmfScore'] ?? 0;
    final engagementScore = engagement['averageEngagementScore'] ?? 0;
    
    if (learningScore > 7.5 && pmfScore > 40 && engagementScore > 7.5) {
      return "STRONG VALIDATION: Conversational learning method shows significant effectiveness with strong commercial viability.";
    } else if (learningScore > 6.5 && pmfScore > 20) {
      return "MODERATE VALIDATION: Method shows promise but requires optimization for stronger market validation.";
    } else {
      return "EARLY STAGE: Collect more data and optimize user experience before drawing conclusions.";
    }
  }

  String _getNextSteps(Map<String, dynamic> metrics) {
    final totalUsers = metrics['totalUsers'] ?? 0;
    final commercial = metrics['commercialValidation'] as Map<String, dynamic>;
    final pmfScore = commercial['pmfScore'] ?? 0;
    
    if (totalUsers < 50) {
      return "1. Recruit more users (target: 100+) 2. Gather more feedback data 3. Optimize onboarding";
    } else if (pmfScore < 40) {
      return "1. Improve product-market fit 2. Enhance user experience 3. Validate pricing strategy";
    } else {
      return "1. Scale user acquisition 2. Prepare investor deck 3. Optimize monetization";
    }
  }

  /// 📊 Show Metrics Summary Dialog
  void _showMetricsSummary(Map<String, dynamic> metrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 Essential Metrics Summary'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Users: ${metrics['totalUsers']}'),
              const SizedBox(height: 16),
              
              const Text('🎯 Learning Effectiveness:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Concept Clarity: ${(metrics['learningEffectiveness']['averageConceptClarity'] ?? 0).toStringAsFixed(1)}/10'),
              Text('• Learning Effectiveness: ${(metrics['learningEffectiveness']['averageLearningEffectiveness'] ?? 0).toStringAsFixed(1)}/10'),
              const SizedBox(height: 16),
              
              const Text('💰 Commercial Validation:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• PMF Score: ${(metrics['commercialValidation']['pmfScore'] ?? 0).toStringAsFixed(1)}%'),
              Text('• NPS: ${metrics['commercialValidation']['npsScore'] ?? 'N/A'}'),
              Text('• Willingness to Pay: \$${(metrics['commercialValidation']['averageWillingnessToPayMonthly'] ?? 0).toStringAsFixed(2)}/month'),
              const SizedBox(height: 16),
              
              const Text('📈 Engagement:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Avg Engagement: ${(metrics['engagementMetrics']['averageEngagementScore'] ?? 0).toStringAsFixed(1)}/10'),
              Text('• High Engagement: ${(metrics['engagementMetrics']['highEngagementPercentage'] ?? 0).toStringAsFixed(1)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// 📄 Export Raw Data
  Future<void> _exportRawData() async {
    final metrics = await EssentialMetricsExporter.getEssentialMetrics();
    final rawData = metrics['rawData'];
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(rawData);
    await Clipboard.setData(ClipboardData(text: jsonString));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Raw research data copied to clipboard!'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
