import 'dart:async';
import '../models/message_record.dart';
import '../models/evidence_item.dart';
import '../utils/database_helper.dart';

class MessageFilterService {
  static final MessageFilterService instance = MessageFilterService._init();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  // 工作相关关键词
  final List<String> _workKeywords = [
    // 中文关键词
    '项目', '会议', 'deadline', '需求', '加班', '任务', '汇报',
    '方案', '进度', '客户', '合同', '预算', '计划', '紧急',
    '开发', '测试', '上线', '部署', '修复', '优化', '重构',
    '需求', '设计', '评审', '验收', '发布', '维护', '支持',
    '培训', '文档', '规范', '流程', '审批', '报告', '总结',
    '飞书', '文档协作', '在线会议', '日历', '云文档', '多维表格',
    
    // 英文关键词
    'project', 'meeting', 'urgent', 'task', 'report', 'client',
    'development', 'testing', 'deployment', 'release', 'bug',
    'feature', 'requirement', 'design', 'review', 'approval',
    'documentation', 'training', 'support', 'maintenance',
    'deadline', 'milestone', 'sprint', 'scrum', 'agile',
    'lark', 'feishu', 'collaboration', 'video call', 'calendar'
  ];

  // 自动回复模板
  final Map<String, String> _autoReplyTemplates = {
    'default': '您好，我已收到您的消息。由于现在是非工作时间，我会在工作时间内回复您。如有紧急事务，请致电联系。',
    'weekend': '您好，今天是周末，我会在下个工作日回复您的消息。感谢理解！',
    'late_night': '您好，现在是深夜时间，我会在明天工作时间内回复您。祝您晚安！',
  };

  MessageFilterService._init();

  // 开始消息过滤
  Future<void> startMessageFiltering() async {
    // 这里应该实现通知监听，由于Flutter限制，这是一个简化版本
    print('消息过滤服务已启动');
    
    // 生成一些模拟消息用于演示
    await generateMockMessages();
  }
  
