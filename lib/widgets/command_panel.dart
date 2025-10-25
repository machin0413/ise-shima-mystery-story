import 'package:flutter/material.dart';

class CommandPanel extends StatelessWidget {
  final Function(String) onCommandSelected;

  const CommandPanel({super.key, required this.onCommandSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF001100),
        border: Border(
          top: BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Row(
            children: [
              Expanded(
                child: _CommandButton(
                  label: 'かんがえる',
                  icon: Icons.lightbulb_outline,
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
          SizedBox(
            width: double.infinity,
            child: _CommandButton(
              label: 'こっそりしらべる',
              icon: Icons.security,
              onPressed: () => onCommandSelected('secret'),
              isWarning: true,
            ),
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

  const _CommandButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isWarning ? const Color(0xFF330000) : const Color(0xFF003300),
        foregroundColor: isWarning ? const Color(0xFFFF0000) : const Color(0xFF00FF00),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: isWarning ? const Color(0xFFFF0000) : const Color(0xFF00FF00),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
