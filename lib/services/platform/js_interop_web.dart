// Web implementation
// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

dynamic jsCallImpl(String funcPath, List<dynamic> args) {
  try {
    final parts = funcPath.split('.');
    if (parts.length != 2) return null;

    final objName = parts[0]; // 'FlutterAudioPlayer'
    final methodName = parts[1]; // 'playBgm', 'stopBgm', etc.

    // window オブジェクトから FlutterAudioPlayer を取得
    final obj = js_util.getProperty<Object?>(js.context, objName);
    if (obj == null) {
      if (kDebugMode) {
        debugPrint('⚠️ JS object not found: $objName');
      }
      return null;
    }

    // メソッドを呼び出す
    final result = js_util.callMethod<dynamic>(obj, methodName, args);
    if (kDebugMode) {
      debugPrint('✅ JS called: $funcPath(${args.join(', ')})');
    }
    return result;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ JS call error ($funcPath): $e');
    }
    return null;
  }
}
