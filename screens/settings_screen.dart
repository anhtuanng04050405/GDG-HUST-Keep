import 'package:flutter/material.dart';

typedef OnThemeColorChanged = void Function(String theme, String color);

class SettingsScreen extends StatefulWidget {
  final String currentTheme;
  final String currentColor;
  final OnThemeColorChanged onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.currentColor,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _choice;
  late String _choice2;

  @override
  void initState() {
    super.initState();
    _choice = widget.currentTheme;
    _choice2 = widget.currentColor;
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
      body: ListView(
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
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
                widget.onThemeChanged(_choice, _choice2);
              }
            },
          ),
        ],
      ),
    );
  }
}
