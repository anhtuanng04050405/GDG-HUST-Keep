import 'package:flutter/material.dart';
import '../instance/main_instance.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _choice;
  late String _choice2;

  @override
  void initState() {
    super.initState();
    _choice = ThemeInstance.currentTheme;
    _choice2 = ThemeInstance.currentColor;
  }

  void _onThemeOrColorChanged() {
    ThemeInstance.updateTheme(_choice, _choice2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Theme",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile<String>(
              title: const Text("System"),
              value: 'system',
              groupValue: _choice,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text("LightMode"),
              value: 'light',
              groupValue: _choice,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text("DarkMode"),
              value: 'dark',
              groupValue: _choice,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Color",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            RadioListTile<String>(
              title: const Text("Default (Yellow)"),
              value: 'yellow',
              groupValue: _choice2,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice2 = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text("Green"),
              value: 'green',
              groupValue: _choice2,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice2 = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text("Blue"),
              value: 'blue',
              groupValue: _choice2,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice2 = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text("Red"),
              value: 'red',
              groupValue: _choice2,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice2 = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text("Pink"),
              value: 'pink',
              groupValue: _choice2,
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _choice2 = value;
                  });
                  _onThemeOrColorChanged();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
