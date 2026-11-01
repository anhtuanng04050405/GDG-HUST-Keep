import 'package:flutter/material.dart';

class NoteLoading extends StatelessWidget {
  const NoteLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      // Hiển thị GIF khi đang tải ghi chú.
      child: Image.asset(
        'assets/indicator/loading.gif',
        width: 100,
        height: 100,
        fit: BoxFit.contain,

        // Dùng loading mặc định nếu GIF không tải được.
        errorBuilder: (context, error, stackTrace) {
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
