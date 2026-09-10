class PackingItem {
  const PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isPacked = false,
  });

  final String id;
  final String name;
  final String category;
  final bool isPacked;

  PackingItem copyWith({bool? isPacked}) => PackingItem(
        id: id,
        name: name,
        category: category,
        isPacked: isPacked ?? this.isPacked,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'isPacked': isPacked,
      };

  factory PackingItem.fromMap(Map<String, dynamic> map) => PackingItem(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? 'Item',
        category: map['category'] as String? ?? 'Other',
        isPacked: map['isPacked'] as bool? ?? false,
      );
}

List<PackingItem> defaultPackingList() {
  const entries = <(String, String)>[
    ('Tent', 'Shelter'),
    ('Sleeping bag', 'Shelter'),
    ('Ground mat', 'Shelter'),
    ('Water bottles', 'Food & Water'),
    ('Dry food', 'Food & Water'),
    ('Portable stove', 'Food & Water'),
    ('First-aid kit', 'Safety'),
    ('Flashlight', 'Safety'),
    ('Power bank', 'Safety'),
    ('Warm jacket', 'Clothing'),
    ('Rain coat', 'Clothing'),
    ('Hiking shoes', 'Clothing'),
  ];
  return [
    for (var i = 0; i < entries.length; i++)
      PackingItem(
        id: 'default_$i',
        name: entries[i].$1,
        category: entries[i].$2,
      ),
  ];
}
