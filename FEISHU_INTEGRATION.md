# 飞书集成说明

## 🚀 飞书支持功能

职场边界守卫现已全面支持飞书（Lark）应用的监控和管理功能。

### 📱 支持的飞书功能

#### 1. 应用监控
- **包名**: `com.ss.android.lark`
- **应用名称**: 飞书
- **监控范围**: 
  - 文档协作时间
  - 在线会议参与
  - 日历查看和管理
  - 多维表格操作
  - 即时消息收发

#### 2. 消息过滤
支持识别以下飞书相关关键词：
- **中文关键词**: 飞书、文档协作、在线会议、日历、云文档、多维表格
- **英文关键词**: lark、feishu、collaboration、video call、calendar

#### 3. 证据收集
自动收集以下类型的飞书使用证据：
- 非工作时间使用飞书开会和处理文档
- 周末期间飞书文档协作记录
- 深夜时间飞书会议参与记录
- 休息时间飞书消息处理记录

### 🔧 配置说明

#### 默认配置
飞书已被添加到以下默认配置中：
1. **工作应用列表**: 自动包含在监控应用中
2. **消息过滤**: 自动识别飞书相关工作消息
3. **证据收集**: 自动收集飞书使用证据
4. **统计报告**: 包含在工作时长统计中

#### 自定义配置
用户可以在设置页面中：
- 添加更多飞书相关关键词
- 调整飞书消息过滤规则
- 自定义飞书使用时间统计

### 📊 监控数据

#### 统计指标
- 飞书日均使用时长
- 非工作时间飞书使用频率
- 飞书会议参与时长
- 飞书文档协作时间

#### 证据类型
- **加班记录**: 非工作时间使用飞书的详细记录
- **工作消息**: 飞书中收到的工作相关消息
- **应用使用**: 飞书应用的使用时长和频率
- **会议记录**: 飞书会议的参与时间和时长

### 🛡️ 隐私保护

#### 数据安全
- 所有飞书使用数据仅存储在本地
- 不会上传任何飞书聊天内容或文档
- 仅记录使用时间和基本统计信息
- 支持随时删除所有飞书相关数据

#### 权限说明
- 仅监控应用使用时长，不读取具体内容
- 不会访问飞书中的文档或聊天记录
- 仅用于工作时间统计和边界管理

### 📈 使用场景

#### 适用情况
1. **远程办公**: 监控在家使用飞书的工作时间
2. **项目协作**: 统计飞书文档协作的时间投入
3. **会议管理**: 记录飞书会议的参与情况
4. **工作边界**: 防止非工作时间过度使用飞书

#### 报告内容
生成的报告将包含：
- 飞书使用时长统计
- 非工作时间飞书使用记录
- 飞书相关工作消息统计
- 飞书会议参与分析

### 🔄 更新日志

#### v1.0.0 (当前版本)
- ✅ 添加飞书应用监控支持
- ✅ 集成飞书消息过滤功能
- ✅ 支持飞书证据自动收集
- ✅ 包含飞书使用统计报告
- ✅ 添加飞书相关关键词识别

### 📞 技术支持

如果在使用飞书集成功能时遇到问题，请：
1. 检查应用权限设置
2. 确认飞书应用包名正确
3. 查看监控日志信息
4. 联系技术支持团队

---

**注意**: 飞书集成功能遵循相同的隐私政策，所有数据仅用于个人工作时间管理，不会泄露任何敏感信息。