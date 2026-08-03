import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'music_service.g.dart';

const _kPrefKey = 'music_enabled';
const _kMusicAsset = 'audio/ambient/theme.wav';

@Riverpod(keepAlive: true)
MusicService musicService(Ref ref) => MusicService();

/// Manages looping ambient background music.
///
/// Call [init] once at app start. The service is lifecycle-aware:
/// it pauses when the app goes to background and resumes on foreground.
/// Parents can toggle via [setEnabled]; the preference persists across launches.
class MusicService with WidgetsBindingObserver {
  final _player = AudioPlayer();
  final _storage = const FlutterSecureStorage();
  bool _enabled = true;
  bool _initialized = false;
  final double _normalVolume = 0.35;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final stored = await _storage.read(key: _kPrefKey);
    _enabled = stored != 'false';
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_normalVolume);
    WidgetsBinding.instance.addObserver(this);
    if (_enabled) await _start();
  }

  Future<void> _start() async {
    try {
      // Request duck-able focus so narration (which takes gain focus) auto-lowers us.
      await _player.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          usageType: AndroidUsageType.media,
          contentType: AndroidContentType.music,
          isSpeakerphoneOn: false,
          stayAwake: false,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
      ));
      await _player.play(AssetSource(_kMusicAsset));
    } catch (e) {
      debugPrint('[MusicService] could not start audio: $e');
    }
  }

  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _storage.write(key: _kPrefKey, value: enabled ? 'true' : 'false');
    if (enabled) {
      await _start();
    } else {
      await _player.stop();
    }
  }

  bool get isEnabled => _enabled;

  /// Silence music during narration.  Volume-based — stateless, idempotent,
  /// no interaction with Android audio-focus state machine.
  Future<void> duck() async {
    try { await _player.setVolume(0.0); } catch (_) {}
  }

  /// Restore music volume after narration.
  Future<void> unduck() async {
    if (!_enabled) return;
    try { await _player.setVolume(_normalVolume); } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _player.pause();
    } else if (state == AppLifecycleState.resumed && _enabled) {
      _player.resume();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
  }
}
