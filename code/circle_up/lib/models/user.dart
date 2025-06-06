import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents a user in the application.
/// This model stores user information including authentication details,
/// profile information, and alarm-related data.
class AppUser {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// User's display name (optional)
  final String? displayName;

  /// URL to user's profile photo (optional)
  final String? photoUrl;

  /// When the user account was created
  final DateTime createdAt;

  /// When the user last logged in
  final DateTime lastLoginAt;

  /// User's personal alarm time setting (optional)
  final DateTime? personalAlarmTime;

  /// Whether the user is currently in a group
  final bool isInGroup;

  /// Code of the group the user is in (if any)
  final String? groupCode;

  /// Firebase Authentication UID for the user
  final uid = FirebaseAuth.instance.currentUser?.uid;

  /// Number of successful alarm completions
  final int numSuccess;

  /// Number of failed alarm attempts
  final int numFailure;

  /// Creates an AppUser instance
  ///
  /// [id] is required and must be unique
  /// [email] is required and must be valid
  /// [createdAt] is required and sets account creation time
  /// [lastLoginAt] is required and tracks last login
  /// [displayName], [photoUrl], [personalAlarmTime] are optional
  /// [isInGroup] defaults to false if not specified
  /// [groupCode] is optional and only set when user is in a group
  /// [numSuccess] and [numFailure] default to 0 if not specified
  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.personalAlarmTime,
    this.isInGroup = false,
    this.groupCode,
    this.numSuccess = 0,
    this.numFailure = 0,
  });

  // Convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'personalAlarmTime': personalAlarmTime != null ? Timestamp.fromDate(personalAlarmTime!) : null,
      'isInGroup': isInGroup,
      'groupCode': groupCode,
      'numSuccess': numSuccess,
      'numFailure': numFailure,
    };
  }

  // Create AppUser from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      personalAlarmTime: data['personalAlarmTime'] != null ? (data['personalAlarmTime'] as Timestamp).toDate() : null,
      isInGroup: data['isInGroup'] ?? false,
      groupCode: data['groupCode'],
      numSuccess: data['numSuccess'] ?? 0,
      numFailure: data['numFailure'] ?? 0,
    );
  }
}