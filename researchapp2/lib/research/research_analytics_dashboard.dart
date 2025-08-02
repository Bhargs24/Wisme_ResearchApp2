import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/research_metrics_provider.dart';

class ResearchAnalyticsDashboard extends StatefulWidget {
  const ResearchAnalyticsDashboard({super.key});

  @override
  State<ResearchAnalyticsDashboard> createState() => _ResearchAnalyticsDashboardState();
}

class _ResearchAnalyticsDashboardState extends State<ResearchAnalyticsDashboard> {
  late final ResearchMetricsProvider _researchProvider;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _researchProvider = ResearchMetricsProvider();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _researchProvider.getResearchAnalytics();
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Analytics'),
        backgroundColor: const Color(0xFF2D3748),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalyticsData,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportData,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _analyticsData == null
          ? const Center(child: Text('No analytics data available'))
          : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    final data = _analyticsData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(data),
          const SizedBox(height: 24),
          _buildPMFAnalysis(data),
          const SizedBox(height: 24),
          _buildEngagementMetrics(data),
          const SizedBox(height: 24),
          _buildCommercialValidation(data),
          const SizedBox(height: 24),
          _buildUserJourneyProgress(data),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Research Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'Total Users',
              '${data['totalUsers'] ?? 0}',
              Icons.people,
              Colors.blue,
            ),
            _buildMetricCard(
              'PMF Score',
              '${(data['pmfScore'] ?? 0.0).toStringAsFixed(1)}',
              Icons.star,
              _getPMFColor(data['pmfScore'] ?? 0.0),
            ),
            _buildMetricCard(
              'Avg NPS',
              '${(data['averageNPS'] ?? 0.0).toStringAsFixed(1)}',
              Icons.sentiment_satisfied,
              _getNPSColor(data['averageNPS'] ?? 0.0),
            ),
            _buildMetricCard(
              'Journey Completion',
              '${(data['journeyCompletionRate'] ?? 0.0).toStringAsFixed(1)}%',
              Icons.flag,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPMFAnalysis(Map<String, dynamic> data) {
    final pmfDistribution = data['pmfDistribution'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product-Market Fit Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPMFPieChartSections(pmfDistribution),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildPMFLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPMFPieChartSections(Map<String, dynamic> distribution) {
    final colors = [Colors.red, Colors.orange, Colors.green];
    final categories = ['Very Disappointed', 'Somewhat Disappointed', 'Not Disappointed'];
    
    return List.generate(3, (index) {
      final value = (distribution[categories[index]] ?? 0).toDouble();
      return PieChartSectionData(
        color: colors[index],
        value: value,
        title: '${value.toInt()}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildPMFLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Very Disappointed', Colors.red),
        _buildLegendItem('Somewhat Disappointed', Colors.orange),
        _buildLegendItem('Not Disappointed', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEngagementMetrics(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement Metrics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEngagementStat(
                    'Avg Episodes per User',
                    '${(data['averageEpisodesPerUser'] ?? 0.0).toStringAsFixed(1)}',
                  ),
                ),
                Expanded(
                  child: _buildEngagementStat(
                    'Avg Session Duration',
                    '${(data['averageSessionDuration'] ?? 0.0).toStringAsFixed(0)}min',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEngagementStat(
                    'Feature Interest Score',
                    '${(data['averageFeatureInterest'] ?? 0.0).toStringAsFixed(1)}/10',
                  ),
                ),
                Expanded(
                  child: _buildEngagementStat(
                    'Learning Effectiveness',
                    '${(data['averageLearningEffectiveness'] ?? 0.0).toStringAsFixed(1)}/10',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCommercialValidation(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Commercial Validation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCommercialStat(
                    'Willing to Pay',
                    '${(data['willingToPayPercentage'] ?? 0.0).toStringAsFixed(1)}%',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildCommercialStat(
                    'Avg Pain Point Severity',
                    '${(data['averagePainPointSeverity'] ?? 0.0).toStringAsFixed(1)}/10',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Top Requested Features:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...((data['topFeatures'] as List<dynamic>?) ?? [])
                .take(5)
                .map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(feature.toString()),
                        ],
                      ),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildCommercialStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserJourneyProgress(Map<String, dynamic> data) {
    final journeyData = data['journeyProgress'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Journey Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...journeyData.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text('${(entry.value as double).toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: (entry.value as double) / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getPMFColor(double score) {
    if (score >= 40) return Colors.green;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }

  Color _getNPSColor(double score) {
    if (score >= 50) return Colors.green;
    if (score >= 0) return Colors.orange;
    return Colors.red;
  }

  Future<void> _exportData() async {
    try {
      final exported = await _researchProvider.exportResearchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Research data exported successfully: ${exported['filename']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
