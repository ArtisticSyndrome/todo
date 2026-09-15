/// A task node. Tree depth is capped at 3 levels (depth 0, 1, 2)
/// enforced by callers before inserting a child.
class Task {
  final String id;
  String title;
  String notes;
  bool done;
  final DateTime createdAt;
  final List<Task> children;
  // Path to a saved PNG sketch, and a Quill Delta (rich text) as JSON —
  // both optional alternate note formats alongside plain [notes].
  String? drawingPath;
  String? richNotes;

  Task({
    required this.id,
    required this.title,
    this.notes = '',
    this.done = false,
    DateTime? createdAt,
    List<Task>? children,
    this.drawingPath,
    this.richNotes,
  })  : createdAt = createdAt ?? DateTime.now(),
        children = children ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
        'children': children.map((c) => c.toJson()).toList(),
        'drawingPath': drawingPath,
        'richNotes': richNotes,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String? ?? '',
        done: json['done'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        children: (json['children'] as List<dynamic>? ?? [])
            .map((c) => Task.fromJson(c as Map<String, dynamic>))
            .toList(),
        drawingPath: json['drawingPath'] as String?,
        richNotes: json['richNotes'] as String?,
      );
}
