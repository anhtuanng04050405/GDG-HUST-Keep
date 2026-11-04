import 'package:flutter/material.dart';

import '../models/note.dart';
import '../models/note_sort.dart';
import '../services/note_service.dart';
import '../services/settings_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/card_view.dart';
import '../widgets/home_search_bar.dart';
import 'note_editor_screen.dart';
import '../widgets/note_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _searchController = TextEditingController();

  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Chế độ mặc định: ghi chú sửa gần nhất hiển thị trước.
  NoteSortMode _sortMode = NoteSortMode.editedAt;

  @override
  void initState() {
    super.initState();
    _notes = List.from(NoteService.cachedHomeNotes);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lấy danh sách ghi chú từ Supabase (tải ngầm nếu đã có cache).
  Future<void> _fetchNotes() async {
    if (_notes.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final data = await NoteService.getHomeNotes();

      // Không cập nhật State nếu màn hình đã bị hủy.
      if (!mounted) return;

      setState(() {
        _notes = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      debugPrint('Lỗi tải danh sách ghi chú: $e');
    }
  }

  // Lọc ghi chú theo tiêu đề, sau đó sắp xếp theo lựa chọn.
  List<Note> get _filteredNotes {
    final query = _searchQuery.trim().toLowerCase();

    // Không có từ khóa thì sử dụng toàn bộ danh sách.
    final filtered = query.isEmpty
        ? _notes
        : _notes.where((note) {
            return note.title.toLowerCase().contains(query);
          }).toList();

    // sortNotes tạo danh sách mới, không thay đổi _notes gốc.
    return sortNotes(filtered, _sortMode);
  }

  // Tạo nút sort cho thanh tìm kiếm.
  Widget _buildSortButton() {
    return PopupMenuButton<NoteSortMode>(
      tooltip: 'Sắp xếp ghi chú',
      icon: const Icon(Icons.sort),

      // Cập nhật màn hình khi người dùng chọn kiểu sắp xếp.
      onSelected: (mode) {
        setState(() {
          _sortMode = mode;
        });
        SettingsService.saveSortMode(mode);
      },

      // Dấu tích cho biết chế độ đang được sử dụng.
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

  // Hiển thị menu tùy chọn khi ấn giữ ghi chú.
  void _showNoteContextMenu(Note note) {
    final isPinned = note.pin;

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
                  leading: Icon(
                    isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  ),
                  title: Text(isPinned ? 'Bỏ ghim' : 'Ghim ghi chú'),
                  onTap: () async {
                    Navigator.pop(context);
                    final updatedPin = !isPinned;

                    // Cập nhật giao diện ngay lập tức trước khi gọi API
                    setState(() {
                      final index = _notes.indexWhere(
                        (n) =>
                            (n.id != null && n.id == note.id) ||
                            (n.createdAt != null &&
                                n.createdAt == note.createdAt) ||
                            (n.title == note.title &&
                                n.content == note.content),
                      );
                      if (index != -1) {
                        _notes[index] = _notes[index].copyWith(pin: updatedPin);
                      }
                    });

                    try {
                      await NoteService.saveNote(
                        existingNote: note,
                        title: note.title,
                        content: note.content,
                        pin: updatedPin,
                        color: note.color,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updatedPin
                                ? 'Đã ghim ghi chú'
                                : 'Đã bỏ ghim ghi chú',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Lỗi ghim ghi chú: $e');
                    } finally {
                      _fetchNotes();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('Lưu trữ'),
                  onTap: () async {
                    Navigator.pop(context);

                    // Xóa khỏi danh sách giao diện ngay lập tức
                    setState(() {
                      _notes.removeWhere(
                        (n) =>
                            (n.id != null && n.id == note.id) ||
                            (n.createdAt != null &&
                                n.createdAt == note.createdAt) ||
                            (n.title == note.title &&
                                n.content == note.content),
                      );
                    });

                    try {
                      await NoteService.archiveNote(
                        existingNote: note,
                        title: note.title,
                        content: note.content,
                        pin: note.pin,
                        color: note.color,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã chuyển ghi chú vào lưu trữ'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } catch (e) {
                      debugPrint('Lỗi chuyển vào lưu trữ: $e');
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

    // Chỉ tính danh sách đã lọc và sắp xếp một lần mỗi build.
    final visibleNotes = _filteredNotes;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      drawer: KeepDrawer(
        selectedIndex: 0,
        onReturnFromArchive: () async {
          if (!mounted) return;
          await _fetchNotes();
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Thanh tìm kiếm ghi chú (sort button nằm bên trong).
            KeepSearchBar(
              controller: _searchController,
              onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              trailing: _buildSortButton(),
            ),

            // Hiển thị loading, empty state hoặc danh sách ghi chú.
            Expanded(
              child: _isLoading
                  ? const NoteLoading()
                  : visibleNotes.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : RefreshIndicator(
                      onRefresh: _fetchNotes,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: visibleNotes.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final note = visibleNotes[index];

                          return CardView(
                            note: note,
                            onTap: () async {
                              // Mở Editor để chỉnh sửa ghi chú.
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NoteEditorScreen(note: note),
                                ),
                              );

                              // Tải lại dữ liệu sau khi đóng Editor.
                              if (!mounted) return;
                              _fetchNotes();
                            },
                            onLongPress: () => _showNoteContextMenu(note),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),

      // Nút tạo ghi chú mới.
      floatingActionButton: SizedBox(
        width: 55,
        height: 55,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
            );

            // Cập nhật danh sách sau khi tạo ghi chú.
            if (!mounted) return;
            _fetchNotes();
          },
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, color: colorScheme.onPrimary, size: 28),
        ),
      ),
    );
  }

  // Hiển thị thông báo khi không có ghi chú phù hợp.
  Widget _buildEmptyState(ColorScheme colorScheme) {
    final isSearching = _searchQuery.trim().isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_outlined : Icons.lightbulb_outline,
            size: 80,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'Không tìm thấy ghi chú phù hợp'
                : 'Không có ghi chú nào',
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
