import 'package:circle_up/photos/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/alarm_circle.dart';
import '../services/alarm_circle_service.dart';
import '../services/user_service.dart';
import 'photo_gallery.dart';
import '../models/user.dart';

class CirclePage extends StatefulWidget {
  final AlarmCircle circle;
  // final AlarmCircleService _circleService = AlarmCircleService();
  // final UserService _userService = UserService();
  const CirclePage({super.key, required this.circle});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  final AlarmCircleService _circleService = AlarmCircleService();
  final UserService _userService = UserService();
  late Future<List<AppUser>> _membersFuture;

  String _formatDateTime(DateTime dateTime) {
    final hour =
        dateTime.hour == 0
            ? 12
            : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _leaveCircle(BuildContext context) async {
    try {
      await _circleService.leaveCircle(widget.circle.id);
      await _userService.leaveGroup();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/noGroup');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving circle: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the members future
    _membersFuture = _userService.getUsersByIds(widget.circle.memberIds);
  }

  @override
  Widget build(BuildContext context) {
    final circle = widget.circle;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.camera),
            tooltip: 'Upload Photo',
            onPressed: () {
              Navigator.pushNamed(context, '/photo');
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            tooltip: 'View Photos',
            onPressed: () async {
              // Navigate to the photo gallery page
              // 1) Fetch photos from the circle
              try {
                final photos = await getCirclePhotos(circle.memberIds);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoGallery(photos: photos),
                    ),
                  );
                }
                // Need to display the photos when this is clicked
              } catch (e) {
                //print('Error fetching photos: $e');
              }
            },
          ),
        ],
        title: const Text('Circle Details'),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Code Section
              const Text(
                'Circle Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      circle.code,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: circle.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Circle code copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Alarm Time Section
              const Text(
                'Alarm Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      _formatDateTime(circle.alarmTime),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Members Section
              const Text(
                'Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: FutureBuilder<List<AppUser>>(
                  future: _membersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading members');
                    }
                    final members = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${members.length} members',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...members.map(
                          (user) => ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.displayName ?? user.email),
                            subtitle: Text(
                              '${user.numSuccess} successes / ${user.numFailure} failures',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),
              // Leave Circle Button
              Center(
                child: ElevatedButton(
                  onPressed: () => _leaveCircle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Leave Circle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
