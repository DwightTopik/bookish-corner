import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:bookish_corner/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'bookish_corner.audio',
    androidNotificationChannelName: 'Audiobook playback',
    androidNotificationOngoing: true,
    rewindInterval: const Duration(seconds: 15),
    fastForwardInterval: const Duration(seconds: 30),
  );
  runApp(const ProviderScope(child: BookishApp()));
}
