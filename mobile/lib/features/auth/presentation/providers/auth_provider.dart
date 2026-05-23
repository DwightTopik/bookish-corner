import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthState { guest, authenticated, loading }

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => .guest;
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
