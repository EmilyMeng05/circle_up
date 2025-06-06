import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm_circle.dart';
import '../services/user_service.dart';
import 'dart:math';

/*
 * Represents the service for managing and creating alarm circles
 * Allows for users to join, create, and leave alarm circles
*/
class AlarmCircleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Generate a random 6-digit code
  // This code is used to identify a particular alarm circle
  String _generateCircleCode() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Create a new alarm circle
  // [alarmTime]: Represents the time when the alarm will trigger for all members
  // If the user is already in a group, throws an exception
  // If successful, creates a new circle document in Firestore and updates the user's group status
  // Returns the created AlarmCircle object
  Future<AlarmCircle> createCircle(DateTime alarmTime) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check if user is already in a group
    if (await _userService.isUserInGroup()) {
      throw Exception('Already in a circle. Leave current circle first.');
    }

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

    // Update user's group status
    await _userService.joinGroup(code);

    // Get the created document
    final doc = await docRef.get();
    return AlarmCircle.fromFirestore(doc);
  }

  // Join an existing circle
  // [code]: Represents the unique circle code
  // If the user is already in a circle or the code is not valid, throws an exception
  // If successful, adds the user to the circle and updates their group status
  Future<AlarmCircle> joinCircle(String code) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (await _userService.isUserInGroup()) {
      throw Exception('Already in a circle. Leave current circle first.');
    }

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

    // Update user's group status
    await _userService.joinGroup(code);

    // Fetch the updated circle data
    final updatedDoc = await doc.reference.get();
    return AlarmCircle.fromFirestore(updatedDoc);
  }

  // Get user's active circles
  // Returns all of the alarm circles the user is currently a member of
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

  // Function to Leave a circle
  // [circleId] is the ID of the circle to leave
  // When a user leaves the circle, they are removed from the member list
  // Further, their status in the group is updated locally and in firestore
  Future<void> leaveCircle(String circleId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Remove user from circle
    await _firestore.collection('alarmCircles').doc(circleId).update({
      'memberIds': FieldValue.arrayRemove([user.uid])
    });

    // Update user's group status
    await _userService.leaveGroup();
  }
}