import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Lớp tương thích với Drawer; không truy vấn bảng public.login.
class LoginService {
  static String? get currentUserId => AuthService.currentUserId;

  static Future<String> login(String email, String password) async {
    final response = await AuthService.signIn(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw const AuthException('Chưa có phiên đăng nhập hợp lệ.');
    }
    return response.session!.user.id;
  }

  static Future<void> logout() => AuthService.signOut();
}
