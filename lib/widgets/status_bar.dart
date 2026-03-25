import 'package:flutter/material.dart';
import '../models/game_state.dart';

class StatusBar extends StatelessWidget {
  final GameState gameState;

  const StatusBar({super.key, required this.gameState});

  Color _alertColor() {
    if (gameState.policeAlert < 30) return const Color(0xFF00FF00);
    if (gameState.policeAlert < 60) return const Color(0xFFFFFF00);
    if (gameState.policeAlert < 90) return const Color(0xFFFF6600);
    return const Color(0xFFFF0000);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF001100),
        border: Border(
          bottom: BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 日付・時間
          Text(
            'Day ${gameState.currentDay} ${gameState.currentTime}',
            style: const TextStyle(
              color: Color(0xFF00FF00),
              fontSize: 14,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          // 現在地
          Flexible(
            child: Text(
              gameState.currentLocation,
              style: const TextStyle(
                color: Color(0xFF00AAAA),
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // 行動回数
          Text(
            '行動 ${gameState.actionCount}/5',
            style: const TextStyle(
              color: Color(0xFF00AA00),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          // 警戒度
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility,
                color: _alertColor(),
                size: 14,
              ),
              const SizedBox(width: 2),
              Text(
                '${gameState.policeAlert}%',
                style: TextStyle(
                  color: _alertColor(),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: gameState.policeAlert >= 60
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
