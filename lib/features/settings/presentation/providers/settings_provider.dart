import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._repo);
  final SettingsRepository _repo;

  AppSettings settings = const AppSettings();
  bool loading = true;

  Future<void> load() async {
    settings = await _repo.load();
    loading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    settings = settings.copyWith(isDark: !settings.isDark);
    await _repo.save(settings);
    notifyListeners();
  }

  Future<void> pickBackgroundImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final saved = await File(picked.path).copy('${dir.path}/background.jpg');
    settings = AppSettings(isDark: settings.isDark, backgroundImagePath: saved.path);
    await _repo.save(settings);
    notifyListeners();
  }

  Future<void> clearBackgroundImage() async {
    settings = AppSettings(isDark: settings.isDark, backgroundImagePath: null);
    await _repo.save(settings);
    notifyListeners();
  }
}
