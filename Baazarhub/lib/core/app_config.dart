class AppConfig {
  AppConfig._();

  // Public client credentials for the BazaarHub Supabase project. These are
  // safe to ship in a mobile client; database access is protected by RLS.
  // --dart-define values can still override them for another environment.
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sqyqvbyytioaxcwpycgb.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_51_E6fqqfHgiN1doSej1og_wX4PwIVo',
  );

  static bool get hasSupabase =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;
}
