import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tts_service.g.dart';

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) => TtsService();

class TtsService {
  // Plan spec: Lumi voice — warm but not cartoonish. Verified on device before locking.
  static const double lumiPitch = 1.1;
  static const double lumiRate  = 0.82;
  // Verse word-by-word: slower so children can follow each word highlighted.
  static const double verseRate = 0.52;

  TtsService() {
    _ready = _init();
  }

  final _tts = FlutterTts();
  late final Future<void> _ready;

  Future<void> _init() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(lumiPitch);
    await _tts.setSpeechRate(lumiRate);
    await _tts.setVolume(1.0);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }
  }

  Future<void> speak(String text, {VoidCallback? onDone}) async {
    await _ready;
    await _tts.stop();
    // Always replace completion handler so stale callbacks don't fire
    _tts.setCompletionHandler(onDone ?? () {});
    await _tts.speak(text);
  }

  /// Speak with per-word highlight callbacks.
  Future<void> speakWithHighlight(
    String text, {
    required void Function(String word, int start, int end) onWord,
    VoidCallback? onDone,
    double rate = verseRate,
  }) async {
    await _ready;
    await _tts.stop();
    await _tts.setSpeechRate(rate);
    _tts.setProgressHandler((_, start, end, word) => onWord(word, start, end));
    if (onDone != null) _tts.setCompletionHandler(onDone);
    await _tts.speak(text);
  }

  Future<void> resetRate() => _tts.setSpeechRate(lumiRate);

  Future<void> stop() => _tts.stop();

  Future<void> dispose() => _tts.stop();
}
