import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sound_service.g.dart';

// ─── Sound effect catalogue ───────────────────────────────────────────────────

enum SoundEffect {
  correct,       // right answer tap
  incorrect,     // wrong answer tap
  pageAdvance,   // story scene forward
  storyComplete, // end of story session
  colorFill,     // region filled in coloring screen
}

// ─── Provider ─────────────────────────────────────────────────────────────────

@riverpod
SoundService soundService(Ref ref) => SoundService();

// ─── Service ──────────────────────────────────────────────────────────────────

class SoundService {
  final _pool = <SoundEffect, AudioPlayer>{};
  bool _muted = false;

  void setMuted(bool muted) => _muted = muted;

  Future<void> play(SoundEffect effect) async {
    if (_muted) return;
    final player = _pool.putIfAbsent(effect, AudioPlayer.new);
    // Each pool entry can only play one sound at a time; stop before re-play.
    await player.stop();
    await player.play(AssetSource(_assetFor(effect)));
  }

  String _assetFor(SoundEffect effect) => switch (effect) {
    SoundEffect.correct       => 'audio/sfx/correct.wav',
    SoundEffect.incorrect     => 'audio/sfx/incorrect.wav',
    SoundEffect.pageAdvance   => 'audio/sfx/page_advance.wav',
    SoundEffect.storyComplete => 'audio/sfx/complete.wav',
    SoundEffect.colorFill     => 'audio/sfx/color_fill.wav',
  };

  void dispose() {
    for (final p in _pool.values) { p.dispose(); }
  }
}
