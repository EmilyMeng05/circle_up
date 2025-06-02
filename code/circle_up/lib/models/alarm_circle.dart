import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmCircle {
  final String id;
  final String code;
  final DateTime alarmTime;
  final List<String> memberIds;
  final String creatorId;
  final bool isActive;

  AlarmCircle({
    required this.id,
    required this.code,
    required this.alarmTime,
    required this.memberIds,
    required this.creatorId,
    this.isActive = true,
  });

  // Convert AlarmCircle to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'alarmTime': Timestamp.fromDate(alarmTime),
      'memberIds': memberIds,
      'creatorId': creatorId,
      'isActive': isActive,
    };
  }

  // Create AlarmCircle from Firestore document
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