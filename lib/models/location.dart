/// ロケーションデータ
class Location {
  final String id;
  final String name;
  final String description;
  final List<String> availableCharacters; // この場所にいるキャラクター
  final List<String> day2Characters; // Day2に追加されるキャラクター
  final String? backgroundImage; // 背景画像パス
  
  Location({
    required this.id,
    required this.name,
    required this.description,
    this.availableCharacters = const [],
    this.day2Characters = const [],
    this.backgroundImage,
  });

  List<String> getCharacters(int day) {
    if (day >= 2) {
      return [...availableCharacters, ...day2Characters];
    }
    return availableCharacters;
  }
}

/// ゲーム内のロケーション一覧
class Locations {
  static final Location minshuku = Location(
    id: 'minshuku',
    name: '民宿うみかぜ',
    description: '主人公が泊まっている民宿。女将さんが切り盛りしている。',
    availableCharacters: ['okami'],
    backgroundImage: 'assets/images/bg_minshuku.jpg',
  );
  
  static final Location amagoya = Location(
    id: 'amagoya',
    name: '海女小屋',
    description: '海女たちが休憩する小屋。取材の約束をした場所。',
    availableCharacters: ['midori', 'yuki', 'tome'],
    backgroundImage: 'assets/images/bg_amagoya.jpg',
  );
  
  static final Location suzukiHouse = Location(
    id: 'suzuki_house',
    name: '鈴木家',
    description: 'アキコさんの自宅。海が見える高台にある。',
    availableCharacters: ['takeshi'],
    backgroundImage: 'assets/images/bg_suzuki_house.jpg',
  );
  
  static final Location harbor = Location(
    id: 'harbor',
    name: '漁港',
    description: '漁師たちが集まる場所。朝は特に賑やか。',
    availableCharacters: ['takeshi'],
    backgroundImage: 'assets/images/bg_harbor.jpg',
  );
  
  static final Location policeStation = Location(
    id: 'police_station',
    name: '駐在所',
    description: '村の小さな駐在所。村田巡査が一人で守っている。',
    availableCharacters: ['policeman'],
    day2Characters: ['detective'],
    backgroundImage: 'assets/images/bg_police_station.jpg',
  );
  
  static final Location beach = Location(
    id: 'beach',
    name: '海岸',
    description: '海女たちが潜る海岸。岩場が多い。',
    availableCharacters: [],
    backgroundImage: 'assets/images/bg_beach.jpg',
  );

  static final Location pearlFarm = Location(
    id: 'pearl_farm',
    name: '真珠養殖場',
    description: '村の沖合にある養殖場。立入制限がある。',
    availableCharacters: [],
    day2Characters: ['pearl_boss'],
    backgroundImage: 'assets/images/bg_harbor.jpg', // 暫定
  );
  
  static final List<Location> all = [
    minshuku,
    amagoya,
    suzukiHouse,
    harbor,
    policeStation,
    beach,
    pearlFarm,
  ];
  
  static Location? getById(String id) {
    try {
      return all.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }
}
