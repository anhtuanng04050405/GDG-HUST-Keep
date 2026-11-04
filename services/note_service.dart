import 'package:flutter/foundation.dart';
import '../instance/supabase_instance.dart';
import '../models/note.dart';

class NoteService {
  static const String _homeTable = 'data_home';
  static const String _archiveTable = 'data_archive';

  static List<Note> cachedHomeNotes = [];
  static List<Note> cachedArchiveNotes = [];

  static void clearCache() {
    cachedHomeNotes = [];
    cachedArchiveNotes = [];
  }

  // Không bao giờ truy vấn ghi chú khi chưa có session thực.
  static String _requireUserId() {
    final uid = supabase.auth.currentSession?.user.id;
    if (uid == null) {
      throw StateError('Vui lòng đăng nhập để truy cập ghi chú.');
    }
    return uid;
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
      debugPrint('NoteService.saveNote error: $e');
      rethrow;
    }
  }

  static Future<void> archiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
  }) async {
    await _moveNote(
      source: _homeTable,
      destination: _archiveTable,
      existingNote: existingNote,
      title: title,
      content: content,
      pin: pin,
      color: color,
    );
  }

  static Future<void> unarchiveNote({
    Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    String color = 'default',
  }) async {
    await _moveNote(
      source: _archiveTable,
      destination: _homeTable,
      existingNote: existingNote,
      title: title,
      content: content,
      pin: pin,
      color: color,
    );
  }

  static Future<void> _moveNote({
    required String source,
    required String destination,
    required Note? existingNote,
    required String title,
    required String content,
    required bool pin,
    required String color,
  }) async {
    final uid = _requireUserId();
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();
    if (existingNote == null && trimmedTitle.isEmpty && trimmedContent.isEmpty) {
      return;
    }
    if (existingNote != null) _checkOwnedNote(existingNote, uid);

    // Trước khi di chuyển, xác nhận bản ghi nguồn còn tồn tại và thuộc user.
    // Tránh tạo bản sao khi ghi chú đã bị xóa trên thiết bị khác.
    if (existingNote != null) {
      final sourceRecord = await supabase.from(source)
          .select('id')
          .eq('id', existingNote.id!)
          .eq('user_id', uid)
          .maybeSingle();
      if (sourceRecord == null) {
        throw StateError('Ghi chú không còn tồn tại hoặc không thuộc tài khoản này.');
      }
    }

    // Giữ hành vi hiện tại: copy sang bảng đích rồi xóa nguồn.
    // Hai thao tác không atomic; nếu cần đảm bảo tuyệt đối, thay bằng RPC transaction.
    await supabase.from(destination).insert({
      'user_id': uid,
      'title': trimmedTitle,
      'content': trimmedContent,
      'pin': pin,
      'color': color,
      'edited_at': DateTime.now().toUtc().toIso8601String(),
    });

    if (existingNote != null) {
      await _deleteRecordFromTable(source, existingNote, uid);
    }
  }

  static Future<void> deleteNote(Note note) async {
    final uid = _requireUserId();
    _checkOwnedNote(note, uid);
    await _deleteRecordFromTable(_archiveTable, note, uid);
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

  // Chỉ cho phép tác động lên ID cụ thể của ghi chú đang sở hữu.
  static void _checkOwnedNote(Note note, String uid) {
    if (note.id == null || note.userId != uid) {
      throw StateError('Ghi chú không hợp lệ hoặc không thuộc tài khoản hiện tại.');
    }
  }

  static Future<void> _deleteRecordFromTable(
    String table,
    Note note,
    String uid,
  ) async {
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
