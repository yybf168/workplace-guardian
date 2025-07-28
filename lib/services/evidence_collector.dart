import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../models/evidence_item.dart';
import '../utils/database_helper.dart';

class EvidenceCollector {
  static final EvidenceCollector instance = EvidenceCollector._init();
  final DatabaseHelper _db = DatabaseHelper.instance;

  EvidenceCollector._init();

  // 收集加班证据
  Future<void> collectOvertimeEvidence(String appName, int duration) async {
    final evidence = EvidenceItem(
      type: EvidenceType.overtime,
      content: '检测到非工作时间使用工作软件: $appName，持续时间: ${duration}分钟',
      timestamp: DateTime.now(),
      metadata: {
        'app_name': appName,
        'duration_minutes': duration,
        'is_weekend': _isWeekend(DateTime.now()),
        'hour': DateTime.now().hour,
      },
    );

    await _db.insertEvidence(evidence);
  }

  // 收集消息证据
  Future<void> collectMessageEvidence(String message, String sender, String appName) async {
    final evidence = EvidenceItem(
      type: EvidenceType.workMessage,
      content: '收到工作相关消息: $message',
      timestamp: DateTime.now(),
      metadata: {
        'sender': sender,
        'app_name': appName,
        'is_after_hours': _isAfterWorkHours(DateTime.now()),
        'message_length': message.length,
      },
    );

    await _db.insertEvidence(evidence);
  }

  // 收集应用使用证据
  Future<void> collectAppUsageEvidence(String appName, int usageTime) async {
    final evidence = EvidenceItem(
      type: EvidenceType.appUsage,
      content: '应用使用记录: $appName，使用时长: ${usageTime}秒',
      timestamp: DateTime.now(),
      metadata: {
        'app_name': appName,
        'usage_seconds': usageTime,
        'time_of_day': DateTime.now().hour,
      },
    );

    await _db.insertEvidence(evidence);
  }

  // 生成证据报告
  Future<String> generateEvidenceReport(String caseName) async {
    final evidence = await _db.getAllEvidence();
    final report = StringBuffer();
    
    report.writeln('职场边界守卫 - 证据报告');
    report.writeln('案例名称: $caseName');
    report.writeln('生成时间: ${DateTime.now().toString()}');
    report.writeln('=' * 50);
    report.writeln();

    // 按类型分组统计
    final overtimeEvidence = evidence.where((e) => e.type == EvidenceType.overtime).toList();
    final messageEvidence = evidence.where((e) => e.type == EvidenceType.workMessage).toList();
    final appUsageEvidence = evidence.where((e) => e.type == EvidenceType.appUsage).toList();

    report.writeln('证据统计:');
    report.writeln('- 加班记录: ${overtimeEvidence.length} 条');
    report.writeln('- 工作消息: ${messageEvidence.length} 条');
    report.writeln('- 应用使用: ${appUsageEvidence.length} 条');
    report.writeln();

    // 详细证据列表
    report.writeln('详细证据:');
    for (final item in evidence) {
      report.writeln('时间: ${item.timestamp}');
      report.writeln('类型: ${item.typeDisplayName}');
      report.writeln('内容: ${item.content}');
      if (item.metadata != null) {
        report.writeln('详情: ${item.metadata}');
      }
      report.writeln('-' * 30);
    }

    return report.toString();
  }

