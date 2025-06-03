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
  /// ** TODO: Check if a photo is being duplicated
  static Future<Photo?> uploadPhoto(File? photo) async {
    if (photo == null) return null;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) throw Exception("User not authenticated");
      // The user should be logged in before uploading a photo

      final fileName = basename(photo.path);
      final destination =
          'users/$uid/photos/$fileName'; // File path in Firebase Storage

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

    final snapshot =
        await FirebaseFirestore.instance
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

/// Retrieves photos from all members in a circle
Future<List<Photo>> getCirclePhotos(List<String> memberIds) async {
  if (memberIds.isEmpty) return [];
  print('Fetching photos for circle members: $memberIds');
  final List<Photo> photos = [];
  try {
    for (String memberId in memberIds) {
      // Get all photos for each member in the circle
      
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .collection('photos')
              .orderBy('uploadedAt', descending: true)
              .get();
      //if (snapshot.docs.isEmpty) continue;

      // For each photo, only add if its in the last 24 hours
      final now = Timestamp.now();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['uploadedAt'] == null) continue;
        final uploadedAt = data['uploadedAt'] as Timestamp;
        // Check if the photo was uploaded in the last 24 hours
        if (now.seconds - uploadedAt.seconds > 24 * 60 * 60) continue;
        photos.add(
          Photo(
            fileName: data['fileName'] ?? 'Unknown',
            downloadUrl: data['downloadUrl'] ?? '',
          ),
        );
      }
    }
  } catch (e) {
    print('Error retrieving circle photos: $e');
  }
  print('Retrieved ${photos.length} photos for circle members');
  return photos;
}
