import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioPlayer? _musicPlayer;
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;

  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> init() async {
    _musicPlayer ??= AudioPlayer(playerId: 'music');
    // attempt to loop a background track if available at assets/audio/bgm.mp3
    // The project currently does not include audio assets by default.
  }

  Future<void> setMusicVolume(double v) async {
    _musicVolume = v.clamp(0.0, 1.0);
    if (_musicPlayer != null) await _musicPlayer!.setVolume(_musicVolume);
  }

  Future<void> setSfxVolume(double v) async {
    _sfxVolume = v.clamp(0.0, 1.0);
  }

  Future<void> playMusicFromAsset(String assetPath, {bool loop = true}) async {
    await init();
    if (_musicPlayer == null) return;
    await _musicPlayer!.stop();
    await _musicPlayer!.setSource(AssetSource(assetPath));
    await _musicPlayer!.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await _musicPlayer!.setVolume(_musicVolume);
    await _musicPlayer!.resume();
  }

  Future<void> stopMusic() async {
    if (_musicPlayer != null) await _musicPlayer!.stop();
  }

  Future<void> playSfxFromAsset(String assetPath) async {
    final player = AudioPlayer();
    await player.setSource(AssetSource(assetPath));
    await player.setVolume(_sfxVolume);
    await player.resume();
    // let the player be GC'd after playback
  }
}
