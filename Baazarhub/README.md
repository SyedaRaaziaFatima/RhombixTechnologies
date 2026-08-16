# BazaarHub

BazaarHub is a mobile-only Flutter marketplace where registered users can buy
and sell products. It includes a black and shimmery-gold interface, authentication,
product listings with images, search/categories, favourites, cart, secure order
creation, COD and a sandbox card-payment demonstration.

## What works

- Demo mode runs without any backend credentials.
- Real email/password authentication through Supabase.
- Product creation, image upload and seller-owned listing management.
- Cart quantity/stock validation and server-calculated order totals.
- Buyer orders, seller ownership and storage security through RLS policies.
- Cash on Delivery and a clearly labelled no-money demo card flow.

## First run (demo mode)

Open PowerShell in this folder and run:

```powershell
flutter create --project-name bazaarhub --platforms=android .
flutter pub get
flutter run
```

Use the pre-filled demo login. Any password of 6 or more characters works.

## Connect the free Supabase backend

1. Create a free project at https://supabase.com/dashboard.
2. Open **SQL Editor**, paste all of `supabase/schema.sql`, then click **Run**.
3. Go to **Project Settings > Data API** and copy the Project URL and public
   anon/publishable key. Never use the service-role key in the app.
4. Run the app with:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

For an APK:

```powershell
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

The APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

## Payment note

The demo card option intentionally moves no real money. A real marketplace must
confirm a payment through a trusted server/webhook and use a supported payment
provider account. Secret keys must never be added to Flutter source code.
