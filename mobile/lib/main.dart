import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/app/app.dart';

void main() {
  runApp(const ProviderScope(child: BookishApp()));
}
