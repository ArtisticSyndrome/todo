import 'package:flutter/foundation.dart';

import '../../data/task.dart';
import '../../data/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repo);
  final TaskRepository _repo;

  List<Task> tasks = [];
  bool loading = true;
  int _idCounter = 0;

  // Timestamp + counter is enough uniqueness for a single local device.
  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}';

  Future<void> load() async {
    tasks = await _repo.load();
    loading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _repo.save(tasks);
    notifyListeners();
  }

  void addRoot(String title, {String notes = ''}) {
    tasks.add(Task(id: _newId(), title: title, notes: notes));
    _persist();
  }

  /// Returns false if [parentId] is already at max depth and can't take a child.
  bool addChild(String parentId, String title, {String notes = ''}) {
    final found = _findWithDepth(tasks, parentId, 0);
    if (found == null || found.$2 >= maxDepth) return false;
    found.$1.children.add(Task(id: _newId(), title: title, notes: notes));
    _persist();
    return true;
  }

  int? depthOf(String id) => _findWithDepth(tasks, id, 0)?.$2;

  void toggleDone(String id) {
    final found = _findWithDepth(tasks, id, 0);
    if (found == null) return;
    found.$1.done = !found.$1.done;
    _persist();
  }

  void updateTitle(String id, String title) {
    _findWithDepth(tasks, id, 0)?.$1.title = title;
    _persist();
  }

  void updateNotes(String id, String notes) {
    _findWithDepth(tasks, id, 0)?.$1.notes = notes;
    _persist();
  }

  void setDrawing(String id, String? path) {
    _findWithDepth(tasks, id, 0)?.$1.drawingPath = path;
    _persist();
  }

  void setRichNotes(String id, String? json) {
    _findWithDepth(tasks, id, 0)?.$1.richNotes = json;
    _persist();
  }

  void deleteTask(String id) {
    _removeById(tasks, id);
    _persist();
  }

  bool _removeById(List<Task> list, String id) {
    final before = list.length;
    list.removeWhere((t) => t.id == id);
    if (list.length != before) return true;
    for (final t in list) {
      if (_removeById(t.children, id)) return true;
    }
    return false;
  }

  (Task, int)? _findWithDepth(List<Task> list, String id, int depth) {
    for (final t in list) {
      if (t.id == id) return (t, depth);
      final inChild = _findWithDepth(t.children, id, depth + 1);
      if (inChild != null) return inChild;
    }
    return null;
  }

  Future<void> export() => _repo.export(tasks);

  Future<bool> import() async {
    final imported = await _repo.import();
    if (imported == null) return false;
    tasks = imported;
    notifyListeners();
    return true;
  }
}
