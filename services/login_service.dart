import 'package:flutter/foundation.dart';
import '../instance/main_instance.dart';

class LoginService {
  static const String _tableName = 'login';

  /// id_user hiện tại thông qua UserInstance
  static int? get currentUserId => UserInstance.idUser;
  static set currentUserId(int? value) => UserInstance.idUser = value;

  /// Khởi tạo và đọc id_user đã lưu từ SharedPreferences nếu có
  static Future<int?> init() async {
    return await UserInstance.init();
  }

  /// Lấy id_user hiện tại
  static Future<int?> getSavedUserId() async {
    return await UserInstance.getIdUser();
  }

  /// Kiểm tra xem có tồn tại username và password trong bảng login không.
  /// Nếu có: lưu lại id_user và trả về id_user.
  /// Nếu không: trả về null.
  static Future<int?> login(String username, String password) async {
    try {
      final response = await supabase
          .from(_tableName)
          .select('id_user, username, password')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null && response['id_user'] != null) {
        final idUser = response['id_user'] is int
            ? response['id_user'] as int
            : int.tryParse(response['id_user'].toString());

        if (idUser != null) {
          await UserInstance.setUserId(idUser);
          debugPrint('LoginService: Đăng nhập thành công, id_user = $idUser');
          return idUser;
        }
      }

      debugPrint('LoginService: Sai thông tin đăng nhập');
      return null;
    } catch (e) {
      debugPrint('LoginService.login error: $e');
      rethrow;
    }
  }

  /// Đăng xuất: xóa id_user
  static Future<void> logout() async {
    await UserInstance.clear();
    debugPrint('LoginService: Đã đăng xuất và xóa id_user');
  }
}
