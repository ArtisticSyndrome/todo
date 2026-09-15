import 'package:flutter/material.dart';

/// Bottom sheet for a new task/subtask. Slides up with the platform's
/// native spring-like sheet transition — no custom animation needed.
Future<void> showAddTaskSheet(
  BuildContext context, {
  required String title,
  required void Function(String title, String notes) onSubmit,
}) {
  final titleController = TextEditingController();
  final notesController = TextEditingController();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final text = titleController.text.trim();
              if (text.isEmpty) return;
              onSubmit(text, notesController.text.trim());
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Add'),
            ),
          ),
        ],
      ),
    ),
  );
}
