import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/character.dart' as char;

class NotesScreen extends StatelessWidget {
  final GameState gameState;

  const NotesScreen({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFF001100),
          border: Border.all(color: const Color(0xFF00FF00), width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF003300),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF00FF00), width: 2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Color(0xFF00FF00), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '捜査ノート',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            
            // タブコンテンツ
            Flexible(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    // タブバー
                    TabBar(
                      labelColor: const Color(0xFF00FF00),
                      unselectedLabelColor: const Color(0xFF006600),
                      indicatorColor: const Color(0xFF00FF00),
                      tabs: const [
                        Tab(text: '手がかり'),
                        Tab(text: '人物'),
                        Tab(text: 'アイテム'),
                      ],
                    ),
                    // タブコンテンツ
                    Flexible(
                      child: TabBarView(
                        children: [
                          // 手がかりリスト
                          _CluesTab(clues: gameState.clues),
                          // 人物リスト
                          _CharactersTab(talkedTo: gameState.talkedTo),
                          // アイテムリスト
                          _ItemsTab(items: gameState.items),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 閉じるボタン
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 手がかりタブ
class _CluesTab extends StatelessWidget {
  final Set<String> clues;

  const _CluesTab({required this.clues});

  @override
  Widget build(BuildContext context) {
    if (clues.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'まだ手がかりはない。\n調査を続けよう。',
            style: TextStyle(
              color: Color(0xFF006600),
              fontSize: 14,
              fontFamily: 'monospace',
              height: 2.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: clues.length,
      itemBuilder: (context, index) {
        final clue = clues.elementAt(index);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF002200),
            border: Border.all(color: const Color(0xFF004400)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '◆ ',
                style: TextStyle(
                  color: Color(0xFF00AA00),
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
              Expanded(
                child: Text(
                  clue,
                  style: const TextStyle(
                    color: Color(0xFF00FF00),
                    fontSize: 13,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 人物タブ
class _CharactersTab extends StatelessWidget {
  final Set<String> talkedTo;

  const _CharactersTab({required this.talkedTo});

  @override
  Widget build(BuildContext context) {
    if (talkedTo.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'まだ誰とも話していない。',
            style: TextStyle(
              color: Color(0xFF006600),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final characters = talkedTo
        .map((id) => char.GameCharacters.getById(id))
        .where((c) => c != null)
        .cast<char.Character>()
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF001800),
            border: Border.all(color: const Color(0xFF004400)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${character.name}  (${character.age}歳)',
                style: const TextStyle(
                  color: Color(0xFF00FF00),
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                character.role,
                style: const TextStyle(
                  color: Color(0xFF00AAAA),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                character.description,
                style: const TextStyle(
                  color: Color(0xFF00AA00),
                  fontSize: 12,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// アイテムタブ
class _ItemsTab extends StatelessWidget {
  final Set<String> items;

  const _ItemsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'まだ証拠品はない。\n「しらべる」や「こっそりしらべる」で\n証拠を集めよう。',
            style: TextStyle(
              color: Color(0xFF006600),
              fontSize: 14,
              fontFamily: 'monospace',
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items.elementAt(index);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF220000),
            border: Border.all(color: const Color(0xFF440000)),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFFFF6600),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Color(0xFFFFAA00),
                    fontSize: 13,
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
