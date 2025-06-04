import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/user_service.dart';

/// AlarmPage - Waits until [alarmTime], triggers sound/vibration,
/// allows skipping within 2 minutes to count as success, otherwise counts as failure.
class AlarmPage extends StatefulWidget {
  final DateTime alarmTime;

  const AlarmPage({super.key, required this.alarmTime});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final UserService _userService = UserService();

  Timer? _checkTimer;
  Timer? _failureTimer;

  bool _alarmTriggered = false;
  bool _skipped = false;

  @override
  void initState() {
    super.initState();
    _watchForAlarmTime();
  }

  /// Watches the clock and triggers alarm when the time matches.
  void _watchForAlarmTime() {
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final target = widget.alarmTime;

      if (!_alarmTriggered && now.hour == target.hour && now.minute == target.minute) {
        _triggerAlarm();
        timer.cancel();
      }
    });
  }

  /// Triggers sound, vibration, and starts failure countdown.
  Future<void> _triggerAlarm() async {
    setState(() => _alarmTriggered = true);

    // Vibration support
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }

    // Start alarm sound in loop
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('alarm.mp3'));

    // If user doesn't skip in 2 minutes, mark failure
    _failureTimer = Timer(const Duration(minutes: 2), () async {
      if (!_skipped) {
        await _userService.incrementFailure();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/uploadPhoto');
        }
      }
    });
  }

  /// Handles Skip button tap
  Future<void> _handleSkip() async {
    _skipped = true;
    await _audioPlayer.stop();
    _failureTimer?.cancel();
    await _userService.incrementSuccess();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/uploadPhoto');
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _failureTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _alarmTriggered ? Colors.red[100] : Colors.grey[200],
      body: Center(
        child: _alarmTriggered
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.alarm, size: 150, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text('ALARM!', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('Get ready to upload your morning selfie!'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _handleSkip,
                    child: const Text('Skip'),
                  )
                ],
              )
            : const Text(
                'Waiting for alarm time...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
      ),
    );
  }
}
