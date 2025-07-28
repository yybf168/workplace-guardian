import 'package:flutter/material.dart';
import '../services/smart_reminder_service.dart';
import '../utils/advanced_analytics.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SmartReminderService _reminderService = SmartReminderService.instance;
  final AdvancedAnalytics _analytics = AdvancedAnalytics.instance;
  
  List<String> _healthSuggestions = [];
  List<String> _productivitySuggestions = [];
  WorkLifeBalanceReport? _balanceReport;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHealthData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final healthSuggestions = await _reminderService.generateHealthSuggestions();
      final productivitySuggestions = await _reminderService.generateProductivitySuggestions();
      final balanceReport = await _analytics.analyzeWorkLifeBalance(30);

      setState(() {
        _healthSuggestions = healthSuggestions;
        _productivitySuggestions = productivitySuggestions;
        _balanceReport = balanceReport;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载健康数据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('健康中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthData,
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            onPressed: _performHealthCheck,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '健康建议', icon: Icon(Icons.favorite)),
            Tab(text: '效率提升', icon: Icon(Icons.trending_up)),
            Tab(text: '平衡分析', icon: Icon(Icons.balance)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHealthSuggestions(),
                _buildProductivitySuggestions(),
                _buildBalanceAnalysis(),
              ],
            ),
    );
  }

  Widget _buildHealthSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 健康状态卡片
          _buildHealthStatusCard(),
          
          const SizedBox(height: 20),
          
          // 健康建议列表
          Text(
            '个性化健康建议',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._healthSuggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            return _buildSuggestionCard(
              suggestion,
              _getHealthIcon(index),
              _getHealthColor(index),
            );
          }),
          
          const SizedBox(height: 20),
          
          // 快速操作
          _buildQuickHealthActions(),
        ],
      ),
    );
  }

  Widget _buildProductivitySuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 效率状态卡片
          _buildProductivityStatusCard(),
          
          const SizedBox(height: 20),
          
          // 效率建议列表
          Text(
            '效率提升建议',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._productivitySuggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final suggestion = entry.value;
            return _buildSuggestionCard(
              suggestion,
              _getProductivityIcon(index),
              _getProductivityColor(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBalanceAnalysis() {
    if (_balanceReport == null) {
      return const Center(
        child: Text('暂无平衡分析数据'),
      );
    }

    final report = _balanceReport!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 平衡指数卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '工作生活平衡指数',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 圆形进度指示器
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: report.balanceScore / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getBalanceColor(report.balanceScore),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${report.balanceScore.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: _getBalanceColor(report.balanceScore),
                              ),
                            ),
                            Text(
                              '分',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    _getBalanceDescription(report.balanceScore),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 详细分析
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '详细分析',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildAnalysisItem(
                    '工作日平均时长',
                    '${report.weekdayAverageHours.toStringAsFixed(1)} 小时',
                    Icons.work,
                    Colors.blue,
                  ),
                  
                  _buildAnalysisItem(
                    '周末工作时长',
                    '${report.weekendAverageHours.toStringAsFixed(1)} 小时',
                    Icons.weekend,
                    Colors.orange,
                  ),
                  
                  _buildAnalysisItem(
                    '加班比例',
                    '${(report.overtimeRatio * 100).toStringAsFixed(1)}%',
                    Icons.access_time,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 改善建议
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '改善建议',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue),
                        const SizedBox(width: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '健康状态良好',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '继续保持良好的工作习惯',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up,
                color: Colors.blue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '效率有待提升',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '参考以下建议优化工作效率',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(String suggestion, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(suggestion),
        trailing: IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {
            // 收藏建议功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('建议已收藏')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnalysisItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHealthActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速操作',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _performHealthCheck,
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('健康检查'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showReminderSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('提醒设置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getHealthIcon(int index) {
    final icons = [
      Icons.schedule,
      Icons.visibility,
      Icons.local_drink,
      Icons.directions_run,
      Icons.shield,
    ];
    return icons[index % icons.length];
  }

  Color _getHealthColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  IconData _getProductivityIcon(int index) {
    final icons = [
      Icons.timer,
      Icons.priority_high,
      Icons.meeting_room,
      Icons.assignment,
      Icons.analytics,
    ];
    return icons[index % icons.length];
  }

  Color _getProductivityColor(int index) {
    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.amber,
      Colors.deepPurple,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  Color _getBalanceColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getBalanceDescription(double score) {
    if (score >= 80) return '工作生活平衡良好';
    if (score >= 60) return '工作生活平衡一般';
    if (score >= 40) return '工作生活平衡较差';
    return '工作生活严重失衡';
  }

  Future<void> _performHealthCheck() async {
    await _reminderService.performHealthCheck();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('健康检查已完成')),
      );
    }
  }

  void _showReminderSettings() {
    final config = _reminderService.getReminderConfig();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提醒设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('启用智能提醒'),
              value: config.isEnabled,
              onChanged: (value) {
                _reminderService.updateReminderConfig(isEnabled: value);
              },
            ),
            ListTile(
              title: const Text('工作时长限制'),
              subtitle: Text('${config.workHourLimit} 小时'),
              trailing: const Icon(Icons.edit),
            ),
            ListTile(
              title: const Text('加班警告阈值'),
              subtitle: Text('${config.overtimeWarningThreshold} 小时'),
              trailing: const Icon(Icons.edit),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}