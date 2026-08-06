$ErrorActionPreference = 'Stop'

Write-Host 'Generating Android project files...'
flutter create --platforms=android --org com.example .

# flutter create may add its standard counter-app test when the platform folder
# is generated. It does not apply to this project.
Remove-Item 'test\widget_test.dart' -ErrorAction SilentlyContinue

flutter pub get

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host 'Firebase CLI was not found.'
    Write-Host 'Install Node.js, then run: npm install -g firebase-tools'
    exit 1
}

firebase login
dart pub global activate flutterfire_cli
flutterfire configure --platforms=android

Write-Host 'Setup complete. Next command: flutter run'
