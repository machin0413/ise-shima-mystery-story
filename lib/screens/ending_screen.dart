import 'package:flutter/material.dart';
import '../widgets/text_display.dart';
import '../services/audio_service.dart';
import 'title_screen.dart';

/// エンディング画面 - 全画面の一枚絵とタイプライター演出
class EndingScreen extends StatelessWidget {
  final String type; // 'true' / 'normal' / 'timeout'
  final String endingText;

  const EndingScreen({
    super.key,
    required this.type,
    required this.endingText,
  });

  String get _title {
    switch (type) {
      case 'true':
        return 'TRUE ENDING';
      case 'timeout':
        return 'BAD ENDING';
      default:
        return 'NORMAL ENDING';
    }
  }

  Color get _accentColor {
    switch (type) {
      case 'true':
        return const Color(0xFF00FFFF);
      case 'timeout':
        return const Color(0xFFFF6600);
      default:
        return const Color(0xFF00FF00);
    }
  }

  String? get _backgroundImage {
    switch (type) {
      case 'true':
        return 'assets/images/ending_true.jpg'; // 救出されたアキコの引きの絵
      case 'timeout':
        return 'assets/images/bg_harbor.jpg'; // 村を去る朝の漁港
      default:
        return 'assets/images/bg_beach.jpg'; // 夕日の海岸
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // エンディングタイトルバー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF000800),
                border: Border(
                  bottom: BorderSide(color: _accentColor, width: 3),
                ),
              ),
              child: Text(
                '── $_title ──',
                style: TextStyle(
                  color: _accentColor,
                  fontSize: 22,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(color: _accentColor.withValues(alpha: 0.7), blurRadius: 12),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 一枚絵 + エンディングテキスト（タイプライター表示、タップでスキップ）
            Expanded(
              child: TextDisplay(
                text: endingText,
                backgroundImage: _backgroundImage,
                animate: true,
              ),
            ),

            // タイトルへ戻る
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF000800),
                border: Border(
                  top: BorderSide(color: _accentColor, width: 2),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      AudioService().stopBgm();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const TitleScreen()),
                      );
                    },
                    child: const Text('タイトルに戻る', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
