import 'package:cloud_firestore/cloud_firestore.dart';

import 'packing_item.dart';

class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.members,
    required this.notes,
    required this.packingItems,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int members;
  final String notes;
  final List<PackingItem> packingItems;
  final DateTime createdAt;

  int get packedCount => packingItems.where((item) => item.isPacked).length;
  double get packingProgress =>
      packingItems.isEmpty ? 0 : packedCount / packingItems.length;
  bool get isUpcoming => endDate.isAfter(DateTime.now());

  Trip copyWith({List<PackingItem>? packingItems}) => Trip(
        id: id,
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        members: members,
        notes: notes,
        packingItems: packingItems ?? this.packingItems,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'destination': destination,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'members': members,
        'notes': notes,
        'packingItems': packingItems.map((item) => item.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Trip.fromMap(String id, Map<String, dynamic> map) {
    DateTime readDate(Object? value, DateTime fallback) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }

    final now = DateTime.now();
    final rawItems = map['packingItems'] as List<dynamic>? ?? const [];
    return Trip(
      id: id,
      title: map['title'] as String? ?? 'Camping Trip',
      destination: map['destination'] as String? ?? 'Unknown destination',
      startDate: readDate(map['startDate'], now),
      endDate: readDate(map['endDate'], now.add(const Duration(days: 1))),
      members: (map['members'] as num?)?.toInt() ?? 1,
      notes: map['notes'] as String? ?? '',
      packingItems: rawItems
          .whereType<Map>()
          .map((item) => PackingItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      createdAt: readDate(map['createdAt'], now),
    );
  }
}

String shortDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
