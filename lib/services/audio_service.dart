import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages, avoid_web_libraries_in_flutter
import 'package:js/js.dart' if (dart.library.io) '../stub/js_stub.dart';

// JS interop for FlutterAudioPlayer (Web only)
// ignore: non_constant_identifier_names
@JS('FlutterAudioPlayer.playBgm')
external void _jsBgmPlay(String src, bool loop);

@JS('FlutterAudioPlayer.stopBgm')
external void _jsBgmStop();

@JS('FlutterAudioPlayer.pauseBgm')
external void _jsBgmPause();

@JS('FlutterAudioPlayer.resumeBgm')
external void _jsBgmResume();

@JS('FlutterAudioPlayer.setBgmEnabled')
external void _jsBgmSetEnabled(bool enabled);

@JS('FlutterAudioPlayer.setBgmVolume')
external void _jsBgmSetVolume(double volume);

@JS('FlutterAudioPlayer.playSfx')
external void _jsSfxPlay(String src);

@JS('FlutterAudioPlayer.setSfxEnabled')
external void _jsSfxSetEnabled(bool enabled);

@JS('FlutterAudioPlayer.setSfxVolume')
external void _jsSfxSetVolume(double volume);

@JS('FlutterAudioPlayer.isBgmPlaying')
external bool _jsBgmIsPlaying();

/// AudioService - Web版はJS interop経由でHTML5 Audioを使用
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isBgmEnabled = true;
  bool _isSfxEnabled = true;
  String? _currentBgm;
  double _bgmVolume = 0.6;
  double _sfxVolume = 0.8;

  bool get isBgmEnabled => _isBgmEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  String? get currentBgm => _currentBgm;
  double get bgmVolume => _bgmVolume;

  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('✅ AudioService initialized (Web/JS mode)');
    }
  }

  Future<void> playBgm(String assetPath) async {
    if (!_isBgmEnabled) return;
    _currentBgm = assetPath;

    if (kIsWeb) {
      try {
        final src = 'assets/$assetPath';
        _jsBgmPlay(src, true);
        if (kDebugMode) {
          debugPrint('🎵 BGM started (web): $src');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ BGM play error: $e');
        }
      }
    }
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    if (kIsWeb) {
      try {
        _jsBgmStop();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ BGM stop error: $e');
        }
      }
    }
  }

  Future<void> pauseBgm() async {
    if (kIsWeb) {
      try {
        _jsBgmPause();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ BGM pause error: $e');
        }
      }
    }
  }

  Future<void> resumeBgm() async {
    if (_isBgmEnabled && _currentBgm != null && kIsWeb) {
      try {
        _jsBgmResume();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ BGM resume error: $e');
        }
      }
    }
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    if (kIsWeb) {
      try {
        final src = 'assets/$assetPath';
        _jsSfxPlay(src);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ SFX play error: $e');
        }
      }
    }
  }

  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    if (kIsWeb) {
      try {
        _jsBgmSetEnabled(enabled);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ setBgmEnabled error: $e');
        }
      }
    }
    if (enabled && _currentBgm != null) {
      playBgm(_currentBgm!);
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
    if (kIsWeb) {
      try {
        _jsSfxSetEnabled(enabled);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ setSfxEnabled error: $e');
        }
      }
    }
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    if (kIsWeb) {
      try {
        _jsBgmSetVolume(_bgmVolume);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ setBgmVolume error: $e');
        }
      }
    }
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    if (kIsWeb) {
      try {
        _jsSfxSetVolume(_sfxVolume);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ setSfxVolume error: $e');
        }
      }
    }
  }

  bool get isBgmPlaying {
    if (kIsWeb) {
      try {
        return _jsBgmIsPlaying();
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  void dispose() {
    stopBgm();
  }
}
