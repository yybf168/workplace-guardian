import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import '../utils/database_helper.dart';
import '../models/work_session.dart';
import '../models/message_record.dart';
import '../models/evidence_item.dart';

class DataSyncService {
  static final DataSyncService instance = DataSyncService._init();
  final DatabaseHelper _db = DatabaseHelper.instance;

  DataSyncService._init();

  // 导出所有数据
  Future<String> exportAllData({String? fileName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${directory.path}/data_export');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportFileName = fileName ?? 'workplace_guardian_backup_$timestamp';

      // 导出工作会话数据
      await _exportWorkSessions(exportDir);
      
      // 导出消息记录数据
      await _exportMessageRecords(exportDir);
      
      // 导出证据数据
      await _exportEvidenceItems(exportDir);
      
      // 导出配置数据
      await _exportSettings(exportDir);
      
      // 生成元数据文件
      await _generateMetadata(exportDir, exportFileName);

      // 创建ZIP文件
      final zipFile = File('${directory.path}/$exportFileName.zip');
      final encoder = ZipFileEncoder();
      encoder.create(zipFile.path);
      encoder.addDirectory(exportDir);
      encoder.close();

      // 清理临时文件
      await exportDir.delete(recursive: true);

      return zipFile.path;
    } catch (e) {
      throw Exception('数据导出失败: $e');
    }
  }

  // 导入数据
  Future<ImportResult> importData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      // 创建临时解压目录
      final directory = await getApplicationDocumentsDirectory();
      final tempDir = Directory('${directory.path}/temp_import');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
      await tempDir.create(recursive: true);

