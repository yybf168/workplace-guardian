# Android Studio E盘安装指南

## 📁 推荐的目录结构

```
E:\
├── zcsw\                          # 你的Flutter项目（已存在）
├── Android\
│   ├── AndroidStudio\             # Android Studio安装目录
│   ├── Sdk\                       # Android SDK目录
│   └── Projects\                  # 其他Android项目（可选）
└── Flutter\                       # Flutter SDK（如果要移动的话）
```

## 🚀 安装步骤

### 1. 下载Android Studio
- 访问：https://developer.android.com/studio
- 下载最新版本（约1GB）
- 选择"Download Android Studio"

### 2. 自定义安装路径

#### 安装时的关键设置：
```
安装路径：E:\Android\AndroidStudio
SDK路径：E:\Android\Sdk
```

#### 详细安装步骤：
1. **运行安装程序**
2. **选择"Custom"安装类型**（重要！）
3. **设置安装路径**：
   - Android Studio Location: `E:\Android\AndroidStudio`
4. **设置SDK路径**：
   - Android SDK Location: `E:\Android\Sdk`
5. **选择组件**：
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Performance (Intel HAXM)
   - ✅ Android Virtual Device
6. **完成安装**

### 3. 首次启动配置

#### 启动Android Studio后：
1. **选择"Standard"设置**
2. **确认SDK路径**：`E:\Android\Sdk`
3. **下载必要组件**（约2-3GB）：
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator
   - 至少一个Android API版本（推荐API 33/34）

### 4. 环境变量配置

#### 在PowerShell中设置（临时）：
```powershell
# 设置Android SDK路径
$env:ANDROID_HOME = "E:\Android\Sdk"
$env:PATH += ";E:\Android\Sdk\platform-tools;E:\Android\Sdk\tools"

# 验证设置
echo $env:ANDROID_HOME
adb version
```

#### 永久设置环境变量：
1. **打开系统环境变量**：
   - Win + R → `sysdm.cpl` → 高级 → 环境变量
2. **添加系统变量**：
   - 变量名：`ANDROID_HOME`
   - 变量值：`E:\Android\Sdk`
3. **修改PATH变量**，添加：
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`

### 5. 验证安装

```bash
# 重新打开PowerShell，验证Flutter环境
flutter doctor

# 应该显示类似：
# [√] Flutter (Channel stable, 3.19.6, ...)
# [√] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
# [√] Android Studio (version 2023.3)
```

## 🔧 可能遇到的问题

### 问题1：磁盘空间不足
```
解决方案：
- Android Studio: ~3GB
- Android SDK: ~5-10GB
- 确保E盘有至少15GB可用空间
```

### 问题2：路径包含中文或特殊字符
```
解决方案：
- 确保所有路径都是英文
- 避免空格和特殊字符
- 推荐路径：E:\Android\AndroidStudio
```

### 问题3：网络下载慢
```
解决方案：
- 使用代理或VPN
- 或者下载离线SDK包
- 设置国内镜像源
```

## 📱 创建虚拟设备（可选）

如果没有Android手机，可以创建模拟器：

### 1. 在Android Studio中：
- Tools → AVD Manager
- Create Virtual Device
- 选择设备型号（推荐Pixel 6）
- 选择系统镜像（推荐API 33）
- 完成创建

### 2. 启动模拟器：
```bash
# 查看可用模拟器
emulator -list-avds

# 启动模拟器
emulator -avd [模拟器名称]
```

## 🎯 完成后的测试

### 1. 验证环境：
```bash
flutter doctor
```

### 2. 检查设备：
```bash
flutter devices
```

### 3. 运行项目：
```bash
cd E:\zcsw
flutter run
```

## 💡 优化建议

### 1. 性能优化：
- 如果E盘是SSD，性能会更好
- 给Android Studio分配足够内存（8GB+推荐）

### 2. 备份重要配置：
- SDK路径：`E:\Android\Sdk`
- 项目路径：`E:\zcsw`
- 环境变量设置

### 3. 定期清理：
- 清理旧的构建文件：`flutter clean`
- 清理Android缓存：Android Studio → File → Invalidate Caches

## 📞 需要帮助？

如果安装过程中遇到问题：
1. 检查磁盘空间是否充足
2. 确认网络连接正常
3. 验证路径设置正确
4. 查看Android Studio的错误日志

---

**重要提示**：安装完成后，记得重启PowerShell或命令提示符，以确保环境变量生效！