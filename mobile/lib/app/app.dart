import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookish_corner/core/router/app_router.dart';
import 'package:bookish_corner/core/theme/app_theme.dart';

class BookishApp extends ConsumerWidget {
  const BookishApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Bookish Corner',
      routerConfig: ref.watch(goRouterProvider),
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
