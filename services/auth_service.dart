import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

class AuthService {
  // Đăng ký tài khoản mới qua Supabase Auth và đồng bộ vào bảng login.
  static Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = email.trim();

    // 1. Kiểm tra xem username đã tồn tại trong bảng login chưa
    try {
      final existing = await supabase
          .from('login')
          .select('id_user')
          .eq('username', cleanUsername)
          .maybeSingle();

      if (existing != null) {
        throw const AuthException('Tên người dùng đã tồn tại. Vui lòng chọn tên khác.');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      debugPrint('AuthService.checkUsername error: $e');
    }

    // 2. Đăng ký tài khoản qua Supabase Auth
    final response = await supabase.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {
        'username': cleanUsername,
      },
    );

    // 3. Đồng bộ tài khoản vào bảng login để người dùng có thể đăng nhập ngay trong ứng dụng
    try {
      final lastUser = await supabase
          .from('login')
          .select('id_user')
          .order('id_user', ascending: false)
          .limit(1)
          .maybeSingle();

      final nextId = (lastUser != null && lastUser['id_user'] != null)
          ? ((lastUser['id_user'] is int)
              ? lastUser['id_user'] as int
              : int.tryParse(lastUser['id_user'].toString()) ?? 1) + 1
          : 1;

      await supabase.from('login').insert({
        'id_user': nextId,
        'username': cleanUsername,
        'password': password,
      });
      debugPrint('AuthService: Đã đồng bộ tài khoản $cleanUsername vào bảng login (id_user=$nextId)');
    } catch (e) {
      debugPrint('AuthService sync login error: $e');
    }

    return response;
  }

  // Đăng nhập bằng email và mật khẩu.
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ID của người dùng đang đăng nhập.
  // Trả về null nếu chưa có tài khoản đăng nhập.
  static String? get currentUserId {
    return supabase.auth.currentUser?.id;
  }

  // Đăng xuất khỏi tài khoản.
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
