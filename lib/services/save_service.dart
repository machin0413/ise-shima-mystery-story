import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

/// セーブ/ロードサービス
class SaveService {
  static const String _saveKey = 'game_save_slot_1';
  static const String _hasSaveKey = 'has_save_data';

  /// セーブデータが存在するか確認
  static Future<bool> hasSaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_hasSaveKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ hasSaveData error: $e');
      }
      return false;
    }
  }

  /// ゲーム状態をセーブ
  static Future<bool> saveGame(GameState gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(gameState.toJson());
      await prefs.setString(_saveKey, jsonStr);
      await prefs.setBool(_hasSaveKey, true);
      if (kDebugMode) {
        debugPrint('✅ Game saved: Day${gameState.currentDay} ${gameState.currentTime}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Save error: $e');
      }
      return false;
    }
  }

  /// セーブデータをロード
  static Future<GameState?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_saveKey);
      if (jsonStr == null) return null;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final state = GameState.fromJson(json);
      if (kDebugMode) {
        debugPrint('✅ Game loaded: Day${state.currentDay} ${state.currentTime}');
      }
      return state;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Load error: $e');
      }
      return null;
    }
  }

  /// セーブデータを削除
  static Future<void> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
      await prefs.setBool(_hasSaveKey, false);
      if (kDebugMode) {
        debugPrint('✅ Save data deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Delete save error: $e');
      }
    }
  }

  /// セーブ情報のサマリーを取得
  static Future<String?> getSaveSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_saveKey);
      if (jsonStr == null) return null;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final day = json['currentDay'] ?? 1;
      final time = json['currentTime'] ?? '朝';
      final location = json['currentLocation'] ?? '民宿うみかぜ';
      final clueCount = (json['clues'] as List?)?.length ?? 0;
      return 'Day $day - $time  $location\n手がかり: $clueCount件';
    } catch (e) {
      return null;
    }
  }
}
