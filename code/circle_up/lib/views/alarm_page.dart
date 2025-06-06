import 'dart:async';
import 'package:flutter/material.dart';

/// This page checks the time, and once it matches the alarm time,
/// it shows an alarm message and navigates to the photo upload page.
class AlarmPage extends StatefulWidget {
  final DateTime alarmTime;

  const AlarmPage({super.key, required this.alarmTime});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late Timer _timer;
  bool _alarmTriggered = false;

  @override
  void initState() {
    super.initState();
    _checkAlarm();
  }

  /// Starts a timer that checks every second if it's time to trigger the alarm
  void _checkAlarm() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final alarm = widget.alarmTime;

      if (!_alarmTriggered && now.hour == alarm.hour && now.minute == alarm.minute) {
        setState(() {
          _alarmTriggered = true;
        });

        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/uploadPhoto');
          }
        });

        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // Clean up timer when widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _alarmTriggered
          ? 'Alarm triggered page. Time to upload your morning selfie.'
          : 'Alarm page. Waiting for alarm time.',
      child: Scaffold(
        backgroundColor: _alarmTriggered ? Colors.red[100] : Colors.grey[200],
        body: Center(
          child: _alarmTriggered
              ? Semantics(
                  label: 'Alarm triggered. Time to upload your morning selfie.',
                  liveRegion: true,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        label: 'Alarm icon',
                        child: Icon(Icons.alarm, size: 150, color: Colors.red[900]),
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: 'Alarm!',
                        child: Text(
                          'ALARM!',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        label: 'Get ready to upload your morning selfie!',
                        child: Text('Get ready to upload your morning selfie!'),
                      ),
                    ],
                  ),
                )
              : Semantics(
                  label: 'Waiting for alarm time.',
                  liveRegion: true,
                  child: Text(
                    'Waiting for alarm time...',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                ),
        ),
      ),
    );
  }
}
