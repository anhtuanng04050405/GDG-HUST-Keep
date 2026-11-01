import 'package:flutter/material.dart';

class NoteColorHelper {
  static const List<Map<String, String>> availableColors = [
    {'key': 'default', 'label': 'Mặc định'},
    {'key': 'red', 'label': 'Đỏ'},
    {'key': 'green', 'label': 'Xanh lá'},
    {'key': 'blue', 'label': 'Xanh dương'},
    {'key': 'yellow', 'label': 'Vàng'},
    {'key': 'pink', 'label': 'Hồng'},
    {'key': 'purple', 'label': 'Tím'},
    {'key': 'orange', 'label': 'Cam'},
  ];

  /// Trả về màu nền của Card dựa vào key màu và ThemeMode (sáng/tối)
  static Color getCardBackgroundColor(String colorKey, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (colorKey == 'default') {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }

    if (isDark) {
      switch (colorKey) {
        case 'red':
          return const Color(0xFF4A1C24);
        case 'green':
          return const Color(0xFF1B382B);
        case 'blue':
          return const Color(0xFF1B304A);
        case 'yellow':
          return const Color(0xFF423B17);
        case 'pink':
          return const Color(0xFF4A1D36);
        case 'purple':
          return const Color(0xFF381F47);
        case 'orange':
          return const Color(0xFF4A2B19);
        default:
          return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      }
    } else {
      switch (colorKey) {
        case 'red':
          return const Color(0xFFFFEBEE);
        case 'green':
          return const Color(0xFFE8F5E9);
        case 'blue':
          return const Color(0xFFE3F2FD);
        case 'yellow':
          return const Color(0xFFFFFDE7);
        case 'pink':
          return const Color(0xFFFCE4EC);
        case 'purple':
          return const Color(0xFFF3E5F5);
        case 'orange':
          return const Color(0xFFFFF3E0);
        default:
          return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      }
    }
  }

  /// Trả về màu đại diện cho nút chọn màu (Preview Dot)
  static Color getPreviewColor(String colorKey, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (colorKey) {
      case 'red':
        return isDark ? Colors.red.shade700 : Colors.red.shade300;
      case 'green':
        return isDark ? Colors.green.shade700 : Colors.green.shade300;
      case 'blue':
        return isDark ? Colors.blue.shade700 : Colors.blue.shade300;
      case 'yellow':
        return isDark ? Colors.amber.shade700 : Colors.amber.shade300;
      case 'pink':
        return isDark ? Colors.pink.shade700 : Colors.pink.shade300;
      case 'purple':
        return isDark ? Colors.purple.shade700 : Colors.purple.shade300;
      case 'orange':
        return isDark ? Colors.orange.shade700 : Colors.orange.shade300;
      case 'default':
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }
}
