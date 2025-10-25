import 'package:flutter/material.dart';

class TextDisplay extends StatelessWidget {
  final String text;
  final String? backgroundImage;

  const TextDisplay({
    super.key, 
    required this.text,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // 背景画像（ある場合）
          if (backgroundImage != null)
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
                    backgroundImage!,
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
              child: Text(
                text,
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
            ),
          ),
        ],
      ),
    );
  }
}
