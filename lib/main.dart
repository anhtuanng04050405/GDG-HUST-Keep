import 'package:flutter/material.dart';
import 'instance/main_instance.dart';
import 'screens/welcome_screen.dart';
import 'supabase/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await ThemeInstance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeInstance.notifier,
      builder: (context, _, __) {
        final colorScheme = ThemeInstance.colorScheme;

        return MaterialApp(
          title: '<GDG-HUST> Keep',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeInstance.themeMode,
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
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
