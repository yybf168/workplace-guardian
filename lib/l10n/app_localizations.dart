import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // 应用标题
  String get appTitle => _localizedValues[locale.languageCode]?['app_title'] ?? 'Workplace Guardian';

  // 主界面
  String get homeTitle => _localizedValues[locale.languageCode]?['home_title'] ?? '职场边界守卫';
  String get monitoring => _localizedValues[locale.languageCode]?['monitoring'] ?? '守护中';
  String get paused => _localizedValues[locale.languageCode]?['paused'] ?? '已暂停';
  String get monitoringDescription => _localizedValues[locale.languageCode]?['monitoring_description'] ?? '正在监控工作边界';
  String get pausedDescription => _localizedValues[locale.languageCode]?['paused_description'] ?? '点击开始按钮启动监控';

  // 统计相关
  String get todayStats => _localizedValues[locale.languageCode]?['today_stats'] ?? '今日统计';
  String get overtimeHours => _localizedValues[locale.languageCode]?['overtime_hours'] ?? '加班时长';
  String get filteredMessages => _localizedValues[locale.languageCode]?['filtered_messages'] ?? '过滤消息';
  String get weeklyOvertime => _localizedValues[locale.languageCode]?['weekly_overtime'] ?? '本周加班';
  String get totalEvidence => _localizedValues[locale.languageCode]?['total_evidence'] ?? '总证据';

  // 功能模块
  String get workTimeStats => _localizedValues[locale.languageCode]?['work_time_stats'] ?? '工时统计';
  String get evidenceCollection => _localizedValues[locale.languageCode]?['evidence_collection'] ?? '证据收集';
  String get messageFilter => _localizedValues[locale.languageCode]?['message_filter'] ?? '消息过滤';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? '设置';

  // 快速操作
  String get quickActions => _localizedValues[locale.languageCode]?['quick_actions'] ?? '快速操作';
  String get exportEvidence => _localizedValues[locale.languageCode]?['export_evidence'] ?? '导出证据';
  String get refreshData => _localizedValues[locale.languageCode]?['refresh_data'] ?? '刷新数据';

  // 统计界面
  String get overview => _localizedValues[locale.languageCode]?['overview'] ?? '概览';
  String get trends => _localizedValues[locale.languageCode]?['trends'] ?? '趋势';
  String get applications => _localizedValues[locale.languageCode]?['applications'] ?? '应用';
  String get analysis => _localizedValues[locale.languageCode]?['analysis'] ?? '分析';

  // 证据界面
  String get evidenceList => _localizedValues[locale.languageCode]?['evidence_list'] ?? '证据列表';
  String get statisticalAnalysis => _localizedValues[locale.languageCode]?['statistical_analysis'] ?? '统计分析';
  String get noEvidence => _localizedValues[locale.languageCode]?['no_evidence'] ?? '暂无证据记录';
  String get noEvidenceDescription => _localizedValues[locale.languageCode]?['no_evidence_description'] ?? '开启监控后会自动收集证据';

  // 设置界面
  String get basicSettings => _localizedValues[locale.languageCode]?['basic_settings'] ?? '基本设置';
  String get workTime => _localizedValues[locale.languageCode]?['work_time'] ?? '工作时间';
  String get appManagement => _localizedValues[locale.languageCode]?['app_management'] ?? '应用管理';
  String get permissionManagement => _localizedValues[locale.languageCode]?['permission_management'] ?? '权限管理';
  String get dataManagement => _localizedValues[locale.languageCode]?['data_management'] ?? '数据管理';
  String get about => _localizedValues[locale.languageCode]?['about'] ?? '关于';

  // 按钮文本
  String get save => _localizedValues[locale.languageCode]?['save'] ?? '保存';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? '取消';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? '确定';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? '删除';
  String get export => _localizedValues[locale.languageCode]?['export'] ?? '导出';
  String get share => _localizedValues[locale.languageCode]?['share'] ?? '分享';

  // 消息类型
  String get workMessage => _localizedValues[locale.languageCode]?['work_message'] ?? '工作消息';
  String get personalMessage => _localizedValues[locale.languageCode]?['personal_message'] ?? '个人消息';
  String get urgentMessage => _localizedValues[locale.languageCode]?['urgent_message'] ?? '紧急消息';
  String get spamMessage => _localizedValues[locale.languageCode]?['spam_message'] ?? '垃圾消息';

  // 证据类型
  String get overtimeRecord => _localizedValues[locale.languageCode]?['overtime_record'] ?? '加班记录';
  String get messageRecord => _localizedValues[locale.languageCode]?['message_record'] ?? '消息记录';
  String get appUsageRecord => _localizedValues[locale.languageCode]?['app_usage_record'] ?? '应用使用';
  String get screenshotEvidence => _localizedValues[locale.languageCode]?['screenshot_evidence'] ?? '截图证据';
  String get otherEvidence => _localizedValues[locale.languageCode]?['other_evidence'] ?? '其他';

  // 时间单位
  String get minutes => _localizedValues[locale.languageCode]?['minutes'] ?? '分钟';
  String get hours => _localizedValues[locale.languageCode]?['hours'] ?? '小时';
  String get days => _localizedValues[locale.languageCode]?['days'] ?? '天';
  String get items => _localizedValues[locale.languageCode]?['items'] ?? '条';

  static const Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'app_title': '职场边界守卫',
      'home_title': '职场边界守卫',
      'monitoring': '守护中',
      'paused': '已暂停',
      'monitoring_description': '正在监控工作边界',
      'paused_description': '点击开始按钮启动监控',
      'today_stats': '今日统计',
      'overtime_hours': '加班时长',
      'filtered_messages': '过滤消息',
      'weekly_overtime': '本周加班',
      'total_evidence': '总证据',
      'work_time_stats': '工时统计',
      'evidence_collection': '证据收集',
      'message_filter': '消息过滤',
      'settings': '设置',
      'quick_actions': '快速操作',
      'export_evidence': '导出证据',
      'refresh_data': '刷新数据',
      'overview': '概览',
      'trends': '趋势',
      'applications': '应用',
      'analysis': '分析',
      'evidence_list': '证据列表',
      'statistical_analysis': '统计分析',
      'no_evidence': '暂无证据记录',
      'no_evidence_description': '开启监控后会自动收集证据',
      'basic_settings': '基本设置',
      'work_time': '工作时间',
      'app_management': '应用管理',
      'permission_management': '权限管理',
      'data_management': '数据管理',
      'about': '关于',
      'save': '保存',
      'cancel': '取消',
      'confirm': '确定',
      'delete': '删除',
      'export': '导出',
      'share': '分享',
      'work_message': '工作消息',
      'personal_message': '个人消息',
      'urgent_message': '紧急消息',
      'spam_message': '垃圾消息',
      'overtime_record': '加班记录',
      'message_record': '消息记录',
      'app_usage_record': '应用使用',
      'screenshot_evidence': '截图证据',
      'other_evidence': '其他',
      'minutes': '分钟',
      'hours': '小时',
      'days': '天',
      'items': '条',
    },
    'en': {
      'app_title': 'Workplace Guardian',
      'home_title': 'Workplace Guardian',
      'monitoring': 'Monitoring',
      'paused': 'Paused',
      'monitoring_description': 'Monitoring work boundaries',
      'paused_description': 'Click start button to begin monitoring',
      'today_stats': 'Today\'s Stats',
      'overtime_hours': 'Overtime Hours',
      'filtered_messages': 'Filtered Messages',
      'weekly_overtime': 'Weekly Overtime',
      'total_evidence': 'Total Evidence',
      'work_time_stats': 'Work Time Stats',
      'evidence_collection': 'Evidence Collection',
      'message_filter': 'Message Filter',
      'settings': 'Settings',
      'quick_actions': 'Quick Actions',
      'export_evidence': 'Export Evidence',
      'refresh_data': 'Refresh Data',
      'overview': 'Overview',
      'trends': 'Trends',
      'applications': 'Applications',
      'analysis': 'Analysis',
      'evidence_list': 'Evidence List',
      'statistical_analysis': 'Statistical Analysis',
      'no_evidence': 'No Evidence Records',
      'no_evidence_description': 'Evidence will be collected automatically after monitoring starts',
      'basic_settings': 'Basic Settings',
      'work_time': 'Work Time',
      'app_management': 'App Management',
      'permission_management': 'Permission Management',
      'data_management': 'Data Management',
      'about': 'About',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'delete': 'Delete',
      'export': 'Export',
      'share': 'Share',
      'work_message': 'Work Message',
      'personal_message': 'Personal Message',
      'urgent_message': 'Urgent Message',
      'spam_message': 'Spam Message',
      'overtime_record': 'Overtime Record',
      'message_record': 'Message Record',
      'app_usage_record': 'App Usage',
      'screenshot_evidence': 'Screenshot Evidence',
      'other_evidence': 'Other',
      'minutes': 'minutes',
      'hours': 'hours',
      'days': 'days',
      'items': 'items',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}