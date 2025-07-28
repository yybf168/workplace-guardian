import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/work_session.dart';
import '../models/message_record.dart';
import '../models/evidence_item.dart';
import 'database_helper.dart';

class ReportGenerator {
  static final ReportGenerator instance = ReportGenerator._init();
  final DatabaseHelper _db = DatabaseHelper.instance;

  ReportGenerator._init();

  // 生成加班统计报告
  Future<OvertimeReport> generateOvertimeReport(int days) async {
    final sessions = await _db.getWorkSessions(days);
    final overtimeSessions = sessions.where((s) => s.isOvertime).toList();

    final totalOvertimeHours = overtimeSessions.fold(
      0.0,
      (sum, session) => sum + (session.duration / 3600),
    );

    final overtimeDays = overtimeSessions
        .map((s) => '${s.createdAt.year}-${s.createdAt.month}-${s.createdAt.day}')
        .toSet()
        .length;

    final averageOvertimePerDay = overtimeDays > 0 ? totalOvertimeHours / overtimeDays : 0.0;

    final overtimeByWeekday = <int, double>{};
    for (final session in overtimeSessions) {
      final weekday = session.createdAt.weekday;
      overtimeByWeekday[weekday] = (overtimeByWeekday[weekday] ?? 0) + (session.duration / 3600);
    }

    return OvertimeReport(
      totalOvertimeDays: overtimeDays,
      totalOvertimeHours: totalOvertimeHours,
      averageOvertimePerDay: averageOvertimePerDay,
      overtimeByWeekday: overtimeByWeekday,
      sessions: overtimeSessions,
    );
  }

  // 生成详细的文本报告
  Future<String> generateDetailedReport(String caseName, int days) async {
    final report = StringBuffer();
    final now = DateTime.now();
    
    // 报告头部
    report.writeln('=' * 60);
    report.writeln('职场边界守卫 - 详细报告');
    report.writeln('=' * 60);
    report.writeln('案例名称: $caseName');
    report.writeln('报告生成时间: ${_formatDateTime(now)}');
    report.writeln('统计周期: 最近 $days 天');
    report.writeln('');

    // 加班统计
    final overtimeReport = await generateOvertimeReport(days);
    report.writeln('一、加班统计');
    report.writeln('-' * 30);
    report.writeln('总加班天数: ${overtimeReport.totalOvertimeDays} 天');
    report.writeln('总加班时长: ${overtimeReport.totalOvertimeHours.toStringAsFixed(2)} 小时');
    report.writeln('日均加班时长: ${overtimeReport.averageOvertimePerDay.toStringAsFixed(2)} 小时');
    report.writeln('');

    // 按星期统计
    report.writeln('按星期分布:');
    final weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    for (int i = 1; i <= 7; i++) {
      final hours = overtimeReport.overtimeByWeekday[i] ?? 0;
      report.writeln('  ${weekdays[i]}: ${hours.toStringAsFixed(2)} 小时');
    }
    report.writeln('');

    // 消息统计
    final messages = await _db.getMessageRecords(days);
    final workMessages = messages.where((m) => m.type == MessageType.workMessage).toList();
    final afterHoursMessages = workMessages.where((m) => m.isAfterHours).toList();
    
    report.writeln('二、消息统计');
    report.writeln('-' * 30);
    report.writeln('总消息数: ${messages.length} 条');
    report.writeln('工作相关消息: ${workMessages.length} 条');
    report.writeln('非工作时间工作消息: ${afterHoursMessages.length} 条');
    report.writeln('消息过滤率: ${messages.isNotEmpty ? (afterHoursMessages.length / messages.length * 100).toStringAsFixed(1) : 0}%');
    report.writeln('');

    // 证据统计
    final evidence = await _db.getAllEvidence();
    final recentEvidence = evidence.where((e) => 
      e.timestamp.isAfter(now.subtract(Duration(days: days)))
    ).toList();
    
    report.writeln('三、证据统计');
    report.writeln('-' * 30);
    report.writeln('总证据数: ${evidence.length} 条');
    report.writeln('最近${days}天证据: ${recentEvidence.length} 条');
    
    final evidenceByType = <EvidenceType, int>{};
    for (final item in recentEvidence) {
      evidenceByType[item.type] = (evidenceByType[item.type] ?? 0) + 1;
    }
    
    report.writeln('证据类型分布:');
    for (final entry in evidenceByType.entries) {
      report.writeln('  ${_getEvidenceTypeName(entry.key)}: ${entry.value} 条');
    }
    report.writeln('');

    // 详细加班记录
    report.writeln('四、详细加班记录');
    report.writeln('-' * 30);
    for (final session in overtimeReport.sessions.take(20)) {
      report.writeln('时间: ${_formatDateTime(session.createdAt)}');
      report.writeln('应用: ${session.appName}');
      report.writeln('时长: ${(session.duration / 60).toStringAsFixed(0)} 分钟');
      report.writeln('类型: ${session.isOvertime ? "加班" : "正常"}');
      report.writeln('');
    }

    // 重要消息记录
    report.writeln('五、重要消息记录');
    report.writeln('-' * 30);
    for (final message in afterHoursMessages.take(10)) {
      report.writeln('时间: ${_formatDateTime(message.timestamp)}');
      report.writeln('发送者: ${message.sender}');
      report.writeln('内容: ${message.content}');
      report.writeln('应用: ${message.appPackage}');
      report.writeln('');
    }

    // 报告尾部
    report.writeln('=' * 60);
    report.writeln('报告结束');
    report.writeln('注意: 本报告数据仅供参考，具体法律效力请咨询专业律师');
    report.writeln('=' * 60);

    return report.toString();
  }

