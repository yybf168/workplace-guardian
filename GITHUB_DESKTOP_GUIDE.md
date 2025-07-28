# 📱 GitHub Desktop 小白操作指南

## 🚀 第1步：下载并安装

### 1. 下载GitHub Desktop
- 打开浏览器，访问：https://desktop.github.com/
- 点击紫色的"Download for Windows"按钮
- 等待下载完成（约100MB）

### 2. 安装GitHub Desktop
- 双击下载的 `GitHubDesktopSetup.exe` 文件
- 安装程序会自动运行，无需选择任何选项
- 等待安装完成（约2-3分钟）
- 安装完成后会自动打开GitHub Desktop

## 🔑 第2步：登录GitHub账号

### 1. 首次启动设置
- GitHub Desktop打开后，点击"Sign in to GitHub.com"
- 会打开浏览器登录页面
- 输入你的GitHub用户名和密码
- 登录成功后，浏览器会显示"Success!"
- 回到GitHub Desktop，应该已经显示你的用户名

### 2. 配置Git信息
- 在GitHub Desktop中，点击左上角的"File" → "Options"
- 在"Git"选项卡中：
  - Name: 输入你的姓名（可以是中文）
  - Email: 输入你注册GitHub时使用的邮箱
- 点击"Save"

## 📁 第3步：克隆你的仓库

### 1. 克隆仓库到本地
- 在GitHub Desktop主界面，点击"Clone a repository from the Internet..."
- 在"GitHub.com"选项卡中，找到你的 `workplace-guardian` 仓库
- 如果没有看到，点击右上角的刷新按钮
- 选择你的仓库后，设置本地路径：
  - **重要**：将路径改为 `E:\workplace-guardian-github`
  - 这样不会和你现有的项目文件夹冲突
- 点击"Clone"按钮
- 等待克隆完成

### 2. 验证克隆成功
- 克隆完成后，你会看到一个空的仓库界面
- 同时在 `E:\workplace-guardian-github` 文件夹中会有一个空的项目文件夹

## 📂 第4步：复制项目文件

### 1. 打开文件管理器
- 按 Win + E 打开文件管理器
- 同时打开两个文件夹窗口：
  - 窗口1：`E:\zcsw`（你的原项目文件）
  - 窗口2：`E:\workplace-guardian-github`（GitHub克隆的空文件夹）

### 2. 复制所有文件
- 在 `E:\zcsw` 文件夹中：
  - 按 Ctrl + A 选择所有文件和文件夹
  - 按 Ctrl + C 复制
- 在 `E:\workplace-guardian-github` 文件夹中：
  - 按 Ctrl + V 粘贴
  - 等待复制完成（可能需要几分钟）

### 3. 验证文件复制
确认 `E:\workplace-guardian-github` 文件夹中包含以下文件：
- ✅ lib/ 文件夹
- ✅ android/ 文件夹
- ✅ pubspec.yaml 文件
- ✅ README.md 文件
- ✅ .github/ 文件夹（这个很重要，包含自动构建配置）

## 📤 第5步：提交并推送代码

### 1. 查看文件变化
- 回到GitHub Desktop
- 你会看到左侧显示很多文件变化（绿色的+号表示新增文件）
- 这些就是你刚才复制的项目文件

### 2. 提交代码
- 在左下角的提交区域：
  - Summary（必填）：输入 `职场边界守卫完整版 v1.0`
  - Description（可选）：输入 `包含所有功能模块的完整版本`
- 点击蓝色的"Commit to main"按钮

### 3. 推送到GitHub
- 提交完成后，你会看到"Push origin"按钮
- 点击"Push origin"按钮
- 等待推送完成（可能需要几分钟，取决于网络速度）

## ✅ 第6步：验证上传成功

### 1. 检查GitHub网站
- 打开浏览器，访问你的GitHub仓库页面
- 刷新页面，你应该能看到所有项目文件
- 特别检查是否有 `.github/workflows/build-apk.yml` 文件

### 2. 查看自动构建
- 在GitHub仓库页面，点击"Actions"选项卡
- 你应该能看到一个正在运行或已完成的构建任务
- 如果显示黄色圆圈，表示正在构建
- 如果显示绿色✅，表示构建成功
- 如果显示红色❌，表示构建失败

## 🎉 成功标志

当你看到以下情况时，说明上传成功：
- ✅ GitHub Desktop显示"No local changes"
- ✅ GitHub网站上能看到所有项目文件
- ✅ Actions页面显示构建任务（可能正在运行）

## 🔧 可能遇到的问题

### 问题1：GitHub Desktop无法登录
**解决方案**：
- 检查网络连接
- 尝试关闭防火墙或VPN
- 使用手机热点网络

### 问题2：克隆失败
**解决方案**：
- 确认仓库名称正确
- 检查网络连接
- 重新尝试克隆

### 问题3：推送失败
**解决方案**：
- 检查网络连接
- 确认GitHub账号有权限
- 尝试重新推送

### 问题4：文件太大无法推送
**解决方案**：
- GitHub有100MB单文件限制
- 检查是否有大文件（如视频、图片等）
- 删除不必要的大文件后重新提交

## 📱 下一步：等待APK构建

上传成功后：
1. **等待构建完成**（约10-15分钟）
2. **检查Actions页面**看构建进度
3. **构建成功后**，在Releases页面下载APK
4. **用手机浏览器**打开下载链接安装

---

**预计时间**：15-20分钟
**难度**：⭐⭐（小白友好）
**成功率**：95%+