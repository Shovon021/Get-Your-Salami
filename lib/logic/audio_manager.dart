import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Separate players for each audio type to avoid conflicts
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _whooshPlayer = AudioPlayer();

  bool _isMusicOn = false; // Default OFF as per user request
  bool _isSfxOn = true;

  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn => _isSfxOn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isMusicOn = prefs.getBool('music_on') ?? false; // Default OFF
    _isSfxOn = prefs.getBool('sfx_on') ?? true;

    // Configure all players for concurrent playback
    await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _tickPlayer.setPlayerMode(PlayerMode.lowLatency);
    await _whooshPlayer.setPlayerMode(PlayerMode.lowLatency);

    // Start BGM if enabled
    if (_isMusicOn) {
      await playBGM();
    }
  }

  Future<void> toggleMusic(bool value) async {
    _isMusicOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_on', value);

    if (_isMusicOn) {
      playBGM();
    } else {
      _musicPlayer.stop();
    }
  }

  Future<void> toggleSfx(bool value) async {
    _isSfxOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_on', value);
  }

  Future<void> playBGM() async {
    if (!_isMusicOn) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('audio/bgm.mp3'), volume: 0.35);
    } catch (e) {
      // Silently ignore
    }
  }

  Future<void> playTick() async {
    if (!_isSfxOn) return;
    try {
      await _tickPlayer.stop();
      await _tickPlayer.play(AssetSource('audio/tick.mp3'), volume: 0.7);
    } catch (e) {
      // Silently ignore
    }
  }

  Future<void> playWin() async {
    if (!_isSfxOn) return;
    try {
      // Use fresh player to ensure sound plays without conflicts
      final winPlayer = AudioPlayer();
      await winPlayer.setPlayerMode(PlayerMode.lowLatency);
      await winPlayer.play(AssetSource('audio/win.mp3'), volume: 1.0);
    } catch (e) {
      // Silently ignore
    }
  }

  Future<void> playSpinWhoosh() async {
    if (!_isSfxOn) return;
    try {
      await _whooshPlayer.stop();
      await _whooshPlayer.play(AssetSource('audio/spin_whoosh.mp3'), volume: 1.0);
    } catch (e) {
      // Silently ignore
    }
  }

  Future<void> stopSpinWhoosh() async {
    try {
      await _whooshPlayer.stop();
    } catch (e) {
      // Silently ignore
    }
  }
}
