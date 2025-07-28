import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/permission_manager.dart';
import '../services/smart_reminder_service.dart';
import '../services/data_sync_service.dart';
import '../utils/performance_optimizer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoStart = true;
  bool _enableNotifications = true;
  bool _enableAutoReply = true;
  bool _weekendMonitoring = false;
  bool _enableSmartReminder = true;
  bool _enablePerformanceOptimization = true;
  
  TimeOfDay _workStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = const TimeOfDay(hour: 18, minute: 0);
  
  final List<String> _workApps = [
    'com.tencent.wework',
    'com.alibaba.android.rimet',
    'com.ss.android.lark',
    'com.tencent.mm',
  ];
  
  final List<String> _workKeywords = [
    '项目', '会议', '任务', '汇报', '紧急', '飞书', '文档协作'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoStart = prefs.getBool('auto_start') ?? true;
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _enableAutoReply = prefs.getBool('enable_auto_reply') ?? true;
      _weekendMonitoring = prefs.getBool('weekend_monitoring') ?? false;
      
      final startHour = prefs.getInt('work_start_hour') ?? 9;
      final startMinute = prefs.getInt('work_start_minute') ?? 0;
      _workStartTime = TimeOfDay(hour: startHour, minute: startMinute);
      
      final endHour = prefs.getInt('work_end_hour') ?? 18;
      final endMinute = prefs.getInt('work_end_minute') ?? 0;
      _workEndTime = TimeOfDay(hour: endHour, minute: endMinute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_start', _autoStart);
    await prefs.setBool('enable_notifications', _enableNotifications);
    await prefs.setBool('enable_auto_reply', _enableAutoReply);
    await prefs.setBool('weekend_monitoring', _weekendMonitoring);
    
    await prefs.setInt('work_start_hour', _workStartTime.hour);
    await prefs.setInt('work_start_minute', _workStartTime.minute);
    await prefs.setInt('work_end_hour', _workEndTime.hour);
    await prefs.setInt('work_end_minute', _workEndTime.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          TextButton(
            onPressed: () async {
              await _saveSettings();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('设置已保存')),
                );
              }
            },
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 基本设置
          _buildSectionCard(
            '基本设置',
            [
              SwitchListTile(
                title: const Text('自动启动监控'),
                subtitle: const Text('应用启动时自动开始监控'),
                value: _autoStart,
                onChanged: (value) {
                  setState(() {
                    _autoStart = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('启用通知'),
                subtitle: const Text('显示监控状态和提醒通知'),
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('自动回复'),
                subtitle: const Text('非工作时间自动回复工作消息'),
                value: _enableAutoReply,
                onChanged: (value) {
                  setState(() {
                    _enableAutoReply = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('周末监控'),
                subtitle: const Text('在周末也进行工作边界监控'),
                value: _weekendMonitoring,
                onChanged: (value) {
                  setState(() {
                    _weekendMonitoring = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('智能提醒'),
                subtitle: const Text('根据工作模式发送健康提醒'),
                value: _enableSmartReminder,
                onChanged: (value) {
                  setState(() {
                    _enableSmartReminder = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('性能优化'),
                subtitle: const Text('自动优化应用性能和电池使用'),
                value: _enablePerformanceOptimization,
                onChanged: (value) {
                  setState(() {
                    _enablePerformanceOptimization = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 工作时间设置
          _buildSectionCard(
            '工作时间',
            [
              ListTile(
                title: const Text('上班时间'),
                subtitle: Text(_formatTime(_workStartTime)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: const Text('下班时间'),
                subtitle: Text(_formatTime(_workEndTime)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 应用管理
          _buildSectionCard(
            '监控应用',
            [
              ListTile(
                title: const Text('工作应用列表'),
                subtitle: Text('已添加 ${_workApps.length} 个应用'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showWorkAppsDialog(),
              ),
              ListTile(
                title: const Text('工作关键词'),
                subtitle: Text('已添加 ${_workKeywords.length} 个关键词'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showWorkKeywordsDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 权限管理
          _buildSectionCard(
            '权限管理',
            [
              ListTile(
                title: const Text('通知访问权限'),
                subtitle: const Text('用于监听工作消息'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _checkNotificationPermission(),
              ),
              ListTile(
                title: const Text('应用使用权限'),
                subtitle: const Text('用于监控应用使用情况'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _checkUsagePermission(),
              ),
              ListTile(
                title: const Text('存储权限'),
                subtitle: const Text('用于保存证据和报告'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _checkStoragePermission(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 数据管理
          _buildSectionCard(
            '数据管理',
            [
              ListTile(
                title: const Text('导出数据'),
                subtitle: const Text('导出所有监控数据'),
                trailing: const Icon(Icons.download),
                onTap: () => _exportData(),
              ),
              ListTile(
                title: const Text('导入数据'),
                subtitle: const Text('从备份文件导入数据'),
                trailing: const Icon(Icons.upload),
                onTap: () => _importData(),
              ),
              ListTile(
                title: const Text('数据统计'),
                subtitle: const Text('查看数据存储统计'),
                trailing: const Icon(Icons.analytics),
                onTap: () => _showDataStatistics(),
              ),
              ListTile(
                title: const Text('清空数据'),
                subtitle: const Text('删除所有本地数据'),
                trailing: const Icon(Icons.delete),
                onTap: () => _showClearDataDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 关于
          _buildSectionCard(
            '关于',
            [
              const ListTile(
                title: Text('版本'),
                subtitle: Text('1.0.0'),
                trailing: Icon(Icons.info),
              ),
              ListTile(
                title: const Text('隐私政策'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showPrivacyPolicy(),
              ),
              ListTile(
                title: const Text('用户协议'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showUserAgreement(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _workStartTime : _workEndTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _workStartTime = picked;
        } else {
          _workEndTime = picked;
        }
      });
    }
  }

  void _showWorkAppsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('工作应用管理'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _workApps.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_workApps[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _workApps.removeAt(index);
                    });
                    Navigator.pop(context);
                    _showWorkAppsDialog();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddAppDialog();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddAppDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加工作应用'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '应用包名',
            hintText: '例如: com.tencent.wework',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _workApps.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showWorkKeywordsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('工作关键词管理'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _workKeywords.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_workKeywords[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _workKeywords.removeAt(index);
                    });
                    Navigator.pop(context);
                    _showWorkKeywordsDialog();
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddKeywordDialog();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddKeywordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加工作关键词'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '关键词',
            hintText: '例如: 项目',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _workKeywords.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkNotificationPermission() async {
    final hasPermission = await PermissionManager.hasNotificationPermission();
    if (!hasPermission) {
      final granted = await PermissionManager.requestNotificationPermission();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? '通知权限已授予' : '通知权限被拒绝'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('通知权限已授予')),
        );
      }
    }
  }

  Future<void> _checkUsagePermission() async {
    // 这里应该检查应用使用统计权限
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请在系统设置中授予应用使用权限')),
      );
    }
  }

  Future<void> _checkStoragePermission() async {
    final hasPermission = await PermissionManager.hasStoragePermission();
    if (!hasPermission) {
      final granted = await PermissionManager.requestStoragePermission();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted ? '存储权限已授予' : '存储权限被拒绝'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('存储权限已授予')),
        );
      }
    }
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('确定要导出所有监控数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 实现数据导出逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据导出功能开发中')),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空数据'),
        content: const Text('确定要删除所有本地数据吗？此操作不可撤销！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 实现数据清空逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据清空功能开发中')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '职场边界守卫隐私政策\n\n'
            '1. 数据收集\n'
            '本应用仅在本地收集和存储您的工作时间、应用使用情况和消息记录，不会上传到任何服务器。\n\n'
            '2. 数据使用\n'
            '收集的数据仅用于帮助您监控工作边界，生成统计报告和证据材料。\n\n'
            '3. 数据安全\n'
            '所有数据均加密存储在您的设备上，只有您可以访问。\n\n'
            '4. 数据删除\n'
            '您可以随时在设置中删除所有数据。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showUserAgreement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        content: const SingleChildScrollView(
          child: Text(
            '职场边界守卫用户协议\n\n'
            '1. 使用目的\n'
            '本应用旨在帮助用户维护健康的工作生活平衡，监控加班情况。\n\n'
            '2. 合法使用\n'
            '用户应合法合理使用本应用，不得用于非法目的。\n\n'
            '3. 免责声明\n'
            '本应用提供的数据仅供参考，具体法律效力请咨询专业律师。\n\n'
            '4. 更新条款\n'
            '我们保留随时更新本协议的权利。',
          ),
        ),
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
  
void _importData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入数据'),
        content: const Text('导入功能需要选择备份文件。在实际应用中，这里会打开文件选择器。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // 模拟导入过程
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据导入功能开发中')),
              );
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  void _showDataStatistics() async {
    try {
      final stats = await DataSyncService.instance.getDataStatistics();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('数据统计'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('工作会话: ${stats.totalSessions} 条'),
                Text('消息记录: ${stats.totalMessages} 条'),
                Text('证据数据: ${stats.totalEvidence} 条'),
                if (stats.oldestRecord != null)
                  Text('最早记录: ${_formatDate(stats.oldestRecord!)}'),
                if (stats.newestRecord != null)
                  Text('最新记录: ${_formatDate(stats.newestRecord!)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取统计失败: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }