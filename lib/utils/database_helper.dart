// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
import '../models/work_session.dart';
import '../models/message_record.dart';
import '../models/evidence_item.dart';

// 内存数据库实现 (用于Web版本演示)
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  // 内存存储
  static List<WorkSession> _workSessions = [];
  static List<MessageRecord> _messageRecords = [];
  static List<EvidenceItem> _evidenceItems = [];
  static int _nextId = 1;

  DatabaseHelper._init();

  Future<void> get database async {
    // 模拟数据库初始化
    print('内存数据库已初始化');
  }

  // 工作会话相关操作 (内存版本)
  Future<int> insertWorkSession(WorkSession session) async {
    final sessionWithId = WorkSession(
      id: _nextId++,
      startTime: session.startTime,
      endTime: session.endTime,
      appPackage: session.appPackage,
      appName: session.appName,
      duration: session.duration,
      isOvertime: session.isOvertime,
      createdAt: session.createdAt,
    );
    _workSessions.add(sessionWithId);
    return sessionWithId.id!;
  }

  Future<List<WorkSession>> getWorkSessions(int days) async {
    final cutoffTime = DateTime.now().subtract(Duration(days: days));
    return _workSessions
        .where((s) => s.createdAt.isAfter(cutoffTime))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<WorkSession>> getOvertimeSessions(int days) async {
    final cutoffTime = DateTime.now().subtract(Duration(days: days));
    return _workSessions
        .where((s) => s.isOvertime && s.createdAt.isAfter(cutoffTime))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // 消息记录相关操作 (内存版本)
  Future<int> insertMessageRecord(MessageRecord record) async {
    final recordWithId = MessageRecord(
      id: _nextId++,
      content: record.content,
      sender: record.sender,
      appPackage: record.appPackage,
      type: record.type,
      timestamp: record.timestamp,
      isAfterHours: record.isAfterHours,
      isFiltered: record.isFiltered,
      autoReply: record.autoReply,
      metadata: record.metadata,
    );
    _messageRecords.add(recordWithId);
    return recordWithId.id!;
  }

  Future<List<MessageRecord>> getMessageRecords(int days) async {
    final cutoffTime = DateTime.now().subtract(Duration(days: days));
    return _messageRecords
        .where((r) => r.timestamp.isAfter(cutoffTime))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // 证据项相关操作 (内存版本)
  Future<int> insertEvidence(EvidenceItem evidence) async {
    final evidenceWithId = EvidenceItem(
      id: _nextId++,
      type: evidence.type,
      content: evidence.content,
      timestamp: evidence.timestamp,
      metadata: evidence.metadata,
      filePath: evidence.filePath,
      isExported: evidence.isExported,
    );
    _evidenceItems.add(evidenceWithId);
    return evidenceWithId.id!;
  }

  Future<List<EvidenceItem>> getAllEvidence() async {
    return List.from(_evidenceItems)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<List<EvidenceItem>> getEvidenceByType(EvidenceType type) async {
    return _evidenceItems
        .where((e) => e.type == type)
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> close() async {
    // 内存数据库无需关闭
    print('内存数据库关闭');
  }
}