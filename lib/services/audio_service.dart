import 'package:flutter/foundation.dart';
import 'platform/js_interop_stub.dart'
    if (dart.library.js) 'platform/js_interop_web.dart';

/// AudioService - Web版はJavaScript経由でHTML5 Audioを使用
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
      debugPrint('✅ AudioService initialized');
    }
  }

  Future<void> playBgm(String assetPath) async {
    if (!_isBgmEnabled) return;
    _currentBgm = assetPath;
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.playBgm', ['assets/$assetPath', true]);
        if (kDebugMode) debugPrint('🎵 BGM: assets/$assetPath');
      } catch (e) {
        if (kDebugMode) debugPrint('BGM error: $e');
      }
    }
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.stopBgm', []);
      } catch (e) {
        if (kDebugMode) debugPrint('BGM stop error: $e');
      }
    }
  }

  Future<void> pauseBgm() async {
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.pauseBgm', []);
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> resumeBgm() async {
    if (_isBgmEnabled && _currentBgm != null && kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.resumeBgm', []);
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.playSfx', ['assets/$assetPath']);
      } catch (e) {
        // ignore
      }
    }
  }

  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.setBgmEnabled', [enabled]);
      } catch (e) {
        // ignore
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
        jsCallImpl('FlutterAudioPlayer.setSfxEnabled', [enabled]);
      } catch (e) {
        // ignore
      }
    }
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.setBgmVolume', [_bgmVolume]);
      } catch (e) {
        // ignore
      }
    }
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    if (kIsWeb) {
      try {
        jsCallImpl('FlutterAudioPlayer.setSfxVolume', [_sfxVolume]);
      } catch (e) {
        // ignore
      }
    }
  }

  bool get isBgmPlaying {
    if (kIsWeb) {
      try {
        final result = jsCallImpl('FlutterAudioPlayer.isBgmPlaying', []);
        return result == true;
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
