import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/note_color.dart';

class CardView extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CardView({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
  });

  factory CardView.fromMap(
    Map<String, dynamic> data, {
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return CardView(
      note: Note.fromMap(data),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  String parseTime(String time) {
    if (time.length < 10) return time;
    return '${time.substring(8, 10)}-${time.substring(5, 7)}-${time.substring(0, 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = note.title;
    final content = note.content;
    final isPinned = note.pin;
    final createdAt = note.createdAt;
    final editedAt = note.editedAt;
    final hasTitle = title.trim().isNotEmpty;
    final hasContent = content.trim().isNotEmpty;

    final cardBgColor = NoteColorHelper.getCardBackgroundColor(note.color, context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTitle || isPinned)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasTitle)
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (isPinned)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.push_pin,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),

                if (hasTitle && hasContent) const SizedBox(height: 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày tạo: ${parseTime(createdAt.toString())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Ngày chỉnh sửa: ${parseTime(editedAt.toString())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                if (hasContent)
                  Text(
                    content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
