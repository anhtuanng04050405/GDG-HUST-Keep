# GDG Keep — chuyển sang Supabase Auth UUID (nguồn: branch `3.11`)

## Đây là gì?

Bản sửa **không tự kết nối và không cập nhật Supabase production**. Đây là mã Flutter đã sửa và các SQL migration cần **nhóm xem lại, backup và chạy trong SQL Editor**. Đừng đè toàn bộ ZIP lên project Flutter đang chạy trên máy; branch `3.11` thiếu Android build scaffold, trong khi máy đã tạo lại scaffold cục bộ.

## Đã đổi trong code

- `AuthService.signUp`: chỉ đăng ký bằng Supabase Auth; lưu `username` vào user metadata. **Không** ghi `username`/mật khẩu vào bảng `public.login` nữa.
- Login: email + password qua `signInWithPassword()`. Nếu email chưa verified thì hiện lỗi rõ ràng.
- Logout: Supabase Auth signOut; xóa cache ghi chú; không lưu `id_user` vào SharedPreferences.
- Welcome: vào Home nếu đã có session Supabase; nếu không thì mở Login.
- `Note.userId`: UUID dạng `String?`, lấy từ `user_id` thay cho `id_user` số nguyên.
- `NoteService`: **không bao giờ** query không lọc khi chưa có session; tất cả read/write/delete theo UUID tài khoản. Không xóa/cập nhật theo title khi thiếu note ID.
- `pubspec.yaml`: thêm `shared_preferences` (SettingsService đã dùng nhưng branch gốc chưa khai báo).

## Trước khi chạy phần ghi chú

1. Backup database Supabase (ít nhất `public.data_home`, `public.data_archive`, `public.login`), và xác nhận dự án Supabase chính xác.
2. Chạy `sql/01_add_user_id_uuid.sql` trong SQL Editor. Tạo thêm cột `user_id uuid` **không xóa** `id_user` cũ.
3. **Gán lại chủ sở hữu ghi chú cũ**, vì `id_user = 1, 2,...` trong bảng `login` không có ánh xạ đáng tin cậy sang UUID `auth.users.id`. Nhóm phải xác minh ai sở hữu dòng dữ liệu nào. Ví dụ sau chỉ dành để đọc và sửa, KHÔNG chạy khi chưa xác minh mapping:

   ```sql
   -- Ví dụ: nếu đã xác minh id_user 1 thuộc về tài khoản UUID XYZ:
   -- UPDATE public.data_home SET user_id = 'UUID_XYZ'::uuid WHERE id_user = 1 AND user_id IS NULL;
   -- UPDATE public.data_archive SET user_id = 'UUID_XYZ'::uuid WHERE id_user = 1 AND user_id IS NULL;
   ```

4. Kiểm tra ghi chú chưa gán owner:
   ```sql
   SELECT count(*) AS orphan_home FROM public.data_home WHERE user_id IS NULL;
   SELECT count(*) AS orphan_archive FROM public.data_archive WHERE user_id IS NULL;
   ```
   Những bản ghi này **vẫn còn**, nhưng app UUID sẽ không xem được. Đừng tự động gán hết cho tài khoản đầu tiên.
5. Chạy `sql/02_enable_note_rls.sql` **sau khi** rà soát mọi policy cũ và đã sẵn sàng cutover client. Script cố ý dừng nếu có policy sẵn cần xem lại.
6. Chạy `sql/03_disable_insecure_legacy_login.sql` khi các app phiên bản cũ đã ngừng đăng nhập qua bảng `login`. Sau khi kiểm tra thành công và có bản backup, cần loại bỏ mật khẩu plaintext còn lưu ở bảng cũ.

### Lưu ý liên quan database

- Nếu bảng có trigger/constraint khác (đặc biệt `id_user` hoặc chính sách liên quan), kiểm tra chúng trước. Script 01 chỉ hạ điều kiện NOT NULL của cột `id_user` nếu có; không xóa dữ liệu.
- RLS cùng `user_id` UUID ngăn thao tác trái phép ngay cả khi ai đó cố sửa tham số từ app. Không dùng `service_role` key ở client Flutter.
- `archiveNote`/`unarchiveNote` hiện vẫn gồm **hai lệnh** insert + delete. Chưa atomic: nếu mạng ngắt giữa chừng có thể bị trùng note. Để production-grade, nên chuyển thao tác sang Postgres RPC transaction.
- `username` trong Auth metadata **không có unique constraint**, chỉ là tên hiển thị. Nếu cần unique username, thiết kế bảng profile riêng và constraint riêng.
- Email xác nhận đang chuyển về Supabase `SITE_URL` (trước đó thấy localhost). Có thể email đã được xác nhận trước khi trang redirect lỗi. Kiểm tra Authentication > Users. Muốn quay lại app tự động, cấu hình App Links/deep links + Auth Redirect URLs cho Android.
- Vẫn cần chạy `flutter analyze` và test trên emulator sau khi áp các file vào Flutter project đang build được. ZIP xuất từ `3.11` không có đầy đủ Android scaffold để build độc lập.

## Kiểm thử bắt buộc

- Đăng ký user A, nhận email confirm, xác nhận, rồi đăng nhập email/password.
- Đăng xuất, đăng nhập user B, kiểm tra không thấy ghi chú của user A.
- User A tạo/sửa/lưu trữ/khôi phục/xóa note; user B không đọc/sửa/xóa được note đó (kiểm tra cả SQL/RLS và HTTP truy vấn bằng JWT).
- Thử mở app không có session: không được fetch toàn bộ ghi chú công khai.
- Kiểm tra `auth.users.id` trùng `data_home.user_id`/`data_archive.user_id`.
- Kiểm thử restart app và refresh session.

## Cách áp bản sửa qua Git

Tạo worktree riêng từ `origin/3.11` để **không động vào branch `feature/signup` hoặc cấu hình Android chưa track**:

```bash
cd ~/AndroidStudioProjects/ggkeep_team
git fetch origin --prune
git worktree add -b feature/auth-uuid ../ggkeep_auth_uuid origin/3.11
cd ../ggkeep_auth_uuid
# Giải nén ggkeep_auth_patch.zip của bạn vào đây, cho phép thay các file trùng tên.
git status -sb
git diff --check
```

Thay vì ghi đè toàn bộ source, bạn có thể dùng `ggkeep_auth_3_11.patch`:

```bash
git apply --check ~/Downloads/ggkeep_auth_3_11.patch
git apply ~/Downloads/ggkeep_auth_3_11.patch
```

Chỉ dùng **một** trong hai cách. Không merge / push vào main trước khi review database migration. Với Flutter project dạng root `main.dart` (không phải `lib/main.dart`), chạy `flutter run -t main.dart`. Tạo/copy Android build scaffold nếu chưa có; đừng commit đường dẫn máy cá nhân, `.idea`, `.dart_tool`, `build`, `local.properties`, hoặc service keys.
