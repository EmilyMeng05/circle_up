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
}