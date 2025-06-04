// 1) In this page, have 1 button, that triggers a notification immediately
import 'package:flutter/material.dart';
import 'package:circle_up/services/notification_service.dart';

class NotifyTest extends StatelessWidget {
  const NotifyTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Trigger a notification immediately
                await NotificationService().showNotification(
                  title: 'Test Notification',
                  body: 'This is a test notification triggered immediately.',
                );
              },
              child: const Text('Trigger Notification'),
            ),
            ElevatedButton(
              onPressed: () async {
                // final now = DateTime.now();
                // final scheduledTime = now.add(const Duration(seconds: ));
                // Schedule a notification for 10 seconds later
                await NotificationService().scheduleNotification(
                  title: 'Scheduled Notification',
                  body: 'This notification is scheduled to appear in 10 seconds.',
                  hour: 14,
                  minute: 53,
                );
              },
              child: const Text('Schedule Notification for 10 seconds later'),
            ),
          ],
        ),
      ),
    );
  }
}