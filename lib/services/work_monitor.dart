import 'dart:async';
// import 'package:usage_stats/usage_stats.dart'; // 暂时移除
import '../models/work_session.dart';
import '../models/evidence_item.dart';
import '../utils/database_helper.dart';

class WorkMonitorService {
  static final WorkMonitorService instance = WorkMonitorService._init();
  Timer? _monitorTimer;
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  // 工作相关应用包名
  final List<String> _workApps = [
    'com.tencent.wework',      // 企业微信
    'com.alibaba.android.rimet', // 钉钉
    'com.ss.android.lark',     // 飞书
    'com.tencent.mm',          // 微信
    'com.tencent.mobileqq',    // QQ
    'com.microsoft.teams',     // Microsoft Teams
    'com.slack',               // Slack
    'com.zoom.us',             // Zoom
    'com.skype.raider',        // Skype
    'com.discord',             // Discord
    'com.microsoft.office.outlook', // Outlook
    'com.google.android.gm',   // Gmail
    'com.microsoft.office.word', // Word
    'com.microsoft.office.excel', // Excel
    'com.microsoft.office.powerpoint', // PowerPoint
    'com.adobe.reader',        // Adobe Reader
    'com.evernote',           // 印象笔记
    'com.youdao.note',        // 有道云笔记
    'com.notion.id',          // Notion
    'com.trello',             // Trello
    'com.asana.app',          // Asana
    'com.atlassian.jira.core', // Jira
    'com.github.android',     // GitHub
    'com.gitlab.gitlab',      // GitLab
  ];

  WorkMonitorService._init();

  // 开始监控
  Future<void> startMonitoring() async {
    // 请求应用使用统计权限
    await _requestUsageStatsPermission();
    
    // 每分钟检查一次
    _monitorTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkWorkActivity();
    });
  }

  // 停止监控
  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  // 请求使用统计权限 (暂时禁用)
  Future<void> _requestUsageStatsPermission() async {
    try {
      // await UsageStats.grantUsagePermission();
      print('使用统计权限功能暂时禁用');
    } catch (e) {
      print('请求使用统计权限失败: $e');
    }
  }

  // 检查工作活动
  Future<void> _checkWorkActivity() async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      
      // 获取最近一小时的应用使用统计 (暂时模拟数据)
      // final usageStats = await UsageStats.queryUsageStats(oneHourAgo, now);
      
      // 模拟数据用于演示
      if (_isOvertimeWork(now)) {
        await recordMockWorkSession();
        await collectMockOvertimeEvidence();
      }
    } catch (e) {
      print('检查工作活动失败: $e');
    }
  }

  // 判断是否为加班时间
  bool _isOvertimeWork(DateTime time) {
    final hour = time.hour;
    final weekday = time.weekday;
    
    // 周末
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return true;
    }
    
    // 工作日的非工作时间（早于9点或晚于18点）
    if (hour < 9 || hour >= 18) {
      return true;
    }
    
    return false;
  }

  // 记录模拟工作会话
  Future<void> recordMockWorkSession() async {
    final mockApps = [
      {'package': 'com.tencent.wework', 'name': '企业微信'},
      {'package': 'com.alibaba.android.rimet', 'name': '钉钉'},
      {'package': 'com.ss.android.lark', 'name': '飞书'},
      {'package': 'com.microsoft.teams', 'name': 'Microsoft Teams'},
      {'package': 'com.microsoft.office.outlook', 'name': 'Outlook'},
      {'package': 'com.slack', 'name': 'Slack'},
    ];
    
    final random = DateTime.now().millisecond % mockApps.length;
    final selectedApp = mockApps[random];
    final duration = (15 + (DateTime.now().millisecond % 45)) * 60; // 15-60分钟
    
    final session = WorkSession(
      startTime: DateTime.now().subtract(Duration(seconds: duration)),
      endTime: DateTime.now(),
      appPackage: selectedApp['package']!,
      appName: selectedApp['name']!,
      duration: duration,
      isOvertime: true,
      createdAt: DateTime.now(),
    );

    await _db.insertWorkSession(session);
  }

  // 收集模拟加班证据
  Future<void> collectMockOvertimeEvidence() async {
    final mockEvidences = [
      '检测到深夜时间使用企业微信处理工作事务',
      '周末期间使用钉钉参与工作讨论',
      '非工作时间使用飞书开会和处理文档',
      '非工作时间使用Teams开会',
      '晚上使用Outlook处理邮件',
      '休息时间使用Slack回复工作消息',
    ];
    
    final random = DateTime.now().millisecond % mockEvidences.length;
    final selectedEvidence = mockEvidences[random];
    
    final evidence = EvidenceItem(
      type: EvidenceType.overtime,
      content: selectedEvidence,
      timestamp: DateTime.now(),
      metadata: {
        'detection_time': DateTime.now().toIso8601String(),
        'overtime_type': _isWeekend(DateTime.now()) ? 'weekend' : 'after_hours',
        'is_mock_data': true,
      },
    );

    await _db.insertEvidence(evidence);
  }
  
  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // 获取今日加班时长
  Future<int> getTodayOvertimeMinutes() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final sessions = await _db.getWorkSessions(1);
    final overtimeSessions = sessions.where((s) => 
      s.isOvertime && s.createdAt.isAfter(startOfDay)
    );

    return overtimeSessions.fold<int>(0, (sum, session) => sum + (session.duration ~/ 60));
  }

  // 获取本周加班天数
  Future<int> getWeekOvertimeDays() async {
    final sessions = await _db.getOvertimeSessions(7);
    final uniqueDays = <String>{};
    
    for (final session in sessions) {
      final dayKey = '${session.createdAt.year}-${session.createdAt.month}-${session.createdAt.day}';
      uniqueDays.add(dayKey);
    }
    
    return uniqueDays.length;
  }
}