import 'package:flutter/material.dart';
import '../models/evidence_item.dart';
import '../services/evidence_collector.dart';
import '../utils/database_helper.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final EvidenceCollector _collector = EvidenceCollector.instance;
  
  List<EvidenceItem> _allEvidence = [];
  Map<String, int> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvidence();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvidence() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final evidence = await _db.getAllEvidence();
      final stats = await _collector.getEvidenceStatistics();

      setState(() {
        _allEvidence = evidence;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载证据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('证据收集'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportEvidence,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvidence,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '证据列表', icon: Icon(Icons.list)),
            Tab(text: '统计分析', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEvidenceList(),
                _buildStatistics(),
              ],
            ),
    );
  }

  Widget _buildEvidenceList() {
    if (_allEvidence.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无证据记录',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '开启监控后会自动收集证据',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvidence,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allEvidence.length,
        itemBuilder: (context, index) {
          final evidence = _allEvidence[index];
          return _buildEvidenceCard(evidence);
        },
      ),
    );
  }

  Widget _buildEvidenceCard(EvidenceItem evidence) {
    Color typeColor;
    IconData typeIcon;
    
    switch (evidence.type) {
      case EvidenceType.overtime:
        typeColor = Colors.orange;
        typeIcon = Icons.access_time;
        break;
      case EvidenceType.workMessage:
        typeColor = Colors.blue;
        typeIcon = Icons.message;
        break;
      case EvidenceType.appUsage:
        typeColor = Colors.green;
        typeIcon = Icons.apps;
        break;
      case EvidenceType.screenshot:
        typeColor = Colors.purple;
        typeIcon = Icons.screenshot;
        break;
      case EvidenceType.other:
        typeColor = Colors.grey;
        typeIcon = Icons.help;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withOpacity(0.2),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          evidence.typeDisplayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evidence.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(evidence.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '详细信息:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(evidence.content),
                if (evidence.metadata != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '元数据:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    evidence.metadata.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _shareEvidence(evidence),
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteEvidence(evidence),
                      icon: const Icon(Icons.delete),
                      label: const Text('删除'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总体统计
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '证据统计',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '总证据数',
                          '${_statistics['total'] ?? 0}',
                          Icons.folder,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '本周新增',
                          '${_statistics['this_week'] ?? 0}',
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '加班记录',
                          '${_statistics['overtime'] ?? 0}',
                          Icons.access_time,
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '工作消息',
                          '${_statistics['messages'] ?? 0}',
                          Icons.message,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 类型分布
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '证据类型分布',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTypeDistribution(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 操作按钮
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '证据管理',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _exportEvidence,
                          icon: const Icon(Icons.download),
                          label: const Text('导出全部'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showCleanupDialog,
                          icon: const Icon(Icons.cleaning_services),
                          label: const Text('清理旧数据'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDistribution() {
    final typeStats = <EvidenceType, int>{};
    for (final evidence in _allEvidence) {
      typeStats[evidence.type] = (typeStats[evidence.type] ?? 0) + 1;
    }

    return Column(
      children: typeStats.entries.map((entry) {
        final percentage = _allEvidence.isNotEmpty 
            ? entry.value / _allEvidence.length 
            : 0.0;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  _getTypeDisplayName(entry.key),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.value}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getTypeDisplayName(EvidenceType type) {
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _exportEvidence() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在导出证据包...'),
            ],
          ),
        ),
      );

      final path = await _collector.exportEvidencePackage('证据导出_${DateTime.now().millisecondsSinceEpoch}');
      
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('证据包已导出到: $path'),
            action: SnackBarAction(
              label: '确定',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  void _shareEvidence(EvidenceItem evidence) {
    // 实现分享功能
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享证据'),
        content: Text('分享证据: ${evidence.content}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 实际的分享逻辑
            },
            child: const Text('分享'),
          ),
        ],
      ),
    );
  }

  void _deleteEvidence(EvidenceItem evidence) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除证据'),
        content: const Text('确定要删除这条证据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 实际的删除逻辑需要在DatabaseHelper中实现
              _loadEvidence();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理旧数据'),
        content: const Text('将删除30天前的证据数据，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _collector.cleanupOldEvidence();
              _loadEvidence();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('旧数据清理完成')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}