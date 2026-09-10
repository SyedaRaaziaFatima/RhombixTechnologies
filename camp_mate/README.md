# CampMate

A clean Flutter + Firebase camping planner for Android.

## Included in version 1

- Email/password signup, sign-in, password reset, and sign-out
- Firebase Firestore per-user trip storage
- Firestore offline cache on Android
- Local demo mode when Firebase is not configured
- Create, list, open, and delete camping trips
- Auto-generated categorized packing checklist
- Add custom packing items and track progress
- Practical camping safety guide
- Persistent light/dark theme
- Responsive Material 3 interface
- Secure Firestore rules

## Quick start

On Windows, double-click `setup_windows.bat`, or run:

```powershell
flutter create . --platforms=android --org com.campmate
flutter pub get
flutter run
```

Without Firebase configuration, CampMate opens in demo mode so the complete UI can be tested. Follow `FIREBASE_SETUP.md` to enable accounts and cloud sync.

## Project structure

```text
lib/
  core/          Theme and design tokens
  models/        Trip and packing data models
  repositories/ Firestore and demo repositories
  screens/       Authentication, dashboard, trips, checklist, safety, profile
  services/      Firebase authentication service
  main.dart      Firebase bootstrap, theme persistence, app entry point
```
