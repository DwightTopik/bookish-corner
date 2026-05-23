import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Reader')),
    );
  }
}
