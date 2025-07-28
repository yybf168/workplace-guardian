enum EvidenceType {
  overtime,
  workMessage,
  appUsage,
  screenshot,
  other,
}

class EvidenceItem {
  final int? id;
  final EvidenceType type;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? filePath;
  final bool isExported;

  EvidenceItem({
    this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.metadata,
    this.filePath,
    this.isExported = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
      'file_path': filePath,
      'is_exported': isExported ? 1 : 0,
    };
  }

  factory EvidenceItem.fromMap(Map<String, dynamic> map) {
    return EvidenceItem(
      id: map['id'],
      type: EvidenceType.values[map['type']],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
      filePath: map['file_path'],
      isExported: map['is_exported'] == 1,
    );
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    return metadata.toString();
  }

  static Map<String, dynamic> _decodeMetadata(String metadata) {
    return {};
  }

  String get typeDisplayName {
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