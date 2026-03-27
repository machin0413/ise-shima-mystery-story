import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import 'settings_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final AudioService _audioService = AudioService();
  bool _isBgmPlaying = false;
  bool _hasSaveData = false;
  String? _saveSummary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _checkSaveData();
  }

  Future<void> _checkSaveData() async {
    final hasSave = await SaveService.hasSaveData();
    final summary = hasSave ? await SaveService.getSaveSummary() : null;
    if (mounted) {
      setState(() {
        _hasSaveData = hasSave;
        _saveSummary = summary;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBgm() async {
    if (_isBgmPlaying) {
      await _audioService.stopBgm();
      setState(() => _isBgmPlaying = false);
    } else {
      // playBgm を先に呼んでから setState（ユーザーインタラクション内で呼ぶことが重要）
      await _audioService.playBgm('audio/title_theme.mp3');
      setState(() => _isBgmPlaying = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 背景画像
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0, 0.7, 0, 0, 0,
                  0, 0.7, 0, 0, 0,
                  0, 0.7, 0, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    'assets/images/title_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // コンテンツ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // タイトルロゴ
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF001100).withValues(alpha: 0.85),
                        border: Border.all(
                          color: const Color(0xFF00FF00),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF00).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '泡沫に消えた海女',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 30,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00FF00).withValues(alpha: 0.7),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '- 伊勢志摩殺人事件 -',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              letterSpacing: 3,
                              color: const Color(0xFF00AAAA),
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00AAAA).withValues(alpha: 0.7),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ISE-SHIMA MURDER CASE',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // バージョン表示
                    Text(
                      'ver 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF006600),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                
                    // メニューボタン
                    SizedBox(
                      width: 260,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // はじめから
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001100),
                              foregroundColor: const Color(0xFF00FF00),
                              side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              _audioService.stopBgm();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const GameScreen(),
                                ),
                              );
                            },
                            child: const Text('はじめから', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 12),
                          // つづきから
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasSaveData
                                  ? const Color(0xFF001100)
                                  : const Color(0xFF000800),
                              foregroundColor: _hasSaveData
                                  ? const Color(0xFF00AAAA)
                                  : const Color(0xFF003333),
                              side: BorderSide(
                                color: _hasSaveData
                                    ? const Color(0xFF00AAAA)
                                    : const Color(0xFF003333),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isLoading
                                ? null
                                : _hasSaveData
                                    ? () async {
                                        _audioService.stopBgm();
                                        final savedState = await SaveService.loadGame();
                                        if (mounted) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => GameScreen(
                                                savedState: savedState,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                            child: Column(
                              children: [
                                const Text('つづきから', style: TextStyle(fontSize: 18)),
                                if (_hasSaveData && _saveSummary != null)
                                  Text(
                                    _saveSummary!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF008888),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                if (!_hasSaveData && !_isLoading)
                                  const Text(
                                    'セーブデータなし',
                                    style: TextStyle(fontSize: 11),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ゲームについて
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001100),
                              foregroundColor: const Color(0xFF00AA00),
                              side: const BorderSide(color: Color(0xFF00AA00), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              _showAboutDialog(context);
                            },
                            child: const Text('ゲームについて', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // BGM & 設定ボタン行
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isBgmPlaying
                                ? const Color(0xFF00FF00)
                                : const Color(0xFF006600),
                            side: BorderSide(
                              color: _isBgmPlaying
                                  ? const Color(0xFF00FF00)
                                  : const Color(0xFF006600),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onPressed: _toggleBgm,
                          icon: Icon(
                            _isBgmPlaying ? Icons.volume_up : Icons.volume_off,
                            size: 18,
                          ),
                          label: Text(
                            _isBgmPlaying ? 'BGM ON' : 'BGM OFF',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF006600),
                            side: const BorderSide(color: Color(0xFF006600), width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => SettingsScreen(
                                onReset: () => _checkSaveData(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings, size: 18),
                          label: const Text('設定', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // コピーライト
                    Text(
                      '© 2025 Retro Mystery Games',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF004400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          'ゲームについて',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''
「泡沫に消えた海女 - 伊勢志摩殺人事件 -」

三重県伊勢志摩を舞台にした
レトロ推理アドベンチャーゲームです。

あなたはフリーライターとして
海女の取材に訪れますが、
インタビュー予定だった海女が
行方不明になってしまいます。

コマンドを選んで情報を集め、
事件の真相に迫りましょう。

【操作方法】
・はなす：その場所の人物と会話
・しらべる：場所や物を調べる
・かんがえる：手がかりを整理
・いどうする：別の場所へ移動
・こっそりしらべる：警戒度増加のリスクあり
・推理する：犯人を特定して真相解明

【注意】
警戒度が100%になると
ゲームオーバーになります。

【ストーリー進行】
5回行動すると時間が経過します。
Day 1〜Day 2にわたる物語を
お楽しみください。
''',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('とじる'),
          ),
        ],
      ),
    );
  }
}
