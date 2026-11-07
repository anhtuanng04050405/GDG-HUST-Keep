import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase_config.dart';

class AuthService {
  static const String emailRedirectUrl = 'ggkeep://login-callback/';

  static Future<AuthResponse> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username.trim(),
      },
      emailRedirectTo: emailRedirectUrl,
    );
    final user = response.user;
    if (user != null && (user.identities == null || user.identities!.isEmpty)) {
      throw const AuthException('Email này đã được đăng ký tài khoản.');
    }
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (response.session == null) {
      throw const AuthException('Vui lòng xác thực email.');
    }
    return response;
  }

  static String? get currentUserId => supabase.auth.currentSession?.user.id;

  static Future<void> signOut() => supabase.auth.signOut();
}
