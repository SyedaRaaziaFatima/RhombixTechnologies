@echo off
setlocal
cd /d "%~dp0"

if not exist pubspec.yaml (
  echo ERROR: Extract these files inside the CampMate project root.
  echo pubspec.yaml was not found in this folder.
  pause
  exit /b 1
)

where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter was not found in PATH.
  pause
  exit /b 1
)

echo Adding the launcher icon tool...
call flutter pub add --dev flutter_launcher_icons
if errorlevel 1 goto :failed

echo Generating CampMate Android icons...
call dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
if errorlevel 1 goto :failed

call flutter clean

echo.
echo SUCCESS: CampMate launcher icon has been generated.
echo Uninstall the old app from your phone, then run: flutter run
pause
exit /b 0

:failed
echo Icon setup failed. Send the complete error screenshot to ChatGPT.
pause
exit /b 1
