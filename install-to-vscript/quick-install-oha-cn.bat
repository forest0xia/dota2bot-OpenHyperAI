@echo off
chcp 65001 >nul
:: 检查是否以管理员权限运行脚本
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 请求管理员权限...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Get the current timestamp (format: YYYYMMDD_HHMMSS)
for /f "tokens=1-4 delims=/:. " %%a in ("%date% %time%") do (
    set year=%%a
    set month=%%b
    set day=%%c
    set hour=%%d
)
set timestamp=%year%%month%%day%_%time:~0,2%%time:~3,2%%time:~6,2%

:: Remove spaces in the hour if present (in case of 24-hour format)
set timestamp=%timestamp: =0%

:: 检查文件夹是否已经存在
if exist "%~dp0game\dota\scripts\vscripts\bots" (
    echo 文件夹已存在，将其重命名为 bots_old_%timestamp%...
    ren "%~dp0game\dota\scripts\vscripts\bots" "bots_old_%timestamp%"
)

echo 正在创建符号链接...
mklink /d "%~dp0game\dota\scripts\vscripts\bots" "%~dp0..\..\workshop\content\570\3246316298"
if %errorlevel% equ 0 (
    echo ==========
    echo 创建成功!!!
    echo ==========
) else (
    echo ==========
    echo 创建失败!!!
    echo 请确保：
    echo 1. 此文件放在正确的文件夹下："Steam\steamapps\common\dota 2 beta"
    echo 2. 使用管理员模式打开这个文件
    echo ==========
)
pause
