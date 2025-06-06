import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/alarm_circle.dart';
import '../services/alarm_circle_service.dart';
import '../services/user_service.dart';
import 'upload_photos.dart';
import 'alarm_page.dart';

/// Page that displays the details of an alarm circle.
/// Shows circle information, member list, and provides options to leave the circle.
class CirclePage extends StatefulWidget {
  final AlarmCircle circle;
  const CirclePage({super.key, required this.circle});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  final AlarmCircleService _circleService = AlarmCircleService();
  final UserService _userService = UserService();
  late Timer _timer;

  /// Format alarm time for display
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  /// Starts a timer to check if it's time to show the alarm.
  /// If it's time, it navigates to the alarm page.
  void _startAlarmWatcher() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final now = DateTime.now();
      final alarm = widget.circle.alarmTime;

      if (now.hour == alarm.hour && now.minute == alarm.minute) {
        _timer.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AlarmPage(alarmTime: widget.circle.alarmTime),
            ),
          );
        }
      }
    });
  }

  /// Handles the logic for a user leaving their alarm circle.
  /// Makes API calls to remove user from circle and update their group status.
  /// Navigates to no group page on success, shows error message on failure.
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
    _startAlarmWatcher();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circle = widget.circle;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
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
              const Text('Circle Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(circle.code, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: circle.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Circle code copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Alarm Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 10),
                    Text(_formatDateTime(circle.alarmTime), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text('Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${circle.memberIds.length} members', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    ...circle.memberIds.map((member) => ListTile(leading: const Icon(Icons.person), title: Text(member))),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () => _leaveCircle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Leave Circle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}