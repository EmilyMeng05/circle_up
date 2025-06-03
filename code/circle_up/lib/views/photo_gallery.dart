// This will be the place where the photo gallery will be displayed
import 'package:flutter/material.dart';
import '../photos/photo.dart';

class PhotoGallery extends StatelessWidget {
  final List<Photo> photos;

  const PhotoGallery({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body:
          photos.isEmpty
              ? const Center(child: Text('No photos available'))
              : Expanded(
                child: ListView.builder(
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(photo.downloadUrl, fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              photo.fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
