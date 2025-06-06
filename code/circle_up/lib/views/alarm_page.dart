import 'dart:async';
import 'package:flutter/material.dart';

/// This page checks the time, and once it matches the alarm time,
/// it shows an alarm message and navigates to the photo upload page.
class AlarmPage extends StatefulWidget {
  /// the target alarm time the app should wait for
  final DateTime alarmTime;
  /// the constructor for this class
  /// Parameters: 
  /// - alarmTime: the time at which the alarm should trigger
  const AlarmPage({super.key, required this.alarmTime});

  /// creates the mutable state for this widget
  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

/// This class is responsible for tracking whether the alarm
/// has been triggered and managed the timer to check the current time
class _AlarmPageState extends State<AlarmPage> {
  late Timer _timer;
  bool _alarmTriggered = false;

  /// initializes the timer to begin checking the current time vs. the alarm time
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

  // Clean up timer when widget is disposed
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// The build method that creates the alarm page widget
  /// before alarm triggers, shows a waiting message
  /// once triggered, shows a redthemed alarm page with instructions to stop the alar,
  /// Returns: 
  /// - returns a semantic label that contains the alarm widget
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
