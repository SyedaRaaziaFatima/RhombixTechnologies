# BazaarHub glitter update — sirf aap ke steps

1. Updated ZIP extract karein.
2. Apne Android Studio project mein ZIP ke `lib`, `assets`, `supabase` folders
   aur `pubspec.yaml` replace karein. `android` folder replace **na** karein.
3. Supabase Dashboard > SQL Editor mein
   `supabase/upgrade_glitter_features.sql` ka complete code paste karke **Run**
   karein. `schema.sql` dobara run na karein.
4. Android Studio Terminal mein ye commands run karein:

```powershell
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter run
```

Bas. New blue/silver glitter theme, dark mode, profile photo, search + price
filter, ratings/reviews aur mobile launcher icon active ho jayenge.

Note: Demo mode mein features local testing ke liye chalte hain. Supabase mode
mein profile images aur reviews online save hote hain.
