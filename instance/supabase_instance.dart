import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInstance {
  static SupabaseClient get client => Supabase.instance.client;
}

/// Biến toàn cục dùng chung cho tiện truy cập
SupabaseClient get supabase => SupabaseInstance.client;
