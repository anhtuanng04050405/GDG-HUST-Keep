import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeInstance {
  /// Biến tĩnh lưu theme hiện tại
  static String currentTheme = 'light';

  /// Biến tĩnh lưu color hiện tại
  static String currentColor = 'yellow';

  /// Notifier kích hoạt cập nhật giao diện khi theme hoặc color đổi
  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  /// Khởi tạo theme & color từ SettingsService (SharedPreferences)
  static Future<void> init() async {
    currentTheme = await SettingsService.getTheme();
    currentColor = await SettingsService.getColor();
    notifier.value++;
  }

  /// Cập nhật đồng thời theme và color
  static void updateTheme(String theme, String color) {
    bool changed = false;
    if (theme != currentTheme) {
      currentTheme = theme;
      SettingsService.saveTheme(theme);
      changed = true;
    }
    if (color != currentColor) {
      currentColor = color;
      SettingsService.saveColor(color);
      changed = true;
    }
    if (changed) {
      notifier.value++;
    }
  }

  /// Cập nhật riêng theme
  static void setTheme(String theme) {
    updateTheme(theme, currentColor);
  }

  /// Cập nhật riêng color
  static void setColor(String color) {
    updateTheme(currentTheme, color);
  }

  /// Lấy ThemeMode tương ứng
  static ThemeMode get themeMode {
    switch (currentTheme) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  /// Lấy ColorScheme tương ứng
  static ColorScheme get colorScheme {
    Color seedColor;
    switch (currentColor) {
      case 'green':
        seedColor = Colors.green;
        break;
      case 'blue':
        seedColor = Colors.blue;
        break;
      case 'red':
        seedColor = Colors.red;
        break;
      case 'pink':
        seedColor = Colors.pink;
        break;
      case 'yellow':
      default:
        seedColor = Colors.amber;
        break;
    }

    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: currentTheme == 'dark' ? Brightness.dark : Brightness.light,
    );
  }
}
