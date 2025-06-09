import 'package:flutter/material.dart';
import 'package:circle_up/components/text_field.dart';
import 'package:circle_up/components/enter_button.dart';
import 'package:circle_up/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../services/alarm_circle_service.dart';
import 'circle_page.dart';
import '../services/notification_service.dart';

/*
 * Represetns the page displayed when the user is not part of the group as a stateful widget
 * If a user signs up, or they had left a group, this page will be displayed
*/
class NoGroupPage extends StatefulWidget {
  /// constructor for the class
  const NoGroupPage({super.key});

  @override
  State<NoGroupPage> createState() => _NoGroupPageState();
}

class _NoGroupPageState extends State<NoGroupPage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController circleCodeController = TextEditingController();
  final AlarmCircleService _circleService = AlarmCircleService();
  bool _isLoading = false;

  /// Formats a time of day into a string representation of time
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// This will open a time picker widget for the user to select an alarm time
  /// Based on the selected time, the value will be updated accordingly
  /// Thus, when the user creates a circle, the alarm time will be set to the selected time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  /// Creates a new alarm circle with the selected time.
  /// Schedules a notification for the circle alarm.
  /// Navigates to the circle page on success.
  Future<void> _createCircle() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final alarmTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
      final circle = await _circleService.createCircle(alarmTime);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Circle created! Code: ${circle.code}'), duration: const Duration(seconds: 5)),
      );
      NotificationService().scheduleAlarm(
        circleId: circle.id,
        circleName: circle.name,
        alarmTime: alarmTime,
        prompt: 'Time to share your morning routine!',
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CirclePage(circle: circle)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Joins an existing alarm circle with the provided code.
  /// Schedules a notification for the circle alarm.
  /// Navigates to the circle page on success.
  Future<void> _joinCircle() async {
    if (circleCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a circle code')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final circle = await _circleService.joinCircle(circleCodeController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully joined circle!')));
      NotificationService().scheduleAlarm(
        circleId: circle.id,
        circleName: circle.name,
        alarmTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, selectedTime.hour, selectedTime.minute),
        prompt: 'Time to share your morning routine!',
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CirclePage(circle: circle)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Builds the section for setting the alarm time.
  /// Displays the selected alarm time and provides a button to select a new time.
  Widget _buildAlarmTimeSection() {
    return Semantics(
      container: true,
      label: 'Set alarm time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Alarm Time',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTimeOfDay(selectedTime),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  onPressed: _isLoading ? null : () => _selectTime(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the section for creating and joining circles.
  /// Displays buttons to create a new circle and join an existing circle.
  Widget _buildCircleActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create New Circle',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        EnterButton(
          onTap: _isLoading ? null : _createCircle,
          text: 'Create New Circle',
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 40),
        Text(
          'Join Existing Circle',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: circleCodeController,
          hintText: 'Enter Circle Code',
          obscureText: false,
          prefixIcon: Icon(
            Icons.group_add,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        EnterButton(
          onTap: _isLoading ? null : _joinCircle,
          text: 'Join Circle',
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }

  /// Builds the main page for the no group page.
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Circle Up, ${user?.displayName ?? 'User'}! 👋',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s start your morning routine journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 40),
                _buildAlarmTimeSection(),
                const SizedBox(height: 40),
                _buildCircleActionsSection(),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}