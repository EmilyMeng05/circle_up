import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../components/enter_button.dart';

/// A page that allows users to set and manage their personal alarm time.
class PersonalAlarmPage extends StatefulWidget {
  /// constructor for the class
  const PersonalAlarmPage({super.key});

  @override
  State<PersonalAlarmPage> createState() => _PersonalAlarmPageState();
}

/// State for the personal alarm page.
/// Handles loading and saving the user's personal alarm time.
class _PersonalAlarmPageState extends State<PersonalAlarmPage> {
  final UserService _userService = UserService();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentAlarmTime();
  }

  /// Loads the user's current alarm time from the database.
  Future<void> _loadCurrentAlarmTime() async {
    final currentAlarmTime = await _userService.getPersonalAlarmTime();
    if (currentAlarmTime != null) {
      setState(() {
        _selectedTime = TimeOfDay(
          hour: currentAlarmTime.hour,
          minute: currentAlarmTime.minute,
        );
      });
    }
  }

  /// Opens a time picker dialog to allow the user to select a new alarm time.
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Formats a TimeOfDay object into a readable time string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Saves the user's selected alarm time to the database.
  Future<void> _saveAlarmTime() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final alarmTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _userService.setPersonalAlarmTime(alarmTime);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal alarm time saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Builds the main page for the personal alarm page.
  /// Returns: 
  /// - a semantic label that contains the following: 
  /// a header and instruction text for how to set up the alarm
  /// a time display box that opens the time picker
  /// a button to save the selected time 
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Personal Alarm Settings Page',
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text('Personal Alarm'),
          backgroundColor: Colors.grey[300],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: const Text(
                  'Set Your Personal Alarm',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              Semantics(
                header: true,
                child: const Text(
                  'Alarm Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Selected alarm time is ${_formatTimeOfDay(_selectedTime)}',
                button: true,
                onTapHint: 'Tap to select alarm time',
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
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
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 24, semanticLabel: 'Alarm time icon'),
                            const SizedBox(width: 10),
                            Text(
                              _formatTimeOfDay(_selectedTime),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, semanticLabel: 'Tap to change time'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Semantics(
                label: 'Save alarm time',
                button: true,
                enabled: !_isLoading,
                child: EnterButton(
                  onTap: _isLoading ? null : _saveAlarmTime,
                  text: _isLoading ? 'Saving...' : 'Save Alarm Time',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}