import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final DateTime? personalAlarmTime;
  final bool isInGroup;
  final String? groupCode;

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
    );
  }
}