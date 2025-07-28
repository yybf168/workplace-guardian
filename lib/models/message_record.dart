enum MessageType {
  workMessage,
  personalMessage,
  spam,
  urgent,
}

class MessageRecord {
  final int? id;
  final String content;
  final String sender;
  final String appPackage;
  final MessageType type;
  final DateTime timestamp;
  final bool isAfterHours;
  final bool isFiltered;
  final String? autoReply;
  final Map<String, dynamic>? metadata;

  MessageRecord({
    this.id,
    required this.content,
    required this.sender,
    required this.appPackage,
    required this.type,
    required this.timestamp,
    required this.isAfterHours,
    required this.isFiltered,
    this.autoReply,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'sender': sender,
      'app_package': appPackage,
      'type': type.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_after_hours': isAfterHours ? 1 : 0,
      'is_filtered': isFiltered ? 1 : 0,
      'auto_reply': autoReply,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
    };
  }

  factory MessageRecord.fromMap(Map<String, dynamic> map) {
    return MessageRecord(
      id: map['id'],
      content: map['content'],
      sender: map['sender'],
      appPackage: map['app_package'],
      type: MessageType.values[map['type']],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isAfterHours: map['is_after_hours'] == 1,
      isFiltered: map['is_filtered'] == 1,
      autoReply: map['auto_reply'],
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
    );
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    // 简单的JSON编码，实际项目中可以使用dart:convert
    return metadata.toString();
  }

  static Map<String, dynamic> _decodeMetadata(String metadata) {
    // 简单的解码，实际项目中需要更完善的实现
    return {};
  }
}