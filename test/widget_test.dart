// ゲームロジックのテスト
// （AudioServiceがdart:jsに依存するためUIウィジェットのテストはWeb専用。
// ここではVM上で実行できる純Dartのロジックをテストする）

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/data/scenario_data.dart';
import 'package:flutter_app/models/character.dart';
import 'package:flutter_app/models/game_state.dart';
import 'package:flutter_app/models/location.dart';

void main() {
  group('GameState', () {
    test('初期状態はDay1朝・民宿', () {
      final state = GameState();
      expect(state.currentDay, 1);
      expect(state.currentTime, '朝');
      expect(state.currentLocationId, 'minshuku');
      expect(state.policeAlert, 0);
    });

    test('5回行動すると時間が進む', () {
      final state = GameState();
      for (var i = 0; i < 4; i++) {
        state.incrementAction();
      }
      expect(state.shouldAdvanceTime(), false);
      state.incrementAction();
      expect(state.shouldAdvanceTime(), true);

      state.advanceTime();
      expect(state.currentTime, '昼');
      expect(state.actionCount, 0);
    });

    test('夜が明けるとDayが進む', () {
      final state = GameState();
      state.currentTime = '夜';
      state.advanceTime();
      expect(state.currentDay, 2);
      expect(state.currentTime, '朝');
      expect(state.getFlag('day2_started'), true);
    });

    test('警戒度100でゲームオーバー', () {
      final state = GameState();
      state.increaseAlert(60);
      expect(state.getFlag('game_over'), false);
      state.increaseAlert(40);
      expect(state.policeAlert, 100);
      expect(state.getFlag('game_over'), true);
    });

    test('必要な手がかり4件で推理可能になる', () {
      final state = GameState();
      expect(state.canSolve, false);
      state.addClue('アキコは昨日夕方、海女小屋を出た後に失踪');
      state.addClue('15日に真珠養殖場で何かがあった？');
      state.addClue('鈴木家に立ち退き要求の書類');
      expect(state.canSolve, false);
      state.addClue('30年前にも似た失踪事件があった');
      expect(state.canSolve, true);
    });

    test('会話回数が正しくカウントされる（重複を保持）', () {
      final state = GameState();
      state.talkedTo.add('tome');
      state.talkedTo.add('tome');
      state.talkedTo.add('tome');
      expect(state.talkedTo.where((id) => id == 'tome').length, 3);
    });

    test('セーブ・ロードで状態が復元される', () {
      final state = GameState();
      state.currentDay = 2;
      state.currentTime = '夕';
      state.currentLocationId = 'pearl_farm';
      state.policeAlert = 50;
      state.addClue('テストの手がかり');
      state.addItem('テストの証拠品');
      state.talkedTo.addAll(['okami', 'okami', 'tome']);
      state.setFlag('found_akiko', true);

      final restored = GameState.fromJson(state.toJson());
      expect(restored.currentDay, 2);
      expect(restored.currentTime, '夕');
      expect(restored.currentLocationId, 'pearl_farm');
      expect(restored.policeAlert, 50);
      expect(restored.clues, contains('テストの手がかり'));
      expect(restored.items, contains('テストの証拠品'));
      expect(restored.talkedTo.where((id) => id == 'okami').length, 2);
      expect(restored.getFlag('found_akiko'), true);
    });
  });

  group('ScenarioData', () {
    test('会話データのキャラクターIDがすべて存在する', () {
      for (final entry in ScenarioData.conversations.entries) {
        final charId = entry.value['character'] as String;
        expect(
          GameCharacters.getById(charId),
          isNotNull,
          reason: '会話 ${entry.key} のキャラクター $charId が見つからない',
        );
      }
    });

    test('調査データのロケーションIDがすべて存在する', () {
      for (final entry in ScenarioData.investigations.entries) {
        final locationId = entry.value['location'] as String;
        expect(
          Locations.getById(locationId),
          isNotNull,
          reason: '調査 ${entry.key} のロケーション $locationId が見つからない',
        );
      }
    });

    test('各ロケーションの登場キャラクターがすべて存在する', () {
      for (final location in Locations.all) {
        for (final charId in location.getCharacters(2)) {
          expect(
            GameCharacters.getById(charId),
            isNotNull,
            reason: 'ロケーション ${location.id} のキャラクター $charId が見つからない',
          );
        }
      }
    });

    test('推理可能になるための手がかりがシナリオ内で入手可能', () {
      final obtainableClues = <String>{
        for (final conv in ScenarioData.conversations.values)
          if (conv['clue'] != null) conv['clue'] as String,
        for (final inv in ScenarioData.investigations.values)
          if (inv['clue'] != null) inv['clue'] as String,
      };
      final state = GameState();
      state.clues.addAll(obtainableClues);
      expect(state.canSolve, true);
    });

    test('エンディングテキストが定義されている', () {
      expect(ScenarioData.endingTrue, isNotEmpty);
      expect(ScenarioData.endingGoodbye, isNotEmpty);
      expect(ScenarioData.endingTimeout, isNotEmpty);
      expect(ScenarioData.endingGameOver, isNotEmpty);
      expect(ScenarioData.day2Night, isNotEmpty);
    });
  });
}
