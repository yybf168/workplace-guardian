class WorkSession {
  final int? id;
  final DateTime startTime;
  final DateTime? endTime;
  final String appPackage;
  final String appName;
  final int duration; // 持续时间（秒）
  final bool isOvertime;
  final DateTime createdAt;

  WorkSession({
    this.id,
    required this.startTime,
    this.endTime,
    required this.appPackage,
    required this.appName,
    required this.duration,
    required this.isOvertime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime?.millisecondsSinceEpoch,
      'app_package': appPackage,
      'app_name': appName,
      'duration': duration,
      'is_overtime': isOvertime ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory WorkSession.fromMap(Map<String, dynamic> map) {
    return WorkSession(
      id: map['id'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: map['end_time'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['end_time'])
          : null,
      appPackage: map['app_package'],
      appName: map['app_name'],
      duration: map['duration'],
      isOvertime: map['is_overtime'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}