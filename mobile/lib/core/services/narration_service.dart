import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'music_service.dart';
import 'tts_service.dart';

/// Central speech audio service for Little Bible.
///
/// Every piece of spoken audio — story narration, Bible verse reading, memory
/// verses, UI phrases — flows through the single [_speak] core.
///
/// Key design decisions:
///   • Audio context is set ONCE at construction, not per-play, to eliminate
///     the 300-700 ms Android OS-negotiation lag before each scene starts.
///   • Asset-existence results are cached so the bundle is probed only once
///     per path across the app session.
///   • Implements WidgetsBindingObserver so narration pauses automatically
///     when a phone call arrives and resumes when the call ends.
class NarrationService with WidgetsBindingObserver {
  NarrationService(this._tts, {MusicService? music}) : _music = music {
    _initAudioContext();
    WidgetsBinding.instance.addObserver(this);
  }

  final TtsService _tts;
  final MusicService? _music;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _completionSub;

  bool _muted = false;
  bool _wasPlayingBeforeInterrupt = false;

  void setMuted(bool v) => _muted = v;

  // Set audio context once — keeps per-play latency to a minimum.
  void _initAudioContext() {
    _player.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        audioFocus: AndroidAudioFocus.gain,
        usageType: AndroidUsageType.media,
        contentType: AndroidContentType.speech,
        isSpeakerphoneOn: false,
        stayAwake: false,
      ),
      iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
    )).catchError((_) {});
  }

  // ── Phone-call / app-background handling ─────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (_player.state == PlayerState.playing) {
        _wasPlayingBeforeInterrupt = true;
        _player.pause().catchError((_) {});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforeInterrupt) {
        _wasPlayingBeforeInterrupt = false;
        _player.resume().catchError((_) {});
      }
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> speakScene({
    required String storyId,
    required int sceneIndex,
    required String fallbackText,
    VoidCallback? onDone,
  }) =>
      _speak(
        assetPath: 'assets/audio/stories/$storyId/scene_$sceneIndex.mp3',
        fallbackText: fallbackText,
        onDone: onDone,
      );

  Future<void> speakStoryVerse({
    required String storyId,
    required int verseIndex,
    required String fallbackText,
    double rate = TtsService.verseRate,
    void Function(String, int, int)? onWord,
    VoidCallback? onDone,
  }) =>
      _speak(
        assetPath: 'assets/audio/stories/$storyId/verse_$verseIndex.mp3',
        fallbackText: fallbackText,
        rate: rate,
        onWord: onWord,
        onDone: onDone,
      );

  Future<void> speakMemoryVerse({
    required String storyId,
    required String fallbackText,
    double rate = TtsService.verseRate,
    void Function(String, int, int)? onWord,
    VoidCallback? onDone,
  }) {
    onWord?.call('', 0, 0);
    return _speak(
      assetPath: 'assets/audio/stories/$storyId/memory_verse.mp3',
      fallbackText: fallbackText,
      rate: rate,
      onWord: onWord,
      onDone: onDone,
    );
  }

  Future<void> speakUi(String key, {String fallback = ''}) =>
      _speak(
        assetPath: 'assets/audio/stories/_ui/$key.mp3',
        fallbackText: fallback,
      );

  Future<void> stop() async {
    _wasPlayingBeforeInterrupt = false;
    try { await _stopPlayer(); } catch (_) {}
    try { await _tts.stop(); } catch (_) {}
    try { await _music?.unduck(); } catch (_) {}
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    try { await stop(); } catch (_) {}
    try { await _player.dispose(); } catch (_) {}
  }

  // ── Central speak core ────────────────────────────────────────────────────

  Future<void> _speak({
    required String assetPath,
    required String fallbackText,
    double rate = TtsService.verseRate,
    void Function(String, int, int)? onWord,
    VoidCallback? onDone,
  }) async {
    if (_muted) {
      onDone?.call();
      return;
    }

    await _music?.duck();

    // unduck must complete before onDone fires so the next scene's duck()
    // does not race with this unduck.
    Future<void> finish() async {
      try { await _music?.unduck(); } catch (_) {}
      onDone?.call();
    }

    if (await _assetExists(assetPath)) {
      await _playMp3(assetPath, onDone: finish);
    } else if (fallbackText.isNotEmpty) {
      try {
        await _tts.speakWithHighlight(
          fallbackText,
          rate: rate,
          onWord: onWord ?? (_, _, _) {},
          onDone: finish,
        );
      } catch (_) {
        await finish();
      }
    } else {
      await finish();
    }
  }

  // ── MP3 playback ──────────────────────────────────────────────────────────

  Future<void> _playMp3(String assetPath, {VoidCallback? onDone}) async {
    // Capture state before stopping: Android MediaPlayer needs a brief settling
    // period after stop() before it can accept a new play() without silently
    // dropping the request.
    final wasBusy = _player.state == PlayerState.playing ||
        _player.state == PlayerState.paused;
    await _stopPlayer();
    if (wasBusy) {
      await Future.delayed(const Duration(milliseconds: 80));
    }

    _completionSub = _player.onPlayerComplete.listen((_) {
      _completionSub?.cancel();
      _completionSub = null;
      onDone?.call();
    });

    try {
      await _player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (_) {
      await _completionSub?.cancel();
      _completionSub = null;
      onDone?.call();
    }
  }

  Future<void> _stopPlayer() async {
    await _completionSub?.cancel();
    _completionSub = null;
    try { await _player.stop(); } catch (_) {}
  }

  // Cached — the bundle is probed only once per path per app session.
  static final _existsCache = <String, bool>{};

  static Future<bool> _assetExists(String assetPath) async {
    final cached = _existsCache[assetPath];
    if (cached != null) return cached;
    try {
      await rootBundle.load(assetPath);
      return _existsCache[assetPath] = true;
    } catch (_) {
      return _existsCache[assetPath] = false;
    }
  }
}
