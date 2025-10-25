import 'package:flutter/material.dart';
import '../models/game_state.dart';

class StatusBar extends StatelessWidget {
  final GameState gameState;

  const StatusBar({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF001100),
        border: Border(
          bottom: BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day ${gameState.currentDay} - ${gameState.currentTime}',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                gameState.currentLocation,
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 16,
                  fontFamily: 'monospace',
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF00AAAA),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '行動: ${gameState.actionCount}/6',
                    style: const TextStyle(
                      color: Color(0xFF00AAAA),
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
