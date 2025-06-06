import 'package:flutter/material.dart';
import '../photos/photo.dart';

/// A widget that displays a gallery of photos with swipe navigation.
class PhotoGallery extends StatefulWidget {
  final List<Photo> photos;

  const PhotoGallery({super.key, required this.photos});

  @override
  // ignore: library_private_types_in_public_api
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

/// State for the photo gallery page.
/// Handles the display and navigation of photos in a gallery.
class _PhotoGalleryState extends State<PhotoGallery> {
  int curIdx = 0;
  double dragAmount = 0.0;

  /// Handles the update of the photo gallery when the user drags the photo.
  void _onPanUpdate(DragUpdateDetails details) {
    dragAmount += details.delta.dx;
  }

  /// Handles the end of the drag operation on the photo gallery.
  /// If the drag amount exceeds the fixed threshold of 100, we count this as a proper swipe
  /// Based on the direction of the swipe, update the current index of the photo being displayed
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

  /// Builds the UI for the photo gallery page
  /// If there are no photos in the gallery, displays a message to indicate no photos are available
  /// If there are photos, displays the current photo in a frame like structure, with gesture navigation (swipe left or right)
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Photo Gallery',
      child: Scaffold(
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
            : Semantics(
                label: 'Swipeable photo gallery with ${widget.photos.length} photos',
                child: GestureDetector(
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Displays the current photo in a frame-like structure
                        // On swipe, updates the current index to show the next or previous photo
                        Semantics(
                          label: 'Photo ${curIdx + 1} of ${widget.photos.length}. Swipe left or right to navigate.',
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
                            // Displays the current photo
                            child: Image.network(
                              widget.photos[curIdx].downloadUrl,
                              fit: BoxFit.cover,
                              width: 300,
                              height: 300,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          label: 'Navigation instructions',
                          child: Text(
                            'Swipe left or right to navigate',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}