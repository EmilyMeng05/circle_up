import 'package:flutter/material.dart';
import '../photos/photo.dart';

class PhotoGallery extends StatefulWidget {
  final List<Photo> photos;

  const PhotoGallery({super.key, required this.photos});

  @override
  // ignore: library_private_types_in_public_api
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  int curIdx = 0;
  double dragAmount = 0.0;

  void _onPanUpdate(DragUpdateDetails details) {
    dragAmount += details.delta.dx;
  }

  void _onPanEnd(DragEndDetails details) {
    if (dragAmount.abs() > 100) {
      setState(() {
        if (dragAmount > 0 && curIdx > 0) {
          curIdx--;
        } else if (dragAmount < 0 && curIdx < widget.photos.length - 1) {
          curIdx++;
        }
      });
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
      body: widget.photos.isEmpty
          ? Center(
              child: Semantics(
                label: 'No photos available',
                child: Text('No photos available'),
              ),
            )
          : GestureDetector(
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Semantics(
                      label: 'Photo ${curIdx + 1} of ${widget.photos.length}',
                      image: true,
                      child: Container(
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}