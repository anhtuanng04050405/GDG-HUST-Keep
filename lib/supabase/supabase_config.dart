import 'package:supabase_flutter/supabase_flutter.dart';
export '../instance/supabase_instance.dart';

class SupabaseConfig {
  static const String url = 'https://sfzzebjtcktaoegwazzl.supabase.co';
  static const String publishableKey = 'sb_publishable_O-FwBm_FXthBVn4zLzhwkA_LS_D6e-C';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );
  }
}
