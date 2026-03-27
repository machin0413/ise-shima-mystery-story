// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

/// AudioService - Web版はJavaScript(HTML5 Audio API)経由でBGMを再生
/// dart:js を直接使用（Web専用ビルドのため条件インポート不要）
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
  /// Flutter Web build では assets は /assets/assets/<path> に配置される
  Future<void> playBgm(String assetPath) async {
    if (!_isBgmEnabled) return;
    _currentBgm = assetPath;
    _callFAP('playBgm', ['assets/assets/$assetPath', true]);
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    _callFAP('stopBgm', []);
  }

  Future<void> pauseBgm() async {
    _callFAP('pauseBgm', []);
  }

  Future<void> resumeBgm() async {
    if (!_isBgmEnabled || _currentBgm == null) return;
    _callFAP('resumeBgm', []);
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;
    _callFAP('playSfx', ['assets/assets/$assetPath']);
  }

  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    _callFAP('setBgmEnabled', [enabled]);
    if (enabled && _currentBgm != null) {
      playBgm(_currentBgm!);
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
    _callFAP('setSfxEnabled', [enabled]);
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    _callFAP('setBgmVolume', [_bgmVolume]);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _callFAP('setSfxVolume', [_sfxVolume]);
  }

  bool get isBgmPlaying {
    return _isBgmEnabled && _currentBgm != null;
  }

  void dispose() {
    stopBgm();
  }

  /// window.FlutterAudioPlayer のメソッドを呼び出す
  void _callFAP(String method, List<dynamic> args) {
    try {
      final fap = js.context['FlutterAudioPlayer'];
      if (fap == null) {
        debugPrint('⚠️ FlutterAudioPlayer not found on window.$method');
        return;
      }
      (fap as js.JsObject).callMethod(method, args);
      debugPrint('🎵 FAP.$method(${args.join(", ")})');
    } catch (e) {
      debugPrint('❌ FAP.$method error: $e');
    }
  }
}
