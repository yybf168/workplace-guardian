# 🚀 GitHub Actions 快速开始指南

## 📋 准备工作检查

在开始之前，请确认：
- [ ] 你有稳定的网络连接
- [ ] 项目文件在 E:\zcsw 目录
- [ ] 电脑已安装Git（如果没有，从 https://git-scm.com 下载）

## 🎯 3步完成APK构建

### 第1步：创建GitHub仓库（5分钟）

1. **访问GitHub**
   - 打开浏览器，访问：https://github.com
   - 如果没有账号，点击"Sign up"注册（免费）

2. **创建新仓库**
   - 登录后，点击右上角的"+"号
   - 选择"New repository"
   - 仓库名输入：`workplace-guardian`
   - 描述输入：`职场边界守卫 - 工作生活平衡管理应用`
   - 选择"Public"（公开，这样才能使用免费的Actions）
   - **不要**勾选"Add a README file"
   - 点击"Create repository"

3. **复制仓库地址**
   - 创建完成后，复制显示的仓库地址
   - 格式类似：`https://github.com/你的用户名/workplace-guardian.git`

### 第2步：上传代码（5分钟）

1. **打开PowerShell**
   - 按Win+R，输入`powershell`，回车
   - 或者在项目文件夹按住Shift+右键，选择"在此处打开PowerShell窗口"

2. **进入项目目录**
   ```powershell
   cd E:\zcsw
   ```

3. **初始化Git并上传**
   ```powershell
   # 初始化Git仓库
   git init
   
   # 添加所有文件
   git add .
   
   # 提交代码
   git commit -m "职场边界守卫完整版 v1.0"
   
   # 添加远程仓库（替换为你的实际地址）
   git remote add origin https://github.com/你的用户名/workplace-guardian.git
   
   # 推送到GitHub
   git push -u origin main
   ```

   **注意**：如果是第一次使用Git，可能需要设置用户信息：
   ```powershell
   git config --global user.name "你的姓名"
   git config --global user.email "你的邮箱"
   ```

### 第3步：等待构建并下载（10分钟）

1. **查看构建进度**
   - 代码推送成功后，访问你的GitHub仓库页面
   - 点击"Actions"选项卡
   - 你会看到一个正在运行的构建任务
   - 等待构建完成（约10分钟，显示绿色✅表示成功）

2. **下载APK**
   - 构建完成后，点击"Releases"选项卡
   - 你会看到自动创建的发布版本
   - 下载以下文件之一：
     - `app-arm64-v8a-release.apk` - **推荐**，适用于大多数现代手机
     - `app-armeabi-v7a-release.apk` - 适用于较老的手机
     - `app-x86_64-release.apk` - 适用于x86架构手机

3. **获取下载链接**
   - 右键点击APK文件，选择"复制链接地址"
   - 这个链接可以直接用手机浏览器打开下载

## 📱 手机安装步骤

### 1. 准备手机
```
Android手机：
设置 → 安全 → 未知来源（开启）
或
设置 → 应用 → 特殊访问权限 → 安装未知应用 → 浏览器（允许）
```

### 2. 下载安装
1. 用手机浏览器打开APK下载链接
2. 下载完成后点击APK文件
3. 选择"安装"
4. 等待安装完成

### 3. 首次启动
1. 打开"职场边界守卫"应用
2. 授予通知权限
3. 授予存储权限
4. 点击"生成数据"按钮体验功能

## 🔧 可能遇到的问题

### 问题1：Git命令不识别
**解决方案**：
```powershell
# 下载并安装Git
# 访问：https://git-scm.com/download/win
# 安装后重新打开PowerShell
```

### 问题2：推送失败，要求登录
**解决方案**：
```powershell
# GitHub现在需要使用Personal Access Token
# 1. 访问：https://github.com/settings/tokens
# 2. 点击"Generate new token (classic)"
# 3. 勾选"repo"权限
# 4. 复制生成的token
# 5. 推送时用token替代密码
```

### 问题3：构建失败
**解决方案**：
1. 检查Actions页面的错误日志
2. 常见问题是依赖下载失败，等待几分钟后重新触发构建
3. 在Actions页面点击"Re-run jobs"

### 问题4：手机无法安装APK
**解决方案**：
1. 确认已开启"未知来源"安装
2. 检查手机存储空间是否充足
3. 尝试重新下载APK文件

## 🎉 成功标志

当你看到以下情况时，说明成功了：
- ✅ GitHub仓库中有你的代码
- ✅ Actions页面显示构建成功（绿色✅）
- ✅ Releases页面有APK文件可下载
- ✅ 手机能正常安装和运行应用

## 📞 需要帮助？

如果遇到问题：
1. 仔细检查每一步是否正确执行
2. 查看GitHub Actions的构建日志
3. 确认网络连接正常
4. 检查Git和GitHub账号设置

---

**预计总时间**：20分钟（不包括等待构建的10分钟）
**成功率**：95%+
**费用**：完全免费