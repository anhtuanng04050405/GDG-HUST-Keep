import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_sort.dart';

class SettingsService {
  static const String _keyTheme = 'current_theme';
  static const String _keyColor = 'current_color';
  static const String _keySortMode = 'sort_mode';

  /// Lấy theme đã lưu (mặc định: 'light')
  static Future<String> getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyTheme) ?? 'light';
    } catch (_) {
      return 'light';
    }
  }

  /// Lưu theme
  static Future<void> saveTheme(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, theme);
    } catch (_) {}
  }

  /// Lấy màu giao diện đã lưu (mặc định: 'yellow')
  static Future<String> getColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyColor) ?? 'yellow';
    } catch (_) {
      return 'yellow';
    }
  }

  /// Lưu màu giao diện
  static Future<void> saveColor(String color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyColor, color);
    } catch (_) {}
  }

  /// Lấy chế độ sắp xếp đã lưu (mặc định: editedAt)
  static Future<NoteSortMode> getSortMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt(_keySortMode);
      if (index != null && index >= 0 && index < NoteSortMode.values.length) {
        return NoteSortMode.values[index];
      }
    } catch (_) {}
    return NoteSortMode.editedAt;
  }

  /// Lưu chế độ sắp xếp
  static Future<void> saveSortMode(NoteSortMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keySortMode, mode.index);
    } catch (_) {}
  }
}
