import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Pool of audio players for overlapping sounds
  final List<AudioPlayer> _playerPool = [];
  static const int _maxPlayers = 7; // Maximum simultaneous sounds
  int _currentPlayerIndex = 0;

  AudioPlayer _getNextPlayer() {
    // Create players on demand up to max
    if (_playerPool.length < _maxPlayers) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.stop);
      _playerPool.add(player);
      return player;
    }

    // Rotate through existing players
    final player = _playerPool[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _maxPlayers;
    return player;
  }

  Future<void> playClick() async {
    print('🔊 Playing click sound...'); // Keep for debugging
    try {
      final player = _getNextPlayer();
      await player.play(AssetSource('audio/click.mp3'));
      print('✅ Sound played successfully');
    } catch (e) {
      print('❌ Error playing sound: $e');
    }
  }

  void dispose() {
    for (var player in _playerPool) {
      player.dispose();
    }
    _playerPool.clear();
  }
}