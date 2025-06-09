import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload a photo to Firebase Storage
  /// Returns the download URL of the uploaded photo
  Future<String> uploadPhoto(File photo, String circleId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
    final ref = _storage.ref().child('circles/$circleId/photos/$fileName');

    try {
      final uploadTask = await ref.putFile(photo);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  /// Delete a photo from Firebase Storage
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }
}