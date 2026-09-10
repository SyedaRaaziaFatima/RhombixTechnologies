<img width="720" height="1600" alt="WhatsApp Image 2026-09-10 at 2 32 47 PM" src="https://github.com/user-attachments/assets/937859a1-8d1c-4b3c-b799-e05c1fe68ae7" />
<img width="720" height="1600" alt="WhatsApp Image 2026-09-10 at 2 32 47 PM (1)" src="https://github.com/user-attachments/assets/cc562ead-2ce7-4db9-9022-a1e5fe9a997d" />
<img width="720" height="1600" alt="WhatsApp Image 2026-09-10 at 2 32 47 PM (2)" src="https://github.com/user-attachments/assets/23ba398f-7fc1-4ea9-a4cb-b46483c92046" />
<img width="720" height="1600" alt="WhatsApp Image 2026-09-10 at 2 32 48 PM" src="https://github.com/user-attachments/assets/196e34a5-5111-468e-a00b-d2448a58276e" />
<img width="720" height="1600" alt="WhatsApp Image 2026-09-10 at 2 32 48 PM (1)" src="https://github.com/user-attachments/assets/058a1b85-7480-4e28-b048-a7e87703df99" />
<img width="1080" height="2400" alt="WhatsApp Image 2026-09-10 at 2 32 49 PM" src="https://github.com/user-attachments/assets/8172699c-3663-4006-a14f-fc3a05021628" />

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
