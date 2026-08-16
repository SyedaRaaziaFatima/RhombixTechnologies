import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_config.dart';
import 'core/glitter_background.dart';
import 'core/app_theme.dart';
import 'data/app_controller.dart';
import 'data/marketplace_repository.dart';
import 'features/app_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MarketplaceRepository repository;
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    repository = SupabaseMarketplaceRepository(Supabase.instance.client);
  } else {
    repository = DemoMarketplaceRepository();
  }

  final controller = AppController(repository);
  await controller.initialize();
  runApp(BazaarHubApp(controller: controller));
}

class BazaarHubApp extends StatelessWidget {
  const BazaarHubApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => AppScope(
        controller: controller,
        child: MaterialApp(
          title: 'BazaarHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.glitter,
          darkTheme: AppTheme.dark,
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => GlitterBackground(
            darkMode: controller.darkMode,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const AuthGate(),
        ),
      ),
    );
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
