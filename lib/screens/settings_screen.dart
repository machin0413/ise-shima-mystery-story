import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onReset;

  const SettingsScreen({super.key, this.onReset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  late double _bgmVolume;
  late bool _bgmEnabled;

  @override
  void initState() {
    super.initState();
    _bgmVolume = _audioService.bgmVolume;
    _bgmEnabled = _audioService.isBgmEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
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
                  const Icon(Icons.settings, color: Color(0xFF00FF00), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '設定',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BGM ON/OFF
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BGM',
                        style: TextStyle(
                          color: Color(0xFF00FF00),
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Switch(
                        value: _bgmEnabled,
                        onChanged: (value) {
                          setState(() {
                            _bgmEnabled = value;
                            _audioService.setBgmEnabled(value);
                          });
                        },
                        activeColor: const Color(0xFF00FF00),
                        inactiveThumbColor: const Color(0xFF006600),
                        inactiveTrackColor: const Color(0xFF002200),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // BGMボリューム
                  Text(
                    'BGM音量: ${(_bgmVolume * 100).round()}%',
                    style: const TextStyle(
                      color: Color(0xFF00AA00),
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFF00FF00),
                      inactiveTrackColor: const Color(0xFF003300),
                      thumbColor: const Color(0xFF00FF00),
                      overlayColor: const Color(0xFF00FF00).withValues(alpha: 0.1),
                    ),
                    child: Slider(
                      value: _bgmVolume,
                      onChanged: _bgmEnabled
                          ? (value) {
                              setState(() {
                                _bgmVolume = value;
                                _audioService.setBgmVolume(value);
                              });
                            }
                          : null,
                    ),
                  ),

                  const Divider(color: Color(0xFF003300), height: 24),

                  // データリセット
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF220000),
                        foregroundColor: const Color(0xFFFF4444),
                        side: const BorderSide(color: Color(0xFFFF4444), width: 1),
                      ),
                      onPressed: () {
                        _showResetConfirm(context);
                      },
                      child: const Text('セーブデータを削除'),
                    ),
                  ),
                ],
              ),
            ),

            // 閉じるボタン
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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

  void _showResetConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFFF4444), width: 2),
        ),
        title: const Text(
          '確認',
          style: TextStyle(color: Color(0xFFFF4444), fontFamily: 'monospace'),
        ),
        content: const Text(
          'セーブデータを削除しますか？\nこの操作は取り消せません。',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'monospace',
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('やめる', style: TextStyle(color: Color(0xFF00AA00))),
          ),
          TextButton(
            onPressed: () async {
              await SaveService.deleteSave();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) Navigator.of(context).pop();
              widget.onReset?.call();
            },
            child: const Text('削除する', style: TextStyle(color: Color(0xFFFF4444))),
          ),
        ],
      ),
    );
  }
}
