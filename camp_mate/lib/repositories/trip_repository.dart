import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/packing_item.dart';
import '../models/trip.dart';

abstract class TripRepository {
  Stream<List<Trip>> watchTrips();
  Future<void> saveTrip(Trip trip);
  Future<void> deleteTrip(String id);
}

class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository({required this.userId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final String userId;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _trips =>
      _firestore.collection('users').doc(userId).collection('trips');

  @override
  Stream<List<Trip>> watchTrips() => _trips
      .orderBy('startDate')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Trip.fromMap(doc.id, doc.data()))
          .toList());

  @override
  Future<void> saveTrip(Trip trip) =>
      _trips.doc(trip.id).set(trip.toMap(), SetOptions(merge: true));

  @override
  Future<void> deleteTrip(String id) => _trips.doc(id).delete();
}

class DemoTripRepository implements TripRepository {
  DemoTripRepository() {
    final now = DateTime.now();
    _trips = [
      Trip(
        id: 'demo_trip',
        title: 'Mountain Escape',
        destination: 'Fairy Meadows, Gilgit-Baltistan',
        startDate: now.add(const Duration(days: 8)),
        endDate: now.add(const Duration(days: 11)),
        members: 4,
        notes: 'Meet at 6:00 AM. Carry warm layers and enough drinking water.',
        packingItems: defaultPackingList(),
        createdAt: now,
      ),
    ];
  }

  late List<Trip> _trips;
  final _controller = StreamController<List<Trip>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_trips));

  @override
  Stream<List<Trip>> watchTrips() async* {
    yield List.unmodifiable(_trips);
    yield* _controller.stream;
  }

  @override
  Future<void> saveTrip(Trip trip) async {
    final index = _trips.indexWhere((item) => item.id == trip.id);
    if (index == -1) {
      _trips = [..._trips, trip];
    } else {
      _trips = [..._trips]..[index] = trip;
    }
    _trips.sort((a, b) => a.startDate.compareTo(b.startDate));
    _emit();
  }

  @override
  Future<void> deleteTrip(String id) async {
    _trips = _trips.where((trip) => trip.id != id).toList();
    _emit();
  }
}
