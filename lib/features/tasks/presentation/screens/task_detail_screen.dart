import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../data/task.dart';
import '../../data/task_repository.dart' show maxDepth;
import '../providers/task_provider.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';
import 'note_screen.dart';

String? _richNotesPreview(String? richNotes) {
  if (richNotes == null) return null;
  try {
    final text = Document.fromJson(jsonDecode(richNotes) as List).toPlainText().trim();
    return text.isEmpty ? null : text;
  } catch (_) {
    return null;
  }
}

/// Shows one task's title, notes, and its children. Pushing into a child
/// re-uses this same screen at depth+1 — that's the "tree" navigation.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task, required this.depth});

  final Task task;
  final int depth;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.task.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild on any provider change; task fields mutate in place so the
    // same object reference always reflects current state.
    context.watch<TaskProvider>();
    final task = widget.task;
    final canAddChild = widget.depth < maxDepth;

    return AppScaffold(
      appBar: AppBar(title: Text(task.title, overflow: TextOverflow.ellipsis)),
      floatingActionButton: canAddChild
          ? FloatingActionButton.extended(
              onPressed: () => showAddTaskSheet(
                context,
                title: 'New subtask',
                onSubmit: (title, notes) =>
                    context.read<TaskProvider>().addChild(task.id, title, notes: notes),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Subtask'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Row(
            children: [
              Checkbox(
                value: task.done,
                onChanged: (_) => context.read<TaskProvider>().toggleDone(task.id),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey('title-${task.id}'),
                  initialValue: task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  decoration: const InputDecoration(border: InputBorder.none),
                  onFieldSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      context.read<TaskProvider>().updateTitle(task.id, v.trim());
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
            minLines: 3,
            maxLines: 8,
            onChanged: (v) => context.read<TaskProvider>().updateNotes(task.id, v),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NoteScreen(
                  task: task,
                  initialMode: task.richNotes == null && task.drawingPath != null ? NoteMode.draw : NoteMode.write,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_note),
            label: Text(task.richNotes == null && task.drawingPath == null ? 'Add note' : 'Edit note'),
          ),
          if (task.drawingPath != null) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(task.drawingPath!),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton.filled(
                    onPressed: () => context.read<TaskProvider>().setDrawing(task.id, null),
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Remove drawing',
                  ),
                ),
              ],
            ),
          ],
          if (_richNotesPreview(task.richNotes) case final preview?) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(preview, maxLines: 4, overflow: TextOverflow.ellipsis),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton.filled(
                    onPressed: () => context.read<TaskProvider>().setRichNotes(task.id, null),
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Remove rich note',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          if (task.children.isNotEmpty) ...[
            Text('Subtasks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...task.children.map(
              (child) => Dismissible(
                key: ValueKey(child.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.only(right: 16),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
                onDismissed: (_) => context.read<TaskProvider>().deleteTask(child.id),
                child: TaskTile(
                  task: child,
                  onToggle: () => context.read<TaskProvider>().toggleDone(child.id),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(task: child, depth: widget.depth + 1),
                    ),
                  ),
                ),
              ),
            ),
          ] else
            Text(
              canAddChild ? 'No subtasks yet' : 'Max nesting depth reached',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
        ],
      ),
    );
  }
}
