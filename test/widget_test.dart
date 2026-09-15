// Smallest possible check for the one non-trivial branch in this app:
// the 3-level task depth cap in TaskProvider.addChild.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/storage/storage_service.dart';
import 'package:todo_app/features/tasks/data/task_repository.dart';
import 'package:todo_app/features/tasks/presentation/providers/task_provider.dart';

class _FakeStorage extends StorageService {
  _FakeStorage(this.dir);
  final Directory dir;

  @override
  Future<File> fileFor(String name) async => File('${dir.path}/$name');
}

void main() {
  test('task tree cannot exceed 3 levels', () async {
    final tempDir = await Directory.systemTemp.createTemp('todo_test');
    addTearDown(() async {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {
        // Windows can hold a brief file lock after writes; best-effort cleanup.
      }
    });

    final provider = TaskProvider(TaskRepository(_FakeStorage(tempDir)));
    await provider.load();

    provider.addRoot('root'); // depth 0
    final rootId = provider.tasks.first.id;

    final addedChild = provider.addChild(rootId, 'child'); // depth 1
    expect(addedChild, isTrue);
    final childId = provider.tasks.first.children.first.id;

    final addedGrandchild = provider.addChild(childId, 'grandchild'); // depth 2
    expect(addedGrandchild, isTrue);
    final grandchildId = provider.tasks.first.children.first.children.first.id;

    final addedTooDeep = provider.addChild(grandchildId, 'great-grandchild');
    expect(addedTooDeep, isFalse);
    expect(provider.tasks.first.children.first.children.first.children, isEmpty);
  });
}
