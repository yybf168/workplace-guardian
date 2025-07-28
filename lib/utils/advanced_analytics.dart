import '../models/work_session.dart';
import '../models/message_record.dart';
import '../models/evidence_item.dart';
import 'database_helper.dart';

class AdvancedAnalytics {
  static final AdvancedAnalytics instance = AdvancedAnalytics._init();
  final DatabaseHelper _db = DatabaseHelper.instance;

  AdvancedAnalytics._init();

  // 工作强度分析
  Future<WorkIntensityReport> analyzeWorkIntensity(int days) async {
    final sessions = await _db.getWorkSessions(days);
    final messages = await _db.getMessageRecords(days);
    
    // 按小时分析工作强度
    final hourlyIntensity = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      hourlyIntensity[hour] = 0.0;
    }
    
    // 计算每小时的工作时长
    for (final session in sessions) {
      final hour = session.startTime.hour;
      hourlyIntensity[hour] = (hourlyIntensity[hour] ?? 0) + (session.duration / 3600);
    }
    
    // 计算每小时的消息数量
    final hourlyMessages = <int, int>{};
    for (int hour = 0; hour < 24; hour++) {
      hourlyMessages[hour] = 0;
    }
    
    for (final message in messages) {
      final hour = message.timestamp.hour;
      hourlyMessages[hour] = (hourlyMessages[hour] ?? 0) + 1;
    }
    
    // 计算工作强度指数 (工作时长 + 消息数量 * 0.1)
    final intensityIndex = <int, double>{};
    for (int hour = 0; hour < 24; hour++) {
      intensityIndex[hour] = (hourlyIntensity[hour] ?? 0) + 
                            (hourlyMessages[hour] ?? 0) * 0.1;
    }
    
