import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_profile.dart';
import '../models/college_alert.dart';
import '../services/firebase_service.dart';
import 'alert_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.profile});

  final AppProfile profile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'All';
  String _query = '';
  Set<String> _saved = {};

  static const categories =
      ['All', 'General', 'Exam', 'Event', 'Holiday', 'Fee', 'Emergency'];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    try {
      final ids = await FirebaseService.savedAlertIds();
      if (mounted) setState(() => _saved = ids);
    } catch (_) {
      // Saved alerts are optional; the main alerts feed should still work.
    }
  }

  bool _isForStudent(CollegeAlert alert) {
    if (widget.profile.isAdmin) return true;
    final departmentMatches = alert.targetDepartment == null ||
        alert.targetDepartment!.isEmpty ||
        alert.targetDepartment!.toLowerCase() ==
            widget.profile.department?.toLowerCase();
    final semesterMatches = alert.targetSemester == null ||
        alert.targetSemester == widget.profile.semester;
    return departmentMatches && semesterMatches;
  }

  Future<void> _toggleSaved(CollegeAlert alert) async {
    final newValue = !_saved.contains(alert.id);
    setState(() {
      if (newValue) {
        _saved.add(alert.id);
      } else {
        _saved.remove(alert.id);
      }
    });
    try {
      await FirebaseService.setSaved(alert.id, newValue);
    } catch (_) {
      if (mounted) {
        setState(() {
          if (newValue) {
            _saved.remove(alert.id);
          } else {
            _saved.add(alert.id);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Alert',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: widget.profile.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertFormScreen()),
              ),
              icon: const Icon(Icons.add_alert_outlined),
              label: const Text('Add alert'),
            )
          : null,
      body: StreamBuilder<List<CollegeAlert>>(
        stream: FirebaseService.watchAlerts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load alerts',
              message: snapshot.error.toString(),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allAlerts = snapshot.data!.where(_isForStudent).toList();
          final visible = allAlerts.where((alert) {
            final categoryMatch =
                _category == 'All' || alert.category == _category;
            final searchMatch = _query.isEmpty ||
                alert.title.toLowerCase().contains(_query) ||
                alert.description.toLowerCase().contains(_query);
            return categoryMatch && searchMatch;
          }).toList()
            ..sort((a, b) {
              if (a.isImportant != b.isImportant) return a.isImportant ? -1 : 1;
              return b.createdAt.compareTo(a.createdAt);
            });

          return RefreshIndicator(
            onRefresh: _loadSaved,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _WelcomeCard(profile: widget.profile)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _query = value.trim().toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: 'Search alerts',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final item = categories[index];
                        return ChoiceChip(
                          label: Text(item),
                          selected: item == _category,
                          onSelected: (_) => setState(() => _category = item),
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
                  sliver: visible.isEmpty
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _MessageState(
                            icon: Icons.notifications_none_rounded,
                            title: 'No alerts found',
                            message: 'New campus alerts will appear here.',
                          ),
                        )
                      : SliverList.separated(
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final alert = visible[index];
                            return _AlertCard(
                              alert: alert,
                              saved: _saved.contains(alert.id),
                              isAdmin: widget.profile.isAdmin,
                              onSave: () => _toggleSaved(alert),
                              onOpen: () => _openDetails(alert),
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AlertFormScreen(existing: alert),
                                ),
                              ),
                              onDelete: () => _deleteAlert(alert),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDetails(CollegeAlert alert) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AlertDetails(alert: alert),
      );

  Future<void> _deleteAlert(CollegeAlert alert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete alert?'),
        content: Text('“${alert.title}” will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) await FirebaseService.deleteAlert(alert.id);
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.profile});
  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF6A5AE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, ${profile.name.split(' ').first}!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  profile.isAdmin
                      ? 'Manage campus announcements from one place.'
                      : '${profile.department ?? 'Student'} • Semester ${profile.semester ?? '-'}',
                  style: TextStyle(color: Colors.white.withValues(alpha: .85)),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_active_outlined,
              color: Colors.white, size: 42),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.saved,
    required this.isAdmin,
    required this.onSave,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CollegeAlert alert;
  final bool saved;
  final bool isAdmin;
  final VoidCallback onSave;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: alert.color.withValues(alpha: .11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(alert.icon, color: alert.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _SmallLabel(label: alert.category, color: alert.color),
                        if (alert.isImportant)
                          const _SmallLabel(
                              label: 'IMPORTANT', color: Color(0xFFD92D20)),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(alert.title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy)),
                    const SizedBox(height: 6),
                    Text(
                      alert.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF667085), height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 15, color: Color(0xFF667085)),
                        const SizedBox(width: 5),
                        Text(alert.formattedDate,
                            style: const TextStyle(
                                color: Color(0xFF667085), fontSize: 12)),
                        if (alert.venue?.isNotEmpty == true) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_outlined,
                              size: 15, color: Color(0xFF667085)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(alert.venue!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Color(0xFF667085), fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                )
              else
                IconButton(
                  tooltip: saved ? 'Remove from saved' : 'Save alert',
                  onPressed: onSave,
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  const _SmallLabel({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _AlertDetails extends StatelessWidget {
  const _AlertDetails({required this.alert});
  final CollegeAlert alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 14, 24, 24 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D5DD),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Icon(alert.icon, color: alert.color, size: 36),
            const SizedBox(height: 14),
            Text(alert.title,
                style: const TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 24)),
            const SizedBox(height: 10),
            _SmallLabel(label: alert.category, color: alert.color),
            const SizedBox(height: 20),
            _DetailRow(
                icon: Icons.calendar_month_outlined,
                text: alert.formattedDate),
            if (alert.eventTime?.isNotEmpty == true)
              _DetailRow(icon: Icons.schedule_outlined, text: alert.eventTime!),
            if (alert.venue?.isNotEmpty == true)
              _DetailRow(icon: Icons.location_on_outlined, text: alert.venue!),
            const Divider(height: 30),
            Text(alert.description,
                style: const TextStyle(
                    fontSize: 15.5, height: 1.55, color: Color(0xFF344054))),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF667085)),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: const Color(0xFF98A2B3)),
            const SizedBox(height: 14),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF667085))),
          ],
        ),
      ),
    );
  }
}
