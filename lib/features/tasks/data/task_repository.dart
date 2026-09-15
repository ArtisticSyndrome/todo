import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/storage/storage_service.dart';
import 'task.dart';

const _fileName = 'tasks.json';
const maxDepth = 2; // 0 = root, 1 = sub, 2 = sub-sub -> 3 levels total

class TaskRepository {
  TaskRepository(this._storage);
  final StorageService _storage;

  Future<List<Task>> load() async {
    final json = await _storage.readJson(_fileName);
    if (json == null) return [];
    final list = json['tasks'] as List<dynamic>? ?? [];
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(List<Task> tasks) async {
    await _storage.writeJson(_fileName, {
      'tasks': tasks.map((t) => t.toJson()).toList(),
    });
  }

  /// Shares the raw tasks.json file so the user can back it up anywhere.
  Future<void> export(List<Task> tasks) async {
    await save(tasks);
    final file = await _storage.fileFor(_fileName);
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final exportFile = await file.copy('${dir.path}/todo-backup-$stamp.json');
    await SharePlus.instance.share(
      ShareParams(files: [XFile(exportFile.path)], text: 'Todo backup'),
    );
  }

  /// Lets the user pick a previously exported JSON file and replaces
  /// current data with it. Returns null if the user cancelled.
  Future<List<Task>?> import() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = file?.path;
    if (path == null) return null;
    final content = await File(path).readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;
    final list = json['tasks'] as List<dynamic>? ?? [];
    final tasks = list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    await save(tasks);
    return tasks;
  }
}
