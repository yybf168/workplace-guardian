import 'dart:async';
import 'dart:math';
import '../services/notification_service.dart';
import '../utils/database_helper.dart';
import '../models/work_session.dart';

class SmartReminderService {
  static final SmartReminderService instance = SmartReminderService._init();
  
  Timer? _reminderTimer;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;
  
  // 提醒配置
  bool _isEnabled = true;
  int _workHourLimit = 8; // 每日工作时长限制（小时）
  int _overtimeWarningThreshold = 2; // 加班警告阈值（小时）
  int _restReminderInterval = 60; // 休息提醒间隔（分钟）
  
  SmartReminderService._init();

  // 启动智能提醒
  Future<void> startSmartReminder() async {
    if (!_isEnabled) return;
    
    // 每30分钟检查一次
    _reminderTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _checkAndSendReminders();
    });
    
    print('智能提醒服务已启动');
  }

  // 停止智能提醒
  void stopSmartReminder() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
    print('智能提醒服务已停止');
  }

  // 检查并发送提醒
  Future<void> _checkAndSendReminders() async {
    try {
      await _checkWorkTimeLimit();
      await _checkOvertimeWarning();
      await _checkRestReminder();
      await _checkWeekendWork();
      await _checkLateNightWork();
    } catch (e) {
      print('智能提醒检查失败: $e');
    }
  }

  // 检查工作时长限制
  Future<void> _checkWorkTimeLimit() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final sessions = await _db.getWorkSessions(1);
    final todaySessions = sessions.where((s) => s.createdAt.isAfter(startOfDay));
    
    final totalMinutes = todaySessions.fold<int>(0, (sum, s) => sum + (s.duration ~/ 60));
    final totalHours = totalMinutes / 60;
    
    if (totalHours >= _workHourLimit) {
      await _notificationService.sendHealthReminder(
        '您今天已工作${totalHours.toStringAsFixed(1)}小时，建议适当休息'
      );
    }
  }

  // 检查加班警告
  Future<void> _checkOvertimeWarning() async {
    final sessions = await _db.getOvertimeSessions(1);
    if (sessions.isEmpty) return;
    
    final totalOvertimeMinutes = sessions.fold<int>(0, (sum, s) => sum + (s.duration ~/ 60));
    final overtimeHours = totalOvertimeMinutes / 60;
    
    if (overtimeHours >= _overtimeWarningThreshold) {
      await _notificationService.sendBoundaryReminder();
    }
  }

  // 检查休息提醒
  Future<void> _checkRestReminder() async {
    final now = DateTime.now();
    final hour = now.hour;
    
    // 工作时间内每小时提醒休息
    if (hour >= 9 && hour < 18 && now.minute == 0) {
      final restMessages = [
        '工作1小时了，起来活动一下吧！',
        '记得保护眼睛，看看远方放松一下',
        '适当休息有助于提高工作效率',
        '喝杯水，让大脑得到休息',
        '深呼吸，放松肩膀和颈部',
      ];
      
      final randomMessage = restMessages[Random().nextInt(restMessages.length)];
      await _notificationService.sendHealthReminder(randomMessage);
    }
  }

  // 检查周末工作
  Future<void> _checkWeekendWork() async {
    final now = DateTime.now();
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      final sessions = await _db.getWorkSessions(1);
      final todaySessions = sessions.where((s) => 
        s.createdAt.day == now.day && 
        s.createdAt.month == now.month &&
        s.createdAt.year == now.year
      );
      
      if (todaySessions.isNotEmpty) {
        await _notificationService.sendBoundaryReminder();
      }
    }
  }

  // 检查深夜工作
  Future<void> _checkLateNightWork() async {
    final now = DateTime.now();
    if (now.hour >= 22 || now.hour < 6) {
      final sessions = await _db.getWorkSessions(1);
      final recentSessions = sessions.where((s) => 
        now.difference(s.createdAt).inHours < 1
      );
      
      if (recentSessions.isNotEmpty) {
        await _notificationService.sendHealthReminder(
          '深夜工作影响健康，建议您早点休息'
        );
      }
    }
  }

  // 生成个性化健康建议
  Future<List<String>> generateHealthSuggestions() async {
    final suggestions = <String>[];
    
    // 基于工作模式的建议
    final sessions = await _db.getWorkSessions(7);
    final overtimeSessions = sessions.where((s) => s.isOvertime).toList();
    
    if (overtimeSessions.length > 3) {
      suggestions.add('您本周加班较多，建议合理安排工作时间');
    }
    
    // 基于工作时间的建议
    final lateNightSessions = sessions.where((s) => 
      s.createdAt.hour >= 22 || s.createdAt.hour < 6
    ).toList();
    
    if (lateNightSessions.isNotEmpty) {
      suggestions.add('避免深夜工作，保证充足睡眠');
    }
    
    // 基于周末工作的建议
    final weekendSessions = sessions.where((s) => 
      s.createdAt.weekday >= 6
    ).toList();
    
    if (weekendSessions.isNotEmpty) {
      suggestions.add('周末是休息时间，尽量避免处理工作事务');
    }
    
    // 通用健康建议
    suggestions.addAll([
      '每工作1小时休息10-15分钟',
      '保持良好的坐姿，避免长时间低头',
      '多喝水，保持身体水分充足',
      '适当运动，缓解工作压力',
      '设定明确的工作边界',
    ]);
    
    return suggestions;
  }

  // 生成工作效率建议
  Future<List<String>> generateProductivitySuggestions() async {
    final suggestions = <String>[];
    
    final sessions = await _db.getWorkSessions(7);
    
    // 分析工作模式
    final hourlyUsage = <int, int>{};
    for (final session in sessions) {
      final hour = session.startTime.hour;
      hourlyUsage[hour] = (hourlyUsage[hour] ?? 0) + 1;
    }
    
    // 找出最活跃的工作时间
    if (hourlyUsage.isNotEmpty) {
      final peakHour = hourlyUsage.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      suggestions.add('您在${peakHour}点最活跃，可以安排重要工作');
    }
    
    // 基于加班情况的建议
    final overtimeRatio = sessions.isNotEmpty 
        ? sessions.where((s) => s.isOvertime).length / sessions.length
        : 0;
    
    if (overtimeRatio > 0.3) {
      suggestions.add('加班较多，建议优化工作流程提高效率');
    }
    
    suggestions.addAll([
      '使用番茄工作法，25分钟专注工作',
      '优先处理重要且紧急的任务',
      '减少不必要的会议和打断',
      '合理委派任务，避免过度承担',
      '定期回顾和调整工作计划',
    ]);
    
    return suggestions;
  }

  // 设置提醒配置
  void updateReminderConfig({
    bool? isEnabled,
    int? workHourLimit,
    int? overtimeWarningThreshold,
    int? restReminderInterval,
  }) {
    _isEnabled = isEnabled ?? _isEnabled;
    _workHourLimit = workHourLimit ?? _workHourLimit;
    _overtimeWarningThreshold = overtimeWarningThreshold ?? _overtimeWarningThreshold;
    _restReminderInterval = restReminderInterval ?? _restReminderInterval;
  }

  // 获取提醒配置
  ReminderConfig getReminderConfig() {
    return ReminderConfig(
      isEnabled: _isEnabled,
      workHourLimit: _workHourLimit,
      overtimeWarningThreshold: _overtimeWarningThreshold,
      restReminderInterval: _restReminderInterval,
    );
  }

  // 手动触发健康检查
  Future<void> performHealthCheck() async {
    await _checkAndSendReminders();
    await _notificationService.sendSystemNotification(
      '健康检查完成',
      '已完成工作健康状况检查'
    );
  }
}

// 提醒配置数据模型
class ReminderConfig {
  final bool isEnabled;
  final int workHourLimit;
  final int overtimeWarningThreshold;
  final int restReminderInterval;

  ReminderConfig({
    required this.isEnabled,
    required this.workHourLimit,
    required this.overtimeWarningThreshold,
    required this.restReminderInterval,
  });
}