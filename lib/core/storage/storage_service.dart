import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Generic JSON file storage in the app's documents directory.
/// Doubles as the export format — a saved file IS the backup.
class StorageService {
  Future<File> fileFor(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$name');
  }

  Future<Map<String, dynamic>?> readJson(String name) async {
    final file = await fileFor(name);
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    if (content.trim().isEmpty) return null;
    return jsonDecode(content) as Map<String, dynamic>;
  }

  Future<void> writeJson(String name, Map<String, dynamic> data) async {
    final file = await fileFor(name);
    await file.writeAsString(jsonEncode(data));
  }
}
