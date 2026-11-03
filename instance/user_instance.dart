import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInstance {
  static const String _keyUserId = 'current_id_user';

  /// Biến tĩnh lưu id_user
  static int? idUser;

  static bool get isLoggedIn => idUser != null;

  static Future<int?> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      idUser = prefs.getInt(_keyUserId);
      debugPrint('UserInstance.init: id_user = $idUser');
      return idUser;
    } catch (e) {
      debugPrint('UserInstance.init error: $e');
      return null;
    }
  }

  static Future<int?> getIdUser() async {
    if (idUser != null) return idUser;
    return await init();
  }

  static Future<void> setUserId(int? id) async {
    idUser = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id != null) {
        await prefs.setInt(_keyUserId, id);
      } else {
        await prefs.remove(_keyUserId);
      }
      debugPrint('UserInstance: Cập nhật id_user = $id');
    } catch (e) {
      debugPrint('UserInstance.setUserId error: $e');
    }
  }

  static Future<void> clear() async {
    await setUserId(null);
  }
}
