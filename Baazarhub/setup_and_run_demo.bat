@echo off
setlocal
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter is not available in PATH. Open this folder in Android Studio after configuring Flutter SDK.
  pause
  exit /b 1
)
flutter create --project-name bazaarhub --platforms=android .
if errorlevel 1 goto :failed
flutter pub get
if errorlevel 1 goto :failed
flutter run
exit /b 0
:failed
echo Setup failed. Read the error shown above.
pause
exit /b 1
