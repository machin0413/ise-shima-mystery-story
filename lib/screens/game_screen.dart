import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/character.dart' as char;
import '../models/location.dart';
import '../data/scenario_data.dart';
import '../widgets/command_panel.dart';
import '../widgets/text_display.dart';
import '../widgets/status_bar.dart';
import '../widgets/character_dialogue.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import 'title_screen.dart';

class GameScreen extends StatefulWidget {
  final GameState? savedState;

  const GameScreen({super.key, this.savedState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  String currentText = '';
  bool isOpening = true; // オープニング表示中かどうか
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    if (widget.savedState != null) {
      gameState = widget.savedState!;
      isOpening = false;
      currentText = _getRestoredText();
    } else {
      gameState = GameState();
      _startGame();
    }
    _preloadImages();
  }

  String _getRestoredText() {
    return '''
セーブデータを読み込みました。

現在地：${gameState.currentLocation}
Day ${gameState.currentDay} ${gameState.currentTime}
手がかり：${gameState.clues.length}件

調査を続けましょう。
''';
  }

  void _startGame() {
    setState(() {
      currentText = ScenarioData.opening;
      isOpening = true;
    });
  }
  
  void _preloadImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final imagePaths = [
        'assets/images/okami.jpg',
        'assets/images/midori.jpg',
        'assets/images/yuki.jpg',
        'assets/images/tome.jpg',
        'assets/images/takeshi.jpg',
        'assets/images/policeman.jpg',
        'assets/images/bg_minshuku.jpg',
        'assets/images/bg_amagoya.jpg',
        'assets/images/bg_beach.jpg',
        'assets/images/bg_suzuki_house.jpg',
        'assets/images/bg_harbor.jpg',
        'assets/images/bg_police_station.jpg',
      ];
      for (final path in imagePaths) {
        precacheImage(AssetImage(path), context);
      }
    });
  }

  void _continueToDay1() {
    setState(() {
      currentText = ScenarioData.day1MorningMinshuku;
      gameState.currentDay = 1;
      gameState.currentTime = '朝';
      gameState.currentLocation = '民宿';
      gameState.currentLocationId = 'minshuku';
      gameState.setFlag('heard_about_missing', false); // まだ詳細を聞いていない
      gameState.setFlag('must_go_to_amagoya', true); // 海女小屋に行く必要がある
      isOpening = false;
    });
    _playGameBgm();
    
    // 少し遅延してから女将さんの強制イベントを表示
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showOkamiForceEvent();
      }
    });
  }

  void _playGameBgm() {
    // ゲーム中はタイトルBGMと別にゲームBGMを流す（同じファイルを再利用）
    // 将来的には時間帯別BGMに切り替え可能
  }

  Future<void> _autoSave() async {
    await SaveService.saveGame(gameState);
  }

  void _handleCommand(String command) {
    if (gameState.getFlag('game_over')) return;
    
    switch (command) {
      case 'talk':
        _showTalkDialog();
        break;
      case 'investigate':
        _showInvestigateDialog();
        break;
      case 'think':
        _showNotesScreen();
        break;
      case 'move':
        _showMoveDialog();
        break;
      case 'secret':
        _showSecretInvestigateDialog();
        break;
      case 'deduce':
        _showDeduceDialog();
        break;
    }
  }

  void _showTalkDialog() {
    final location = Locations.getById(gameState.currentLocationId);
    if (location == null) return;

    final availableIds = location.getCharacters(gameState.currentDay);
    final availableChars = availableIds
        .map((id) => char.GameCharacters.getById(id))
        .where((c) => c != null)
        .cast<char.Character>()
        .toList();

    if (availableChars.isEmpty) {
      _showMessage('この場所には誰もいないようだ。');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          '誰と話す?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableChars.map((character) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _talkToCharacter(character.id);
                  },
                  child: Text(character.name),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('やめる'),
          ),
        ],
      ),
    );
  }

  void _talkToCharacter(String charId) {
    // 会話回数に応じてキーを決定
    final talkCount = gameState.talkedTo.where((id) => id == charId).length;
    String conversationKey;
    
    if (talkCount == 0) {
      conversationKey = '${charId}_first';
    } else if (talkCount == 1) {
      conversationKey = '${charId}_second';
    } else {
      conversationKey = '${charId}_third';
    }
    
    // キーが存在しない場合は最後のものを使用
    Map<String, dynamic>? conversation = ScenarioData.conversations[conversationKey];
    if (conversation == null && talkCount > 0) {
      // 最大のキーを探す
      for (final suffix in ['_third', '_second', '_first']) {
        final key = '$charId$suffix';
        if (ScenarioData.conversations.containsKey(key)) {
          conversation = ScenarioData.conversations[key];
          break;
        }
      }
    }
    
    final character = char.GameCharacters.getById(charId);
    
    if (conversation != null && character != null) {
      final conv = conversation; // null-safety用にローカルコピー
      showDialog(
        context: context,
        builder: (context) => CharacterDialogue(
          character: character,
          text: conv['text'],
          onClose: () {
            Navigator.of(context).pop();
            setState(() {
              // ダイアログを閉じた後は、会話内容を背景に表示しない
              currentText = '${character.name}と話をした。';
              gameState.talkedTo.add(charId);
              
              if (conv['clue'] != null) {
                final isNew = !gameState.clues.contains(conv['clue']);
                gameState.addClue(conv['clue']);
                if (isNew) {
                  _showMessage('💡 手がかりを得た: ${conv['clue']}');
                }
              }

              if (conv['flag'] != null) {
                gameState.setFlag(conv['flag'], true);
              }
              
              _checkTimeAdvance();
            });
            _autoSave();
          },
        ),
      );
    } else {
      setState(() {
        currentText = '${char.GameCharacters.getById(charId)?.name ?? ""}は\nこれ以上何も教えてくれなかった。';
      });
    }
  }
  
  void _checkTimeAdvance() {
    gameState.incrementAction();
    
    if (gameState.shouldAdvanceTime()) {
      final oldTime = gameState.currentTime;
      final oldDay = gameState.currentDay;
      gameState.advanceTime();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showTimeAdvanceDialog(oldTime, oldDay, gameState.currentTime, gameState.currentDay);
        }
      });
    }
  }
  
  void _showTimeAdvanceDialog(String oldTime, int oldDay, String newTime, int newDay) {
    String scenarioText = '';
    
    if (newDay == 1) {
      if (newTime == '昼') {
        scenarioText = ScenarioData.day1Afternoon;
      } else if (newTime == '夕') {
        scenarioText = ScenarioData.day1Evening;
      } else if (newTime == '夜') {
        scenarioText = ScenarioData.day1Night;
      }
    } else if (newDay == 2) {
      if (newTime == '朝') {
        scenarioText = ScenarioData.day2Morning;
        // Day2に真珠養殖場が解放
        gameState.setFlag('detective_arrived', true);
      } else if (newTime == '昼') {
        scenarioText = ScenarioData.day2Afternoon;
      } else if (newTime == '夕') {
        scenarioText = ScenarioData.day2Evening;
      }
    }
    
    if (scenarioText.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF001100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFF00FF00), width: 2),
          ),
          title: Text(
            newDay > oldDay ? '── Day $newDay 始まり ──' : '── 時間が経過した ──',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Text(
              scenarioText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    currentText = scenarioText;
                  });
                  _autoSave();
                },
                child: const Text('了解'),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showInvestigateDialog() {
    final locationId = gameState.currentLocationId;
    
    if (gameState.investigatedLocations.contains(locationId)) {
      setState(() {
        currentText = 'この場所はすでに調べた。\n特に新しい発見はなさそうだ。';
      });
      return;
    }
    
    final investigationKey = '${locationId}_investigate';
    final investigation = ScenarioData.investigations[investigationKey];
    
    if (investigation != null) {
      setState(() {
        currentText = investigation['text'];
        gameState.investigatedLocations.add(locationId);
        
        if (investigation['clue'] != null) {
          final isNew = !gameState.clues.contains(investigation['clue']);
          gameState.addClue(investigation['clue']);
          if (isNew) {
            _showMessage('💡 手がかりを得た: ${investigation['clue']}');
          }
        }
        if (investigation['item'] != null) {
          gameState.addItem(investigation['item']);
        }
        if (investigation['flag'] != null) {
          gameState.setFlag(investigation['flag'], true);
        }
        
        _checkTimeAdvance();
      });
      _autoSave();
    } else {
      setState(() {
        currentText = 'この場所で特に気になるものは見つからなかった。';
        gameState.investigatedLocations.add(locationId);
      });
    }
  }

  void _showNotesScreen() {
    showDialog(
      context: context,
      builder: (context) => NotesScreen(gameState: gameState),
    );
  }

  void _showMoveDialog() {
    // 海女小屋に行く必要がある場合の制限
    if (gameState.getFlag('must_go_to_amagoya')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF001100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFF00FF00), width: 2),
          ),
          title: Text(
            'どこへ行く?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          content: const Text(
            '急いで海女小屋に向かった方が良さそうだ。\n\nアキコさんが来ていないとのことだし...',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _moveToLocation(Locations.getById('amagoya')!);
                  // 海女小屋に到着したらフラグを解除
                  setState(() {
                    gameState.setFlag('must_go_to_amagoya', false);
                    gameState.setFlag('heard_about_missing', true);
                    currentText = ScenarioData.day1MorningAmagoya;
                  });
                },
                child: const Text('海女小屋へ向かう'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('やめる'),
            ),
          ],
        ),
      );
      return;
    }
    
    // 通常の移動ダイアログ
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          'どこへ行く?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Locations.all.where((location) {
              // Day2になったら真珠養殖場が解放
              if (location.id == 'pearl_farm') {
                return gameState.getFlag('detective_arrived');
              }
              return true;
            }).map((location) {
              final isCurrent = location.id == gameState.currentLocationId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrent
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _moveToLocation(location);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? const Color(0xFF003300)
                          : const Color(0xFF001100),
                      foregroundColor: isCurrent
                          ? const Color(0xFF00FF00)
                          : const Color(0xFF00CC00),
                    ),
                    child: Text(
                      isCurrent ? '${location.name} ◀現在地' : location.name,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('やめる'),
          ),
        ],
      ),
    );
  }

  void _moveToLocation(Location location) {
    setState(() {
      gameState.currentLocation = location.name;
      gameState.currentLocationId = location.id;
      gameState.visitedLocations.add(location.id);
      currentText = '${location.name}に移動した。\n\n${location.description}';
    });
    _autoSave();
  }

  void _showSecretInvestigateDialog() {
    final locationId = gameState.currentLocationId;
    final secretKey = '${locationId}_secret_investigate';
    final secretInvestigation = ScenarioData.investigations[secretKey];

    if (secretInvestigation == null) {
      _showMessage('この場所ではこっそり調べられるものは見当たらない。');
      return;
    }

    if (gameState.secretInvestigatedLocations.contains(locationId)) {
      setState(() {
        currentText = 'ここはもうこっそり調べた。\nこれ以上は危険だ。';
      });
      return;
    }

    final alertIncrease = secretInvestigation['alert_increase'] as int? ?? 20;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF110000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFFF4400), width: 2),
        ),
        title: Text(
          '⚠ こっそり調べる',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: const Color(0xFFFF4400),
          ),
        ),
        content: Text(
          '警察の目を盗んで調査します。\n\n警戒度が +$alertIncrease% 上昇します。\n現在の警戒度: ${gameState.policeAlert}%\n\n実行しますか？',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: const Color(0xFFFFAA00),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('やめる', style: TextStyle(color: Color(0xFF00AA00))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF440000),
              foregroundColor: const Color(0xFFFF4400),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _executeSecretInvestigate(secretInvestigation, alertIncrease);
            },
            child: const Text('調べる'),
          ),
        ],
      ),
    );
  }

  void _executeSecretInvestigate(
      Map<String, dynamic> investigation, int alertIncrease) {
    setState(() {
      currentText = investigation['text'];
      gameState.secretInvestigatedLocations.add(gameState.currentLocationId);
      gameState.increaseAlert(alertIncrease);

      if (investigation['clue'] != null) {
        final isNew = !gameState.clues.contains(investigation['clue']);
        gameState.addClue(investigation['clue']);
        if (isNew) {
          _showMessage('🔍 秘密の手がかりを得た: ${investigation['clue']}');
        }
      }
      if (investigation['item'] != null) {
        gameState.addItem(investigation['item']);
      }
      if (investigation['flag'] != null) {
        gameState.setFlag(investigation['flag'], true);
      }

      _checkTimeAdvance();
    });

    _autoSave();

    // ゲームオーバーチェック
    if (gameState.getFlag('game_over')) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showGameOver();
      });
    } else if (gameState.policeAlert >= 70) {
      _showMessage('⚠ 警戒度が高くなっている！注意しよう。');
    }

    // アキコ発見イベント
    if (investigation['flag'] == 'found_akiko') {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _showAkikoFoundEvent();
      });
    }
  }

  void _showAkikoFoundEvent() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FFFF), width: 2),
        ),
        title: Text(
          '！！重要な発見！！',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 18,
            color: const Color(0xFF00FFFF),
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'アキコさんを発見した！\nまだ生きている！\n\n急いで橘刑事に知らせるか、\n自分で助け出すか...\n\n「推理する」コマンドで\n真相を明らかにしよう！',
          style: TextStyle(
            color: Color(0xFF00FFFF),
            fontSize: 14,
            fontFamily: 'monospace',
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('了解'),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeduceDialog() {
    if (!gameState.canSolve) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF001100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFF00FF00), width: 2),
          ),
          title: Text(
            '推理する',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          content: Text(
            ScenarioData.deductionResults['insufficient_clues']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('わかった'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          '推理する',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: const Text(
          '犯人と思われる人物を選んでください。',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _deduceButton(context, '鈴木タケシ', 'takeshi'),
              const SizedBox(height: 6),
              _deduceButton(context, '田中ミドリ', 'midori'),
              const SizedBox(height: 6),
              _deduceButton(context, '西山社長（真珠養殖場）', 'pearl_boss'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('やめる'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deduceButton(BuildContext context, String name, String id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002200),
        foregroundColor: const Color(0xFF00FF00),
        side: const BorderSide(color: Color(0xFF00AA00), width: 1),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _processDeduction(id);
      },
      child: Text(name),
    );
  }

  void _processDeduction(String suspectId) {
    if (suspectId == 'pearl_boss') {
      // 正解
      final hasFoundAkiko = gameState.getFlag('found_akiko');
      _showEnding(hasFoundAkiko ? 'true' : 'good');
    } else {
      // 不正解
      final resultKey = 'correct_$suspectId';
      final result = ScenarioData.deductionResults[resultKey] ??
          'その人物が犯人という証拠が不十分だ。\nもう少し調べてみよう。';
      setState(() {
        currentText = result;
      });
      _showMessage('推理が外れた。もっと証拠を集めよう。');
    }
  }

  void _showEnding(String type) {
    String endingText;
    String endingTitle;

    if (type == 'true') {
      endingText = ScenarioData.endingTrue;
      endingTitle = 'TRUE ENDING';
      gameState.setFlag('ending_reached', true);
    } else {
      endingText = ScenarioData.endingGoodbye;
      endingTitle = 'NORMAL ENDING';
      gameState.setFlag('ending_reached', true);
    }

    _audioService.stopBgm();
    _autoSave();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF000800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: type == 'true'
                ? const Color(0xFF00FFFF)
                : const Color(0xFF00FF00),
            width: 3,
          ),
        ),
        title: Text(
          endingTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 20,
            color: type == 'true'
                ? const Color(0xFF00FFFF)
                : const Color(0xFF00FF00),
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Text(
            endingText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              height: 1.8,
              color: const Color(0xFF00FF00),
            ),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _returnToTitle();
              },
              child: const Text('タイトルに戻る'),
            ),
          ),
        ],
      ),
    );
  }

  void _showGameOver() {
    _audioService.stopBgm();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF110000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFFF0000), width: 3),
        ),
        title: Text(
          'GAME OVER',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 24,
            color: const Color(0xFFFF0000),
            letterSpacing: 4,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          ScenarioData.endingGameOver,
          style: const TextStyle(
            color: Color(0xFFFF4444),
            fontSize: 14,
            fontFamily: 'monospace',
            height: 1.8,
          ),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF001100),
                  foregroundColor: const Color(0xFF00FF00),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    gameState = GameState();
                    gameState.setFlag('heard_about_missing', true);
                    gameState.currentDay = 1;
                    gameState.currentTime = '朝';
                    gameState.currentLocation = '海女小屋';
                    gameState.currentLocationId = 'amagoya';
                    currentText = ScenarioData.day1Morning;
                  });
                },
                child: const Text('もう一度挑戦'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _returnToTitle();
                },
                child: const Text('タイトルへ'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _returnToTitle() {
    _audioService.stopBgm();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const TitleScreen()),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFF00FF00),
          ),
        ),
        backgroundColor: const Color(0xFF003300),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダーバー（タイトル中はなし）
            if (!isOpening) ...[
              StatusBar(gameState: gameState),
              // ノート＆設定ボタン行
              Container(
                color: const Color(0xFF000800),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00AA00),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: _showNotesScreen,
                      icon: const Icon(Icons.book, size: 16),
                      label: const Text('ノート', style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF006600),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => const SettingsScreen(),
                        );
                      },
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('設定', style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF004400),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      onPressed: _returnToTitle,
                      icon: const Icon(Icons.home, size: 16),
                      label: const Text('TOP', style: TextStyle(fontSize: 12, fontFamily: 'monospace')),
                    ),
                  ],
                ),
              ),
            ],
            
            // テキスト表示エリア
            Expanded(
              child: TextDisplay(
                text: currentText,
                backgroundImage: isOpening 
                    ? null 
                    : Locations.getById(gameState.currentLocationId)?.backgroundImage,
                animate: true,
                onAnimationComplete: () {},
              ),
            ),
            
            // コマンドエリア
            if (isOpening)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF001100),
                  border: Border(
                    top: BorderSide(color: Color(0xFF00FF00), width: 2),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: _continueToDay1,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'つづける',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              )
            else
              CommandPanel(
                onCommandSelected: _handleCommand,
                showDeduceButton: gameState.currentDay >= 2 ||
                    gameState.clues.length >= 5,
              ),
          ],
        ),
      ),
    );
  }

  // 女将さんの強制イベント（ゲーム開始時）
  void _showOkamiForceEvent() {
    final character = char.GameCharacters.getById('okami');
    if (character == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // 閉じられないようにする
      builder: (context) => CharacterDialogue(
        character: character,
        text: '''「お客さん！大変なんです！」

女将さんが慌てた様子で駆け込んできた。

「アキコさんが来てないんです！
約束の時間を30分も過ぎてるのに...
こんなこと、今まで一度もなかったのに！」

どうやら、今朝インタビューの約束をしていた
海女の鈴木アキコさんが
約束の時間になっても現れないようだ。

「海女小屋に行ってみてください！
他の海女さんたちも心配してるんです！」''',
        onClose: () {
          Navigator.of(context).pop();
          setState(() {
            currentText = '急いで海女小屋に向かった方が良さそうだ。';
          });
          _autoSave();
        },
      ),
    );
  }
}
