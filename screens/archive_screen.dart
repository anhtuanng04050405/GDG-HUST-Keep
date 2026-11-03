import 'package:flutter/material.dart';

import '../instance/main_instance.dart';
import '../models/note.dart';
import '../models/note_sort.dart';
import '../services/note_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/card_view.dart';
import '../widgets/note_loading.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Note> _notes = [];
  bool _isLoading = true;

  // Mặc định ưu tiên ghi chú được chỉnh sửa gần nhất.
  NoteSortMode _sortMode = NoteSortMode.editedAt;

  @override
  void initState() {
    super.initState();
    _notes = List.from(NoteService.cachedArchiveNotes);
    _isLoading = _notes.isEmpty;
    _loadSortMode();
    _fetchNotes();
  }

  Future<void> _loadSortMode() async {
    final mode = await SettingsService.getSortMode();
    if (mounted) {
      setState(() {
        _sortMode = mode;
      });
    }
  }

  // Lấy danh sách ghi chú lưu trữ từ Supabase (tải ngầm nếu đã có cache).
  Future<void> _fetchNotes() async {
    if (_notes.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final data = await NoteService.getArchiveNotes();

      // Tránh cập nhật State khi màn hình đã bị hủy.
      if (!mounted) return;

      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      debugPrint('Lỗi tải danh sách lưu trữ: $e');
    }
  }

  // Sắp xếp ghi chú theo chế độ đang chọn.
  // Dùng chung hàm sortNotes với HomeScreen.
  List<Note> get _sortedNotes {
    return sortNotes(_notes, _sortMode);
  }

  // Menu cho phép người dùng thay đổi kiểu sắp xếp.
  Widget _buildSortMenu(ColorScheme colorScheme) {
    return PopupMenuButton<NoteSortMode>(
      tooltip: 'Sắp xếp ghi chú',
      icon: Icon(Icons.sort, color: colorScheme.onSurfaceVariant),

      // Thay đổi chế độ và cập nhật danh sách hiển thị.
      onSelected: (mode) {
        setState(() {
          _sortMode = mode;
        });
        SettingsService.saveSortMode(mode);
      },

      // Đánh dấu chế độ sắp xếp hiện tại.
      itemBuilder: (context) => [
        CheckedPopupMenuItem<NoteSortMode>(
          value: NoteSortMode.title,
          checked: _sortMode == NoteSortMode.title,
          child: const Text('Tiêu đề A-Z'),
        ),
        CheckedPopupMenuItem<NoteSortMode>(
          value: NoteSortMode.createdAt,
          checked: _sortMode == NoteSortMode.createdAt,
          child: const Text('Ngày tạo mới nhất'),
        ),
        CheckedPopupMenuItem<NoteSortMode>(
          value: NoteSortMode.editedAt,
          checked: _sortMode == NoteSortMode.editedAt,
          child: const Text('Ngày sửa gần nhất'),
        ),
      ],
    );
  }

  // Hiển thị menu tùy chọn khi ấn giữ ghi chú trong màn hình Lưu trữ.
  void _showNoteContextMenu(Note note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note.title.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.unarchive_outlined),
                  title: const Text('Khôi phục'),
                  onTap: () async {
                    Navigator.pop(context);

                    // Xóa khỏi danh sách lưu trữ ngay lập tức
                    setState(() {
                      _notes.removeWhere((n) =>
                          (n.id != null && n.id == note.id) ||
                          (n.createdAt != null && n.createdAt == note.createdAt) ||
                          (n.title == note.title && n.content == note.content));
                    });

                    try {
                      await NoteService.unarchiveNote(
                        existingNote: note,
                        title: note.title,
                        content: note.content,
                        pin: note.pin,
                        color: note.color,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã khôi phục ghi chú về ghi chú'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Lỗi khôi phục ghi chú: $e');
                    } finally {
                      _fetchNotes();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);

                    // Xóa khỏi danh sách lưu trữ ngay lập tức
                    setState(() {
                      _notes.removeWhere((n) =>
                          (n.id != null && n.id == note.id) ||
                          (n.createdAt != null && n.createdAt == note.createdAt) ||
                          (n.title == note.title && n.content == note.content));
                    });

                    try {
                      await NoteService.deleteNote(note);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xóa ghi chú khỏi lưu trữ'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Lỗi xóa ghi chú: $e');
                    } finally {
                      _fetchNotes();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Chỉ sắp xếp danh sách một lần trong mỗi lần build.
    final visibleNotes = _sortedNotes;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      drawer: const KeepDrawer(
        selectedIndex: 1,
      ),

      appBar: AppBar(
        title: Text(
          'Lưu trữ',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: Icon(Icons.menu, color: colorScheme.onSurfaceVariant),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),

        // Hiển thị nút Sorting trên AppBar.
        actions: [_buildSortMenu(colorScheme)],
      ),

      body: SafeArea(
        // Hiển thị GIF loading trong lúc tải dữ liệu từ Supabase.
        child: _isLoading
            ? const NoteLoading()
            : visibleNotes.isEmpty
            ? _buildEmptyState(colorScheme)
            : RefreshIndicator(
                onRefresh: _fetchNotes,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: visibleNotes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final note = visibleNotes[index];

                    return CardView(
                      note: note,
                      onTap: () async {
                        // Mở Editor để xem hoặc sửa ghi chú lưu trữ.
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                NoteEditorScreen(note: note, isArchive: true),
                          ),
                        );

                        // Tải lại danh sách khi quay về Archive.
                        if (!mounted) return;
                        _fetchNotes();
                      },
                      onLongPress: () => _showNoteContextMenu(note),
                    );
                  },
                ),
              ),
      ),
    );
  }

  // Hiển thị khi chưa có ghi chú nào trong lưu trữ.
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có ghi chú nào trong lưu trữ',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
