import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../services/auth_service.dart';
import 'trip_detail_screen.dart';
import 'trip_editor_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.repository,
    required this.isDemo,
    required this.isDark,
    required this.onThemeChanged,
    this.auth,
  });

  final TripRepository repository;
  final bool isDemo;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final AuthService? auth;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  Future<void> _createTrip() async {
    final trip = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(builder: (_) => const TripEditorScreen()),
    );
    if (trip != null) {
      await widget.repository.saveTrip(trip);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip created successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(repository: widget.repository, onCreate: _createTrip),
      _TripsPage(repository: widget.repository, onCreate: _createTrip),
      const _SafetyPage(),
      _ProfilePage(
        isDemo: widget.isDemo,
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
        auth: widget.auth,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.health_and_safety_outlined), selectedIcon: Icon(Icons.health_and_safety), label: 'Safety'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle, this.trailing});
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.repository, required this.onCreate});
  final TripRepository repository;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: StreamBuilder<List<Trip>>(
          stream: repository.watchTrips(),
          builder: (context, snapshot) {
            final trips = snapshot.data ?? const <Trip>[];
            final upcoming = trips.where((trip) => trip.isUpcoming).toList();
            return RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const _PageHeader(title: 'Ready to explore?', subtitle: 'Plan smart. Travel safe.'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HeroCard(onCreate: onCreate),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Expanded(child: _StatCard(icon: Icons.hiking, value: '${trips.length}', label: 'Total trips')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(icon: Icons.event_available, value: '${upcoming.length}', label: 'Upcoming')),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Next adventure', style: Theme.of(context).textTheme.titleLarge),
                      if (upcoming.isNotEmpty) Text('${upcoming.first.members} campers'),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                  else if (upcoming.isEmpty)
                    _EmptyTrips(onCreate: onCreate)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _TripCard(trip: upcoming.first, repository: repository),
                    ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Quick safety check', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _TipCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Water first',
                      text: 'Carry at least 2–3 litres per person per day, plus an emergency reserve.',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.forest, AppColors.pine],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.forest.withValues(alpha: .25), blurRadius: 22, offset: const Offset(0, 12))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.terrain, color: Colors.white, size: 42),
          const SizedBox(height: 30),
          const Text('Where will you camp next?', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Build your plan and packing checklist in minutes.', style: TextStyle(color: Colors.white70, height: 1.4)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreate,
            style: FilledButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: AppColors.ink),
            icon: const Icon(Icons.add),
            label: const Text('Plan a trip'),
          ),
        ]),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ]),
        ),
      );
}

class _TripsPage extends StatelessWidget {
  const _TripsPage({required this.repository, required this.onCreate});
  final TripRepository repository;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: StreamBuilder<List<Trip>>(
          stream: repository.watchTrips(),
          builder: (context, snapshot) {
            final trips = snapshot.data ?? const <Trip>[];
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(children: [
                _PageHeader(
                  title: 'My trips',
                  subtitle: 'Every adventure in one place',
                  trailing: IconButton.filled(onPressed: onCreate, icon: const Icon(Icons.add)),
                ),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : trips.isEmpty
                          ? _EmptyTrips(onCreate: onCreate)
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                              itemCount: trips.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => Dismissible(
                                key: ValueKey(trips[index].id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete trip?'),
                                    content: Text('${trips[index].title} will be permanently deleted.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                    ],
                                  ),
                                ),
                                onDismissed: (_) => repository.deleteTrip(trips[index].id),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(22)),
                                  child: const Icon(Icons.delete_outline, color: Colors.white),
                                ),
                                child: _TripCard(trip: trips[index], repository: repository),
                              ),
                            ),
                ),
              ]),
              floatingActionButton: FloatingActionButton.extended(onPressed: onCreate, icon: const Icon(Icons.add), label: const Text('New trip')),
            );
          },
        ),
      );
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.repository});
  final Trip trip;
  final TripRepository repository;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TripDetailScreen(initialTrip: trip, repository: repository)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(17)),
                  child: const Icon(Icons.terrain),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(trip.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(trip.destination, maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                const Icon(Icons.chevron_right),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 17),
                const SizedBox(width: 7),
                Text(shortDate(trip.startDate)),
                const Spacer(),
                Text('${trip.packedCount}/${trip.packingItems.length} packed'),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: trip.packingProgress, minHeight: 7)),
            ]),
          ),
        ),
      );
}

class _EmptyTrips extends StatelessWidget {
  const _EmptyTrips({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.explore_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text('No trips planned yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Create your first adventure and get a ready-made packing list.', textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton(onPressed: onCreate, child: const Text('Plan first trip')),
        ]),
      );
}

class _SafetyPage extends StatelessWidget {
  const _SafetyPage();

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: const [
            _PageHeader(title: 'Safety guide', subtitle: 'Essential outdoor knowledge'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _EmergencyCard(),
                SizedBox(height: 14),
                _TipCard(icon: Icons.route_outlined, title: 'Share your route', text: 'Tell a trusted person where you are going, your route, and when you expect to return.'),
                SizedBox(height: 12),
                _TipCard(icon: Icons.thunderstorm_outlined, title: 'Watch the weather', text: 'Check the forecast before leaving. Turn back early when storms or flash floods are possible.'),
                SizedBox(height: 12),
                _TipCard(icon: Icons.local_fire_department_outlined, title: 'Fire safety', text: 'Use established fire rings, keep water nearby, and extinguish every ember before leaving.'),
                SizedBox(height: 12),
                _TipCard(icon: Icons.medical_services_outlined, title: 'First aid', text: 'Carry a complete kit and learn how to treat cuts, burns, sprains, dehydration, and heat illness.'),
                SizedBox(height: 12),
                _TipCard(icon: Icons.pets_outlined, title: 'Wildlife distance', text: 'Store food securely, never feed wildlife, and observe animals from a safe distance.'),
              ]),
            ),
          ],
        ),
      );
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(22)),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.sos, size: 36),
          SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('In an emergency', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            SizedBox(height: 6),
            Text('Stay calm, move away from immediate danger, conserve your phone battery, and contact local emergency services.'),
          ])),
        ]),
      );
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Text(text, style: TextStyle(height: 1.4, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ])),
          ]),
        ),
      );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({required this.isDemo, required this.isDark, required this.onThemeChanged, this.auth});
  final bool isDemo;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final AuthService? auth;

  @override
  Widget build(BuildContext context) {
    final User? user = auth?.currentUser;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.only(bottom: 28), children: [
        const _PageHeader(title: 'Profile', subtitle: 'Preferences and account'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            Card(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(radius: 31, child: Text((user?.displayName?.isNotEmpty ?? false) ? user!.displayName![0].toUpperCase() : 'C', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(isDemo ? 'Demo Explorer' : (user?.displayName ?? 'Camper'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 3),
                  Text(isDemo ? 'Local demo mode' : (user?.email ?? '')),
                ])),
              ]),
            )),
            const SizedBox(height: 12),
            Card(child: Column(children: [
              SwitchListTile(
                value: isDark,
                onChanged: onThemeChanged,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                subtitle: const Text('Use a darker outdoor theme'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.cloud_done_outlined),
                title: Text('Data storage'),
                subtitle: Text('Firestore sync with offline cache'),
              ),
            ])),
            const SizedBox(height: 16),
            if (!isDemo)
              OutlinedButton.icon(
                onPressed: auth?.signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              )
            else
              const Text('Connect Firebase to enable private accounts and cloud sync.', textAlign: TextAlign.center),
          ]),
        ),
      ]),
    );
  }
}
