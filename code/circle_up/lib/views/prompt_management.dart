import 'package:flutter/material.dart';
import '../models/alarm_circle.dart';
import '../models/circle_prompt.dart';
import '../services/alarm_scheduler_service.dart';

class PromptManagementView extends StatefulWidget {
  final AlarmCircle circle;

  const PromptManagementView({
    super.key,
    required this.circle,
  });

  @override
  State<PromptManagementView> createState() => _PromptManagementViewState();
}

class _PromptManagementViewState extends State<PromptManagementView> {
  final _promptController = TextEditingController();
  final _schedulerService = AlarmSchedulerService();
  bool _isCreating = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _createPrompt() async {
    if (_promptController.text.isEmpty) return;

    setState(() => _isCreating = true);

    try {
      await _schedulerService.createPrompt(
        widget.circle.id,
        _promptController.text,
      );

      if (mounted) {
        _promptController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Prompts'),
      ),
      body: Column(
        children: [
          // Create Prompt Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _promptController,
                  decoration: const InputDecoration(
                    labelText: 'New Prompt',
                    hintText: 'Enter a prompt for the circle',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createPrompt,
                  child: _isCreating
                      ? const CircularProgressIndicator()
                      : const Text('Create Prompt'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Current Prompt
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Prompt',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                FutureBuilder<CirclePrompt?>(
                  future: _schedulerService.getCurrentPrompt(widget.circle.id),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final prompt = snapshot.data;
                    if (prompt == null) {
                      return const Text('No active prompt');
                    }

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prompt.prompt),
                            const SizedBox(height: 8),
                            Text(
                              'Created on ${prompt.date.toString()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}