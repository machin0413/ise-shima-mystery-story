// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

/// Web用実装 - window.FlutterAudioPlayer のメソッドを呼び出す
void callAudioPlayer(String method, List<dynamic> args) {
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
