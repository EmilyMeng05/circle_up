import 'package:cloud_firestore/cloud_firestore.dart';

class CirclePrompt {
  final String id;
  final String circleId;
  final String prompt;
  final DateTime date;
  final bool isActive;

  CirclePrompt({
    required this.id,
    required this.circleId,
    required this.prompt,
    required this.date,
    this.isActive = true,
  });

  factory CirclePrompt.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CirclePrompt(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      prompt: data['prompt'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'prompt': prompt,
      'date': Timestamp.fromDate(date),
      'isActive': isActive,
    };
  }
}