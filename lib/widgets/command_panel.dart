import 'package:flutter/material.dart';

class CommandPanel extends StatelessWidget {
  final Function(String) onCommandSelected;
  final bool showDeduceButton; // 推理ボタンを表示するか

  const CommandPanel({
    super.key,
    required this.onCommandSelected,
    this.showDeduceButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF001100),
        border: Border(
          top: BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1行目：はなす・しらべる
          Row(
            children: [
              Expanded(
                child: _CommandButton(
                  label: 'はなす',
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => onCommandSelected('talk'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CommandButton(
                  label: 'しらべる',
                  icon: Icons.search,
                  onPressed: () => onCommandSelected('investigate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 2行目：ノート・いどうする
          Row(
            children: [
              Expanded(
                child: _CommandButton(
                  label: 'ノート',
                  icon: Icons.book_outlined,
                  onPressed: () => onCommandSelected('think'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CommandButton(
                  label: 'いどうする',
                  icon: Icons.directions_walk,
                  onPressed: () => onCommandSelected('move'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 3行目：こっそりしらべる・推理する（条件付き）
          Row(
            children: [
              Expanded(
                child: _CommandButton(
                  label: 'こっそり\nしらべる',
                  icon: Icons.visibility_off,
                  onPressed: () => onCommandSelected('secret'),
                  isWarning: true,
                ),
              ),
              if (showDeduceButton) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _CommandButton(
                    label: '推理する',
                    icon: Icons.psychology,
                    onPressed: () => onCommandSelected('deduce'),
                    isSpecial: true,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isWarning;
  final bool isSpecial;

  const _CommandButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isWarning = false,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    Color borderColor;

    if (isWarning) {
      bgColor = const Color(0xFF330000);
      fgColor = const Color(0xFFFF6600);
      borderColor = const Color(0xFFFF6600);
    } else if (isSpecial) {
      bgColor = const Color(0xFF001133);
      fgColor = const Color(0xFF00CCFF);
      borderColor = const Color(0xFF00CCFF);
    } else {
      bgColor = const Color(0xFF003300);
      fgColor = const Color(0xFF00FF00);
      borderColor = const Color(0xFF00FF00);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
