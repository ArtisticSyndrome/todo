import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasks;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(
          context,
          title: 'New task',
          onSubmit: (title, notes) => context.read<TaskProvider>().addRoot(title, notes: notes),
        ),
        child: const Icon(Icons.add),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: tasks.isEmpty
            ? const _EmptyState(key: ValueKey('empty'))
            : ListView.builder(
                key: const ValueKey('list'),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Dismissible(
                    key: ValueKey(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    onDismissed: (_) => context.read<TaskProvider>().deleteTask(task.id),
                    child: TaskTile(
                      task: task,
                      onToggle: () => context.read<TaskProvider>().toggleDone(task.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(task: task, depth: 0),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checklist_rtl, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text('No tasks yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Tap + to add one', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
