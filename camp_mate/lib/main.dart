import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_theme.dart';
import 'repositories/trip_repository.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    firebaseReady = true;
  } catch (_) {
    // The app intentionally remains usable in local demo mode until Firebase is configured.
  }
  runApp(CampMateApp(firebaseReady: firebaseReady));
}

class CampMateApp extends StatefulWidget {
  const CampMateApp({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  State<CampMateApp> createState() => _CampMateAppState();
}

class _CampMateAppState extends State<CampMateApp> {
  final _preferences = SharedPreferencesAsync();
  late final TripRepository _demoRepository = DemoTripRepository();
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final stored = await _preferences.getBool('dark_mode');
    if (mounted && stored != null) setState(() => _darkMode = stored);
  }

  Future<void> _setTheme(bool value) async {
    setState(() => _darkMode = value);
    await _preferences.setBool('dark_mode', value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CampMate',
        debugShowCheckedModeBanner: false,
        theme: campTheme(Brightness.light),
        darkTheme: campTheme(Brightness.dark),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: widget.firebaseReady
            ? _FirebaseGate(isDark: _darkMode, onThemeChanged: _setTheme)
            : MainShell(
                repository: _demoRepository,
                isDemo: true,
                isDark: _darkMode,
                onThemeChanged: _setTheme,
              ),
      );
}

class _FirebaseGate extends StatefulWidget {
  const _FirebaseGate({required this.isDark, required this.onThemeChanged});
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<_FirebaseGate> createState() => _FirebaseGateState();
}

class _FirebaseGateState extends State<_FirebaseGate> {
  late final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
        stream: _auth.userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snapshot.data;
          if (user == null) return AuthScreen(auth: _auth);
          return MainShell(
            repository: FirestoreTripRepository(userId: user.uid),
            isDemo: false,
            isDark: widget.isDark,
            onThemeChanged: widget.onThemeChanged,
            auth: _auth,
          );
        },
      );
}
