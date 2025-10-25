import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterDialogue extends StatefulWidget {
  final Character character;
  final String text;
  final VoidCallback onClose;

  const CharacterDialogue({
    super.key,
    required this.character,
    required this.text,
    required this.onClose,
  });

  @override
  State<CharacterDialogue> createState() => _CharacterDialogueState();
}

class _CharacterDialogueState extends State<CharacterDialogue> {
  @override
  void initState() {
    super.initState();
    if (widget.character.imagePath != null) {
      // 画像を事前ロード（画面表示前にキャッシュに入れる）
      precacheImage(AssetImage(widget.character.imagePath!), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF001100),
          border: Border.all(color: const Color(0xFF00FF00), width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // キャラクター名バー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF003300),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF00FF00), width: 2),
                ),
              ),
              child: Text(
                '${widget.character.name} (${widget.character.age}) - ${widget.character.role}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            
            // コンテンツエリア
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // キャラクター画像（左側）
                    if (widget.character.imagePath != null)
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF00FF00),
                            width: 2,
                          ),
                        ),
                        child: ClipRect(
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0, 1, 0, 0, 0,  // R = G (green channel)
                              0, 1, 0, 0, 0,  // G = G
                              0, 1, 0, 0, 0,  // B = G
                              0, 0, 0, 1, 0,  // A = A
                            ]),
                            child: Image.asset(
                              widget.character.imagePath!,
                              fit: BoxFit.cover,
                              cacheWidth: 240,  // キャッシュサイズ指定
                              cacheHeight: 240,
                            ),
                          ),
                        ),
                      ),
                    
                    // 会話テキスト（右側）
                    Expanded(
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 16,
                          fontFamily: 'monospace',
                          height: 1.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 閉じるボタン
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onClose,
                  child: const Text('OK'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
