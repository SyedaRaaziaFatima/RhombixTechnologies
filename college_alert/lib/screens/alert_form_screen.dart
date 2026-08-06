import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/college_alert.dart';
import '../services/firebase_service.dart';

class AlertFormScreen extends StatefulWidget {
  const AlertFormScreen({super.key, this.existing});

  final CollegeAlert? existing;

  @override
  State<AlertFormScreen> createState() => _AlertFormScreenState();
}

class _AlertFormScreenState extends State<AlertFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _venue;
  late final TextEditingController _time;
  late final TextEditingController _department;
  late String _category;
  late DateTime _eventDate;
  String? _semester;
  late bool _important;
  bool _saving = false;

  static const categories =
      ['General', 'Exam', 'Event', 'Holiday', 'Fee', 'Emergency'];

  @override
  void initState() {
    super.initState();
    final alert = widget.existing;
    _title = TextEditingController(text: alert?.title);
    _description = TextEditingController(text: alert?.description);
    _venue = TextEditingController(text: alert?.venue);
    _time = TextEditingController(text: alert?.eventTime);
    _department = TextEditingController(text: alert?.targetDepartment);
    _category = alert?.category ?? 'General';
    _eventDate = alert?.eventDate ?? DateTime.now();
    _semester = alert?.targetSemester;
    _important = alert?.isImportant ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _venue.dispose();
    _time.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final alert = CollegeAlert(
      id: widget.existing?.id ?? '',
      title: _title.text,
      description: _description.text,
      category: _category,
      eventDate: _eventDate,
      eventTime: _time.text,
      venue: _venue.text,
      isImportant: _important,
      targetDepartment: _department.text,
      targetSemester: _semester,
      createdBy: FirebaseAuth.instance.currentUser!.uid,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.existing == null) {
        await FirebaseService.createAlert(alert);
      } else {
        await FirebaseService.updateAlert(alert);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save alert: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add alert' : 'Edit alert')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Alert title'),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: _required,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => _category = value ?? 'General',
            ),
            const SizedBox(height: 14),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Event date'),
              subtitle: Text(
                  '${_eventDate.day}/${_eventDate.month}/${_eventDate.year}'),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _time,
                    decoration: const InputDecoration(labelText: 'Time (optional)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _venue,
                    decoration: const InputDecoration(labelText: 'Venue (optional)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _department,
              decoration: const InputDecoration(
                labelText: 'Target department (blank means all)',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String?>(
              value: _semester,
              decoration: const InputDecoration(labelText: 'Target semester'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All semesters')),
                ...List.generate(
                  8,
                  (index) => DropdownMenuItem(
                    value: '${index + 1}',
                    child: Text('Semester ${index + 1}'),
                  ),
                ),
              ],
              onChanged: (value) => _semester = value,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: const Text('Mark as important'),
              subtitle: const Text('Important alerts appear at the top visually.'),
              value: _important,
              onChanged: (value) => setState(() => _important = value),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Save alert'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;
}
