import 'package:bookish_corner/features/player/domain/audio_progress.dart';

abstract class AudioProgressRepository {
  Future<AudioProgress?> getProgress(String bookId);
  Future<void> saveProgress(AudioProgress progress);
  Future<void> deleteProgress(String bookId);
}