  // 生成模拟消息
  Future<void> generateMockMessages() async {
    final mockMessages = [
      {'content': '项目进度如何？明天需要汇报', 'sender': '张经理', 'app': 'com.tencent.wework'},
      {'content': '紧急：客户要求今晚修复这个bug', 'sender': '李主管', 'app': 'com.alibaba.android.rimet'},
      {'content': '飞书文档需要今晚完成，请协作编辑', 'sender': '项目经理', 'app': 'com.ss.android.lark'},
      {'content': '会议纪要请尽快整理发送', 'sender': '王总监', 'app': 'com.microsoft.teams'},
      {'content': '需求文档有更新，请查看', 'sender': '产品经理', 'app': 'com.slack'},
      {'content': '明天的演示准备好了吗？', 'sender': '技术总监', 'app': 'com.tencent.wework'},
      {'content': '飞书日历上的会议时间调整了，请注意', 'sender': '助理', 'app': 'com.ss.android.lark'},
      {'content': '多维表格的数据需要更新', 'sender': '数据分析师', 'app': 'com.ss.android.lark'},
    ];
    
    for (int i = 0; i < 3; i++) {
      final random = DateTime.now().millisecond % mockMessages.length;
      final mockMsg = mockMessages[random];
      
      await handleIncomingMessage(
        mockMsg['content']!,
        mockMsg['sender']!,
        mockMsg['app']!,
      );
      
      // 添加延迟避免重复
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // 处理收到的消息（模拟实现）
  Future<void> handleIncomingMessage(String content, String sender, String appPackage) async {
    final message = MessageRecord(
      content: content,
      sender: sender,
      appPackage: appPackage,
      type: _classifyMessage(content),
      timestamp: DateTime.now(),
      isAfterHours: _isAfterWorkHours(DateTime.now()),
      isFiltered: _shouldFilterMessage(content),
    );

    // 保存消息记录
    await _db.insertMessageRecord(message);

    // 如果是工作相关消息且在非工作时间，收集证据
    if (message.type == MessageType.workMessage && message.isAfterHours) {
      await _collectMessageEvidence(message);
    }

    // 如果需要过滤，发送自动回复
    if (message.isFiltered && message.isAfterHours) {
      await _sendAutoReply(sender, _getAutoReplyTemplate());
    }
  }

  // 智能分类消息 - 增强版本
  MessageType _classifyMessage(String content) {
    final lowerContent = content.toLowerCase();
    
    // 紧急消息优先级最高
    if (_isUrgentMessage(lowerContent)) {
      return MessageType.urgent;
    }
    
    // 垃圾消息检测
    if (_isSpamMessage(lowerContent)) {
      return MessageType.spam;
    }
    
    // 工作消息检测 - 使用权重算法
    if (_isWorkMessage(lowerContent)) {
      return MessageType.workMessage;
    }
    
    return MessageType.personalMessage;
  }
  
  // 紧急消息检测
  bool _isUrgentMessage(String content) {
    final urgentKeywords = [
      '紧急', 'urgent', '急', '马上', '立即', 'asap', 'immediately',
      '火急', '十万火急', '刻不容缓', '迫在眉睫', 'critical', 'emergency'
    ];
    
    return urgentKeywords.any((keyword) => content.contains(keyword.toLowerCase()));
  }
  
  // 垃圾消息检测
  bool _isSpamMessage(String content) {
    final spamKeywords = [
      '广告', '推广', '营销', '促销', '优惠', '折扣', '免费',
      'advertisement', 'promotion', 'marketing', 'discount', 'free',
      '点击链接', '立即购买', '限时优惠', '赚钱', '投资', '理财'
    ];
    
    return spamKeywords.any((keyword) => content.contains(keyword.toLowerCase()));
  }
  
  // 工作消息检测 - 权重算法
  bool _isWorkMessage(String content) {
    int workScore = 0;
    
    // 高权重关键词 (3分)
    final highWeightKeywords = [
      '项目', '会议', '任务', '汇报', '需求', 'project', 'meeting', 'task'
    ];
    
    // 中权重关键词 (2分)
    final mediumWeightKeywords = [
      '工作', '客户', '合同', '预算', '计划', 'work', 'client', 'budget'
    ];
    
    // 低权重关键词 (1分)
    final lowWeightKeywords = [
      '文档', '邮件', '电话', '联系', 'document', 'email', 'call'
    ];
    
    for (final keyword in highWeightKeywords) {
      if (content.contains(keyword.toLowerCase())) workScore += 3;
    }
    
    for (final keyword in mediumWeightKeywords) {
      if (content.contains(keyword.toLowerCase())) workScore += 2;
    }
    
    for (final keyword in lowWeightKeywords) {
      if (content.contains(keyword.toLowerCase())) workScore += 1;
    }
    
    // 工作时间内的消息权重降低
    if (!_isAfterWorkHours(DateTime.now())) {
      workScore = (workScore * 0.7).round();
    }
    
    return workScore >= 3; // 阈值为3分
  }

  // 判断是否应该过滤消息
  bool _shouldFilterMessage(String content) {
    final messageType = _classifyMessage(content);
    final isAfterHours = _isAfterWorkHours(DateTime.now());
    
    // 非工作时间的工作消息需要过滤
    if (isAfterHours && messageType == MessageType.workMessage) {
      return true;
    }
    
    // 紧急消息不过滤
    if (messageType == MessageType.urgent) {
      return false;
    }
    
    return false;
  }

  // 判断是否为非工作时间
  bool _isAfterWorkHours(DateTime time) {
    final hour = time.hour;
    final weekday = time.weekday;
    
    // 周末
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return true;
    }
    
    // 工作日的非工作时间
    if (hour < 9 || hour >= 18) {
      return true;
    }
    
    return false;
  }

  // 收集消息证据
  Future<void> _collectMessageEvidence(MessageRecord message) async {
    final evidence = EvidenceItem(
      type: EvidenceType.workMessage,
      content: '收到非工作时间工作消息: ${message.content}',
      timestamp: message.timestamp,
      metadata: {
        'sender': message.sender,
        'app_package': message.appPackage,
        'message_type': message.type.toString(),
        'is_after_hours': message.isAfterHours,
      },
    );

    await _db.insertEvidence(evidence);
  }

  // 发送自动回复（模拟实现）
  Future<void> _sendAutoReply(String recipient, String template) async {
    print('发送自动回复给 $recipient: $template');
    // 实际实现中需要调用相应的API
  }

  // 获取自动回复模板
  String _getAutoReplyTemplate() {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;
    
    if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
      return _autoReplyTemplates['weekend']!;
    } else if (hour >= 22 || hour < 6) {
      return _autoReplyTemplates['late_night']!;
    } else {
      return _autoReplyTemplates['default']!;
    }
  }

  // 获取今日过滤消息数量
  Future<int> getTodayFilteredCount() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final messages = await _db.getMessageRecords(1);
    return messages.where((m) => 
      m.isFiltered && 
      m.timestamp.isAfter(startOfDay) && 
      m.timestamp.isBefore(endOfDay)
    ).length;
  }

  // 获取本周工作消息数量
  Future<int> getWeekWorkMessageCount() async {
    final messages = await _db.getMessageRecords(7);
    return messages.where((m) => 
      m.type == MessageType.workMessage && m.isAfterHours
    ).length;
  }
}