import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/work_monitor.dart';
import '../services/message_filter.dart';
import '../models/work_session.dart';
import '../utils/database_helper.dart';
import '../utils/advanced_analytics.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final AdvancedAnalytics _analytics = AdvancedAnalytics.instance;
  
  List<WorkSession> _workSessions = [];
  Map<String, int> _weeklyStats = {};
  Map<String, int> _appUsageStats = {};
  WorkLifeBalanceReport? _balanceReport;
  WorkIntensityReport? _intensityReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取最近30天的工作会话
      final sessions = await _db.getWorkSessions(30);
      final weeklyStats = await _calculateWeeklyStats(sessions);
      final appStats = await _calculateAppUsageStats(sessions);
      final balanceReport = await _analytics.analyzeWorkLifeBalance(30);
      final intensityReport = await _analytics.analyzeWorkIntensity(30);

      setState(() {
        _workSessions = sessions;
        _weeklyStats = weeklyStats;
        _appUsageStats = appStats;
        _balanceReport = balanceReport;
        _intensityReport = intensityReport;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载统计数据失败: $e')),
        );
      }
    }
  }

  Future<Map<String, int>> _calculateWeeklyStats(List<WorkSession> sessions) async {
    final stats = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.month}/${date.day}';
      
      final dayMinutes = sessions
          .where((s) => _isSameDay(s.createdAt, date) && s.isOvertime)
          .fold(0, (sum, s) => sum + (s.duration ~/ 60));
      
      stats[dateKey] = dayMinutes;
    }
    
    return stats;
  }

  Future<Map<String, int>> _calculateAppUsageStats(List<WorkSession> sessions) async {
    final stats = <String, int>{};
    
    for (final session in sessions.where((s) => s.isOvertime)) {
      final appName = session.appName;
      stats[appName] = (stats[appName] ?? 0) + (session.duration ~/ 60);
    }
    
    return stats;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工时统计'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '概览', icon: Icon(Icons.dashboard)),
            Tab(text: '趋势', icon: Icon(Icons.trending_up)),
            Tab(text: '应用', icon: Icon(Icons.apps)),
            Tab(text: '分析', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTrendTab(),
                _buildAppUsageTab(),
                _buildAnalysisTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final totalOvertimeMinutes = _workSessions
        .where((s) => s.isOvertime)
        .fold(0, (sum, s) => sum + (s.duration ~/ 60));
    
    final overtimeDays = _workSessions
        .where((s) => s.isOvertime)
        .map((s) => '${s.createdAt.year}-${s.createdAt.month}-${s.createdAt.day}')
        .toSet()
        .length;

    final avgOvertimePerDay = overtimeDays > 0 ? totalOvertimeMinutes / overtimeDays : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总体统计卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近30天统计',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewItem(
                          '总加班时长',
                          '${totalOvertimeMinutes}分钟',
                          Icons.access_time,
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildOverviewItem(
                          '加班天数',
                          '$overtimeDays天',
                          Icons.calendar_today,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOverviewItem(
                          '日均加班',
                          '${avgOvertimePerDay.toStringAsFixed(1)}分钟',
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildOverviewItem(
                          '记录总数',
                          '${_workSessions.length}条',
                          Icons.list,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 最近记录
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近记录',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._workSessions.take(5).map((session) => _buildSessionItem(session)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(WorkSession session) {
    return ListTile(
      leading: Icon(
        session.isOvertime ? Icons.warning : Icons.work,
        color: session.isOvertime ? Colors.orange : Colors.blue,
      ),
      title: Text(session.appName),
      subtitle: Text(
        '${session.createdAt.month}/${session.createdAt.day} ${session.createdAt.hour}:${session.createdAt.minute.toString().padLeft(2, '0')}',
      ),
      trailing: Text(
        '${session.duration ~/ 60}分钟',
        style: TextStyle(
          color: session.isOvertime ? Colors.orange : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTrendTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近7天加班趋势',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}分');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final keys = _weeklyStats.keys.toList();
                                if (value.toInt() < keys.length) {
                                  return Text(keys[value.toInt()]);
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _weeklyStats.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value.value.toDouble(),
                                    ))
                                .toList(),
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageTab() {
    final sortedApps = _appUsageStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '应用使用时长排行',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...sortedApps.map((entry) => _buildAppUsageItem(
                    entry.key,
                    entry.value,
                    sortedApps.first.value,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageItem(String appName, int minutes, int maxMinutes) {
    final percentage = maxMinutes > 0 ? minutes / maxMinutes : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${minutes}分钟',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ],
      ),
    );
  }
}
  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 工作生活平衡分析
          if (_balanceReport != null) _buildBalanceAnalysis(),
          
          const SizedBox(height: 20),
          
          // 工作强度分析
          if (_intensityReport != null) _buildIntensityAnalysis(),
          
          const SizedBox(height: 20),
          
          // 健康建议
          _buildHealthRecommendations(),
        ],
      ),
    );
  }

  Widget _buildBalanceAnalysis() {
    final report = _balanceReport!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工作生活平衡分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 平衡分数
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${report.balanceScore.toStringAsFixed(0)}分',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getBalanceColor(report.balanceScore),
                        ),
                      ),
                      Text(
                        '平衡指数',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: LinearProgressIndicator(
                    value: report.balanceScore / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getBalanceColor(report.balanceScore),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 详细数据
            Row(
              children: [
                Expanded(
                  child: _buildBalanceItem(
                    '工作日均时长',
                    '${report.weekdayAverageHours.toStringAsFixed(1)}小时',
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildBalanceItem(
                    '周末工作时长',
                    '${report.weekendAverageHours.toStringAsFixed(1)}小时',
                    Icons.weekend,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 建议
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.recommendation,
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntensityAnalysis() {
    final report = _intensityReport!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工作强度分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 峰值时间
            Row(
              children: [
                Expanded(
                  child: _buildIntensityItem(
                    '工作峰值时间',
                    '${report.peakHour}:00',
                    Icons.schedule,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildIntensityItem(
                    '平均强度',
                    report.averageIntensity.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 24小时强度图表
            Text(
              '24小时工作强度分布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: report.intensityIndex.values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 4 == 0) {
                            return Text('${value.toInt()}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: report.intensityIndex.entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: _getIntensityColor(entry.value, report.averageIntensity),
                          width: 8,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecommendations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '健康建议',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildRecommendationItem(
              Icons.schedule,
              '设定工作边界',
              '建议设置明确的上下班时间，避免工作时间过长',
              Colors.blue,
            ),
            
            _buildRecommendationItem(
              Icons.notifications_off,
              '关闭非工作时间通知',
              '在休息时间关闭工作相关应用的通知',
              Colors.orange,
            ),
            
            _buildRecommendationItem(
              Icons.self_improvement,
              '定期休息',
              '每工作1小时休息10-15分钟，保护身心健康',
              Colors.green,
            ),
            
            _buildRecommendationItem(
              Icons.weekend,
              '保护周末时间',
              '尽量避免在周末处理工作事务，享受个人时间',
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIntensityItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBalanceColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getIntensityColor(double intensity, double average) {
    if (intensity > average * 1.5) return Colors.red;
    if (intensity > average) return Colors.orange;
    return Colors.green;
  }