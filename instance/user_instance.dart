import 'package:supabase_flutter/supabase_flutter.dart';

/// Tương thích với code cũ. UID lấy từ session Supabase Auth,
/// không lưu riêng ID cục bộ (vốn có thể bị thay đổi trên thiết bị).
class UserInstance {
  static String? get idUser => Supabase.instance.client.auth.currentSession?.user.id;
  static bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;
}
