# 职场边界守卫 - 手机安装指南

## 📱 完整安装步骤

### 第一步：安装Android开发环境

#### 1. 下载并安装Android Studio
- 访问：https://developer.android.com/studio
- 下载Android Studio最新版本
- 运行安装程序，选择标准安装

#### 2. 配置Android SDK
```bash
# 启动Android Studio后：
# 1. 点击 "More Actions" -> "SDK Manager"
# 2. 在 "SDK Platforms" 选项卡中，至少选择一个Android版本（推荐Android 13/API 33）
# 3. 在 "SDK Tools" 选项卡中，确保选中：
#    - Android SDK Build-Tools
#    - Android SDK Command-line Tools
#    - Android SDK Platform-Tools
#    - Android Emulator
# 4. 点击 "Apply" 下载并安装
```

#### 3. 设置环境变量
```powershell
# 添加Android SDK到系统PATH
# 通常SDK路径为：C:\Users\[用户名]\AppData\Local\Android\Sdk

# 在PowerShell中临时设置：
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools"

# 永久设置需要在系统环境变量中添加：
# ANDROID_HOME = C:\Users\[用户名]\AppData\Local\Android\Sdk
# PATH 中添加：%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools
```

### 第二步：验证环境

#### 1. 检查Flutter环境
```bash
flutter doctor
```

#### 2. 检查ADB工具
```bash
adb version
```

### 第三步：准备手机

#### 方式A：使用真实手机（推荐）

1. **启用开发者选项**
   - 设置 → 关于手机 → 连续点击"版本号"7次
   - 返回设置，找到"开发者选项"

2. **启用USB调试**
   - 开发者选项 → USB调试（开启）
   - 开发者选项 → 安装未知应用（开启）

3. **连接手机**
   - 用USB数据线连接手机到电脑
   - 手机上选择"传输文件"模式
   - 首次连接会弹出授权对话框，选择"始终允许"

#### 方式B：使用Android模拟器

1. **创建虚拟设备**
   ```bash
   # 在Android Studio中：
   # Tools → AVD Manager → Create Virtual Device
   # 选择设备型号 → 选择系统镜像 → 完成创建
   ```

2. **启动模拟器**
   ```bash
   # 在AVD Manager中点击启动按钮
   # 或使用命令行：
   emulator -avd [模拟器名称]
   ```

### 第四步：构建和安装应用

#### 方法1：直接运行调试版本
```bash
# 确保手机已连接或模拟器已启动
flutter devices

# 运行应用到设备
flutter run

# 如果有多个设备，指定设备ID
flutter run -d [设备ID]
```

#### 方法2：构建APK安装包
```bash
# 构建调试版APK（用于测试）
flutter build apk --debug

# 构建发布版APK（用于分发）
flutter build apk --release

# APK文件位置：
# build/app/outputs/flutter-apk/app-debug.apk
# build/app/outputs/flutter-apk/app-release.apk
```

#### 方法3：通过ADB安装APK
```bash
# 安装调试版本
adb install build/app/outputs/flutter-apk/app-debug.apk

# 安装发布版本
adb install build/app/outputs/flutter-apk/app-release.apk

# 如果需要覆盖安装
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### 第五步：测试应用功能

#### 1. 基础功能测试
- [ ] 应用启动正常
- [ ] 主界面显示完整
- [ ] 各个功能模块可以正常打开
- [ ] 数据生成和显示正常

#### 2. 权限测试
- [ ] 通知权限申请
- [ ] 存储权限申请
- [ ] 应用使用统计权限（需要手动在设置中开启）

#### 3. 功能模块测试
- [ ] 工时统计功能
- [ ] 证据收集功能
- [ ] 健康中心功能
- [ ] 通知中心功能
- [ ] 设置功能

### 第六步：常见问题解决

#### 问题1：设备未识别
```bash
# 检查设备连接
adb devices

# 如果显示 "unauthorized"，检查手机上的授权对话框
# 如果显示 "device"，说明连接正常
```

#### 问题2：构建失败
```bash
# 清理项目
flutter clean

# 重新获取依赖
flutter pub get

# 重新构建
flutter build apk --debug
```

#### 问题3：安装失败
```bash
# 卸载旧版本
adb uninstall com.example.workplace_guardian

# 重新安装
adb install build/app/outputs/flutter-apk/app-debug.apk
```

#### 问题4：权限问题
- 某些权限需要在手机设置中手动开启
- 应用使用统计权限：设置 → 应用 → 特殊应用访问权限 → 使用情况访问权限
- 通知权限：设置 → 应用 → [应用名] → 通知

### 第七步：性能优化建议

#### 1. 发布版本优化
```bash
# 构建优化的发布版本
flutter build apk --release --shrink

# 构建App Bundle（推荐用于Google Play）
flutter build appbundle --release
```

#### 2. 应用签名（用于正式发布）
```bash
# 生成签名密钥
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 配置签名信息到 android/key.properties
# 在 android/app/build.gradle 中配置签名
```

## 🚀 快速开始命令

如果你已经有Android开发环境，可以直接使用以下命令：

```bash
# 1. 检查环境
flutter doctor

# 2. 检查设备
flutter devices

# 3. 运行应用
flutter run

# 或者构建APK
flutter build apk --debug
```

## 📞 技术支持

如果在安装过程中遇到问题：

1. 检查Flutter和Android SDK是否正确安装
2. 确认手机已启用开发者选项和USB调试
3. 检查USB连接和驱动程序
4. 查看Flutter官方文档：https://flutter.dev/docs/get-started/install

---

**注意**: 这是一个演示版本，某些功能使用模拟数据。在实际使用中，需要相应的系统权限才能获取真实的应用使用数据。