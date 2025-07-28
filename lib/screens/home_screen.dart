import 'package:flutter/material.dart';
import '../services/work_monitor.dart';
import '../services/message_filter.dart';
import '../services/evidence_collector.dart';
import '../services/notification_service.dart';
import '../services/smart_reminder_service.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'evidence_screen.dart';
import 'notification_screen.dart';
import 'health_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkMonitorService _workMonitor = WorkMonitorService.instance;
  final MessageFilterService _messageFilter = MessageFilterService.instance;
  final EvidenceCollector _evidenceCollector = EvidenceCollector.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final SmartReminderService _smartReminder = SmartReminderService.instance;

  int _todayOvertimeMinutes = 0;
  int _weekOvertimeDays = 0;
  int _todayFilteredMessages = 0;
  int _totalEvidence = 0;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startServices();
    
    // 显示欢迎提示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  Future<void> _loadData() async {
    final overtimeMinutes = await _workMonitor.getTodayOvertimeMinutes();
    final overtimeDays = await _workMonitor.getWeekOvertimeDays();
    final filteredCount = await _messageFilter.getTodayFilteredCount();
    final evidenceStats = await _evidenceCollector.getEvidenceStatistics();

    setState(() {
      _todayOvertimeMinutes = overtimeMinutes;
      _weekOvertimeDays = overtimeDays;
      _todayFilteredMessages = filteredCount;
      _totalEvidence = evidenceStats['total'] ?? 0;
    });
  }

  Future<void> _startServices() async {
    await _workMonitor.startMonitoring();
    await _messageFilter.startMessageFiltering();
    await _smartReminder.startSmartReminder();
    setState(() {
      _isMonitoring = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('职场边界守卫'),
        actions: [
          // 通知中心
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
              ),
              StreamBuilder<AppNotification>(
                stream: _notificationService.notificationStream,
                builder: (context, snapshot) {
                  final unreadCount = _notificationService.getUnreadCount();
                  if (unreadCount > 0) {
                    return Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          // 监控开关
          IconButton(
            icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isMonitoring) {
                _workMonitor.stopMonitoring();
                _smartReminder.stopSmartReminder();
                setState(() {
                  _isMonitoring = false;
                });
              } else {
                _startServices();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态卡片
              _buildStatusCard(),
              const SizedBox(height: 20),
              
              // 今日统计
              _buildTodayStats(),
              const SizedBox(height: 20),
              
              // 功能按钮网格
              _buildFeatureGrid(),
              const SizedBox(height: 20),
              
              // 快速操作
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isMonitoring ? Icons.shield : Icons.shield_outlined,
                  color: _isMonitoring ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isMonitoring ? '守护中' : '已暂停',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _isMonitoring ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isMonitoring ? '正在监控工作边界' : '点击开始按钮启动监控',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日统计',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '加班时长',
                    '${_todayOvertimeMinutes}分钟',
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '过滤消息',
                    '$_todayFilteredMessages条',
                    Icons.filter_alt,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '本周加班',
                    '$_weekOvertimeDays天',
                    Icons.calendar_today,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '总证据',
                    '$_totalEvidence条',
                    Icons.folder,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(
          '工时统计',
          Icons.analytics,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StatisticsScreen()),
          ),
        ),
        _buildFeatureCard(
          '证据收集',
          Icons.folder_special,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EvidenceScreen()),
          ),
        ),
        _buildFeatureCard(
          '健康中心',
          Icons.favorite,
          Colors.red,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HealthScreen()),
          ),
        ),
        _buildFeatureCard(
          '消息过滤',
          Icons.message,
          Colors.orange,
          () => _showMessageFilterDialog(),
        ),
        _buildFeatureCard(
          '设置',
          Icons.settings,
          Colors.grey,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '快速操作',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final path = await _evidenceCollector.exportEvidencePackage('快速导出');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('证据包已导出到: $path')),
                        );
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('导出证据'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // 生成新的模拟数据
                      await _generateMockData();
                      await _loadData();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('生成数据'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 生成模拟数据
  Future<void> _generateMockData() async {
    // 生成模拟工作会话
    for (int i = 0; i < 3; i++) {
      await _workMonitor.recordMockWorkSession();
      await _workMonitor.collectMockOvertimeEvidence();
    }
    
    // 生成模拟消息
    await _messageFilter.generateMockMessages();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已生成新的模拟数据')),
      );
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield, color: Colors.blue),
            SizedBox(width: 8),
            Text('欢迎使用职场边界守卫'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('这是一个演示版本，帮助您了解应用功能：'),
              SizedBox(height: 12),
              Text('🔹 点击"生成数据"按钮创建模拟的工作记录'),
              Text('🔹 查看工时统计了解加班情况'),
              Text('🔹 浏览证据收集查看详细记录'),
              Text('🔹 在设置中配置工作时间和应用'),
              SizedBox(height: 12),
              Text('注意：当前为Web演示版本，实际Android版本将具备完整的监控功能。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('开始使用'),
          ),
        ],
      ),
    );
  }

  void _showMessageFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('消息过滤'),
        content: const Text('消息过滤功能正在运行中，会自动过滤非工作时间的工作消息。\n\n当前支持的工作应用：\n• 企业微信\n• 钉钉\n• 飞书\n• Microsoft Teams\n• Slack\n• Outlook'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}