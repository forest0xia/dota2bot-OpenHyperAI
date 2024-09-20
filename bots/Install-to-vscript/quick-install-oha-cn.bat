@echo off
chcp 65001 >nul
:: 检查是否以管理员权限运行脚本
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 获取当前时间戳（格式: YYYYMMDD_HHMMSS）
for /f "tokens=1-4 delims=/:. " %%a in ("%date% %time%") do (
    set year=%%a
    set month=%%b
    set day=%%c
    set hour=%%d
)
set timestamp=%year%%month%%day%_%time:~0,2%%time:~3,2%%time:~6,2%

:: 如果小时数中有空格，将其移除（适用于24小时制）
set timestamp=%timestamp: =0%

:: 检查文件夹是否已存在
if exist "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\bots" (
    echo 文件夹已存在，正在重命名为 bots_old_%timestamp%...
    ren "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\bots" "bots_old_%timestamp%"
)

echo 正在创建机器人脚本链接...
mklink /d "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\bots" "%~dp0.."
if %errorlevel% equ 0 (
    echo ============
    echo ============
    echo 成功创建!!!
    echo ============
    echo ============
) else (
    echo ============
    echo "1. 请在正确的文件夹 (Steam\steamapps\workshop\content\570\3246316298\Install-to-vscript) 内运行此文件"
    echo "2. 如果你不知道这个Steam文件夹的位置，请在Steam库中右键点击Dota2，选择属性 > 已安装文件 > 浏览。" 这时会打开文件夹: "Steam\steamapps\common\dota 2 beta"，将地址中的 "common\dota 2 beta" 部分替换成 "workshop\content\570\3246316298\Install-to-vscript"，按下回车键即可打开正确的文件夹。 
    echo "3. 请确保以管理员身份运行该文件"
    echo ============
    echo 创建失败!!!
    echo ============
)
pause
