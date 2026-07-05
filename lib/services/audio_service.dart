import 'package:flutter/foundation.dart';
import 'audio_bridge_stub.dart' if (dart.library.js) 'audio_bridge_web.dart';

/// AudioService - Web版はJavaScript(HTML5 Audio API)経由でBGMを再生
/// 非Web環境（テスト等）ではスタブが使われ何もしない
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
    debugPrint('✅ AudioService initialized');
  }

  /// BGMを再生する
  /// Flutter Web build では assets は /assets/assets/(path) に配置される
  Future<void> playBgm(String assetPath) async {
    if (!_isBgmEnabled) return;
    _currentBgm = assetPath;
    callAudioPlayer('playBgm', ['assets/assets/$assetPath', true]);
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    callAudioPlayer('stopBgm', []);
  }

  Future<void> pauseBgm() async {
    callAudioPlayer('pauseBgm', []);
  }

  Future<void> resumeBgm() async {
    if (!_isBgmEnabled || _currentBgm == null) return;
    callAudioPlayer('resumeBgm', []);
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    callAudioPlayer('playSfx', ['assets/assets/$assetPath']);
  }

  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    callAudioPlayer('setBgmEnabled', [enabled]);
    if (enabled && _currentBgm != null) {
      playBgm(_currentBgm!);
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
    callAudioPlayer('setSfxEnabled', [enabled]);
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    callAudioPlayer('setBgmVolume', [_bgmVolume]);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    callAudioPlayer('setSfxVolume', [_sfxVolume]);
  }

  bool get isBgmPlaying {
    return _isBgmEnabled && _currentBgm != null;
  }

  void dispose() {
    stopBgm();
  }
}
