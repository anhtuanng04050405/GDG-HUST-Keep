import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'services/settings_service.dart';
import 'supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
  }

  final initialTheme = await SettingsService.getTheme();
  final initialColor = await SettingsService.getColor();

  runApp(MyApp(
    initialTheme: initialTheme,
    initialColor: initialColor,
  ));
}

class MyApp extends StatefulWidget {
  final String initialTheme;
  final String initialColor;

  const MyApp({
    super.key,
    this.initialTheme = 'light',
    this.initialColor = 'yellow',
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _currentTheme;
  late String _currentColor;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
    _currentColor = widget.initialColor;
  }

  void _updateTheme(String theme, String color) {
    setState(() {
      _currentTheme = theme;
      _currentColor = color;
    });
    SettingsService.saveTheme(theme);
    SettingsService.saveColor(color);
  }

  ColorScheme _getColorScheme() {
    Color seedColor;
    switch (_currentColor) {
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
      brightness: _currentTheme == 'dark' ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getColorScheme();

    return MaterialApp(
      title: '<GDG-HUST> Keep',
      debugShowCheckedModeBanner: false,
      themeMode: _currentTheme == 'dark'
          ? ThemeMode.dark
          : _currentTheme == 'light'
              ? ThemeMode.light
              : ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
      ),
      home: WelcomeScreen(
        currentTheme: _currentTheme,
        currentColor: _currentColor,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
