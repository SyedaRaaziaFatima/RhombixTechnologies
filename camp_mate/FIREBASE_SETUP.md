# CampMate Firebase setup (Android)

The app runs immediately in local demo mode. Complete these steps to enable login and cloud sync.

## 1. Create the Android wrapper

Open the `campmate` folder in PowerShell and run:

```powershell
flutter create . --platforms=android --org com.campmate
flutter pub get
```

The Android package name will be `com.campmate.campmate`.

## 2. Create Firebase project

1. Open <https://console.firebase.google.com>.
2. Select **Create a project** and name it `CampMate`.
3. Analytics is optional and can be disabled.
4. Inside the project, select **Add app > Android**.
5. Enter package name: `com.campmate.campmate`.
6. Download `google-services.json`.
7. Put it here: `campmate/android/app/google-services.json`.

## 3. Connect FlutterFire

Run these commands in PowerShell:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID --platforms=android
flutter pub get
```

Select the Android app with package `com.campmate.campmate` when asked.

## 4. Enable login

In Firebase Console:

1. Open **Build > Authentication**.
2. Select **Get started**.
3. Open **Sign-in method**.
4. Enable **Email/Password** and save.

## 5. Create Firestore

1. Open **Build > Firestore Database**.
2. Select **Create database**.
3. Choose **Production mode**.
4. Choose the closest available region.
5. Open the **Rules** tab.
6. Replace the rules with the contents of `firestore.rules`, then publish.

No collections need to be created manually. `users` and each user's `trips` collection are created after the first signup/trip.

## 6. Run

```powershell
flutter run
```

If the app opens directly in demo mode after Firebase setup, verify that:

- `android/app/google-services.json` exists.
- `flutterfire configure` completed successfully.
- You fully stopped and restarted the app (hot reload is not enough).

## Build an APK

```powershell
flutter build apk --release
```

APK location:

`build/app/outputs/flutter-apk/app-release.apk`
