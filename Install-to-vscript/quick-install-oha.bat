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
if exist "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\bots" (
    echo bots folder already exists, renaming to bots_old_%timestamp%...
    ren "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\bots" "bots_old_%timestamp%"
)

echo Creating symbolic link...
mklink /d "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\bots" "%~dp0.."

if exist "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize" (
    echo Customize folder already exists, renaming to bots_old_%timestamp%...
    ren "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize" "Customize_old_%timestamp%"
)
echo Creating Customize script...
xcopy  "%~dp0..\Customize\" "%~dp0..\..\..\..\..\common\dota 2 beta\game\dota\scripts\vscripts\game\Customize\" /E

if %errorlevel% equ 0 (
    echo ============
    echo ============
    echo Install Succeeded!!!
    echo ============
    echo ============
) else (
    echo ============
    echo "1. Make sure to execute this file in this folder:'Steam\steamapps\workshop\content\570\3246316298\Install-to-vscript'. 
    echo "2. If you don't know where the Steam folder is, right click Dota2 in Steam Library, select Properties > Installed Files > Browse." It will open the folder: "Steam\steamapps\common\dota 2 beta", now replace the path text "common\dota 2 beta" in the address to be "workshop\content\570\3246316298\Install-to-vscript", hit Enter to open the correct folder. 
    echo "3. Run this file as Administrator"
    echo ============
    echo Install failed!!!
    echo ============
)
pause