  // 导出HTML格式报告
  Future<String> generateHtmlReport(String caseName, int days) async {
    final textReport = await generateDetailedReport(caseName, days);
    final overtimeReport = await generateOvertimeReport(days);
    
    final html = StringBuffer();
    html.writeln('<!DOCTYPE html>');
    html.writeln('<html lang="zh-CN">');
    html.writeln('<head>');
    html.writeln('    <meta charset="UTF-8">');
    html.writeln('    <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    html.writeln('    <title>职场边界守卫报告 - $caseName</title>');
    html.writeln('    <style>');
    html.writeln('        body { font-family: Arial, sans-serif; margin: 20px; }');
    html.writeln('        .header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 10px; }');
    html.writeln('        .section { margin: 20px 0; }');
    html.writeln('        .section h2 { color: #333; border-bottom: 1px solid #ccc; }');
    html.writeln('        .stat-item { margin: 10px 0; }');
    html.writeln('        .highlight { background-color: #ffeb3b; padding: 2px 4px; }');
    html.writeln('        .warning { color: #f44336; font-weight: bold; }');
    html.writeln('        table { width: 100%; border-collapse: collapse; margin: 10px 0; }');
    html.writeln('        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }');
    html.writeln('        th { background-color: #f2f2f2; }');
    html.writeln('    </style>');
    html.writeln('</head>');
    html.writeln('<body>');
    
    html.writeln('    <div class="header">');
    html.writeln('        <h1>职场边界守卫报告</h1>');
    html.writeln('        <p>案例: $caseName</p>');
    html.writeln('        <p>生成时间: ${_formatDateTime(DateTime.now())}</p>');
    html.writeln('    </div>');
    
    // 加班统计表格
    html.writeln('    <div class="section">');
    html.writeln('        <h2>加班统计概览</h2>');
    html.writeln('        <table>');
    html.writeln('            <tr><th>统计项</th><th>数值</th></tr>');
    html.writeln('            <tr><td>总加班天数</td><td class="highlight">${overtimeReport.totalOvertimeDays} 天</td></tr>');
    html.writeln('            <tr><td>总加班时长</td><td class="warning">${overtimeReport.totalOvertimeHours.toStringAsFixed(2)} 小时</td></tr>');
    html.writeln('            <tr><td>日均加班时长</td><td>${overtimeReport.averageOvertimePerDay.toStringAsFixed(2)} 小时</td></tr>');
    html.writeln('        </table>');
    html.writeln('    </div>');
    
    html.writeln('</body>');
    html.writeln('</html>');
    
    return html.toString();
  }

  // 保存报告到文件
  Future<String> saveReportToFile(String content, String fileName, {bool isHtml = false}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${directory.path}/reports');
      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }
      
      final extension = isHtml ? '.html' : '.txt';
      final file = File('${reportsDir.path}/$fileName$extension');
      await file.writeAsString(content);
      
      return file.path;
    } catch (e) {
      throw Exception('保存报告失败: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getEvidenceTypeName(EvidenceType type) {
    switch (type) {
      case EvidenceType.overtime:
        return '加班记录';
      case EvidenceType.workMessage:
        return '工作消息';
      case EvidenceType.appUsage:
        return '应用使用';
      case EvidenceType.screenshot:
        return '截图证据';
      case EvidenceType.other:
        return '其他';
    }
  }
}

// 加班报告数据类
class OvertimeReport {
  final int totalOvertimeDays;
  final double totalOvertimeHours;
  final double averageOvertimePerDay;
  final Map<int, double> overtimeByWeekday;
  final List<WorkSession> sessions;

  OvertimeReport({
    required this.totalOvertimeDays,
    required this.totalOvertimeHours,
    required this.averageOvertimePerDay,
    required this.overtimeByWeekday,
    required this.sessions,
  });
}