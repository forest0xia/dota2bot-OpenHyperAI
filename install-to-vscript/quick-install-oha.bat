@echo off
chcp 65001 >nul
:: Check if the script is run as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
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

:: Check if the folder already exists
if exist "%~dp0game\dota\scripts\vscripts\bots" (
    echo Folder already exists, renaming to bots_old_%timestamp%...
    ren "%~dp0game\dota\scripts\vscripts\bots" "bots_old_%timestamp%"
)

echo Creating symbolic link...
mklink /d "%~dp0game\dota\scripts\vscripts\bots" "%~dp0..\..\workshop\content\570\3246316298"
if %errorlevel% equ 0 (
    echo ============
    echo Succeeded!!!
    echo ============
) else (
    echo ============
    echo Failed!!!
    echo ============
)
pause
