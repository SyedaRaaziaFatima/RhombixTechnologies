import 'package:flutter/material.dart';

import '../models/packing_item.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({
    super.key,
    required this.initialTrip,
    required this.repository,
  });

  final Trip initialTrip;
  final TripRepository repository;

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip _trip = widget.initialTrip;

  Future<void> _toggle(PackingItem selected, bool value) async {
    final items = _trip.packingItems
        .map((item) => item.id == selected.id ? item.copyWith(isPacked: value) : item)
        .toList();
    setState(() => _trip = _trip.copyWith(packingItems: items));
    try {
      await widget.repository.saveTrip(_trip);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update the item. Please try again.')),
        );
      }
    }
  }

  Future<void> _addItem() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _AddPackingItemDialog(),
    );
    if (!mounted || name == null || name.isEmpty) return;
    final item = PackingItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: 'Other',
    );
    setState(() => _trip = _trip.copyWith(packingItems: [..._trip.packingItems, item]));
    try {
      await widget.repository.saveTrip(_trip);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the item. Check Firebase rules.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PackingItem>>{};
    for (final item in _trip.packingItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.title),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add), tooltip: 'Add item'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.place_outlined),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_trip.destination, style: const TextStyle(fontWeight: FontWeight.w700))),
                ]),
                const SizedBox(height: 12),
                Text('${shortDate(_trip.startDate)} — ${shortDate(_trip.endDate)}'),
                const SizedBox(height: 8),
                Text('${_trip.members} camper${_trip.members == 1 ? '' : 's'}'),
                if (_trip.notes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(_trip.notes),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Packing checklist', style: Theme.of(context).textTheme.titleLarge),
              Text('${_trip.packedCount}/${_trip.packingItems.length}'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: _trip.packingProgress, minHeight: 9),
          ),
          const SizedBox(height: 18),
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
            ),
            Card(
              child: Column(
                children: [
                  for (final item in entry.value)
                    CheckboxListTile(
                      value: item.isPacked,
                      onChanged: (value) => _toggle(item, value ?? false),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isPacked ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );
  }
}

class _AddPackingItemDialog extends StatefulWidget {
  const _AddPackingItemDialog();

  @override
  State<_AddPackingItemDialog> createState() => _AddPackingItemDialogState();
}

class _AddPackingItemDialogState extends State<_AddPackingItemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isNotEmpty) Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add packing item'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Sunblock'),
          onSubmitted: (_) => _submit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: _submit, child: const Text('Add')),
        ],
      );
}
