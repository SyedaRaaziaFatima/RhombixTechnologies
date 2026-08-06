<img width="600" height="1200" alt="WhatsApp Image 2026-08-06 at 9 28 33 AM (1)" src="https://github.com/user-attachments/assets/852d397d-5d48-4901-89cd-92c0630fb7de" /><img width="500" height="1200" alt="WhatsApp Image 2026-08-06 at 9 28 33 AM" src="https://github.com/user-attachments/assets/99d03c88-1f04-4530-98fa-2dcd21ccd85c" />
<img width="720" height="1200" alt="WhatsApp Image 2026-08-06 at 9 28 33 AM (2)" src="https://github.com/user-attachments/assets/61c6924c-9c1d-4911-8dc8-5869376150fa" />
<img width="720" height="1200" alt="WhatsApp Image 2026-08-06 at 9 28 33 AM (3)" src="https://github.com/user-attachments/assets/2de9c7bc-16eb-4da4-8833-1337802d7407" />
<img width="1080" height="1200" alt="WhatsApp Image 2026-08-06 at 9 28 33 AM (4)" src="https://github.com/user-attachments/assets/36151e34-e171-4f58-ab85-53f3cfecbc1e" />
<img width="1080" height="1200" alt="WhatsApp Image 2026-08-06 at 9 28 33 AM (5)" src="https://github.com/user-attachments/assets/0c30132a-5400-4cfe-aa22-7180a26ccd56" />




# College Alert — Firebase-only version

A beginner-friendly Android application built with Flutter and Firebase. No
Supabase account, URL, key, database, or SQL is used.

## Included features

- Student email registration and login with Firebase Authentication
- Student/admin roles stored in Cloud Firestore
- Realtime college announcements
- Search and category filters
- Department and semester targeting
- Important alerts and saved alerts
- Admin create, edit, and delete controls
- Secure Firestore rules
- Free Firebase Cloud Messaging registration
- Blue-and-white Material 3 interface

## What remains for the owner to do

Firebase configuration belongs to the owner's Google account and cannot safely
be pre-filled by anyone else. Complete the one-time steps below.

## 1. Create the free Firebase project

1. Open the Firebase Console and click **Create a project**.
2. Project name: `college-alert`.
3. Google Analytics is optional and can be turned off.
4. Open **Build > Authentication > Get started**.
5. Enable the **Email/Password** provider.
6. Open **Build > Firestore Database > Create database**.
7. Choose **Production mode** and select a nearby region.

Do not enable phone/SMS login because it is unnecessary for this app.

## 2. Prepare the Flutter project on Windows

Extract the ZIP and open PowerShell inside the `college_alert` folder.

Install Node.js first if it is not already installed, then run:

```powershell
npm install -g firebase-tools
Set-ExecutionPolicy -Scope Process Bypass
.\tool\setup_project.ps1
```

The script opens browser login and asks you to choose the Firebase project. It
generates standard Android files and the account-specific Firebase config.

## 3. Publish the supplied security rules

After configuration, run:

```powershell
firebase deploy --only firestore:rules
```

This uploads `firestore.rules`. Do not leave Firestore in test mode.
If the CLI says there is no active project, run `firebase use --add`, select the
College Alert project, and then repeat the deploy command.

## 4. Create the admin account

1. Run the app with `flutter run`.
2. Register the account you want to use as admin.
3. In Firebase Console open **Firestore Database > profiles**.
4. Open that user's document and change `role` from `student` to `admin`.
5. Sign out and sign in again. The **Add alert** button appears.

Normal student accounts should keep `role: student`.

## 5. Send a free push notification

Every signed-in installation subscribes to the `all_students` FCM topic.

1. Open Firebase Console > **Messaging**.
2. Create a notification campaign.
3. Enter the alert title and message.
4. Select the Android app/topic as the target and send it.

Firebase displays notification messages while the Android app is in the
background. When the app is open, the Firestore alerts feed updates in realtime.

Automatic notification immediately after an admin saves an alert would require
a trusted server/Cloud Function. Deploying Cloud Functions requires enabling the
Blaze billing plan, so this strict zero-budget version uses the free Firebase
Notifications composer.

## 6. Build the APK

```powershell
flutter build apk --release
```

APK location:

```text
build\app\outputs\flutter-apk\app-release.apk
```

The APK can be shared directly without buying a Play Store account.
