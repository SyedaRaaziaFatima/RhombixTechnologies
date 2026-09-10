import 'package:flutter/material.dart';

import '../models/packing_item.dart';
import '../models/trip.dart';

class TripEditorScreen extends StatefulWidget {
  const TripEditorScreen({super.key});

  @override
  State<TripEditorScreen> createState() => _TripEditorScreenState();
}

class _TripEditorScreenState extends State<TripEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _destination = TextEditingController();
  final _members = TextEditingController(text: '2');
  final _notes = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(days: 1));
  DateTime _end = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    _title.dispose();
    _destination.dispose();
    _members.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool start) async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: start ? _start : _end,
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _start = selected;
        if (_end.isBefore(_start)) _end = _start.add(const Duration(days: 1));
      } else {
        _end = selected;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_end.isBefore(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }
    final now = DateTime.now();
    Navigator.pop(
      context,
      Trip(
        id: now.microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        destination: _destination.text.trim(),
        startDate: _start,
        endDate: _end,
        members: int.tryParse(_members.text) ?? 1,
        notes: _notes.text.trim(),
        packingItems: defaultPackingList(),
        createdAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Plan a new trip')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Trip details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 18),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Trip name',
                  hintText: 'Weekend mountain escape',
                  prefixIcon: Icon(Icons.landscape_outlined),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Give your trip a name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _destination,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Fairy Meadows',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Enter a destination'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Start',
                      date: _start,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'End',
                      date: _end,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _members,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of campers',
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                validator: (value) {
                  final count = int.tryParse(value ?? '');
                  return count == null || count < 1 || count > 99
                      ? 'Enter a number from 1 to 99'
                      : null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Meeting point, route, special instructions…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Create trip'),
              ),
            ],
          ),
        ),
      );
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          child: Text(shortDate(date), maxLines: 1),
        ),
      );
}
