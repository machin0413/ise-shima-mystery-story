/// ゲーム状態管理
class GameState {
  int currentDay = 1;
  String currentTime = '朝'; // 朝/昼/夕/夜
  String currentLocation = '民宿うみかぜ';
  String currentLocationId = 'minshuku'; // ロケーションID
  int policeAlert = 0; // 警察の警戒度 (100でゲームオーバー)
  
  // 収集した手がかり
  Set<String> clues = {};
  
  // 会話したNPC
  Set<String> talkedTo = {};
  
  // 訪れた場所
  Set<String> visitedLocations = {};
  
  // 調査済みの場所
  Set<String> investigatedLocations = {};
  
  // こっそり調査済みの場所
  Set<String> secretInvestigatedLocations = {};
  
  // 行動回数（時間経過に使用）
  int actionCount = 0;
  
  // ストーリーフラグ
  Map<String, bool> flags = {
    'met_akiko': false,
    'heard_about_missing': false,
    'talked_to_police': false,
    'found_first_clue': false,
    'reached_afternoon': false,
    'reached_evening': false,
    'reached_night': false,
    'day2_started': false,
    'detective_arrived': false,
    'found_body': false,
    'pearl_farm_investigated': false,
    'suspect_identified': false,
    'game_over': false,
    'ending_reached': false,
  };

  // 収集したアイテム（証拠品）
  Set<String> items = {};

  // 推理に使用した証拠
  Set<String> usedEvidence = {};
  
  GameState();
  
  void addClue(String clue) {
    clues.add(clue);
  }

  void addItem(String item) {
    items.add(item);
  }
  
  void setFlag(String flag, bool value) {
    flags[flag] = value;
  }
  
  bool getFlag(String flag) {
    return flags[flag] ?? false;
  }
  
  void incrementAction() {
    actionCount++;
  }

  // 警戒度を増加（こっそりしらべる）
  void increaseAlert(int amount) {
    policeAlert = (policeAlert + amount).clamp(0, 100);
    if (policeAlert >= 100) {
      setFlag('game_over', true);
    }
  }

  // 警戒度の表示テキスト
  String get alertLevel {
    if (policeAlert < 30) return '低';
    if (policeAlert < 60) return '中';
    if (policeAlert < 90) return '高';
    return '危険';
  }
  
  bool shouldAdvanceTime() {
    // 5回行動するごとに時間が進む
    return actionCount >= 5;
  }
  
  void advanceTime() {
    actionCount = 0; // リセット
    switch (currentTime) {
      case '朝':
        currentTime = '昼';
        setFlag('reached_afternoon', true);
        break;
      case '昼':
        currentTime = '夕';
        setFlag('reached_evening', true);
        break;
      case '夕':
        currentTime = '夜';
        setFlag('reached_night', true);
        break;
      case '夜':
        currentDay++;
        currentTime = '朝';
        if (currentDay == 2) {
          setFlag('day2_started', true);
        }
        break;
    }
  }
  
  String getTimeBasedScenario() {
    if (currentDay == 1) {
      switch (currentTime) {
        case '朝':
          return 'day1_morning';
        case '昼':
          return 'day1_afternoon';
        case '夕':
          return 'day1_evening';
        case '夜':
          return 'day1_night';
      }
    } else if (currentDay == 2) {
      switch (currentTime) {
        case '朝':
          return 'day2_morning';
        case '昼':
          return 'day2_afternoon';
        case '夕':
          return 'day2_evening';
      }
    }
    return 'day1_morning';
  }

  // 推理に必要な手がかりが揃っているか
  bool get canSolve {
    final requiredClues = {
      'アキコは昨日夕方、海女小屋を出た後に失踪',
      '15日に真珠養殖場で何かがあった？',
      '鈴木家に立ち退き要求の書類',
      '30年前にも似た失踪事件があった',
      'アキコは開発計画に反対していた',
    };
    return clues.intersection(requiredClues).length >= 4;
  }

  // セーブデータをMapに変換
  Map<String, dynamic> toJson() {
    return {
      'currentDay': currentDay,
      'currentTime': currentTime,
      'currentLocation': currentLocation,
      'currentLocationId': currentLocationId,
      'policeAlert': policeAlert,
      'clues': clues.toList(),
      'talkedTo': talkedTo.toList(),
      'visitedLocations': visitedLocations.toList(),
      'investigatedLocations': investigatedLocations.toList(),
      'secretInvestigatedLocations': secretInvestigatedLocations.toList(),
      'actionCount': actionCount,
      'flags': flags,
      'items': items.toList(),
    };
  }

  // MapからGameStateを復元
  static GameState fromJson(Map<String, dynamic> json) {
    final state = GameState();
    state.currentDay = json['currentDay'] ?? 1;
    state.currentTime = json['currentTime'] ?? '朝';
    state.currentLocation = json['currentLocation'] ?? '民宿うみかぜ';
    state.currentLocationId = json['currentLocationId'] ?? 'minshuku';
    state.policeAlert = json['policeAlert'] ?? 0;
    state.clues = Set<String>.from(json['clues'] ?? []);
    state.talkedTo = Set<String>.from(json['talkedTo'] ?? []);
    state.visitedLocations = Set<String>.from(json['visitedLocations'] ?? []);
    state.investigatedLocations = Set<String>.from(json['investigatedLocations'] ?? []);
    state.secretInvestigatedLocations = Set<String>.from(json['secretInvestigatedLocations'] ?? []);
    state.actionCount = json['actionCount'] ?? 0;
    state.items = Set<String>.from(json['items'] ?? []);
    if (json['flags'] != null) {
      final flagsMap = json['flags'] as Map<String, dynamic>;
      flagsMap.forEach((key, value) {
        state.flags[key] = value as bool;
      });
    }
    return state;
  }
}
