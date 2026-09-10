# CampMate — sab se pehle yahan se start karein

Main app ka Flutter code, UI, Firebase services, database models, security rules aur demo data bana chuka hoon. Aapko neeche wale account/device steps karne hain.

## Pehli dafa app chalana

1. `campmate` folder ko apne PC par rakhein.
2. Folder ke andar `setup_windows.bat` ko double-click karein.
3. Android Studio ka emulator start karein ya USB debugging wala Android phone connect karein.
4. Folder mein PowerShell open karke run karein:

```powershell
flutter run
```

Firebase abhi connect na bhi ho to app **Demo Mode** mein poori UI ke saath open hogi. Aap trip create, delete aur packing items check kar sakte hain. Demo data temporary hota hai.

## Firebase connect karna

Is folder ki `FIREBASE_SETUP.md` file follow karein. Aapko sirf:

1. Firebase Console par `CampMate` project banana hai.
2. Android app ka package name `com.campmate.campmate` dena hai.
3. `google-services.json` ko `android/app/` mein rakhna hai.
4. Email/Password Authentication enable karni hai.
5. Firestore database create karke `firestore.rules` publish karni hain.

Collections/tables manually banane ki zaroorat nahi. Pehli signup aur trip par app khud data create karegi.

## Agar error aaye

Error ka poora screenshot ya PowerShell ka red text send karein. File apni taraf se randomly change na karein; main exact correction dunga.
