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
    _membersFuture = _userService.getUsersByIds(widget.circle.memberIds);
  }

  @override
  Widget build(BuildContext context) {
    final circle = widget.circle;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: _buildAppBar(circle),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Circle Code'),
              const SizedBox(height: 10),
              _buildCircleCodeBox(circle),
              const SizedBox(height: 40),
              _buildSectionHeader('Alarm Time'),
              const SizedBox(height: 10),
              _buildAlarmTimeBox(circle),
              const SizedBox(height: 40),
              _buildSectionHeader('Members'),
              const SizedBox(height: 10),
              _buildMembersBox(),
              const Spacer(),
              _buildLeaveButton(context),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(AlarmCircle circle) {
    return AppBar(
      actions: [
        Semantics(
          label: 'Upload Photo',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.camera),
            tooltip: 'Upload Photo',
            onPressed: () {
              Navigator.pushNamed(context, '/photo');
            },
          ),
        ),
        Semantics(
          label: 'View Photos',
          button: true,
          child: IconButton(
            icon: const Icon(Icons.photo),
            tooltip: 'View Photos',
            onPressed: () async {
              try {
                final photos = await getCirclePhotos(circle.memberIds);
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhotoGallery(photos: photos),
                  ),
                );
              } catch (e) {
                debugPrint('Error loading photos: $e');
              }
            },
          ),
        ),
      ],
      title: Semantics(
        header: true,
        child: Text('Circle Details'),
      ),
      backgroundColor: Colors.grey[300],
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCircleCodeBox(AlarmCircle circle) {
    return Semantics(
      label: 'Circle code is ${circle.code}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: 'Circle code text',
              child: Text(
                circle.code,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            Semantics(
              label: 'Copy circle code',
              button: true,
              child: IconButton(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmTimeBox(AlarmCircle circle) {
    return Semantics(
      label: 'Alarm time is ${_formatDateTime(circle.alarmTime)}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 24, semanticLabel: 'Alarm time icon'),
            const SizedBox(width: 10),
            Semantics(
              label: 'Formatted alarm time',
              child: Text(
                _formatDateTime(circle.alarmTime),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersBox() {
    return Semantics(
      label: 'Circle members list',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration(),
        child: FutureBuilder<List<AppUser>>(
          future: _membersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Text('Error loading members');
            }
            final members = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: '${members.length} members total',
                  child: Text(
                    '${members.length} members',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...members.map(
                  (user) => Semantics(
                    label:
                        '${user.displayName ?? user.email}, ${user.numSuccess} successes, ${user.numFailure} failures',
                    child: ListTile(
                      leading: const Icon(Icons.person, semanticLabel: 'Member icon'),
                      title: Text(user.displayName ?? user.email),
                      subtitle: Text(
                        '${user.numSuccess} successes / ${user.numFailure} failures',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeaveButton(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Leave Circle',
        button: true,
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
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: const Color.fromRGBO(158, 158, 158, 0.2),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}