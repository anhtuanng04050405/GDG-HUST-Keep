import 'note.dart';

// Các kiểu sắp xếp mà người dùng có thể chọn.
enum NoteSortMode { title, createdAt, editedAt }

// Nhận danh sách ghi chú và trả về danh sách đã sắp xếp.
List<Note> sortNotes(List<Note> notes, NoteSortMode mode) {
  // Tạo bản sao để không thay đổi danh sách gốc.
  final sortedNotes = List<Note>.from(notes);

  sortedNotes.sort((a, b) {
    // Ghi chú được ghim luôn nằm phía trên.
    if (a.pin != b.pin) {
      return a.pin ? -1 : 1;
    }

    // Chọn cách so sánh theo chế độ sắp xếp.
    switch (mode) {
      case NoteSortMode.title:
        // So sánh tên A-Z, không phân biệt chữ hoa/chữ thường.
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());

      case NoteSortMode.createdAt:
        // Ngày tạo mới nhất hiển thị trước.
        return _compareNewestFirst(a.createdAt, b.createdAt);

      case NoteSortMode.editedAt:
        // Chưa từng sửa thì dùng ngày tạo thay thế.
        final dateA = a.editedAt ?? a.createdAt;
        final dateB = b.editedAt ?? b.createdAt;

        return _compareNewestFirst(dateA, dateB);
    }
  });

  return sortedNotes;
}

// So sánh ngày theo thứ tự mới nhất đến cũ nhất.
int _compareNewestFirst(DateTime? a, DateTime? b) {
  // Hai ghi chú cùng thiếu ngày thì giữ mức ưu tiên ngang nhau.
  if (a == null && b == null) return 0;

  // Ghi chú không có ngày được xếp cuối.
  if (a == null) return 1;
  if (b == null) return -1;

  // Đổi thứ tự so sánh để ngày mới nằm phía trên.
  return b.compareTo(a);
}
