import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alarm_circle.dart';
import '../models/circle_post.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/alarm_scheduler_service.dart';
import '../services/alarm_circle_service.dart';
import '../services/user_service.dart';

class CircleFeedView extends StatefulWidget {
  final AlarmCircle circle;

  const CircleFeedView({
    super.key,
    required this.circle,
  });

  @override
  State<CircleFeedView> createState() => _CircleFeedViewState();
}

class _CircleFeedViewState extends State<CircleFeedView> {
  final _storageService = StorageService();
  final _alarmSchedulerService = AlarmSchedulerService();
  final _alarmCircleService = AlarmCircleService();
  final _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  File? _selectedPhoto;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedPhoto == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Get the current prompt
      final currentPrompt = await _alarmSchedulerService.getCurrentPrompt(widget.circle.id);
      if (currentPrompt == null) {
        throw Exception('No active prompt found');
      }

      // Upload the photo to Firebase Storage
      final photoUrl = await _storageService.uploadPhoto(_selectedPhoto!, widget.circle.id);

      // Create the post in Firestore
      await _alarmCircleService.createPost(
        widget.circle.id,
        currentPrompt,
        photoUrl,
        caption: _captionController.text,
      );

      // Handle the photo submission (check if all members have submitted)
      await _alarmSchedulerService.handlePhotoSubmission(widget.circle.id, currentPrompt);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!')),
        );
        Navigator.of(context).pop(); // Close the upload dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedPhoto = null;
          _captionController.clear();
        });
      }
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Photo'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedPhoto != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedPhoto!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickImage,
                icon: const Icon(Icons.photo_library),
                label: Text(_selectedPhoto == null ? 'Select Photo' : 'Change Photo'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isUploading || _selectedPhoto == null ? null : _uploadPhoto,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Feed'),
      ),
      body: StreamBuilder<String?>(
        stream: _alarmSchedulerService.getCurrentPrompt(widget.circle.id).asStream(),
        builder: (context, promptSnapshot) {
          if (promptSnapshot.hasError) {
            return Center(child: Text('Error: ${promptSnapshot.error}'));
          }

          if (!promptSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final prompt = promptSnapshot.data ?? 'Share your morning routine!';

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Today\'s Prompt: $prompt',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<CirclePost>>(
                  stream: _alarmCircleService.getCirclePosts(widget.circle.id),
                  builder: (context, postsSnapshot) {
                    if (postsSnapshot.hasError) {
                      return Center(child: Text('Error: ${postsSnapshot.error}'));
                    }

                    if (!postsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = postsSnapshot.data!;

                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('No photos shared yet. Be the first to share!'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return FutureBuilder<AppUser?>(
                          future: _userService.getUserById(post.userId),
                          builder: (context, userSnapshot) {
                            final userName = userSnapshot.data?.displayName ?? 'Anonymous';
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    post.photoUrl,
                                    height: 300,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  if (post.caption != null && post.caption!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        post.caption!,
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          child: Icon(Icons.person),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          userName,
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatTimestamp(post.createdAt),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}