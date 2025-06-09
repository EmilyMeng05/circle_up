import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alarm_circle.dart';
import '../models/circle_prompt.dart';
import '../services/notification_service.dart';

class AlarmSchedulerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  /// Schedule alarms for all members of a circle
  Future<void> scheduleCircleAlarms(AlarmCircle circle) async {
    try {
      // Get the current prompt for the circle
      final promptDoc = await _firestore
          .collection('circles')
          .doc(circle.id)
          .collection('prompts')
          .where('isActive', isEqualTo: true)
          .get();

      String prompt = 'Share your morning routine!';
      if (promptDoc.docs.isNotEmpty) {
        prompt = promptDoc.docs.first.data()['text'] as String;
      }

      // Schedule the alarm notification
      await _notificationService.scheduleAlarm(
        circleId: circle.id,
        circleName: circle.name,
        alarmTime: circle.alarmTime,
        prompt: prompt,
      );

      // Update the last scheduled time in Firestore
      await _firestore.collection('circles').doc(circle.id).update({
        'lastScheduled': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error scheduling alarms: $e');
      rethrow;
    }
  }

  /// Create a new prompt for a circle
  Future<void> createPrompt(String circleId, String prompt) async {
    try {
      // Deactivate any existing active prompts
      final activePrompts = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('prompts')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in activePrompts.docs) {
        await doc.reference.update({'isActive': false});
      }

      // Create the new prompt
      await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('prompts')
          .add({
        'text': prompt,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      print('Error creating prompt: $e');
      rethrow;
    }
  }

  /// Get the current active prompt for a circle
  Future<String?> getCurrentPrompt(String circleId) async {
    try {
      final promptDoc = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('prompts')
          .where('isActive', isEqualTo: true)
          .get();

      if (promptDoc.docs.isEmpty) {
        return null;
      }

      return promptDoc.docs.first.data()['text'] as String;
    } catch (e) {
      print('Error getting current prompt: $e');
      rethrow;
    }
  }

  /// Deactivate a prompt
  Future<void> deactivatePrompt(String promptId) async {
    try {
      await _firestore
          .collection('prompts')
          .doc(promptId)
          .update({'isActive': false});
    } catch (e) {
      print('Error deactivating prompt: $e');
      rethrow;
    }
  }

  /// Check if all members have submitted photos for the current prompt
  Future<bool> areAllPhotosSubmitted(String circleId, String promptId) async {
    try {
      final members = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('members')
          .get();

      final submissions = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('posts')
          .where('promptId', isEqualTo: promptId)
          .get();

      return submissions.docs.length >= members.docs.length;
    } catch (e) {
      print('Error checking photo submissions: $e');
      rethrow;
    }
  }

  /// Handle alarm dismissal when a photo is submitted
  Future<void> handlePhotoSubmission(String circleId, String promptId) async {
    try {
      final allSubmitted = await areAllPhotosSubmitted(circleId, promptId);
      if (allSubmitted) {
        // Deactivate the current prompt
        await deactivatePrompt(promptId);

        // Get the circle details
        final circleDoc = await _firestore.collection('circles').doc(circleId).get();
        final circle = AlarmCircle.fromFirestore(circleDoc);

        // Schedule the next day's alarm
        await scheduleCircleAlarms(circle);
      }
    } catch (e) {
      print('Error handling photo submission: $e');
      rethrow;
    }
  }
}