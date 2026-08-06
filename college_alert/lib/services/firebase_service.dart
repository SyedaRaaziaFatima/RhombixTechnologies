import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_profile.dart';
import '../models/college_alert.dart';

class FirebaseService {
  FirebaseService._();

  static final auth = FirebaseAuth.instance;
  static final db = FirebaseFirestore.instance;

  static Future<AppProfile> loadProfile() async {
    final user = auth.currentUser;
    if (user == null) throw FirebaseAuthException(code: 'signed-out');

    for (var attempt = 0; attempt < 3; attempt++) {
      final document = await db.collection('profiles').doc(user.uid).get();
      if (document.exists && document.data() != null) {
        return AppProfile.fromMap({'id': document.id, ...document.data()!});
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
    }
    throw Exception('Profile is missing. Create the account again.');
  }

  static Stream<List<CollegeAlert>> watchAlerts() => db
      .collection('alerts')
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CollegeAlert.fromMap({'id': doc.id, ...doc.data()}))
          .toList());

  static Future<void> createAlert(CollegeAlert alert) =>
      db.collection('alerts').add({
        ...alert.toMap(),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

  static Future<void> updateAlert(CollegeAlert alert) =>
      db.collection('alerts').doc(alert.id).update({
        ...alert.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
      });

  static Future<void> deleteAlert(String id) =>
      db.collection('alerts').doc(id).delete();

  static CollectionReference<Map<String, dynamic>> get _savedCollection => db
      .collection('profiles')
      .doc(auth.currentUser!.uid)
      .collection('saved_alerts');

  static Future<Set<String>> savedAlertIds() async {
    final snapshot = await _savedCollection.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  static Future<void> setSaved(String alertId, bool saved) async {
    final document = _savedCollection.doc(alertId);
    if (saved) {
      await document.set({
        'alert_id': alertId,
        'created_at': FieldValue.serverTimestamp(),
      });
    } else {
      await document.delete();
    }
  }
}
