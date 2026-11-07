import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInstance {
  static SupabaseClient get client => Supabase.instance.client;
}

SupabaseClient get supabase => SupabaseInstance.client;
