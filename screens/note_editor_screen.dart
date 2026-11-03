import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../utils/note_color.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final bool isArchive;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.isArchive = false,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isPinned;
  late String _selectedColor;
  bool _isSaving = false;
  bool _isActionHandled = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _isPinned = widget.note?.pin ?? false;
    _selectedColor = widget.note?.color ?? 'default';
  }

  Future<void> _saveNote() async {
    if (_isSaving || _isActionHandled) return;
    _isSaving = true;

    try {
      await NoteService.saveNote(
        existingNote: widget.note,
        title: _titleController.text,
        content: _contentController.text,
        pin: _isPinned,
        color: _selectedColor,
        isArchive: widget.isArchive,
      );
    } catch (e) {
      debugPrint('Lỗi khi lưu ghi chú: $e');
    }
  }

  Future<void> _archiveNote() async {
    _isActionHandled = true;

    try {
      await NoteService.archiveNote(
        existingNote: widget.note,
        title: _titleController.text,
        content: _contentController.text,
        pin: _isPinned,
        color: _selectedColor,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chuyển ghi chú vào lưu trữ'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi lưu trữ ghi chú: $e');
      _isActionHandled = false;
    }
  }

  Future<void> _unarchiveNote() async {
    _isActionHandled = true;

    try {
      await NoteService.unarchiveNote(
        existingNote: widget.note,
        title: _titleController.text,
        content: _contentController.text,
        pin: _isPinned,
        color: _selectedColor,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã khôi phục ghi chú về ghi chú'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi khôi phục ghi chú: $e');
      _isActionHandled = false;
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteNote();
    }
  }

  Future<void> _deleteNote() async {
    _isActionHandled = true;

    if (widget.note == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      await NoteService.deleteNote(widget.note!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa ghi chú khỏi lưu trữ'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa ghi chú: $e');
      _isActionHandled = false;
    }
  }

  Widget _buildColorMenu(ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      tooltip: 'Chọn màu ghi chú',
      icon: Icon(
        Icons.palette_outlined,
        color: colorScheme.onSurface,
      ),
      constraints: const BoxConstraints(
        minWidth: 44,
        maxWidth: 48,
      ),
      padding: EdgeInsets.zero,
      menuPadding: const EdgeInsets.symmetric(vertical: 4),
      onSelected: (String colorKey) {
        setState(() {
          _selectedColor = colorKey;
        });
      },
      itemBuilder: (BuildContext context) {
        return NoteColorHelper.availableColors.map((colorItem) {
          final key = colorItem['key']!;
          final isSelected = _selectedColor == key;
          final previewColor = NoteColorHelper.getPreviewColor(key, context);

          return PopupMenuItem<String>(
            value: key,
            height: 36,
            padding: EdgeInsets.zero,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: previewColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: key == 'default'
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.white,
                      )
                    : null,
              ),
            ),
          );
        }).toList();
      },
    );
  }

  Future<void> _handleBack() async {
    if (!_isActionHandled) {
      await _saveNote();
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = _selectedColor == 'default'
        ? theme.scaffoldBackgroundColor
        : NoteColorHelper.getCardBackgroundColor(_selectedColor, context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_isActionHandled) {
          await _saveNote();
        }
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: _handleBack,
          ),
          actions: [
            // Ghim
            IconButton(
              tooltip: _isPinned ? 'Bỏ ghim' : 'Ghim',
              icon: Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                });
              },
            ),

            // Dropdown chọn màu ghi chú theo chiều dọc
            _buildColorMenu(colorScheme),

            // Lưu trữ (khi ở màn hình chính)
            if (!widget.isArchive)
              IconButton(
                tooltip: 'Lưu trữ',
                icon: Icon(
                  Icons.archive_outlined,
                  color: colorScheme.onSurface,
                ),
                onPressed: _archiveNote,
              ),

            // Khôi phục & Xóa (khi ở màn hình lưu trữ)
            if (widget.isArchive) ...[
              IconButton(
                tooltip: 'Khôi phục',
                icon: Icon(
                  Icons.unarchive_outlined,
                  color: colorScheme.onSurface,
                ),
                onPressed: _unarchiveNote,
              ),
              IconButton(
                tooltip: 'Xóa',
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.onSurface,
                ),
                onPressed: _showDeleteDialog,
              ),
            ],

            const SizedBox(width: 15),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Tiêu đề
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tiêu đề',
                    hintStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),

                // Nội dung ghi chú
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ghi chú',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
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
