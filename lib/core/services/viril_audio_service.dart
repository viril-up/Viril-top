import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide ambient music controller. The audio asset is supplied separately
/// by placing background_music.mp3 in assets/audio/.
class VirilAudioService extends ChangeNotifier {
  VirilAudioService._();

  static final VirilAudioService instance = VirilAudioService._();

  static const _enabledKey = 'viril.audio.background.enabled.v1';
  static const _volumeKey = 'viril.audio.background.volume.v1';
  static const _assetPath = 'audio/background_music.mp3';

  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;
  double _volume = 0.16;
  bool _initialized = false;
  bool _foreground = true;
  bool _playing = false;

  bool get enabled => _enabled;
  double get volume => _volume;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    _volume = (prefs.getDouble(_volumeKey) ?? 0.16).clamp(0.0, 1.0).toDouble();

    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_volume);
    if (_enabled && _foreground) {
      await _startPlayback();
    }
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);

    if (value && _foreground) {
      await _startPlayback();
    } else {
      await _stopPlayback();
    }
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0).toDouble();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
    try {
      await _player.setVolume(_volume);
    } catch (error) {
      debugPrint('Viril music volume update failed: $error');
    }
  }

  Future<void> handleLifecycle(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _foreground = true;
      if (_enabled) await _startPlayback();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _foreground = false;
      await _stopPlayback();
    }
  }

  Future<void> _startPlayback() async {
    if (_playing || !_enabled || !_foreground) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
      await _player.play(AssetSource(_assetPath));
      _playing = true;
    } catch (error) {
      // The app remains usable before the owner adds the optional audio file.
      debugPrint('Viril background music is not available yet: $error');
      _playing = false;
    }
  }

  Future<void> _stopPlayback() async {
    if (!_playing) return;
    try {
      await _player.pause();
    } catch (error) {
      debugPrint('Viril background music pause failed: $error');
    } finally {
      _playing = false;
    }
  }
}
