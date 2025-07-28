@echo off
echo ========================================
echo 职场边界守卫 - 一键部署到GitHub
echo ========================================
echo.

REM 检查Git是否安装
git --version >nul 2>&1
if errorlevel 1 (
    echo 错误：未检测到Git，请先安装Git
    echo 下载地址：https://git-scm.com/download/win
    pause
    exit /b 1
)

echo 1. 初始化Git仓库...
git init

echo 2. 添加所有文件...
git add .

echo 3. 提交代码...
git commit -m "职场边界守卫 - 完整版本 v1.0"

echo.
echo ========================================
echo 接下来需要手动操作：
echo ========================================
echo 1. 在GitHub上创建新仓库：
echo    - 访问：https://github.com/new
echo    - 仓库名：workplace-guardian
echo    - 设为公开（Public）
echo    - 不要初始化README
echo.
echo 2. 复制仓库地址，然后运行：
echo    git remote add origin https://github.com/你的用户名/workplace-guardian.git
echo    git push -u origin main
echo.
echo 3. 推送完成后，GitHub Actions会自动构建APK
echo    - 进入仓库的Actions页面查看构建进度
echo    - 构建完成后在Releases页面下载APK
echo.
echo ========================================
pause