  // 导出证据包 - 增强版本
  Future<String> exportEvidencePackage(String caseName, {
    bool includeAnalytics = true,
    bool includeCharts = false,
    String format = 'comprehensive'
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/evidence_export');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      // 生成基础报告文件
      final report = await generateEvidenceReport(caseName);
      final reportFile = File('${exportDir.path}/evidence_report.txt');
      await reportFile.writeAsString(report);

      // 生成HTML报告
      final htmlReport = await _generateHtmlReport(caseName);
      final htmlFile = File('${exportDir.path}/evidence_report.html');
      await htmlFile.writeAsString(htmlReport);

      // 导出原始数据
      await _exportRawData(exportDir);

      // 如果包含分析，生成分析报告
      if (includeAnalytics) {
        await _exportAnalyticsReport(exportDir);
      }

      // 生成证据清单
      await _generateEvidenceManifest(exportDir, caseName);

      // 创建ZIP文件
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFile = File('${directory.path}/${caseName}_evidence_$timestamp.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      encoder.addDirectory(exportDir);
      encoder.close();

      // 清理临时文件
      await exportDir.delete(recursive: true);

      return zipFile.path;
    } catch (e) {
      throw Exception('导出证据包失败: $e');
    }
  }

  // 生成HTML报告
  Future<String> _generateHtmlReport(String caseName) async {
    final evidence = await _db.getAllEvidence();
    final stats = await getEvidenceStatistics();
    
    final html = StringBuffer();
    html.writeln('<!DOCTYPE html>');
    html.writeln('<html lang="zh-CN">');
    html.writeln('<head>');
    html.writeln('    <meta charset="UTF-8">');
    html.writeln('    <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    html.writeln('    <title>职场边界守卫 - 证据报告</title>');
    html.writeln('    <style>');
    html.writeln(_getReportCSS());
    html.writeln('    </style>');
    html.writeln('</head>');
    html.writeln('<body>');
    
    // 报告头部
    html.writeln('    <div class="header">');
    html.writeln('        <h1>职场边界守卫证据报告</h1>');
    html.writeln('        <div class="case-info">');
    html.writeln('            <p><strong>案例名称:</strong> $caseName</p>');
    html.writeln('            <p><strong>生成时间:</strong> ${DateTime.now().toString()}</p>');
    html.writeln('            <p><strong>证据总数:</strong> ${evidence.length} 条</p>');
    html.writeln('        </div>');
    html.writeln('    </div>');
    
    // 统计概览
    html.writeln('    <div class="section">');
    html.writeln('        <h2>证据统计概览</h2>');
    html.writeln('        <div class="stats-grid">');
    html.writeln('            <div class="stat-card">');
    html.writeln('                <h3>${stats['overtime'] ?? 0}</h3>');
    html.writeln('                <p>加班记录</p>');
    html.writeln('            </div>');
    html.writeln('            <div class="stat-card">');
    html.writeln('                <h3>${stats['messages'] ?? 0}</h3>');
    html.writeln('                <p>工作消息</p>');
    html.writeln('            </div>');
    html.writeln('            <div class="stat-card">');
    html.writeln('                <h3>${stats['app_usage'] ?? 0}</h3>');
    html.writeln('                <p>应用使用</p>');
    html.writeln('            </div>');
    html.writeln('        </div>');
    html.writeln('    </div>');
    
    // 详细证据列表
    html.writeln('    <div class="section">');
    html.writeln('        <h2>详细证据列表</h2>');
    html.writeln('        <div class="evidence-list">');
    
    for (final item in evidence.take(50)) { // 限制显示数量
      html.writeln('            <div class="evidence-item">');
      html.writeln('                <div class="evidence-header">');
      html.writeln('                    <span class="evidence-type">${item.typeDisplayName}</span>');
      html.writeln('                    <span class="evidence-time">${_formatDateTime(item.timestamp)}</span>');
      html.writeln('                </div>');
      html.writeln('                <div class="evidence-content">');
      html.writeln('                    <p>${item.content}</p>');
      html.writeln('                </div>');
      html.writeln('            </div>');
    }
    
    html.writeln('        </div>');
    html.writeln('    </div>');
    
    // 法律声明
    html.writeln('    <div class="footer">');
    html.writeln('        <p><strong>法律声明:</strong> 本报告由职场边界守卫应用自动生成，仅供参考。如需在法律程序中使用，请咨询专业律师。</p>');
    html.writeln('    </div>');
    
    html.writeln('</body>');
    html.writeln('</html>');
    
    return html.toString();
  }

  // 导出原始数据
  Future<void> _exportRawData(Directory exportDir) async {
    // 导出工作会话数据
    final sessions = await _db.getWorkSessions(365);
    final sessionsFile = File('${exportDir.path}/work_sessions.json');
    await sessionsFile.writeAsString(_encodeJson(sessions.map((s) => s.toMap()).toList()));

    // 导出消息记录数据
    final messages = await _db.getMessageRecords(365);
    final messagesFile = File('${exportDir.path}/message_records.json');
    await messagesFile.writeAsString(_encodeJson(messages.map((m) => m.toMap()).toList()));

    // 导出证据数据
    final evidence = await _db.getAllEvidence();
    final evidenceFile = File('${exportDir.path}/evidence_items.json');
    await evidenceFile.writeAsString(_encodeJson(evidence.map((e) => e.toMap()).toList()));
  }

  // 导出分析报告
  Future<void> _exportAnalyticsReport(Directory exportDir) async {
    // final analytics = AdvancedAnalytics.instance;
    
    // 工作生活平衡分析
    final balanceReport = await analytics.analyzeWorkLifeBalance(30);
    final balanceFile = File('${exportDir.path}/balance_analysis.json');
    await balanceFile.writeAsString(_encodeJson({
      'balance_score': balanceReport.balanceScore,
      'weekday_average_hours': balanceReport.weekdayAverageHours,
      'weekend_average_hours': balanceReport.weekendAverageHours,
      'overtime_ratio': balanceReport.overtimeRatio,
      'recommendation': balanceReport.recommendation,
    }));

    // 工作强度分析
    final intensityReport = await analytics.analyzeWorkIntensity(30);
    final intensityFile = File('${exportDir.path}/intensity_analysis.json');
    await intensityFile.writeAsString(_encodeJson({
      'peak_hour': intensityReport.peakHour,
      'average_intensity': intensityReport.averageIntensity,
      'hourly_intensity': intensityReport.hourlyIntensity,
    }));
  }

  // 生成证据清单
  Future<void> _generateEvidenceManifest(Directory exportDir, String caseName) async {
    final manifest = StringBuffer();
    manifest.writeln('# 证据包清单');
    manifest.writeln('');
    manifest.writeln('案例名称: $caseName');
    manifest.writeln('生成时间: ${DateTime.now()}');
    manifest.writeln('');
    manifest.writeln('## 文件列表');
    manifest.writeln('');
    manifest.writeln('1. evidence_report.txt - 文本格式证据报告');
    manifest.writeln('2. evidence_report.html - HTML格式证据报告');
    manifest.writeln('3. work_sessions.json - 工作会话原始数据');
    manifest.writeln('4. message_records.json - 消息记录原始数据');
    manifest.writeln('5. evidence_items.json - 证据项原始数据');
    manifest.writeln('6. balance_analysis.json - 工作生活平衡分析');
    manifest.writeln('7. intensity_analysis.json - 工作强度分析');
    manifest.writeln('8. manifest.md - 本清单文件');
    manifest.writeln('');
    manifest.writeln('## 使用说明');
    manifest.writeln('');
    manifest.writeln('- HTML报告可在浏览器中查看，包含完整的格式和样式');
    manifest.writeln('- JSON文件包含原始数据，可用于进一步分析');
    manifest.writeln('- 所有时间戳均为本地时间');
    manifest.writeln('- 如需法律用途，请咨询专业律师');

    final manifestFile = File('${exportDir.path}/manifest.md');
    await manifestFile.writeAsString(manifest.toString());
  }

  // 获取报告CSS样式
  String _getReportCSS() {
    return '''
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        margin: 0;
        padding: 20px;
        background-color: #f5f5f5;
      }
      .header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 30px;
        border-radius: 10px;
        margin-bottom: 30px;
        text-align: center;
      }
      .header h1 {
        margin: 0 0 20px 0;
        font-size: 2.5em;
      }
      .case-info {
        background: rgba(255,255,255,0.1);
        padding: 15px;
        border-radius: 5px;
        display: inline-block;
      }
      .section {
        background: white;
        padding: 25px;
        margin-bottom: 20px;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
      }
      .section h2 {
        color: #333;
        border-bottom: 2px solid #667eea;
        padding-bottom: 10px;
        margin-bottom: 20px;
      }
      .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 20px;
      }
      .stat-card {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        color: white;
        padding: 20px;
        border-radius: 10px;
        text-align: center;
      }
      .stat-card h3 {
        font-size: 2em;
        margin: 0 0 10px 0;
      }
      .evidence-list {
        max-height: 600px;
        overflow-y: auto;
      }
      .evidence-item {
        border: 1px solid #ddd;
        border-radius: 5px;
        margin-bottom: 15px;
        overflow: hidden;
      }
      .evidence-header {
        background: #f8f9fa;
        padding: 10px 15px;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .evidence-type {
        background: #667eea;
        color: white;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 0.9em;
      }
      .evidence-time {
        color: #666;
        font-size: 0.9em;
      }
      .evidence-content {
        padding: 15px;
      }
      .footer {
        background: #333;
        color: white;
        padding: 20px;
        border-radius: 10px;
        margin-top: 30px;
        text-align: center;
      }
    ''';
  }

  String _encodeJson(dynamic data) {
    // 简单的JSON编码，实际项目中应使用dart:convert
    return data.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 获取证据统计
  Future<Map<String, int>> getEvidenceStatistics() async {
    final evidence = await _db.getAllEvidence();
    
    return {
      'total': evidence.length,
      'overtime': evidence.where((e) => e.type == EvidenceType.overtime).length,
      'messages': evidence.where((e) => e.type == EvidenceType.workMessage).length,
      'app_usage': evidence.where((e) => e.type == EvidenceType.appUsage).length,
      'this_week': evidence.where((e) => 
        e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length,
    };
  }

  // 清理旧证据（保留最近30天）
  Future<void> cleanupOldEvidence() async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    // 这里需要在DatabaseHelper中添加删除方法
    print('清理 $cutoffDate 之前的证据');
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool _isAfterWorkHours(DateTime time) {
    final hour = time.hour;
    final weekday = time.weekday;
    
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return true;
    }
    
    return hour < 9 || hour >= 18;
  }
}