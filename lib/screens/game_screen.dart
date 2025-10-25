import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/character.dart' as char;
import '../models/location.dart';
import '../data/scenario_data.dart';
import '../widgets/command_panel.dart';
import '../widgets/text_display.dart';
import '../widgets/status_bar.dart';
import '../widgets/character_dialogue.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  String currentText = '';
  bool isShowingDialog = false;
  bool isOpening = true; // オープニング表示中かどうか
  
  @override
  void initState() {
    super.initState();
    gameState = GameState();
    _preloadImages();
    _startGame();
  }

  void _startGame() {
    setState(() {
      currentText = ScenarioData.opening;
      isOpening = true;
    });
  }
  
  // 画像を事前に読み込む
  void _preloadImages() {
    final imagePaths = [
      // キャラクター画像
      'assets/images/okami.jpg',
      'assets/images/midori.jpg',
      'assets/images/yuki.jpg',
      'assets/images/tome.jpg',
      'assets/images/takeshi.jpg',
      'assets/images/policeman.jpg',
      // 背景画像
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
  }

  void _continueToDay1() {
    setState(() {
      currentText = ScenarioData.day1Morning;
      gameState.currentDay = 1;
      gameState.currentTime = '朝';
      gameState.currentLocation = '海女小屋';
      gameState.currentLocationId = 'amagoya';
      gameState.setFlag('heard_about_missing', true);
      isOpening = false;
    });
  }

  void _handleCommand(String command) {
    switch (command) {
      case 'talk':
        _showTalkDialog();
        break;
      case 'investigate':
        _showInvestigateDialog();
        break;
      case 'think':
        _showThinkDialog();
        break;
      case 'move':
        _showMoveDialog();
        break;
      case 'secret':
        _showSecretInvestigateDialog();
        break;
    }
  }

  void _showTalkDialog() {
    final location = Locations.getById(gameState.currentLocationId);
    if (location == null) return;

    final availableChars = location.availableCharacters
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
          children: availableChars.map((char) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _talkToCharacter(char.id);
                  },
                  child: Text(char.name),
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
    // 初回会話か2回目以降かを判定
    final conversationKey = gameState.talkedTo.contains(charId)
        ? '${charId}_second'
        : '${charId}_first';
    
    final conversation = ScenarioData.conversations[conversationKey];
    final character = char.GameCharacters.getById(charId);
    
    if (conversation != null && character != null) {
      // キャラクターダイアログを表示
      showDialog(
        context: context,
        builder: (context) => CharacterDialogue(
          character: character,
          text: conversation['text'],
          onClose: () {
            Navigator.of(context).pop();
            setState(() {
              currentText = conversation['text'];
              gameState.talkedTo.add(charId);
              
              // 手がかりがあれば追加
              if (conversation['clue'] != null) {
                gameState.addClue(conversation['clue']);
                _showMessage('手がかりを得た: ${conversation['clue']}');
              }
              
              // 行動回数を増やして時間経過をチェック
              _checkTimeAdvance();
            });
          },
        ),
      );
    } else {
      setState(() {
        currentText = 'これ以上、新しい情報は得られなさそうだ。';
      });
    }
  }
  
  void _checkTimeAdvance() {
    gameState.incrementAction();
    
    if (gameState.shouldAdvanceTime()) {
      final oldTime = gameState.currentTime;
      gameState.advanceTime();
      
      // 時間経過のメッセージを表示（少し遅延させる）
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showTimeAdvanceDialog(oldTime, gameState.currentTime);
        }
      });
    }
  }
  
  void _showTimeAdvanceDialog(String oldTime, String newTime) {
    String scenarioText = '';
    
    if (gameState.currentDay == 1) {
      if (newTime == '昼') {
        scenarioText = ScenarioData.day1Afternoon;
      } else if (newTime == '夕') {
        scenarioText = ScenarioData.day1Evening;
      } else if (newTime == '夜') {
        scenarioText = ScenarioData.day1Night;
      }
    } else if (gameState.currentDay == 2 && newTime == '朝') {
      scenarioText = ScenarioData.day2Morning;
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
            '時間が経過した',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
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
    
    // 既に調査済みかチェック
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
        
        // 調査済みとしてマーク
        gameState.investigatedLocations.add(locationId);
        
        if (investigation['clue'] != null) {
          gameState.addClue(investigation['clue']);
          _showMessage('手がかりを得た: ${investigation['clue']}');
        }
        
        // 行動回数を増やして時間経過をチェック
        _checkTimeAdvance();
      });
    } else {
      setState(() {
        currentText = 'この場所で特に気になるものは見つからなかった。';
        // 調査可能な場所でなくても、調査済みとしてマーク
        gameState.investigatedLocations.add(locationId);
      });
    }
  }

  void _showThinkDialog() {
    final cluesList = gameState.clues.isEmpty
        ? '手がかり: まだ何も集めていない'
        : '手がかり:\n${gameState.clues.map((c) => '・$c').join('\n')}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          '情報整理',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cluesList,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                '\n会話した人物:\n${gameState.talkedTo.isEmpty ? "まだ誰とも話していない" : gameState.talkedTo.map((id) => '・${char.GameCharacters.getById(id)?.name ?? id}').join('\n')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            ],
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

  void _showMoveDialog() {
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
            children: Locations.all.map((location) {
              final isCurrent = location.name == gameState.currentLocation;
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
                    child: Text(
                      isCurrent ? '${location.name} (現在地)' : location.name,
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
  }

  void _showSecretInvestigateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFF00FF00), width: 2),
        ),
        title: Text(
          '⚠️ こっそり調べる',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        content: Text(
          '警察の目を盗んで調査をすると、\n警戒度が上がるリスクがあります。\n\n（パイロット版では未実装）',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
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

  void _showMessage(String message) {
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
            // オープニング中はステータスバーを非表示
            if (!isOpening) StatusBar(gameState: gameState),
            
            // テキスト表示エリア
            Expanded(
              child: TextDisplay(
                text: currentText,
                backgroundImage: isOpening 
                    ? null 
                    : Locations.getById(gameState.currentLocationId)?.backgroundImage,
              ),
            ),
            
            // オープニング中は「つづける」ボタン、それ以外はコマンドパネル
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
              CommandPanel(onCommandSelected: _handleCommand),
          ],
        ),
      ),
    );
  }
}
