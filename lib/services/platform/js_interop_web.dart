// Web implementation using dart:js
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

dynamic jsCallImpl(String funcPath, List<dynamic> args) {
  final parts = funcPath.split('.');
  
  if (parts.length == 2) {
    final obj = js.context[parts[0]];
    if (obj == null) return null;
    return obj.callMethod(parts[1], args);
  } else if (parts.length == 1) {
    return js.context.callMethod(parts[0], args);
  }
  return null;
}
