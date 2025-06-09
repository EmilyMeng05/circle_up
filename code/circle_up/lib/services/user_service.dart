import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

/*
 * Represents the user service class
 * In this class, we handle all user-related operations and persist the user data to the database
*/
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or update user document in Firestore
  // If the user does not exist, create a new object and persist to the database
  // If the user exists, update their last login time and other details
  // Returns the AppUser object representing the user
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
      // Return newly created user object
      return newUser;
    } else {
      // Update existing user's last login
      final user = AppUser.fromFirestore(docSnapshot);
      await userDoc.update({
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        'displayName': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
      });

      // Return updated user object
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
  // Retrieves a user document from firestore based on the user's id
  Future<AppUser?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  // Get multiple users by their IDs
  Future<List<AppUser>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    final users = await Future.wait(userIds.map((id) => getUserById(id)));

    return users.whereType<AppUser>().toList();
  }

  // Update user profile
  // When this is called, the user's display name or photo URL can be updated in the database
  // Ensures the user is authenticated before making changes
  // If the user is not authenticated, throws an exception
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
  // [groupCode]: Represents the unique group code to join
  // If the user is not authenticated, throws an exception
  Future<void> joinGroup(String groupCode) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'isInGroup': true,
      'groupCode': groupCode,
    });
  }

  // Leave a group
  // If the user is not authenticated, throws an exception
  // This will set the user's group status to false and clear the group code
  Future<void> leaveGroup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).update({
      'isInGroup': false,
      'groupCode': null,
    });
  }

  // Check if user is in a group
  // Returns true if the user is currently in a group, false otherwise
  // If the user is not authenticated, throws an exception
  Future<bool> isUserInGroup() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>;
    return data['isInGroup'] ?? false;
  }

  // Get user's current group code
  // Returns the group code if the user is in a group, null otherwise
  // If the user is not authenticated, throws an exception
  Future<String?> getCurrentGroupCode() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return data['groupCode'];
  }

  // Gets the current user object
  // Returns an AppUser object if the user is authenticated and exists in Firestore
  // If the user is not authenticated or does not exist, returns null
  Future<AppUser?> getUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(doc);
  }

  /// Get a stream of member IDs for a specific circle
  Stream<List<String>> getCircleMembers(String circleId) {
    return _firestore
        .collection('alarmCircles')
        .doc(circleId)
        .snapshots()
        .map((doc) => List<String>.from(doc.data()?['memberIds'] ?? []));
  }
}
