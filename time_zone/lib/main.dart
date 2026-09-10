import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tzdata.initializeTimeZones();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    TimeZoneConverterApp(prefs: prefs),
  );
}

// ============================================================
// ZONE MODEL
// ============================================================

class ZoneOption {
  final String city;
  final String country;
  final String zoneId;
  final String flag;

  const ZoneOption({
    required this.city,
    required this.country,
    required this.zoneId,
    required this.flag,
  });
}

// ============================================================
// WORLD TIME ZONES
// ============================================================

const List<ZoneOption> zones = [
  ZoneOption(
    city: 'Islamabad',
    country: 'Pakistan',
    zoneId: 'Asia/Karachi',
    flag: '🇵🇰',
  ),
  ZoneOption(
    city: 'Karachi',
    country: 'Pakistan',
    zoneId: 'Asia/Karachi',
    flag: '🇵🇰',
  ),
  ZoneOption(
    city: 'Lahore',
    country: 'Pakistan',
    zoneId: 'Asia/Karachi',
    flag: '🇵🇰',
  ),
  ZoneOption(
    city: 'Dubai',
    country: 'UAE',
    zoneId: 'Asia/Dubai',
    flag: '🇦🇪',
  ),
  ZoneOption(
    city: 'Riyadh',
    country: 'Saudi Arabia',
    zoneId: 'Asia/Riyadh',
    flag: '🇸🇦',
  ),
  ZoneOption(
    city: 'London',
    country: 'United Kingdom',
    zoneId: 'Europe/London',
    flag: '🇬🇧',
  ),
  ZoneOption(
    city: 'Paris',
    country: 'France',
    zoneId: 'Europe/Paris',
    flag: '🇫🇷',
  ),
  ZoneOption(
    city: 'Berlin',
    country: 'Germany',
    zoneId: 'Europe/Berlin',
    flag: '🇩🇪',
  ),
  ZoneOption(
    city: 'New York',
    country: 'USA',
    zoneId: 'America/New_York',
    flag: '🇺🇸',
  ),
  ZoneOption(
    city: 'Los Angeles',
    country: 'USA',
    zoneId: 'America/Los_Angeles',
    flag: '🇺🇸',
  ),
  ZoneOption(
    city: 'Chicago',
    country: 'USA',
    zoneId: 'America/Chicago',
    flag: '🇺🇸',
  ),
  ZoneOption(
    city: 'Toronto',
    country: 'Canada',
    zoneId: 'America/Toronto',
    flag: '🇨🇦',
  ),
  ZoneOption(
    city: 'Tokyo',
    country: 'Japan',
    zoneId: 'Asia/Tokyo',
    flag: '🇯🇵',
  ),
  ZoneOption(
    city: 'Seoul',
    country: 'South Korea',
    zoneId: 'Asia/Seoul',
    flag: '🇰🇷',
  ),
  ZoneOption(
    city: 'Singapore',
    country: 'Singapore',
    zoneId: 'Asia/Singapore',
    flag: '🇸🇬',
  ),
  ZoneOption(
    city: 'Hong Kong',
    country: 'Hong Kong',
    zoneId: 'Asia/Hong_Kong',
    flag: '🇭🇰',
  ),
  ZoneOption(
    city: 'Bangkok',
    country: 'Thailand',
    zoneId: 'Asia/Bangkok',
    flag: '🇹🇭',
  ),
  ZoneOption(
    city: 'Delhi',
    country: 'India',
    zoneId: 'Asia/Kolkata',
    flag: '🇮🇳',
  ),
  ZoneOption(
    city: 'Sydney',
    country: 'Australia',
    zoneId: 'Australia/Sydney',
    flag: '🇦🇺',
  ),
  ZoneOption(
    city: 'Melbourne',
    country: 'Australia',
    zoneId: 'Australia/Melbourne',
    flag: '🇦🇺',
  ),
  ZoneOption(
    city: 'Auckland',
    country: 'New Zealand',
    zoneId: 'Pacific/Auckland',
    flag: '🇳🇿',
  ),
  ZoneOption(
    city: 'Cairo',
    country: 'Egypt',
    zoneId: 'Africa/Cairo',
    flag: '🇪🇬',
  ),
  ZoneOption(
    city: 'Johannesburg',
    country: 'South Africa',
    zoneId: 'Africa/Johannesburg',
    flag: '🇿🇦',
  ),
  ZoneOption(
    city: 'Istanbul',
    country: 'Türkiye',
    zoneId: 'Europe/Istanbul',
    flag: '🇹🇷',
  ),
];

// ============================================================
// MAIN APP
// ============================================================

class TimeZoneConverterApp extends StatefulWidget {
  final SharedPreferences prefs;

