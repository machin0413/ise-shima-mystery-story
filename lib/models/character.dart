/// 登場人物データ
class Character {
  final String id;
  final String name;
  final int age;
  final String role;
  final String description;
  final String? secret; // 隠された秘密
  final String? imagePath; // キャラクター画像パス
  
  Character({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.description,
    this.secret,
    this.imagePath,
  });
}

/// ゲームに登場するキャラクター一覧
class GameCharacters {
  static final Character akiko = Character(
    id: 'akiko',
    name: '鈴木アキコ',
    age: 45,
    role: '行方不明の海女',
    description: 'ベテラン海女でリーダー格。気が強くはっきり物を言う性格。',
    secret: '真珠の密漁を目撃していた',
  );
  
  static final Character midori = Character(
    id: 'midori',
    name: '田中ミドリ',
    age: 52,
    role: '海女仲間',
    description: 'アキコの先輩海女。最近漁場の縄張りで対立していた。',
    secret: '自分の漁場を守りたかった',
    imagePath: 'assets/images/midori.jpg',
  );
  
  static final Character yuki = Character(
    id: 'yuki',
    name: '山本ユキ',
    age: 38,
    role: '若手海女',
    description: 'まだ海女歴が浅い。アキコに厳しく指導されていた。',
    secret: 'アキコの指導に恨みを持っていた',
    imagePath: 'assets/images/yuki.jpg',
  );
  
  static final Character tome = Character(
    id: 'tome',
    name: '伊藤トメ',
    age: 68,
    role: '最年長の海女',
    description: '村の古老。昔から海女を続けている。何か知っているようだが...',
    secret: '過去の事件を知っている',
    imagePath: 'assets/images/tome.jpg',
  );
  
  static final Character takeshi = Character(
    id: 'takeshi',
    name: '鈴木タケシ',
    age: 50,
    role: 'アキコの夫・漁師',
    description: '無口で感情を表に出さない。妻の失踪後も淡々としている。',
    secret: '妻との関係が冷え切っていた',
    imagePath: 'assets/images/takeshi.jpg',
  );
  
  static final Character okami = Character(
    id: 'okami',
    name: '磯野カズエ',
    age: 60,
    role: '民宿「うみかぜ」の女将',
    description: '主人公が泊まっている宿の女将。村の情報通。',
    imagePath: 'assets/images/okami.jpg',
  );
  
  static final Character policeman = Character(
    id: 'policeman',
    name: '村田巡査',
    age: 55,
    role: '駐在所の巡査',
    description: '地元の駐在さん。温厚だが捜査には不慣れ。',
    imagePath: 'assets/images/policeman.jpg',
  );

  // Day2から登場
  static final Character detective = Character(
    id: 'detective',
    name: '橘刑事',
    age: 42,
    role: '県警捜査一課',
    description: '本庁から派遣された敏腕刑事。よそ者に冷たい。',
    imagePath: 'assets/images/policeman.jpg', // 暫定
  );

  static final Character pearlBoss = Character(
    id: 'pearl_boss',
    name: '西山社長',
    age: 58,
    role: '真珠養殖場社長',
    description: '村の有力者。開発計画を推進。',
    secret: '不法投棄と殺人を隠蔽',
    imagePath: 'assets/images/takeshi.jpg', // 暫定
  );
  
  static final List<Character> all = [
    akiko,
    midori,
    yuki,
    tome,
    takeshi,
    okami,
    policeman,
    detective,
    pearlBoss,
  ];
  
  static Character? getById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
