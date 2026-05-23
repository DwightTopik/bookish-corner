import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            const Text('Profile'),
            FilledButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
