import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_session.g.dart';

/// True while a child is inside a story session.
///
/// Content downloads queue behind this: a download must never compete with
/// narration playback or interrupt a session in progress (US-12). The story
/// player raises it on entry and lowers it on exit.
@Riverpod(keepAlive: true)
class StorySessionActive extends _$StorySessionActive {
  @override
  bool build() => false;

  void begin() => state = true;
  void end() => state = false;
}

/// Bumped whenever downloaded content changes on disk.
///
/// The story providers watch this, so a package that finishes downloading
/// refreshes the home grid in place — no app restart (US-12).
@Riverpod(keepAlive: true)
class ContentRevision extends _$ContentRevision {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}
