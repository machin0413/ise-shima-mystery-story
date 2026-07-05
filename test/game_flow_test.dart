// 推理〜エンディングまでのゲームフローのウィジェットテスト

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app/models/game_state.dart';
import 'package:flutter_app/screens/game_screen.dart';

GameState solvableState({bool foundAkiko = false, bool withClues = true}) {
  final s = GameState();
  s.currentDay = 2;
  s.currentTime = '夕';
  s.currentLocation = '民宿うみかぜ';
  s.currentLocationId = 'minshuku';
  if (withClues) {
    s.clues.addAll([
      'アキコは昨日夕方、海女小屋を出た後に失踪',
      '15日に真珠養殖場で何かがあった？',
      '鈴木家に立ち退き要求の書類',
      '30年前にも似た失踪事件があった',
      'アキコは開発計画に反対していた',
    ]);
  }
  if (foundAkiko) {
    s.setFlag('found_akiko', true);
  }
  return s;
}

Future<void> pumpGame(WidgetTester tester, GameState state) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(MaterialApp(home: GameScreen(savedState: state)));
  // タイプライター表示の完了を待つ
  await tester.pump(const Duration(seconds: 15));
}

void main() {
  testWidgets('手がかり不足では推理できない', (tester) async {
    await pumpGame(tester, solvableState(withClues: false));

    await tester.tap(find.text('推理する'));
    await tester.pumpAndSettle();

    expect(find.textContaining('まだ証拠が不十分だ'), findsOneWidget);

    await tester.tap(find.text('わかった'));
    await tester.pumpAndSettle();
  });

  testWidgets('誤った容疑者を選ぶと推理が外れる', (tester) async {
    await pumpGame(tester, solvableState());

    await tester.tap(find.text('推理する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('鈴木タケシ'));
    await tester.pumpAndSettle();
    // 「違う気がする」テキストがタイプライター表示される
    await tester.pump(const Duration(seconds: 10));

    expect(find.textContaining('違う気がする'), findsOneWidget);
  });

  testWidgets('西山社長を特定するとNORMAL ENDING（アキコ未発見）', (tester) async {
    await pumpGame(tester, solvableState(foundAkiko: false));

    await tester.tap(find.text('推理する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('西山社長（真珠養殖場）'));
    await tester.pumpAndSettle();

    expect(find.text('NORMAL ENDING'), findsOneWidget);
    expect(find.textContaining('─Fin─'), findsOneWidget);
  });

  testWidgets('アキコ発見済みで西山社長を特定するとTRUE ENDING', (tester) async {
    await pumpGame(tester, solvableState(foundAkiko: true));

    await tester.tap(find.text('推理する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('西山社長（真珠養殖場）'));
    await tester.pumpAndSettle();

    expect(find.text('TRUE ENDING'), findsOneWidget);
    expect(find.textContaining('西山社長は逮捕'), findsOneWidget);
  });

  testWidgets('Day 3の朝を迎えるとBAD ENDING（タイムアップ）', (tester) async {
    final state = solvableState();
    state.currentTime = '夜';
    state.actionCount = 4; // 次の行動で時間が進む
    await pumpGame(tester, state);

    // 「しらべる」で行動回数を消費して時間を進める
    await tester.tap(find.text('しらべる'));
    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();

    expect(find.text('BAD ENDING'), findsOneWidget);
    expect(find.textContaining('3日目の朝が来てしまった'), findsOneWidget);
  });
}
