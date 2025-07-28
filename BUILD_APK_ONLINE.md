# 在线构建APK方案

## 🌐 使用GitHub Actions自动构建

### 1. 创建GitHub仓库
```bash
# 将项目上传到GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/workplace-guardian.git
git push -u origin main
```

### 2. 配置GitHub Actions

创建 `.github/workflows/build.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.6'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: workplace-guardian-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### 3. 下载构建的APK
- 推送代码到GitHub后，Actions会自动构建
- 在Actions页面下载生成的APK文件
- 传输到手机安装

## 📱 使用Codemagic（推荐）

### 1. 注册Codemagic
- 访问：https://codemagic.io
- 使用GitHub账号登录

### 2. 连接项目
- 选择你的GitHub仓库
- 配置构建设置

### 3. 自动构建
- 每次推送代码都会自动构建APK
- 可以直接下载安装包

## 🔧 本地简化构建（无Android Studio）

### 1. 下载Android SDK命令行工具
```bash
# 下载SDK命令行工具
# https://developer.android.com/studio#command-tools

# 解压到 C:\android-sdk
# 设置环境变量
$env:ANDROID_HOME = "C:\android-sdk"
$env:PATH += ";C:\android-sdk\cmdline-tools\latest\bin;C:\android-sdk\platform-tools"
```

### 2. 安装必要组件
```bash
# 接受许可证
sdkmanager --licenses

# 安装必要组件
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

### 3. 构建APK
```bash
flutter build apk --release
```