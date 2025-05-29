// // This will contain the class for the photo object that will be used in the application
// // Contains all of the methods to insert the photo into the database

// //import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:io';
// import 'package:path/path.dart';

// class Photo {

//   // Function to upload a photo to the firebase storage
//   Future<void> uploadPhoto(File? photo) async {
//     if (photo == null) {
//       return;
//     }

//     final fileName = basename(photo.path);
//     final destination = 'photos/$fileName';
//     try {
//       final ref = firebase_storage.FirebaseStorage.instance
//           .ref(destination)
//           .child('file/');
//       await ref.putFile(_photo!);
//     } catch (e) {
//       print('error occured');
//     }
//   }

//   // Function to retrieve the photo from the firebase storage
//   // Retrieve 
// }