    return WorkIntensityReport(
      hourlyIntensity: hourlyIntensity,
      hourlyMessages: hourlyMessages,
      intensityIndex: intensityIndex,
      peakHour: _findPeakHour(intensityIndex),
      averageIntensity: _calculateAverageIntensity(intensityIndex),
    );
  }

  // 工作生活平衡分析
  Future<WorkLifeBalanceReport> analyzeWorkLifeBalance(int days) async {
    final sessions = await _db.getWorkSessions(days);
    final overtimeSessions = sessions.where((s) => s.isOvertime).toList();
    
    // 计算工作日和周末的工作时长
    double weekdayHours = 0;
    double weekendHours = 0;
    int weekdayCount = 0;
    int weekendCount = 0;
    
    final processedDays = <String>{};
    
    for (final session in sessions) {
      final dayKey = '${session.createdAt.year}-${session.createdAt.month}-${session.createdAt.day}';
      if (!processedDays.contains(dayKey)) {
        processedDays.add(dayKey);
        
        final dayHours = sessions
            .where((s) => s.createdAt.day == session.createdAt.day &&
                         s.createdAt.month == session.createdAt.month &&
                         s.createdAt.year == session.createdAt.year)
            .fold(0.0, (sum, s) => sum + (s.duration / 3600));
        
        if (session.createdAt.weekday >= 6) {
          weekendHours += dayHours;
          weekendCount++;
        } else {
          weekdayHours += dayHours;
          weekdayCount++;
        }
      }
    }
    
    // 计算平衡指数 (0-100, 100为完美平衡)
    final overtimeRatio = sessions.isNotEmpty ? overtimeSessions.length / sessions.length : 0;
    final weekendWorkRatio = weekendCount > 0 ? weekendHours / (weekdayHours + weekendHours) : 0;
    
    final balanceScore = (100 * (1 - overtimeRatio * 0.6 - weekendWorkRatio * 0.4)).clamp(0.0, 100.0);
    
    return WorkLifeBalanceReport(
      balanceScore: balanceScore,
      weekdayAverageHours: weekdayCount > 0 ? weekdayHours / weekdayCount : 0,
      weekendAverageHours: weekendCount > 0 ? weekendHours / weekendCount : 0,
      overtimeRatio: overtimeRatio,
      weekendWorkRatio: weekendWorkRatio,
      recommendation: _generateBalanceRecommendation(balanceScore),
    );
  }

  // 应用使用模式分析
  Future<AppUsagePatternReport> analyzeAppUsagePattern(int days) async {
    final sessions = await _db.getWorkSessions(days);
    
    // 按应用统计使用时长
    final appUsage = <String, double>{};
    final appSessions = <String, List<WorkSession>>{};
    
    for (final session in sessions) {
      appUsage[session.appName] = (appUsage[session.appName] ?? 0) + (session.duration / 3600);
      appSessions[session.appName] = (appSessions[session.appName] ?? [])..add(session);
    }
    
    // 计算每个应用的使用模式
    final appPatterns = <String, AppPattern>{};
    for (final entry in appSessions.entries) {
      final appName = entry.key;
      final sessions = entry.value;
      
      // 计算平均使用时长
      final avgDuration = sessions.fold(0.0, (sum, s) => sum + s.duration) / sessions.length / 60;
      
      // 计算使用频率
      final uniqueDays = sessions.map((s) => 
        '${s.createdAt.year}-${s.createdAt.month}-${s.createdAt.day}'
      ).toSet().length;
      
      // 计算加班使用比例
      final overtimeRatio = sessions.where((s) => s.isOvertime).length / sessions.length;
      
      appPatterns[appName] = AppPattern(
        totalHours: appUsage[appName]!,
        averageSessionMinutes: avgDuration,
        usageDays: uniqueDays,
        overtimeRatio: overtimeRatio,
        riskLevel: _calculateRiskLevel(overtimeRatio, avgDuration),
      );
    }
    
    return AppUsagePatternReport(
      appPatterns: appPatterns,
      mostUsedApp: _findMostUsedApp(appUsage),
      riskiestApp: _findRiskiestApp(appPatterns),
    );
  }

  // 消息模式分析
  Future<MessagePatternReport> analyzeMessagePattern(int days) async {
    final messages = await _db.getMessageRecords(days);
    
    // 按时间段分析消息分布
    final timeSlots = <String, int>{
      'early_morning': 0,  // 6-9
      'morning': 0,        // 9-12
      'afternoon': 0,      // 12-18
      'evening': 0,        // 18-22
      'late_night': 0,     // 22-6
    };
    
    for (final message in messages) {
      final hour = message.timestamp.hour;
      if (hour >= 6 && hour < 9) {
        timeSlots['early_morning'] = timeSlots['early_morning']! + 1;
      } else if (hour >= 9 && hour < 12) {
        timeSlots['morning'] = timeSlots['morning']! + 1;
      } else if (hour >= 12 && hour < 18) {
        timeSlots['afternoon'] = timeSlots['afternoon']! + 1;
      } else if (hour >= 18 && hour < 22) {
        timeSlots['evening'] = timeSlots['evening']! + 1;
      } else {
        timeSlots['late_night'] = timeSlots['late_night']! + 1;
      }
    }
    
    // 按类型统计消息
    final messageTypes = <MessageType, int>{};
    for (final type in MessageType.values) {
      messageTypes[type] = messages.where((m) => m.type == type).length;
    }
    
    return MessagePatternReport(
      timeSlotDistribution: timeSlots,
      messageTypeDistribution: messageTypes,
      afterHoursRatio: messages.isNotEmpty ? 
        messages.where((m) => m.isAfterHours).length / messages.length : 0,
      averageMessagesPerDay: messages.length / days,
    );
  }

  // 辅助方法
  int _findPeakHour(Map<int, double> intensityIndex) {
    return intensityIndex.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _calculateAverageIntensity(Map<int, double> intensityIndex) {
    return intensityIndex.values.fold(0.0, (sum, value) => sum + value) / 24;
  }

  String _generateBalanceRecommendation(double balanceScore) {
    if (balanceScore >= 80) {
      return '工作生活平衡良好，继续保持！';
    } else if (balanceScore >= 60) {
      return '工作生活平衡一般，建议适当减少加班时间。';
    } else if (balanceScore >= 40) {
      return '工作生活平衡较差，建议制定明确的工作边界。';
    } else {
      return '工作生活严重失衡，强烈建议寻求帮助并调整工作方式。';
    }
  }

  String _findMostUsedApp(Map<String, double> appUsage) {
    return appUsage.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String _findRiskiestApp(Map<String, AppPattern> appPatterns) {
    return appPatterns.entries
        .reduce((a, b) => a.value.riskLevel > b.value.riskLevel ? a : b)
        .key;
  }

  double _calculateRiskLevel(double overtimeRatio, double avgSessionMinutes) {
    return (overtimeRatio * 0.7 + (avgSessionMinutes / 60) * 0.3).clamp(0, 1);
  }
}

// 数据模型
class WorkIntensityReport {
  final Map<int, double> hourlyIntensity;
  final Map<int, int> hourlyMessages;
  final Map<int, double> intensityIndex;
  final int peakHour;
  final double averageIntensity;

  WorkIntensityReport({
    required this.hourlyIntensity,
    required this.hourlyMessages,
    required this.intensityIndex,
    required this.peakHour,
    required this.averageIntensity,
  });
}

class WorkLifeBalanceReport {
  final double balanceScore;
  final double weekdayAverageHours;
  final double weekendAverageHours;
  final double overtimeRatio;
  final double weekendWorkRatio;
  final String recommendation;

  WorkLifeBalanceReport({
    required this.balanceScore,
    required this.weekdayAverageHours,
    required this.weekendAverageHours,
    required this.overtimeRatio,
    required this.weekendWorkRatio,
    required this.recommendation,
  });
}

class AppUsagePatternReport {
  final Map<String, AppPattern> appPatterns;
  final String mostUsedApp;
  final String riskiestApp;

  AppUsagePatternReport({
    required this.appPatterns,
    required this.mostUsedApp,
    required this.riskiestApp,
  });
}

class AppPattern {
  final double totalHours;
  final double averageSessionMinutes;
  final int usageDays;
  final double overtimeRatio;
  final double riskLevel;

  AppPattern({
    required this.totalHours,
    required this.averageSessionMinutes,
    required this.usageDays,
    required this.overtimeRatio,
    required this.riskLevel,
  });
}

class MessagePatternReport {
  final Map<String, int> timeSlotDistribution;
  final Map<MessageType, int> messageTypeDistribution;
  final double afterHoursRatio;
  final double averageMessagesPerDay;

  MessagePatternReport({
    required this.timeSlotDistribution,
    required this.messageTypeDistribution,
    required this.afterHoursRatio,
    required this.averageMessagesPerDay,
  });
}