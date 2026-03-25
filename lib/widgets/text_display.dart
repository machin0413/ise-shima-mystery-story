import 'dart:async';
import 'package:flutter/material.dart';

/// テキスト表示エリア - タイプライター効果付き
class TextDisplay extends StatefulWidget {
  final String text;
  final String? backgroundImage;
  final bool animate; // アニメーションするか
  final VoidCallback? onAnimationComplete;

  const TextDisplay({
    super.key, 
    required this.text,
    this.backgroundImage,
    this.animate = true,
    this.onAnimationComplete,
  });

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  String _displayedText = '';
  Timer? _timer;
  int _charIndex = 0;
  bool _isAnimating = false;
  bool _isComplete = false;
  static const int _charsPerTick = 2; // 1回のティックで表示する文字数
  static const Duration _tickDuration = Duration(milliseconds: 30);

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(TextDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _resetAnimation();
    }
  }

  void _resetAnimation() {
    _timer?.cancel();
    setState(() {
      _displayedText = '';
      _charIndex = 0;
      _isAnimating = false;
      _isComplete = false;
    });
    _startAnimation();
  }

  void _startAnimation() {
    if (!widget.animate || widget.text.isEmpty) {
      setState(() {
        _displayedText = widget.text;
        _isComplete = true;
      });
      widget.onAnimationComplete?.call();
      return;
    }

    _isAnimating = true;
    _timer = Timer.periodic(_tickDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final end = (_charIndex + _charsPerTick).clamp(0, widget.text.length);
        _charIndex = end;
        _displayedText = widget.text.substring(0, _charIndex);
        
        if (_charIndex >= widget.text.length) {
          _isAnimating = false;
          _isComplete = true;
          timer.cancel();
          widget.onAnimationComplete?.call();
        }
      });
    });
  }

  void _skipAnimation() {
    if (_isAnimating) {
      _timer?.cancel();
      setState(() {
        _displayedText = widget.text;
        _charIndex = widget.text.length;
        _isAnimating = false;
        _isComplete = true;
      });
      widget.onAnimationComplete?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skipAnimation, // タップでアニメーションをスキップ
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [
            // 背景画像（ある場合）
            if (widget.backgroundImage != null)
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0, 0.7, 0, 0, 0,  // R = G * 0.7
                    0, 0.7, 0, 0, 0,  // G = G * 0.7
                    0, 0.7, 0, 0, 0,  // B = G * 0.7
                    0, 0, 0, 1, 0,    // A = A
                  ]),
                  child: Opacity(
                    opacity: 0.3, // 背景を薄く表示
                    child: Image.asset(
                      widget.backgroundImage!,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                    ),
                  ),
                ),
              ),
            
            // テキスト表示（前面）
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayedText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 17,
                        height: 2.0,
                        letterSpacing: 1.2,
                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // アニメーション中のカーソル
                    if (_isAnimating)
                      Container(
                        width: 10,
                        height: 20,
                        color: const Color(0xFF00FF00),
                      ),
                    // アニメーション完了後のタップヒント
                    if (_isComplete && _isAnimating == false)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '',
                          style: TextStyle(
                            color: const Color(0xFF00FF00).withValues(alpha: 0.0),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // アニメーション中はタップヒント
            if (_isAnimating)
              Positioned(
                bottom: 8,
                right: 16,
                child: Text(
                  'タップでスキップ',
                  style: TextStyle(
                    color: const Color(0xFF006600).withValues(alpha: 0.7),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
