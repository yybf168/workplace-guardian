import 'dart:async';
import 'package:flutter/material.dart';
import '../models/work_session.dart';
import '../models/message_record.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  
  final List<AppNotification> _notifications = [];
  final StreamController<AppNotification> _notificationController = 
      StreamController<AppNotification>.broadcast();
  
  NotificationService._init();

  Stream<AppNotification> get notificationStream => _notificationController.stream;

  // 发送加班提醒通知
  Future<void> sendOvertimeAlert(WorkSession session) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '加班提醒',
      message: '检测到您正在使用${session.appName}，当前为非工作时间',
      type: NotificationType.overtime,
      timestamp: DateTime.now(),
      data: {'session': session},
    );
    
    await _addNotification(notification);
  }

  // 发送工作消息提醒
  Future<void> sendWorkMessageAlert(MessageRecord message) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '工作消息提醒',
      message: '收到来自${message.sender}的工作消息',
      type: NotificationType.workMessage,
      timestamp: DateTime.now(),
      data: {'message': message},
    );
    
    await _addNotification(notification);
  }

  // 发送工作边界提醒
  Future<void> sendBoundaryReminder() async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '工作边界提醒',
      message: '建议您关闭工作应用，享受个人时间',
      type: NotificationType.boundary,
      timestamp: DateTime.now(),
    );
    
    await _addNotification(notification);
  }

  // 发送健康提醒
  Future<void> sendHealthReminder(String message) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '健康提醒',
      message: message,
      type: NotificationType.health,
      timestamp: DateTime.now(),
    );
    
    await _addNotification(notification);
  }

  // 发送系统通知
  Future<void> sendSystemNotification(String title, String message) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: NotificationType.system,
      timestamp: DateTime.now(),
    );
    
    await _addNotification(notification);
  }

  // 添加通知
  Future<void> _addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    
    // 限制通知数量
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }
    
    _notificationController.add(notification);
    
    // 自动标记为已读（5秒后）
    Timer(const Duration(seconds: 5), () {
      markAsRead(notification.id);
    });
  }

  // 标记通知为已读
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  // 删除通知
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  // 清空所有通知
  void clearAllNotifications() {
    _notifications.clear();
  }

  // 获取所有通知
  List<AppNotification> getAllNotifications() {
    return List.from(_notifications);
  }

  // 获取未读通知数量
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // 获取特定类型的通知
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // 释放资源
  void dispose() {
    _notificationController.close();
  }
}

// 通知数据模型
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.overtime:
        return Icons.access_time;
      case NotificationType.workMessage:
        return Icons.message;
      case NotificationType.boundary:
        return Icons.shield;
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.overtime:
        return Colors.orange;
      case NotificationType.workMessage:
        return Colors.blue;
      case NotificationType.boundary:
        return Colors.purple;
      case NotificationType.health:
        return Colors.green;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}

enum NotificationType {
  overtime,
  workMessage,
  boundary,
  health,
  system,
}