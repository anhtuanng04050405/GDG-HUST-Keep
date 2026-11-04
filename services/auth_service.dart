
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

/// Supabase Auth là nguồn xác thực duy nhất.
/// Không lưu mật khẩu trong public.login hoặc SharedPreferences.
class AuthService {
  static const String emailRedirectUrl =
      'ggkeep://login-callback/';

  static Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    return supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username.trim(),
      },
      emailRedirectTo: emailRedirectUrl,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  static String? get currentUserId =>
      supabase.auth.currentSession?.user.id;

  static Future<void> signOut() =>
      supabase.auth.signOut();
}
