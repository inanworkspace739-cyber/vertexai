import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _historyKey = 'ai_history_v1';
  static const _styleKey = 'user_style_pref';
  static const _aspectKey = 'user_aspect_pref';
  static const _modelKey = 'user_model_pref';
  static const _autoEnhanceKey = 'user_auto_enhance_pref';
  static const _seedModeKey = 'user_seed_mode_pref';
  static const _fixedSeedKey = 'user_fixed_seed_pref';

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<String?> loadString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveHistory(String json) async => saveString(_historyKey, json);

  Future<String?> loadHistory() async => loadString(_historyKey);

  // Save user preferences
  Future<void> savePreferences({
    required String style,
    required String aspect,
    required String model,
    required bool autoEnhance,
    required bool isRandomSeed,
    required int fixedSeed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_styleKey, style);
    await prefs.setString(_aspectKey, aspect);
    await prefs.setString(_modelKey, model);
    await prefs.setBool(_autoEnhanceKey, autoEnhance);
    await prefs.setBool(_seedModeKey, isRandomSeed);
    await prefs.setInt(_fixedSeedKey, fixedSeed);
  }

  // Load user preferences
  Future<Map<String, dynamic>> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'style': prefs.getString(_styleKey) ?? 'Anime',
      'aspect': prefs.getString(_aspectKey) ?? 'Portrait 9:16',
      'model': prefs.getString(_modelKey) ?? 'flux',
      'autoEnhance': prefs.getBool(_autoEnhanceKey) ?? true,
      'isRandomSeed': prefs.getBool(_seedModeKey) ?? true,
      'fixedSeed': prefs.getInt(_fixedSeedKey) ?? 0,
    };
  }
}
