
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

class AuthService {
  // Đăng ký tài khoản mới qua Supabase Auth.
  static Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username.trim(),
      },
    );
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
