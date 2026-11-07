import 'package:flutter/foundation.dart';
import '../instance/supabase_instance.dart';
import '../models/note.dart';

enum NoteSortMode { title, createdAt, editedAt }
class NoteService {

  // Kiểm tra session đăng nhập
  static String _requireUserId() {
    final uid = supabase.auth.currentSession?.user.id;
    if (uid == null) {
      throw StateError('Vui lòng đăng nhập để truy cập ghi chú.');
    }
    return uid;
  }
  static void _checkOwnedNote(Note note, String uid) {
    if (note.id == null || note.userId != uid) {
      throw StateError('Ghi chú không hợp lệ hoặc không thuộc tài khoản hiện tại.');
    }
  }

  // Lấy các ghi chú
  static const String _homeTable = 'data_home';
  static const String _archiveTable = 'data_archive';
  static List<Note> cachedHomeNotes = [];
  static List<Note> cachedArchiveNotes = [];
  static void clearCache() {
    cachedHomeNotes = [];
    cachedArchiveNotes = [];
  }
  static Future<List<Note>> _fetchNotesFromTable(String table) async {
    final uid = _requireUserId();
    try {
      final rows = await supabase.from(table)
          .select()
          .eq('user_id', uid)
          .order('pin', ascending: false)
          .order('edited_at', ascending: false);
      return (rows as List).map((row) => Note.fromMap(row)).toList();
    } catch (e) {
      debugPrint('NoteService.loadNotes ($table) error: $e');
      rethrow;
    }
  }
  static Future<List<Note>> getHomeNotes() async {
    final data = await _fetchNotesFromTable(_homeTable);
    cachedHomeNotes = data;
    return data;
  }
  static Future<List<Note>> getArchiveNotes() async {
    final data = await _fetchNotesFromTable(_archiveTable);
    cachedArchiveNotes = data;
    return data;
  }

  // Sắp xếp các ghi chú
  static List<Note> sortNotes(List<Note> notes, NoteSortMode mode) {
    final sortedNotes = List<Note>.from(notes);
    sortedNotes.sort((a, b) {
      if (a.pin != b.pin) {
        return a.pin ? -1 : 1;
      }
      switch (mode) {
        case NoteSortMode.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case NoteSortMode.createdAt:
          return _compareNewestFirst(a.createdAt, b.createdAt);
        case NoteSortMode.editedAt:
          final dateA = a.editedAt ?? a.createdAt;
          final dateB = b.editedAt ?? b.createdAt;
          return _compareNewestFirst(dateA, dateB);
      }
    });
    return sortedNotes;
  }
  static int _compareNewestFirst(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  // Lưu ghi chú
  static Future<void> saveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
    bool isArchive = false,
  }) async {
    final uid = _requireUserId();
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();
    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }
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
        _checkOwnedNote(existingNote, uid);
        final changes = <String, dynamic>{
          'title': trimmedTitle,
          'content': trimmedContent,
          'pin': pin,
          'color': color,
          'edited_at': nowUtc,
        };
        final updated = await supabase.from(table)
            .update(changes)
            .eq('id', existingNote.id!)
            .eq('user_id', uid)
            .select('id')
            .maybeSingle();
        if (updated == null) {
          throw StateError('Không thể sửa ghi chú: bản ghi đã mất hoặc không thuộc tài khoản này.');
        }
      } else {
        await supabase.from(table).insert({
          'user_id': uid,
          'title': trimmedTitle,
          'content': trimmedContent,
          'pin': pin,
          'color': color,
          'edited_at': nowUtc,
        });
      }
    } catch (e) {
      debugPrint('Có lỗi xảy ra.');
      rethrow;
    }
  }

  // Chuyển ghi chú vào phần lưu trữ và ngược lại
  static Future<void> archiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
  }) async {
    final uid = _requireUserId();
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();
    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }
    if (existingNote != null) _checkOwnedNote(existingNote, uid);
    if (existingNote != null) {
      final sourceRecord = await supabase.from(_homeTable)
          .select('id')
          .eq('id', existingNote.id!)
          .eq('user_id', uid)
          .maybeSingle();
      if (sourceRecord == null) {
        throw StateError('Ghi chú không còn tồn tại hoặc không thuộc tài khoản này.');
      }
    }
    await supabase.from(_archiveTable).insert({
      'user_id': uid,
      'title': trimmedTitle,
      'content': trimmedContent,
      'pin': pin,
      'color': color,
      'edited_at': DateTime.now().toUtc().toIso8601String(),
    });
    if (existingNote != null) {
      await deleteNote(existingNote, table: _homeTable);
    }
  }

  static Future<void> unarchiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
  }) async {
    final uid = _requireUserId();
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();
    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }
    if (existingNote != null) _checkOwnedNote(existingNote, uid);
    if (existingNote != null) {
      final sourceRecord = await supabase.from(_archiveTable)
          .select('id')
          .eq('id', existingNote.id!)
          .eq('user_id', uid)
          .maybeSingle();
      if (sourceRecord == null) {
        throw StateError('Ghi chú không còn tồn tại hoặc không thuộc tài khoản này.');
      }
    }
    await supabase.from(_homeTable).insert({
      'user_id': uid,
      'title': trimmedTitle,
      'content': trimmedContent,
      'pin': pin,
      'color': color,
      'edited_at': DateTime.now().toUtc().toIso8601String(),
    });
    if (existingNote != null) {
      await deleteNote(existingNote, table: _archiveTable);
    }
  }

  // Xóa ghi chú
  static Future<void> deleteNote(Note note, {required String table}) async {
    final uid = _requireUserId();
    _checkOwnedNote(note, uid);
    final deleted = await supabase.from(table)
        .delete()
        .eq('id', note.id!)
        .eq('user_id', uid)
        .select('id')
        .maybeSingle();
    if (deleted == null) {
      throw StateError('Không thể xóa ghi chú: bản ghi đã mất hoặc không thuộc tài khoản này.');
    }
  }
}
