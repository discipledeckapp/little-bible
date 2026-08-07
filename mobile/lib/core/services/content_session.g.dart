// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storySessionActiveHash() =>
    r'37de579840837d39a3dca2824bde7c53860a1880';

/// True while a child is inside a story session.
///
/// Content downloads queue behind this: a download must never compete with
/// narration playback or interrupt a session in progress (US-12). The story
/// player raises it on entry and lowers it on exit.
///
/// Copied from [StorySessionActive].
@ProviderFor(StorySessionActive)
final storySessionActiveProvider =
    NotifierProvider<StorySessionActive, bool>.internal(
      StorySessionActive.new,
      name: r'storySessionActiveProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storySessionActiveHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StorySessionActive = Notifier<bool>;
String _$contentRevisionHash() => r'47ab38219cc4894bdbff1d57fff036e310dc0a2a';

/// Bumped whenever downloaded content changes on disk.
///
/// The story providers watch this, so a package that finishes downloading
/// refreshes the home grid in place — no app restart (US-12).
///
/// Copied from [ContentRevision].
@ProviderFor(ContentRevision)
final contentRevisionProvider = NotifierProvider<ContentRevision, int>.internal(
  ContentRevision.new,
  name: r'contentRevisionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contentRevisionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ContentRevision = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
