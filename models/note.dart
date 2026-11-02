class Note {
  final int? id;
  final String title;
  final String content;
  final bool pin;
  final String color;
  final DateTime? createdAt;
  final DateTime? editedAt;

  // Constructor
  const Note({
    this.id,
    this.title = '',
    this.content = '',
    this.pin = false,
    this.color = 'default',
    this.createdAt,
    this.editedAt,
  });

  // Chuyển dữ liệu từ supabase thành note object
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] is int
          ? map['id'] as int
          : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      pin: map['pin'] == true,
      color: map['color']?.toString() ?? 'default',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      editedAt: map['edited_at'] != null
          ? DateTime.tryParse(map['edited_at'].toString())
          : null,
    );
  }

  // Chuyển 1 note object thành 1 map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'pin': pin,
      'color': color,
      'created_at': createdAt,
      'edited_at': (editedAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
  }

  // Tạo một bản sao của note, được sử dụng trong khi thay đổi nội dung
  Note copyWith({
    int? id,
    String? title,
    String? content,
    bool? pin,
    String? color,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      pin: pin ?? this.pin,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }
}
