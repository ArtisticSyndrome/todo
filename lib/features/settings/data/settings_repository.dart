import '../../../core/storage/storage_service.dart';

const _fileName = 'settings.json';

class AppSettings {
  final bool isDark;
  final String? backgroundImagePath;

  const AppSettings({this.isDark = false, this.backgroundImagePath});

  AppSettings copyWith({bool? isDark, String? backgroundImagePath}) => AppSettings(
        isDark: isDark ?? this.isDark,
        backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      );

  Map<String, dynamic> toJson() => {
        'isDark': isDark,
        'backgroundImagePath': backgroundImagePath,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        isDark: json['isDark'] as bool? ?? false,
        backgroundImagePath: json['backgroundImagePath'] as String?,
      );
}

class SettingsRepository {
  SettingsRepository(this._storage);
  final StorageService _storage;

  Future<AppSettings> load() async {
    final json = await _storage.readJson(_fileName);
    if (json == null) return const AppSettings();
    return AppSettings.fromJson(json);
  }

  Future<void> save(AppSettings settings) => _storage.writeJson(_fileName, settings.toJson());
}
