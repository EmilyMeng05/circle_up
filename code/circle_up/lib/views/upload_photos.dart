// Handles the upload of photos to the server
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:circle_up/photos/photo.dart';
import 'package:circle_up/components/enter_button.dart';

/*
 * Represents the class that handles uploading user photos as a StatefulWidget.
 * This widget allows users to select photos from their gallery or take new photos with the camera.
 * It provides functionality to undo and redo photo selections, and upload the selected photo to Firebase Storage.
*/
class UploadPhotos extends StatefulWidget {
  const UploadPhotos({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadPhotosState createState() => _UploadPhotosState();
}

/// State for the upload photos page.
/// Handles the selection and upload of photos from the gallery or camera.
class _UploadPhotosState extends State<UploadPhotos> {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  final List<File> _undoPhotos = [];
  final List<File> _redoPhotos = [];

  /// Selects a photo from the gallery.
  Future<void> _selectPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
      _undoPhotos.add(_photo!);
    }
  }

  /// Uploads a photo from the camera.
  Future<void> _uploadFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
      _undoPhotos.add(_photo!);
    }
  }

  /// Uploads a photo from the gallery.
  Future<void> _uploadPhoto() async {
    if (_photo == null) return;
    final result = await Photo.uploadPhoto(_photo);
    if (result != null) {
      setState(() => _photo = null);
    }
  }

  /// Undo the last photo selection.
  void undoPhoto() {
    if (_undoPhotos.isNotEmpty) {
      setState(() {
        final removedPhoto = _undoPhotos.removeLast();
        _redoPhotos.add(removedPhoto);
        _photo = _undoPhotos.isNotEmpty ? _undoPhotos.last : null;
      });
    }
  }

  /// Redo the last photo selection.
  void redoPhoto() {
    if (_redoPhotos.isNotEmpty) {
      setState(() {
        final restoredPhoto = _redoPhotos.removeLast();
        _undoPhotos.add(restoredPhoto);
        _photo = restoredPhoto;
      });
    }
  }

  /// Builds the main page for the upload photos page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Photos'),
        actions: [
          Semantics(
            label: 'Undo last photo selection',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.undo),
              tooltip: 'Undo',
              onPressed: undoPhoto,
            ),
          ),
          Semantics(
            label: 'Redo photo selection',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.redo),
              tooltip: 'Redo',
              onPressed: redoPhoto,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Displays the selected photo or a placeholder if no photo is selected
            Semantics(
              label: _photo == null
                  ? 'No image selected'
                  : 'Selected image preview',
              image: true,
              child: _photo == null
                  ? const Text('No image selected.')
                  : Image.file(
                      _photo!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),
            // Button to select a photo from the gallery
            Semantics(
              label: 'Select photo from gallery',
              button: true,
              child: EnterButton(
                onTap: _selectPhoto,
                text: 'Select Photo from Gallery',
              ),
            ),
            const SizedBox(height: 20),
            // Button to take a photo with the camera
            Semantics(
              label: 'Take photo with camera',
              button: true,
              child: EnterButton(
                onTap: _uploadFromCamera,
                text: 'Take Photo with Camera',
              ),
            ),
            const SizedBox(height: 20),
            // If there is a photo selected, displays the upload button
            // On click, uploads the photo to Firebase Storage
            if (_photo != null)
              Semantics(
                label: 'Upload selected photo',
                button: true,
                child: EnterButton(
                  onTap: _uploadPhoto,
                  text: 'Upload Selected Photo',
                ),
              ),
          ],
        ),
      ),
    );
  }
}