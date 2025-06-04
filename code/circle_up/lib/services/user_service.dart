import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or update user document in Firestore
  Future<AppUser> createOrUpdateUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) throw Exception('User not authenticated');

    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // Create new user document
      final newUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await userDoc.set(newUser.toMap());
      return newUser;
    } else {
      // Update existing user's last login
      final user = AppUser.fromFirestore(docSnapshot);
      await userDoc.update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        'displayName': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
      });

      return AppUser(
        id: user.id,
        email: user.email,
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: user.createdAt,
        lastLoginAt: DateTime.now(),
        personalAlarmTime: user.personalAlarmTime,
        isInGroup: user.isInGroup,
        groupCode: user.groupCode,
      );
    }
  }

  // Get user by ID
  Future<AppUser?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  // Get multiple users by their IDs
  Future<List<AppUser>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final users = await Future.wait(
      userIds.map((id) => getUserById(id)),
    );

    return users.whereType<AppUser>().toList();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).update(updates);
    }
  }

  // Set personal alarm time
  Future<void> setPersonalAlarmTime(DateTime alarmTime) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'personalAlarmTime': Timestamp.fromDate(alarmTime),
    });
  }

  // Get current user's personal alarm time
  Future<DateTime?> getPersonalAlarmTime() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return data['personalAlarmTime'] != null
        ? (data['personalAlarmTime'] as Timestamp).toDate()
        : null;
  }

  // Stream of current user's data including personal alarm time
  Stream<AppUser?> getCurrentUserStream() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  // Join a group
  Future<void> joinGroup(String groupCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'isInGroup': true,
      'groupCode': groupCode,
    });
  }

  // Leave a group
  Future<void> leaveGroup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'isInGroup': false,
      'groupCode': null,
    });
  }

  // Check if user is in a group
  Future<bool> isUserInGroup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>;
    return data['isInGroup'] ?? false;
  }

  // Get user's current group code
  Future<String?> getCurrentGroupCode() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return data['groupCode'];
  }

  Future<AppUser?> getUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(doc);
  }

  // increment success
  Future<void> incrementSuccess() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final current = snapshot.data()?['numSuccess'] ?? 0;
      transaction.update(docRef, {'numSuccess': current + 1});
    });
  }

  // increment failure
  Future<void> incrementFailure() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final current = snapshot.data()?['numFailure'] ?? 0;
      transaction.update(docRef, {'numFailure': current + 1});
    });
  }
}