import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an alarm circle in the application.
/// An alarm circle is a group of users who share a common alarm time.
/// Each circle has a unique code for joining and tracks its members and creator.
class AlarmCircle {
  /// Unique identifier for the alarm circle
  final String id;
  /// Unique code used to join the circle
  final String code;
  /// The time when the alarm will trigger for all members
  final DateTime alarmTime;
  /// List of user IDs who are members of this circle
  final List<String> memberIds;
  /// ID of the user who created this circle
  final String creatorId;
  /// Whether the circle is currently active
  final bool isActive;

  /// Creates an AlarmCircle instance
  /// Parameters: 
  /// - id: the user id
  /// - code: the code for the circle group
  /// - alarmTime: sets when the alarm triggers
  /// - memberIds: list of all member user IDs in that group
  /// - creatorId: user ID of the creator of the group
  /// - isActive: whether the circle is active (defaults to true)
  AlarmCircle({
    required this.id,
    required this.code,
    required this.alarmTime,
    required this.memberIds,
    required this.creatorId,
    this.isActive = true,
  });

  /// Converts the AlarmCircle instance to a Map for Firestore storage
  /// Returns a Map containing all circle properties in Firestore-compatible format
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'alarmTime': Timestamp.fromDate(alarmTime),
      'memberIds': memberIds,
      'creatorId': creatorId,
      'isActive': isActive,
    };
  }

  /// Creates an AlarmCircle instance from a Firestore document
  /// Parameters: 
  /// - doc: a firestore document containing the data for the alarm circle
  /// Returns: 
  /// - an alarmcircle instance initialized from the doc fields 
  factory AlarmCircle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AlarmCircle(
      id: doc.id,
      code: data['code'] ?? '',
      alarmTime: (data['alarmTime'] as Timestamp).toDate(),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      creatorId: data['creatorId'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}