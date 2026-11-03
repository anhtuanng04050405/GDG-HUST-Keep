import 'package:flutter/material.dart';
import '../instance/main_instance.dart';
import '../screens/home_screen.dart';
import '../screens/archive_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../services/login_service.dart';
import '../services/note_service.dart';

class KeepDrawer extends StatelessWidget {
  final int selectedIndex;

  const KeepDrawer({
    super.key,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      width: 225,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 24, 8),
              child: Text(
                'Ghi chú',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Ghi chú
            _DrawerItem(
              icon: Icons.lightbulb_outline,
              label: 'Ghi chú',
              isSelected: selectedIndex == 0,
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                if (selectedIndex != 0) {
                  if (navigator.canPop()) {
                    navigator.pop();
                  } else {
                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  }
                }
              },
            ),

            // Lưu trữ
            _DrawerItem(
              icon: Icons.archive_outlined,
              label: 'Lưu trữ',
              isSelected: selectedIndex == 1,
              onTap: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                if (selectedIndex != 1) {
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const ArchiveScreen(),
                    ),
                  );
                }
              },
            ),

            const Spacer(),

            // Cài đặt (Settings)
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              isSelected: false,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),

            // Đăng xuất
            _DrawerItem(
              icon: Icons.logout,
              label: 'Đăng xuất',
              isSelected: false,
              onTap: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                await LoginService.logout();
                NoteService.clearCache();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
          ),
          dense: true,
          visualDensity: const VisualDensity(vertical: -1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
