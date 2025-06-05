// Handles the upload of photos to the server

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:circle_up/photos/photo.dart';
import 'package:circle_up/components/enter_button.dart';

class UploadPhotos extends StatefulWidget {
  const UploadPhotos({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadPhotosState createState() => _UploadPhotosState();
}

class _UploadPhotosState extends State<UploadPhotos> {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  // For undo and redo functionality (Can Undo and Redo the choice of photos)
  final List<File> _undoPhotos = [];
  final List<File> _redoPhotos = [];

  // Select a photo from the gallery
  Future<void> _selectPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
      // wait for user to confirm the upload
      // Add this to the undo stack
      _undoPhotos.add(_photo!);
      //await _uploadPhoto();
    } else {
      // print('No image selected.');
    }
  }

  // Take a photo using the camera
  Future<void> _uploadFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));

      /// wait for user to confirm 
      _undoPhotos.add(_photo!);
    } else {
      // print('No image selected.');
    }
  }


  // Upload the photo to Firebase and show success/failure message
  Future<void> _uploadPhoto() async {
    if (_photo == null) return;

    final result = await Photo.uploadPhoto(_photo);
    if (result != null) {
      // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      //   const SnackBar(content: Text('Photo uploaded successfully!')),
      // );
      setState(() => _photo = null); // Clear selected photo
    } else {
      // ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      //   const SnackBar(content: Text('Failed to upload photo.')),
      // );
    }
  }


  void undoPhoto() {
    if (_undoPhotos.isNotEmpty) {
      setState(() {
        final removedPhoto = _undoPhotos.removeLast();
        _redoPhotos.add(removedPhoto);
        _photo = _undoPhotos.isNotEmpty ? _undoPhotos.last : null;
      });
    }
  }

  void redoPhoto() {
    if (_redoPhotos.isNotEmpty) {
      setState(() {
        final restoredPhoto = _redoPhotos.removeLast();
        _undoPhotos.add(restoredPhoto);
        _photo = restoredPhoto;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: undoPhoto,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
            onPressed: redoPhoto,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _photo == null
                ? const Text('No image selected.')
                : Image.file(
                  _photo!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
            const SizedBox(height: 20),
            EnterButton(onTap: _selectPhoto, text: 'Select Photo from Gallery'),
            const SizedBox(height: 20),
            EnterButton(
              onTap: _uploadFromCamera,
              text: 'Take Photo with Camera',
            ),
            const SizedBox(height: 20),
            if (_photo != null)
              EnterButton(onTap: _uploadPhoto, text: 'Upload Selected Photo'),
          ],
        ),
      ),
    );
  }
}
