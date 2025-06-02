import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class Photo {
  final String fileName;
  final String downloadUrl;

  Photo({required this.fileName, required this.downloadUrl});

  /// Uploads photo and returns a Photo object
  static Future<Photo?> uploadPhoto(File? photo) async {
    if (photo == null) return null;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not authenticated");

      final fileName = basename(photo.path);
      final destination = 'users/$uid/photos/$fileName';

      final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
      await ref.putFile(photo);

      final downloadUrl = await ref.getDownloadURL();

      // Store metadata in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('photos')
          .add({
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': Timestamp.now(),
      });

      return Photo(fileName: fileName, downloadUrl: downloadUrl);
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }

  /// Retrieves all photo metadata for the current user
  static Future<List<Photo>> getUserPhotos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('photos')
        .orderBy('uploadedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Photo(
        fileName: data['fileName'] ?? 'Unknown',
        downloadUrl: data['downloadUrl'] ?? '',
      );
    }).toList();
  }
}
