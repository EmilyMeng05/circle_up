// Handles the upload of photos to the server

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:circle_up/components/navbar.dart';
import 'package:circle_up/components/enter_button.dart';

class UploadPhotos extends StatefulWidget {
  const UploadPhotos({super.key});

  @override
  _UploadPhotosState createState() => _UploadPhotosState();
}

class _UploadPhotosState extends State<UploadPhotos> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        //print('No image selected.');
      }
    });
  }

  Future<void> _uploadFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        //print('No image selected.');
      }
    });
  }

  Future<void> _uploadPhoto() async {
if (_photo == null) return;
    final fileName = basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
    } catch (e) {
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text('Upload Photos'), 
      backgroundColor: Colors.grey[300],),
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
            EnterButton(
              onTap: _uploadPhoto,
              text: 'Upload Photo',
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBarExampleApp(),
    );
  }
}
