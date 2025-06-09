import 'package:cloud_firestore/cloud_firestore.dart';

class CirclePost {
  final String id;
  final String circleId;
  final String userId;
  final String photoUrl;
  final String promptId;
  final DateTime createdAt;
  final String? caption;

  CirclePost({
    required this.id,
    required this.circleId,
    required this.userId,
    required this.photoUrl,
    required this.promptId,
    required this.createdAt,
    this.caption,
  });

  factory CirclePost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CirclePost(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      userId: data['userId'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      promptId: data['promptId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      caption: data['caption'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'circleId': circleId,
      'userId': userId,
      'photoUrl': photoUrl,
      'promptId': promptId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (caption != null) 'caption': caption,
    };
  }
}