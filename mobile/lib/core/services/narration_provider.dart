import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'music_service.dart';
import 'narration_service.dart';
import 'tts_service.dart';

final narrationServiceProvider = Provider<NarrationService>((ref) {
  final tts = ref.watch(ttsServiceProvider);
  final music = ref.watch(musicServiceProvider);
  final service = NarrationService(tts, music: music);
  ref.onDispose(service.dispose);
  return service;
});
