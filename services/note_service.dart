import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../supabase/supabase_config.dart';

class NoteService {
  static const String _homeTable = 'data_home';
  static const String _archiveTable = 'data_archive';

  /// Bộ nhớ tạm ngầm cho màn hình Home và Archive
  static List<Note> cachedHomeNotes = [];
  static List<Note> cachedArchiveNotes = [];

  /// Lấy data_home
  static Future<List<Note>> getHomeNotes() async {
    final list = await _fetchNotesFromTable(_homeTable);
    cachedHomeNotes = list;
    return list;
  }

  /// Lấy data_archive
  static Future<List<Note>> getArchiveNotes() async {
    final list = await _fetchNotesFromTable(_archiveTable);
    cachedArchiveNotes = list;
    return list;
  }

  /// Lưu ghi chú
  static Future<void> saveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
    bool isArchive = false,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    // Nếu là ghi chú mới và cả 2 trường đều trống thì không lưu
    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }

    // Nếu không có gì thay đổi so với dữ liệu cũ thì bỏ qua
    if (existingNote != null &&
        existingNote.title.trim() == trimmedTitle &&
        existingNote.content.trim() == trimmedContent &&
        existingNote.pin == pin &&
        existingNote.color == color) {
      return;
    }

    final table = isArchive ? _archiveTable : _homeTable;
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      if (existingNote != null) {
        // Cập nhật ghi chú đã tồn tại
        final updates = {
          'title': trimmedTitle,
          'content': trimmedContent,
          'pin': pin,
          'color': color,
          'edited_at': nowUtc,
        };

        if (existingNote.id != null) {
          await supabase.from(table).update(updates).eq('id', existingNote.id!);
        } else if (existingNote.createdAt != null) {
          await supabase
              .from(table)
              .update(updates)
              .eq('created_at', existingNote.createdAt!.toIso8601String());
        } else {
          await supabase
              .from(table)
              .update(updates)
              .eq('title', existingNote.title);
        }
      } else {
        // Tạo mới ghi chú
        await supabase.from(table).insert({
          'title': trimmedTitle,
          'content': trimmedContent,
          'pin': pin,
          'color': color,
          'edited_at': nowUtc,
        });
      }
    } catch (e) {
      debugPrint('NoteService.saveNote error: $e');
      rethrow;
    }
  }

  /// data_home -> data_archive
  static Future<void> archiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }

    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      // 1. Thêm vào data_archive
      await supabase.from(_archiveTable).insert({
        'title': trimmedTitle,
        'content': trimmedContent,
        'pin': pin,
        'color': color,
        'edited_at': nowUtc,
      });

      // 2. Xóa khỏi data_home nếu ghi chú đã tồn tại
      if (existingNote != null) {
        await _deleteRecordFromTable(_homeTable, existingNote);
      }
    } catch (e) {
      debugPrint('NoteService.archiveNote error: $e');
      rethrow;
    }
  }

  /// data_archive -> data_home
  static Future<void> unarchiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }

    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      // 1. Thêm vào data_home
      await supabase.from(_homeTable).insert({
        'title': trimmedTitle,
        'content': trimmedContent,
        'pin': pin,
        'color': color,
        'edited_at': nowUtc,
      });

      // 2. Xóa khỏi data_archive nếu ghi chú đã tồn tại
      if (existingNote != null) {
        await _deleteRecordFromTable(_archiveTable, existingNote);
      }
    } catch (e) {
      debugPrint('NoteService.unarchiveNote error: $e');
      rethrow;
    }
  }

  /// Xóa vĩnh viễn
  static Future<void> deleteNote(Note note) async {
    try {
      await _deleteRecordFromTable(_archiveTable, note);
    } catch (e) {
      debugPrint('NoteService.deleteNote error: $e');
      rethrow;
    }
  }

  //Load ghi chú từ bảng data_home hoặc data_archive
  static Future<List<Note>> _fetchNotesFromTable(String tableName) async {
    try {
      final data = await supabase
          .from(tableName)
          .select()
          .order('pin', ascending: false)
          .order('edited_at', ascending: false);

      return (data as List).map((item) => Note.fromMap(item)).toList();
    } catch (e) {
      debugPrint('NoteService._fetchNotesFromTable ($tableName) error: $e');
      rethrow;
    }
  }

  // Xóa một hàng nào đó
  static Future<void> _deleteRecordFromTable(
    String tableName,
    Note note,
  ) async {
    if (note.id != null) {
      await supabase.from(tableName).delete().eq('id', note.id!);
    } else if (note.createdAt != null) {
      await supabase
          .from(tableName)
          .delete()
          .eq('created_at', note.createdAt!.toIso8601String());
    } else {
      await supabase.from(tableName).delete().eq('title', note.title);
    }
  }
}
