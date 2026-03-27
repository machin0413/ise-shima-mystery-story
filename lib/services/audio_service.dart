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
      debugPrint('✅ AudioService initialized (Web mode)');
    }
  }

  Future<void> playBgm(String assetPath) async {
    if (!_isBgmEnabled) return;
    _currentBgm = assetPath;
    // Web以外では何もしない
    if (!kIsWeb) return;
    // Flutter Webのアセットは assets/assets/ の下に配置される
    jsCallImpl('FlutterAudioPlayer.playBgm', ['assets/assets/$assetPath', true]);
  }

  Future<void> stopBgm() async {
    _currentBgm = null;
    if (!kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.stopBgm', []);
  }

  Future<void> pauseBgm() async {
    if (!kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.pauseBgm', []);
  }

  Future<void> resumeBgm() async {
    if (!_isBgmEnabled || _currentBgm == null || !kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.resumeBgm', []);
  }

  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled || !kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.playSfx', ['assets/assets/$assetPath']);
  }

  void setBgmEnabled(bool enabled) {
    _isBgmEnabled = enabled;
    if (!kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.setBgmEnabled', [enabled]);
    if (enabled && _currentBgm != null) {
      playBgm(_currentBgm!);
    }
  }

  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
    if (!kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.setSfxEnabled', [enabled]);
  }

  void setBgmVolume(double volume) {
    _bgmVolume = volume.clamp(0.0, 1.0);
    if (!kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.setBgmVolume', [_bgmVolume]);
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    if (!kIsWeb) return;
    jsCallImpl('FlutterAudioPlayer.setSfxVolume', [_sfxVolume]);
  }

  bool get isBgmPlaying {
    if (!kIsWeb) return false;
    final result = jsCallImpl('FlutterAudioPlayer.isBgmPlaying', []);
    return result == true;
  }

  void dispose() {
    stopBgm();
  }
}
