# 🔧 Git安装指南（小白版）

## 📥 下载和安装Git

### 1. 下载Git
- 打开浏览器，访问：https://git-scm.com/download/win
- 页面会自动开始下载，文件名类似：`Git-2.42.0-64-bit.exe`
- 如果没有自动下载，点击"64-bit Git for Windows Setup"

### 2. 安装Git
1. **运行下载的安装程序**
   - 双击下载的 `.exe` 文件
   - 如果弹出安全提示，点击"是"或"运行"

2. **安装选项（重要！）**
   - **许可协议**：点击"Next"
   - **安装路径**：保持默认，点击"Next"
   - **组件选择**：保持默认勾选，点击"Next"
   - **开始菜单文件夹**：保持默认，点击"Next"
   - **默认编辑器**：选择"Use Notepad as Git's default editor"，点击"Next"
   - **初始分支名**：选择"Let Git decide"，点击"Next"
   - **PATH环境**：选择"Git from the command line and also from 3rd-party software"，点击"Next"
   - **SSH可执行文件**：选择"Use bundled OpenSSH"，点击"Next"
   - **HTTPS传输后端**：选择"Use the OpenSSL library"，点击"Next"
   - **行尾转换**：选择"Checkout Windows-style, commit Unix-style line endings"，点击"Next"
   - **终端模拟器**：选择"Use MinTTY"，点击"Next"
   - **git pull行为**：选择"Default (fast-forward or merge)"，点击"Next"
   - **凭据管理器**：选择"Git Credential Manager"，点击"Next"
   - **额外选项**：保持默认，点击"Next"
   - **实验性功能**：不勾选，点击"Install"

3. **完成安装**
   - 等待安装完成（约2-3分钟）
   - 安装完成后，点击"Finish"

### 3. 验证安装
- 关闭所有PowerShell窗口
- 重新打开PowerShell
- 输入：`git --version`
- 如果显示版本号，说明安装成功

## 🔧 如果安装失败

### 方案A：使用便携版Git
1. 访问：https://git-scm.com/download/win
2. 下载"Portable"版本
3. 解压到 `E:\Git` 文件夹
4. 将 `E:\Git\bin` 添加到系统PATH

### 方案B：使用GitHub Desktop（推荐给小白）
1. 访问：https://desktop.github.com/
2. 下载并安装GitHub Desktop
3. 这个软件包含了Git，并且有图形界面，更适合小白使用