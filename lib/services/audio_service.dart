import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  String? _currentBgm;

  // BGM volume (0.0 to 1.0)
  double _bgmVolume = 0.6;
  double _sfxVolume = 0.8;

  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;

  Future<void> initialize() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
      await _bgmPlayer.setVolume(_bgmVolume);
      await _sfxPlayer.setVolume(_sfxVolume);
      if (kDebugMode) {
        debugPrint('✅ AudioService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ AudioService initialization error: $e');
      }
    }
  }

  Future<void> playBgm(String assetPath) async {
    if (!_isBgmEnabled) return;
    
    // 同じBGMが再生中なら何もしない
    if (_currentBgm == assetPath && _bgmPlayer.state == PlayerState.playing) {
      return;
    }

    try {
      await _bgmPlayer.stop();
      _currentBgm = assetPath;
      await _bgmPlayer.play(AssetSource(assetPath));
      if (kDebugMode) {
        debugPrint('🎵 BGM started: $assetPath');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ BGM play error: $e');
      }
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _currentBgm = null;
    if (kDebugMode) {
      debugPrint('🎵 BGM stopped');
    }
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (_isBgmEnabled && _currentBgm != null) {
      await _bgmPlayer.resume();
    }
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    
    try {
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ SFX play error: $e');
      }
    }
  }

  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    if (!enabled) {
      stopBgm();
    } else if (_currentBgm != null) {
      playBgm(_currentBgm!);
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    _bgmPlayer.setVolume(_bgmVolume);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _sfxPlayer.setVolume(_sfxVolume);
  }

  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
