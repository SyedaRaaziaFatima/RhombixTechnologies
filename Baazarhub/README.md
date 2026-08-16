<img width="600" height="1200" alt="WhatsApp Image 2026-08-16 at 6 58 48 PM" src="https://github.com/user-attachments/assets/272b54ee-b267-4c73-91ee-c655efdf8222" />
<img width="600" height="1200" alt="WhatsApp Image 2026-08-16 at 6 58 49 PM" src="https://github.com/user-attachments/assets/9906d0a7-d348-4ca3-afac-e81ef48fb071" />
<img width="600" height="1200" alt="WhatsApp Image 2026-08-16 at 6 58 49 PM (1)" src="https://github.com/user-attachments/assets/ce0cbc7c-d7a5-4416-9461-285aad3a3d58" />
<img width="600" height="1200" alt="WhatsApp Image 2026-08-16 at 6 58 49 PM (2)" src="https://github.com/user-attachments/assets/6a38f6bd-59fe-473e-becf-b6176dcd4a5e" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 50 PM" src="https://github.com/user-attachments/assets/145fd94f-d2d9-45dc-b0f4-7ffa49698f2a" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 51 PM (1)" src="https://github.com/user-attachments/assets/544a0185-9b84-48fe-b72d-9398cd4e3a90" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 51 PM" src="https://github.com/user-attachments/assets/1efd7549-1d6b-4820-a119-243108fd6429" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 52 PM" src="https://github.com/user-attachments/assets/4a08ec3d-d400-4cc0-bac7-f06fae99251a" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 52 PM (1)" src="https://github.com/user-attachments/assets/eb996103-4819-4d76-94fc-d0039a112a7c" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 52 PM (2)" src="https://github.com/user-attachments/assets/dbcf4387-75e3-40f5-ade8-07a5a6372675" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 53 PM" src="https://github.com/user-attachments/assets/854e5274-7c7d-472c-b822-27b25208d334" />
<img width="720" height="1600" alt="WhatsApp Image 2026-08-16 at 6 58 53 PM (1)" src="https://github.com/user-attachments/assets/0f771431-272f-47e3-8a19-b72df9ebb6d4" />
**# BazaarHub

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
