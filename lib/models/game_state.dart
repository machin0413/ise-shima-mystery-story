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
  };
  
  GameState();
  
  void addClue(String clue) {
    clues.add(clue);
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
  
  bool shouldAdvanceTime() {
    // 6回行動するごとに時間が進む
    return actionCount >= 6;
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
      }
    }
    return 'day1_morning';
  }
}
