import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm_circle.dart';
import 'dart:math';

class AlarmCircleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate a random 6-digit code
  String _generateCircleCode() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Create a new alarm circle
  Future<AlarmCircle> createCircle(DateTime alarmTime) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    String code;
    bool codeExists;

    // Generate a unique code
    do {
      code = _generateCircleCode();
      final querySnapshot = await _firestore
          .collection('alarmCircles')
          .where('code', isEqualTo: code)
          .get();
      codeExists = querySnapshot.docs.isNotEmpty;
    } while (codeExists);

    // Create the circle document
    final docRef = await _firestore.collection('alarmCircles').add({
      'code': code,
      'alarmTime': Timestamp.fromDate(alarmTime),
      'memberIds': [user.uid],
      'creatorId': user.uid,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Get the created document
    final doc = await docRef.get();
    return AlarmCircle.fromFirestore(doc);
  }

  // Join an existing circle
  Future<AlarmCircle> joinCircle(String code) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Find the circle with the given code
    final querySnapshot = await _firestore
        .collection('alarmCircles')
        .where('code', isEqualTo: code)
        .where('isActive', isEqualTo: true)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Invalid or inactive circle code');
    }

    final doc = querySnapshot.docs.first;
    final circle = AlarmCircle.fromFirestore(doc);

    // Check if user is already a member
    if (circle.memberIds.contains(user.uid)) {
      throw Exception('Already a member of this circle');
    }

    // Add user to the circle
    await doc.reference.update({
      'memberIds': FieldValue.arrayUnion([user.uid])
    });

    return circle;
  }

  // Get user's active circles
  Stream<List<AlarmCircle>> getUserCircles() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('alarmCircles')
        .where('memberIds', arrayContains: user.uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AlarmCircle.fromFirestore(doc))
            .toList());
  }

  // Leave a circle
  Future<void> leaveCircle(String circleId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('alarmCircles').doc(circleId).update({
      'memberIds': FieldValue.arrayRemove([user.uid])
    });
  }
}