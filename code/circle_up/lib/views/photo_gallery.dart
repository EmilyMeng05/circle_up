// This will be the place where the photo gallery will be displayed
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../photos/photo.dart';

class PhotoGallery extends StatefulWidget {
  final List<Photo> photos;

  const PhotoGallery({super.key, required this.photos});

  @override
  // ignore: library_private_types_in_public_api
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery>{
  //late AnimationController _controller;  TODO: For nice swipe effect add animation
  int curIdx = 0;
  double dragAmount = 0.0;

  // Updates the current index of the widget based on the swipe direction
  void _onPanUpdate(DragUpdateDetails details) {
    dragAmount += details.delta.dx;
  }

  void _onPanEnd(DragEndDetails details) {
    if (dragAmount.abs() > 100) {
      if (dragAmount > 0) {
        // Swiping right
        if (curIdx > 0) {
          setState(() {
            curIdx--;
          });
        }
      } else {
        // Swiping left
        if (curIdx < widget.photos.length - 1) {
          setState(() {
            curIdx++;
          });
        }
      }
    }
    dragAmount = 0.0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Photo Gallery'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body:
          widget.photos.isEmpty
              ? const Center(child: Text('No photos available'))
              : GestureDetector(
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          widget.photos[curIdx].downloadUrl,
                          fit: BoxFit.cover,
                          width: 300,
                          height: 300,
                        )
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }
}
