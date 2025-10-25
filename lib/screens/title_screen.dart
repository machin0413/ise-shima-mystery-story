import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/audio_service.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }
  
  void _toggleBgm() {
    setState(() {
      if (_isBgmPlaying) {
        _audioService.stopBgm();
        _isBgmPlaying = false;
      } else {
        _audioService.playBgm('audio/title_theme.mp3');
        _isBgmPlaying = true;
      }
    });
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
                              fontSize: 32,
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
                          const SizedBox(height: 16),
                          Text(
                            '- 伊勢志摩殺人事件 -',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 20,
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
                          const SizedBox(height: 10),
                          Text(
                            'ISE-SHIMA MURDER CASE',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // サブタイトル
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF001100).withValues(alpha: 0.7),
                        border: Border.all(
                          color: const Color(0xFF00FF00).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'レトロ推理アドベンチャー',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'パイロット版 ver 0.1',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF00AA00),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 80),
                
                    // メニューボタン
                    SizedBox(
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001100),
                              foregroundColor: const Color(0xFF00FF00),
                              side: const BorderSide(color: Color(0xFF00FF00), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              // BGMを停止してからゲーム画面へ遷移
                              _audioService.stopBgm();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const GameScreen(),
                                ),
                              );
                            },
                            child: const Text('はじめから', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001100),
                              foregroundColor: const Color(0xFF004400),
                              side: const BorderSide(color: Color(0xFF004400), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: null, // パイロット版では無効
                            child: const Text('つづきから（未実装）', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF001100),
                              foregroundColor: const Color(0xFF00AA00),
                              side: const BorderSide(color: Color(0xFF00AA00), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              _showAboutDialog(context);
                            },
                            child: const Text('ゲームについて', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // BGM ON/OFFボタン
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isBgmPlaying ? const Color(0xFF00FF00) : const Color(0xFF006600),
                        side: BorderSide(
                          color: _isBgmPlaying ? const Color(0xFF00FF00) : const Color(0xFF006600),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _toggleBgm,
                      icon: Icon(
                        _isBgmPlaying ? Icons.volume_up : Icons.volume_off,
                        size: 20,
                      ),
                      label: Text(
                        _isBgmPlaying ? 'BGM ON' : 'BGM OFF',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // コピーライト
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000).withValues(alpha: 0.6),
                      ),
                      child: Text(
                        '© 2025 Retro Mystery Games',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF006600),
                        ),
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

【パイロット版について】
このバージョンはDay 1の序盤のみ
プレイ可能な体験版です。

【操作方法】
画面下部のコマンドボタンを
タップして操作します。
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
