@echo off
setlocal
set /p BAZAAR_SUPABASE_URL=Paste Supabase Project URL: 
set /p BAZAAR_SUPABASE_KEY=Paste public anon/publishable key: 
if "%BAZAAR_SUPABASE_URL%"=="" goto :missing
if "%BAZAAR_SUPABASE_KEY%"=="" goto :missing
flutter pub get
flutter run --dart-define=SUPABASE_URL=%BAZAAR_SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%BAZAAR_SUPABASE_KEY%
exit /b %errorlevel%
:missing
echo Both values are required. Never paste the service-role key here.
pause
exit /b 1
