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
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  final List<File> _undoPhotos = [];
  final List<File> _redoPhotos = [];

  Future<void> _selectPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
      _undoPhotos.add(_photo!);
    }
  }

  Future<void> _uploadFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
      _undoPhotos.add(_photo!);
    }
  }

  Future<void> _uploadPhoto() async {
    if (_photo == null) return;
    final result = await Photo.uploadPhoto(_photo);
    if (result != null) {
      setState(() => _photo = null);
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
            Semantics(
              label: 'Select photo from gallery',
              button: true,
              child: EnterButton(
                onTap: _selectPhoto,
                text: 'Select Photo from Gallery',
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: 'Take photo with camera',
              button: true,
              child: EnterButton(
                onTap: _uploadFromCamera,
                text: 'Take Photo with Camera',
              ),
            ),
            const SizedBox(height: 20),
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