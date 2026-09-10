import 'package:campmate/models/packing_item.dart';
import 'package:campmate/models/trip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('packing progress counts packed items', () {
    final trip = Trip(
      id: '1',
      title: 'Test',
      destination: 'Test place',
      startDate: DateTime(2026),
      endDate: DateTime(2026, 1, 2),
      members: 2,
      notes: '',
      packingItems: const [
        PackingItem(id: 'a', name: 'Tent', category: 'Shelter', isPacked: true),
        PackingItem(id: 'b', name: 'Water', category: 'Food & Water'),
      ],
      createdAt: DateTime(2025),
    );

    expect(trip.packedCount, 1);
    expect(trip.packingProgress, .5);
  });
}
