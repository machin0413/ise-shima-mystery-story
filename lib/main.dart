import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'screens/title_screen.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AudioServiceを初期化（エラーでもアプリは起動する）
  try {
    await AudioService().initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Audio initialization failed, continuing without audio: $e');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '泡沫に消えた海女 - 伊勢志摩殺人事件',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // レトロPC風のダークテーマ
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00FF00), // グリーンモニター風
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF00),
          secondary: Color(0xFF00AA00),
          surface: Color(0xFF001100),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 18,
            fontFamily: 'monospace',
            height: 1.8,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 16,
            fontFamily: 'monospace',
            height: 1.8,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003300),
            foregroundColor: const Color(0xFF00FF00),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: const BorderSide(color: Color(0xFF00FF00), width: 2),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const TitleScreen(),
    );
  }
}