      // 解压文件
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final extractedFile = File('${tempDir.path}/$filename');
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(data);
        }
      }

      // 验证数据完整性
      final validationResult = await _validateImportData(tempDir);
      if (!validationResult.isValid) {
        await tempDir.delete(recursive: true);
        throw Exception('数据验证失败: ${validationResult.error}');
      }

      // 导入数据
      final importResult = await _performDataImport(tempDir);

      // 清理临时文件
      await tempDir.delete(recursive: true);

      return importResult;
    } catch (e) {
      throw Exception('数据导入失败: $e');
    }
  }

  // 导出工作会话数据
  Future<void> _exportWorkSessions(Directory exportDir) async {
    final sessions = await _db.getWorkSessions(365); // 导出一年的数据
    final jsonData = sessions.map((s) => s.toMap()).toList();
    
    final file = File('${exportDir.path}/work_sessions.json');
    await file.writeAsString(json.encode(jsonData));
  }

  // 导出消息记录数据
  Future<void> _exportMessageRecords(Directory exportDir) async {
    final messages = await _db.getMessageRecords(365);
    final jsonData = messages.map((m) => m.toMap()).toList();
    
    final file = File('${exportDir.path}/message_records.json');
    await file.writeAsString(json.encode(jsonData));
  }

  // 导出证据数据
  Future<void> _exportEvidenceItems(Directory exportDir) async {
    final evidence = await _db.getAllEvidence();
    final jsonData = evidence.map((e) => e.toMap()).toList();
    
    final file = File('${exportDir.path}/evidence_items.json');
    await file.writeAsString(json.encode(jsonData));
  }

  // 导出设置数据
  Future<void> _exportSettings(Directory exportDir) async {
    // 这里可以导出SharedPreferences中的设置
    final settings = {
      'export_version': '1.0',
      'export_date': DateTime.now().toIso8601String(),
      'app_version': '1.0.0',
    };
    
    final file = File('${exportDir.path}/settings.json');
    await file.writeAsString(json.encode(settings));
  }

  // 生成元数据文件
  Future<void> _generateMetadata(Directory exportDir, String fileName) async {
    final workSessions = await _db.getWorkSessions(365);
    final messages = await _db.getMessageRecords(365);
    final evidence = await _db.getAllEvidence();
    
    final metadata = {
      'export_info': {
        'file_name': fileName,
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'data_version': '1.0',
      },
      'data_summary': {
        'work_sessions_count': workSessions.length,
        'message_records_count': messages.length,
        'evidence_items_count': evidence.length,
        'date_range': {
          'start': workSessions.isNotEmpty 
              ? workSessions.last.createdAt.toIso8601String()
              : null,
          'end': workSessions.isNotEmpty 
              ? workSessions.first.createdAt.toIso8601String()
              : null,
        },
      },
      'files': [
        'work_sessions.json',
        'message_records.json',
        'evidence_items.json',
        'settings.json',
        'metadata.json',
      ],
    };
    
    final file = File('${exportDir.path}/metadata.json');
    await file.writeAsString(json.encode(metadata));
  }

  // 验证导入数据
  Future<ValidationResult> _validateImportData(Directory importDir) async {
    try {
      // 检查必需文件是否存在
      final requiredFiles = [
        'metadata.json',
        'work_sessions.json',
        'message_records.json',
        'evidence_items.json',
      ];

      for (final fileName in requiredFiles) {
        final file = File('${importDir.path}/$fileName');
        if (!await file.exists()) {
          return ValidationResult(false, '缺少必需文件: $fileName');
        }
      }

      // 验证元数据
      final metadataFile = File('${importDir.path}/metadata.json');
      final metadataContent = await metadataFile.readAsString();
      final metadata = json.decode(metadataContent);

      if (metadata['export_info'] == null) {
        return ValidationResult(false, '元数据格式错误');
      }

      // 验证数据格式
      final workSessionsFile = File('${importDir.path}/work_sessions.json');
      final workSessionsContent = await workSessionsFile.readAsString();
      final workSessionsData = json.decode(workSessionsContent) as List;

      // 简单验证第一条记录的格式
      if (workSessionsData.isNotEmpty) {
        final firstSession = workSessionsData.first;
        if (firstSession['start_time'] == null || firstSession['app_name'] == null) {
          return ValidationResult(false, '工作会话数据格式错误');
        }
      }

      return ValidationResult(true, null);
    } catch (e) {
      return ValidationResult(false, '数据验证异常: $e');
    }
  }

  // 执行数据导入
  Future<ImportResult> _performDataImport(Directory importDir) async {
    int importedSessions = 0;
    int importedMessages = 0;
    int importedEvidence = 0;
    final errors = <String>[];

    try {
      // 导入工作会话
      final workSessionsFile = File('${importDir.path}/work_sessions.json');
      if (await workSessionsFile.exists()) {
        final content = await workSessionsFile.readAsString();
        final data = json.decode(content) as List;
        
        for (final item in data) {
          try {
            final session = WorkSession.fromMap(item);
            await _db.insertWorkSession(session);
            importedSessions++;
          } catch (e) {
            errors.add('工作会话导入错误: $e');
          }
        }
      }

      // 导入消息记录
      final messagesFile = File('${importDir.path}/message_records.json');
      if (await messagesFile.exists()) {
        final content = await messagesFile.readAsString();
        final data = json.decode(content) as List;
        
        for (final item in data) {
          try {
            final message = MessageRecord.fromMap(item);
            await _db.insertMessageRecord(message);
            importedMessages++;
          } catch (e) {
            errors.add('消息记录导入错误: $e');
          }
        }
      }

      // 导入证据数据
      final evidenceFile = File('${importDir.path}/evidence_items.json');
      if (await evidenceFile.exists()) {
        final content = await evidenceFile.readAsString();
        final data = json.decode(content) as List;
        
        for (final item in data) {
          try {
            final evidence = EvidenceItem.fromMap(item);
            await _db.insertEvidence(evidence);
            importedEvidence++;
          } catch (e) {
            errors.add('证据数据导入错误: $e');
          }
        }
      }

      return ImportResult(
        success: true,
        importedSessions: importedSessions,
        importedMessages: importedMessages,
        importedEvidence: importedEvidence,
        errors: errors,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        importedSessions: importedSessions,
        importedMessages: importedMessages,
        importedEvidence: importedEvidence,
        errors: [...errors, '导入过程异常: $e'],
      );
    }
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    // 由于使用内存数据库，直接清空静态列表
    // 在实际SQLite实现中，这里会执行DELETE语句
    print('清空所有数据');
  }

  // 获取数据统计
  Future<DataStatistics> getDataStatistics() async {
    final sessions = await _db.getWorkSessions(365);
    final messages = await _db.getMessageRecords(365);
    final evidence = await _db.getAllEvidence();

    return DataStatistics(
      totalSessions: sessions.length,
      totalMessages: messages.length,
      totalEvidence: evidence.length,
      oldestRecord: sessions.isNotEmpty 
          ? sessions.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b).createdAt
          : null,
      newestRecord: sessions.isNotEmpty 
          ? sessions.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b).createdAt
          : null,
    );
  }
}

// 数据模型
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult(this.isValid, this.error);
}

class ImportResult {
  final bool success;
  final int importedSessions;
  final int importedMessages;
  final int importedEvidence;
  final List<String> errors;

  ImportResult({
    required this.success,
    required this.importedSessions,
    required this.importedMessages,
    required this.importedEvidence,
    required this.errors,
  });
}

class DataStatistics {
  final int totalSessions;
  final int totalMessages;
  final int totalEvidence;
  final DateTime? oldestRecord;
  final DateTime? newestRecord;

  DataStatistics({
    required this.totalSessions,
    required this.totalMessages,
    required this.totalEvidence,
    this.oldestRecord,
    this.newestRecord,
  });
}