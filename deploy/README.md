# 📱 在线APK构建和部署指南

## 🚀 快速部署步骤

### 1. 上传到GitHub

```bash
# 初始化Git仓库（如果还没有）
git init

# 添加所有文件
git add .

# 提交代码
git commit -m "职场边界守卫 - 完整版本"

# 添加远程仓库（替换为你的GitHub仓库地址）
git remote add origin https://github.com/yourusername/workplace-guardian.git

# 推送到GitHub
git push -u origin main
```

### 2. 启用GitHub Actions

1. 在GitHub仓库页面，点击 "Actions" 选项卡
2. GitHub会自动检测到 `.github/workflows/build-apk.yml` 文件
3. 点击 "I understand my workflows, go ahead and enable them"
4. 推送代码后，Actions会自动开始构建

### 3. 下载APK

构建完成后，你可以通过以下方式获取APK：

#### 方式A：从Actions下载
1. 进入GitHub仓库的 "Actions" 页面
2. 点击最新的构建任务
3. 在 "Artifacts" 部分下载 `workplace-guardian-apk`

#### 方式B：从Releases下载
1. 进入GitHub仓库的 "Releases" 页面
2. 下载最新版本的APK文件
3. 选择适合你手机的版本：
   - `app-arm64-v8a-release.apk` - 现代手机（推荐）
   - `app-armeabi-v7a-release.apk` - 较老手机
   - `app-x86_64-release.apk` - x86架构手机

## 📱 手机安装步骤

### 1. 准备手机
```
设置 → 安全 → 未知来源（开启）
或
设置 → 应用 → 特殊访问权限 → 安装未知应用
```

### 2. 下载APK
- 用手机浏览器访问GitHub Releases页面
- 下载对应的APK文件
- 或者扫描二维码下载

### 3. 安装应用
- 点击下载的APK文件
- 选择"安装"
- 等待安装完成

### 4. 授予权限
首次启动时需要授予以下权限：
- 通知权限
- 存储权限
- 应用使用统计权限（需要在设置中手动开启）

## 🌐 在线构建服务对比

| 服务 | 免费额度 | 构建时间 | 优点 | 缺点 |
|------|----------|----------|------|------|
| GitHub Actions | 2000分钟/月 | 5-10分钟 | 集成度高，自动化 | 需要GitHub账号 |
| Codemagic | 500分钟/月 | 3-8分钟 | 专业CI/CD | 配置复杂 |
| AppCenter | 240分钟/月 | 5-15分钟 | 微软支持 | 额度较少 |

## 🔧 自定义构建配置

### 修改应用信息
编辑 `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.workplace_guardian"
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 添加应用图标
1. 准备1024x1024的PNG图标
2. 使用在线工具生成Android图标包
3. 替换 `android/app/src/main/res/` 下的图标文件

### 修改应用名称
编辑 `android/app/src/main/res/values/strings.xml`:
```xml
<resources>
    <string name="app_name">职场边界守卫</string>
</resources>
```

## 📊 构建状态监控

### GitHub Actions状态徽章
在README中添加：
```markdown
![Build Status](https://github.com/yourusername/workplace-guardian/workflows/Build%20Android%20APK/badge.svg)
```

### 自动通知
构建完成后会自动发送邮件通知（如果配置了）

## 🔒 安全注意事项

### 代码签名
- 当前使用调试签名，适用于测试
- 正式发布需要生成发布签名
- 不要将签名文件提交到公开仓库

### 权限说明
应用请求的权限：
- `INTERNET` - 网络访问（用于数据同步）
- `WRITE_EXTERNAL_STORAGE` - 存储权限（保存数据）
- `PACKAGE_USAGE_STATS` - 应用使用统计
- `BIND_NOTIFICATION_LISTENER_SERVICE` - 通知监听

## 📞 技术支持

如果构建过程中遇到问题：

1. **检查构建日志**
   - 在GitHub Actions页面查看详细日志
   - 查找错误信息和解决方案

2. **常见问题**
   - 依赖下载失败：网络问题，重新触发构建
   - 编译错误：检查代码语法
   - 权限问题：检查仓库设置

3. **获取帮助**
   - 查看Flutter官方文档
   - 搜索相关错误信息
   - 在GitHub Issues中提问

---

**提示**：首次构建可能需要10-15分钟，后续构建会更快（约5分钟）。