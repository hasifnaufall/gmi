// lib/services/sfx_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Simple, reusable sound-effects helper used by quiz screens.
/// Make sure your pubspec has:
/// assets:
///   - audio/streak.wav
///   - audio/level_complete.wav
class Sfx {
  // Singleton
  static final Sfx _instance = Sfx._internal();
  factory Sfx() => _instance;
  Sfx._internal();

  final AudioPlayer _fxA = AudioPlayer();
  final AudioPlayer _fxB = AudioPlayer();

  bool _inited = false;

  /// Safe to call multiple times.
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    try {
      // Best for short sfx; avoid mixing with long music here
      await _fxA.setPlayerMode(PlayerMode.lowLatency);
      await _fxB.setPlayerMode(PlayerMode.lowLatency);

      // We keep default volume (1.0). Change if you like:
      // await _fxA.setVolume(1.0);
      // await _fxB.setVolume(1.0);

      // Stop after playing each clip
      await _fxA.setReleaseMode(ReleaseMode.stop);
      await _fxB.setReleaseMode(ReleaseMode.stop);
    } catch (e) {
      debugPrint('Sfx init error: $e');
    }
  }

  /// Plays the "level complete" sound.
  Future<void> playLevelComplete() async {
    try {
      // Use one player for this category of sound to prevent overlap tails
      await _fxA.stop();
      await _fxA.play(AssetSource('audio/level_complete.wav'));
    } catch (e) {
      debugPrint('Sfx playLevelComplete error: $e');
    }
  }

  /// Plays the "streak up" sound.
  Future<void> playStreak() async {
    try {
      await _fxB.stop();
      await _fxB.play(AssetSource('audio/streak.wav'));
    } catch (e) {
      debugPrint('Sfx playStreak error: $e');
    }
  }

  /// Optional: call if you ever want to fully release players.
  Future<void> dispose() async {
    try {
      await _fxA.dispose();
      await _fxB.dispose();
    } catch (e) {
      debugPrint('Sfx dispose error: $e');
    }
  }
}
