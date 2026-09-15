import 'package:flutter/material.dart';

import '../../data/task.dart';

/// A single row. Checkbox + title animate (strike-through, fade) on toggle.
/// Wrapped in InkWell so Material gives instant press feedback for free.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final hasChildren = task.children.isNotEmpty;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: task.done,
                onChanged: (_) => onToggle(),
              ),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task.done
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                  child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
              if (hasChildren)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Chip(
                    label: Text('${task.children.length}'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
