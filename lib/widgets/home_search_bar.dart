import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';

class KeepSearchBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final Widget? trailing;

  const KeepSearchBar({
    super.key,
    required this.onMenuTap,
    this.onChanged,
    this.controller,
    this.onClear,
    this.trailing,
  });

  // Lọc ghi chú theo từ khóa tìm kiếm và sắp xếp theo chế độ được chọn.
  static List<Note> filterNotes({
    required List<Note> notes,
    required String query,
    required NoteSortMode sortMode,
  }) {
    final cleanQuery = query.trim().toLowerCase();

    // Không có từ khóa thì sử dụng toàn bộ danh sách.
    final filtered = cleanQuery.isEmpty
        ? notes
        : notes.where((note) {
            return note.title.toLowerCase().contains(cleanQuery);
          }).toList();

    // Sắp xếp danh sách đã lọc.
    return NoteService.sortNotes(filtered, sortMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
            onPressed: onMenuTap,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
          if (controller != null && controller!.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
              onPressed: () {
                controller?.clear();
                if (onClear != null) {
                  onClear!();
                } else if (onChanged != null) {
                  onChanged!('');
                }
              },
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