  const TimeZoneConverterApp({
    super.key,
    required this.prefs,
  });

  @override
  State<TimeZoneConverterApp> createState() =>
      _TimeZoneConverterAppState();
}

class _TimeZoneConverterAppState
    extends State<TimeZoneConverterApp> {
  late bool dark;

  @override
  void initState() {
    super.initState();
    dark = widget.prefs.getBool('dark') ?? true;
  }

  Future<void> toggleTheme() async {
    setState(() {
      dark = !dark;
    });

    await widget.prefs.setBool('dark', dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorldClock',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,

      // LIGHT THEME
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B8A9),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4FAF9),
      ),

      // DARK SEA THEME
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00B8A9),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF03090A),
        cardColor: const Color(0xFF0B1B1D),
      ),

      home: LoginPage(
        prefs: widget.prefs,
        onTheme: toggleTheme,
      ),
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onTheme;

  const LoginPage({
    super.key,
    required this.prefs,
    required this.onTheme,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController nameController =
  TextEditingController();

  bool signup = false;
  bool obscurePassword = true;

  void login() {
    final enteredName =
    signup
        ? (nameController.text.trim().isEmpty
        ? 'User'
        : nameController.text.trim())
        : (widget.prefs.getString('name') ?? 'User');

    widget.prefs.setString('name', enteredName);
    widget.prefs.setString(
      'email',
      emailController.text.trim(),
    );
    widget.prefs.setBool('logged', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConverterPage(
          prefs: widget.prefs,
          onTheme: widget.onTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // LOGO
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF004D4A),
                          Color(0xFF00B8A9),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B8A9)
                              .withOpacity(0.3),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      size: 46,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'WorldClock',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Convert and compare time worldwide',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Text(
                            signup
                                ? 'Create your account'
                                : 'Welcome back',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (signup) ...[
                            TextField(
                              controller: nameController,
                              decoration:
                              const InputDecoration(
                                labelText: 'Full name',
                                prefixIcon:
                                Icon(Icons.person_outline),
                                border:
                                OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 13),
                          ],

                          TextField(
                            controller: emailController,
                            keyboardType:
                            TextInputType.emailAddress,
                            decoration:
                            const InputDecoration(
                              labelText: 'Email',
                              prefixIcon:
                              Icon(Icons.email_outlined),
                              border:
                              OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 13),

                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                              const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword =
                                    !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons
                                      .visibility_off_outlined,
                                ),
                              ),
                              border:
                              const OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: login,
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Text(
                                  signup
                                      ? 'Create Account'
                                      : 'Sign In',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                signup = !signup;
                              });
                            },
                            child: Text(
                              signup
                                  ? 'Already have an account? Sign in'
                                  : 'New here? Create an account',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  OutlinedButton.icon(
                    onPressed: widget.onTheme,
                    icon: const Icon(
                      Icons.dark_mode_outlined,
                    ),
                    label: const Text(
                      'Toggle Dark Mode',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CONVERTER PAGE
// ============================================================

class ConverterPage extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onTheme;

  const ConverterPage({
    super.key,
    required this.prefs,
    required this.onTheme,
  });

  @override
  State<ConverterPage> createState() =>
      _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  ZoneOption from = zones[0];
  ZoneOption to = zones[8];

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  SharedPreferences get prefs => widget.prefs;

  bool get favorite =>
      prefs.getBool('favorite') ?? false;

  // SOURCE TIME
  tz.TZDateTime get sourceTime {
    final location =
    tz.getLocation(from.zoneId);

    return tz.TZDateTime(
      location,
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  // CONVERTED TIME
  tz.TZDateTime get convertedTime {
    final location =
    tz.getLocation(to.zoneId);

    return tz.TZDateTime.from(
      sourceTime.toUtc(),
      location,
    );
  }

  String twoDigits(int number) {
    return number.toString().padLeft(2, '0');
  }

  String formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String formatClock(DateTime date) {
    final hour =
    date.hour % 12 == 0 ? 12 : date.hour % 12;

    final minute = twoDigits(date.minute);

    final period =
    date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  String formatOffset(tz.TZDateTime date) {
    final offset = date.timeZoneOffset;

    final sign =
    offset.isNegative ? '-' : '+';

    final hours =
    offset.inHours.abs().toString().padLeft(2, '0');

    final minutes =
    (offset.inMinutes.abs() % 60)
        .toString()
        .padLeft(2, '0');

    return 'UTC$sign$hours:$minutes';
  }

  // ==========================================================
  // CURRENT TIME
  // ==========================================================

  void setCurrentTime() {
    final now = DateTime.now();

    setState(() {
      selectedDate = now;
      selectedTime =
          TimeOfDay.fromDateTime(now);
    });
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ==========================================================
  // TIME PICKER
  // ==========================================================

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // ==========================================================
  // LOCATION PICKER
  // ==========================================================

  Future<void> selectZone(bool isFrom) async {
    final selected =
    await showModalBottomSheet<ZoneOption>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return ZonePicker(
          current: isFrom ? from : to,
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isFrom) {
          from = selected;
        } else {
          to = selected;
        }
      });
    }
  }

  // ==========================================================
  // SWAP LOCATIONS
  // ==========================================================

  void swapLocations() {
    setState(() {
      final oldFrom = from;
      from = to;
      to = oldFrom;
    });
  }

  // ==========================================================
  // FAVORITE
  // ==========================================================

  Future<void> toggleFavorite() async {
    await prefs.setBool(
      'favorite',
      !favorite,
    );

    setState(() {});
  }

  // ==========================================================
  // PROFILE
  // ==========================================================

  void openProfile() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ProfileSheet(
          prefs: prefs,
          onTheme: widget.onTheme,
          onLogout: logout,
        );
      },
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  void logout() {
    prefs.setBool('logged', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          prefs: prefs,
          onTheme: widget.onTheme,
        ),
      ),
          (route) => false,
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final converted = convertedTime;

    final difference =
        (converted.timeZoneOffset -
            sourceTime.timeZoneOffset)
            .inMinutes;

    final differenceSign =
    difference < 0 ? '-' : '+';

    final absoluteDifference =
    difference.abs();

    final differenceText =
    absoluteDifference % 60 == 0
        ? '$differenceSign${absoluteDifference ~/ 60}h'
        : '$differenceSign${absoluteDifference ~/ 60}h ${absoluteDifference % 60}m';

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Time Zone Converter',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              'Compare time around the world',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: widget.onTheme,
            icon: const Icon(
              Icons.brightness_6_rounded,
            ),
          ),
          IconButton(
            onPressed: openProfile,
            icon: const Icon(
              Icons.account_circle_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            10,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // HERO CARD
              // ==================================================

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(28),
                  gradient:
                  const LinearGradient(
                    colors: [
                      Color(0xFF020708),
                      Color(0xFF006B68),
                      Color(0xFF00B8A9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF00B8A9,
                      ).withOpacity(0.22),
                      blurRadius: 25,
                      offset:
                      const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.public_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'TIME DIFFERENCE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${absoluteDifference ~/ 60} hour${absoluteDifference ~/ 60 == 1 ? '' : 's'} difference',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${from.city} → ${to.city}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // DATE AND TIME
              // ==================================================

              const Text(
                'Choose date & time',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: PickerCard(
                      icon:
                      Icons.calendar_month,
                      title: 'Date',
                      value:
                      formatDate(selectedDate),
                      onTap: pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PickerCard(
                      icon: Icons.access_time,
                      title: 'Time',
                      value:
                      selectedTime.format(
                        context,
                      ),
                      onTap: pickTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ==================================================
              // LOCATIONS
              // ==================================================

              const Text(
                'Locations',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              LocationCard(
                label: 'FROM',
                zone: from,
                dateTime: sourceTime,
                onTap: () =>
                    selectZone(true),
              ),

              // SWAP
              Center(
                child: IconButton.filled(
                  onPressed: swapLocations,
                  icon: const Icon(
                    Icons.swap_vert_rounded,
                  ),
                  tooltip:
                  'Swap locations',
                ),
              ),

              LocationCard(
                label: 'TO',
                zone: to,
                dateTime: converted,
                onTap: () =>
                    selectZone(false),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // OFFSET CARD
              // ==================================================

              Card(
                elevation: 0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    const Color(0xFF0D393A),
                    child: const Icon(
                      Icons.compare_arrows,
                      color:
                      Color(0xFF00B8A9),
                    ),
                  ),
                  title: const Text(
                    'Time zone offset',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '$differenceText • ${converted.timeZoneName}',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // BUTTONS
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                      setCurrentTime,
                      icon: const Icon(
                        Icons.my_location_rounded,
                      ),
                      label: const Text(
                        'Current Time',
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  IconButton.filledTonal(
                    onPressed:
                    toggleFavorite,
                    icon: Icon(
                      favorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                    ),
                    tooltip:
                    'Save favorite',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PICKER CARD
// ============================================================

class PickerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const PickerCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color:
                const Color(0xFF00B8A9),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION CARD
// ============================================================

class LocationCard extends StatelessWidget {
  final String label;
  final ZoneOption zone;
  final tz.TZDateTime dateTime;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.label,
    required this.zone,
    required this.dateTime,
    required this.onTap,
  });

  String clock() {
    final hour =
    dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute =
    dateTime.minute
        .toString()
        .padLeft(2, '0');

    final period =
    dateTime.hour >= 12
        ? 'PM'
        : 'AM';

    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                zone.flag,
                style: const TextStyle(
                  fontSize: 29,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color:
                        Color(0xFF00B8A9),
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      zone.city,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),

                    Text(
                      zone.country,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    clock(),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                    style:
                    const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ZONE PICKER
// ============================================================

class ZonePicker extends StatefulWidget {
  final ZoneOption current;

  const ZonePicker({
    super.key,
    required this.current,
  });

  @override
  State<ZonePicker> createState() =>
      _ZonePickerState();
}

class _ZonePickerState
    extends State<ZonePicker> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered =
    zones.where((zone) {
      final text =
      '${zone.city} ${zone.country} ${zone.zoneId}'
          .toLowerCase();

      return text.contains(
        search.toLowerCase(),
      );
    }).toList();

    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          18,
          5,
          18,
          20,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                'Select location',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 13),

            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration:
              const InputDecoration(
                hintText:
                'Search city or country',
                prefixIcon:
                Icon(Icons.search),
                filled: true,
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder:
                    (context, index) {
                  final zone =
                  filtered[index];

                  final selected =
                      zone.city ==
                          widget.current.city;

                  return ListTile(
                    leading: Text(
                      zone.flag,
                      style:
                      const TextStyle(
                        fontSize: 26,
                      ),
                    ),
                    title: Text(
                      zone.city,
                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    subtitle:
                    Text(zone.country),
                    trailing: selected
                        ? const Icon(
                      Icons
                          .check_circle,
                      color:
                      Color(0xFF00B8A9),
                    )
                        : null,
                    onTap: () {
                      Navigator.pop(
                        context,
                        zone,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE SHEET
// ============================================================

class ProfileSheet extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onTheme;
  final VoidCallback onLogout;

  const ProfileSheet({
    super.key,
    required this.prefs,
    required this.onTheme,
    required this.onLogout,
  });

  @override
  State<ProfileSheet> createState() =>
      _ProfileSheetState();
}

class _ProfileSheetState
    extends State<ProfileSheet> {
  String photoPath = '';

  final ImagePicker picker =
  ImagePicker();

  @override
  void initState() {
    super.initState();

    photoPath =
        widget.prefs.getString(
          'photo',
        ) ??
            '';
  }

  Future<void> choosePhoto() async {
    final image =
    await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      await widget.prefs.setString(
        'photo',
        image.path,
      );

      setState(() {
        photoPath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name =
        widget.prefs.getString(
          'name',
        ) ??
            'User';

    final email =
        widget.prefs.getString(
          'email',
        ) ??
            '';

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          22,
          5,
          22,
          24,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Align(
              alignment:
              Alignment.centerLeft,
              child: Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PROFILE PICTURE
            GestureDetector(
              onTap: choosePhoto,
              child: CircleAvatar(
                radius: 48,
                backgroundColor:
                const Color(0xFF0D393A),
                backgroundImage:
                photoPath.isNotEmpty
                    ? FileImage(
                  File(photoPath),
                )
                    : null,
                child:
                photoPath.isEmpty
                    ? const Icon(
                  Icons.person,
                  size: 48,
                  color:
                  Color(0xFF00B8A9),
                )
                    : null,
              ),
            ),

            const SizedBox(height: 5),

            TextButton.icon(
              onPressed: choosePhoto,
              icon: const Icon(
                Icons.camera_alt_outlined,
              ),
              label: const Text(
                'Change profile picture',
              ),
            ),

            Text(
              name,
              style: const TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            // DARK MODE
            ListTile(
              leading: const Icon(
                Icons.dark_mode_outlined,
              ),
              title: const Text(
                'Dark Mode',
              ),
              subtitle: Text(
                isDark
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
              ),
              trailing: Switch(
                value: isDark,
                onChanged: (_) {
                  widget.onTheme();
                  setState(() {});
                },
              ),
            ),

            // FAVORITE
            ListTile(
              leading: const Icon(
                Icons.star_outline_rounded,
              ),
              title: const Text(
                'Favorite Conversion',
              ),
              subtitle: Text(
                widget.prefs.getBool(
                  'favorite',
                ) ??
                    false
                    ? 'Saved'
                    : 'Not saved',
              ),
            ),

            const SizedBox(height: 5),

            // LOGOUT
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                widget.onLogout,
                icon: const Icon(
                  Icons.logout,
                ),
                label: const Text(
                  'Sign Out',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}