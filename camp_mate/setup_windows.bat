@echo off
setlocal
cd /d "%~dp0"

where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter was not found. Add Flutter\bin to PATH, then run this file again.
  pause
  exit /b 1
)

if not exist android (
  echo Creating Android platform files...
  call flutter create . --platforms=android --org com.campmate
  if errorlevel 1 goto :failed
)

echo Downloading packages...
call flutter pub get
if errorlevel 1 goto :failed

echo.
echo CampMate setup complete.
echo Run in demo mode: flutter run
echo For Firebase, follow FIREBASE_SETUP.md first.
pause
exit /b 0

:failed
echo Setup failed. Copy the error shown above and send it to ChatGPT.
pause
exit /b 1
