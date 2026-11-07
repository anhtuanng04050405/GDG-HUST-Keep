import 'package:flutter/material.dart';

class NoteLoading extends StatelessWidget {
  const NoteLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/indicator/loading.gif',
        width: MediaQuery.of(context).size.width * 0.75,
        fit: BoxFit.contain,

        errorBuilder: (context, error, stackTrace) {
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
