import 'package:supabase_flutter/supabase_flutter.dart';

class UserInstance {
  static String? get idUser => Supabase.instance.client.auth.currentSession?.user.id;
  static bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;
}
