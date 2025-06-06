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
  ///
  /// [id] is required and must be unique
  /// [code] is required and used for joining the circle
  /// [alarmTime] is required and sets when the alarm triggers
  /// [memberIds] is required and contains all member user IDs
  /// [creatorId] is required and identifies the circle creator
  /// [isActive] defaults to true if not specified
  AlarmCircle({
    required this.id,
    required this.code,
    required this.alarmTime,
    required this.memberIds,
    required this.creatorId,
    this.isActive = true,
  });

  /// Converts the AlarmCircle instance to a Map for Firestore storage
  ///
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