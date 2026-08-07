// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storyHash() => r'be607cb8bb9a748ef5a819099319709916d4aea5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [story].
@ProviderFor(story)
const storyProvider = StoryFamily();

/// See also [story].
class StoryFamily extends Family<AsyncValue<StoryModel>> {
  /// See also [story].
  const StoryFamily();

  /// See also [story].
  StoryProvider call(String storyId) {
    return StoryProvider(storyId);
  }

  @override
  StoryProvider getProviderOverride(covariant StoryProvider provider) {
    return call(provider.storyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'storyProvider';
}

/// See also [story].
class StoryProvider extends AutoDisposeFutureProvider<StoryModel> {
  /// See also [story].
  StoryProvider(String storyId)
    : this._internal(
        (ref) => story(ref as StoryRef, storyId),
        from: storyProvider,
        name: r'storyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$storyHash,
        dependencies: StoryFamily._dependencies,
        allTransitiveDependencies: StoryFamily._allTransitiveDependencies,
        storyId: storyId,
      );

  StoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storyId,
  }) : super.internal();

  final String storyId;

  @override
  Override overrideWith(
    FutureOr<StoryModel> Function(StoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoryProvider._internal(
        (ref) => create(ref as StoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storyId: storyId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<StoryModel> createElement() {
    return _StoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoryProvider && other.storyId == storyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StoryRef on AutoDisposeFutureProviderRef<StoryModel> {
  /// The parameter `storyId` of this provider.
  String get storyId;
}

class _StoryProviderElement extends AutoDisposeFutureProviderElement<StoryModel>
    with StoryRef {
  _StoryProviderElement(super.provider);

  @override
  String get storyId => (origin as StoryProvider).storyId;
}

String _$allStoriesHash() => r'1822a3d42c7f9b4e0e8517883587ccdb138eb90d';

/// See also [allStories].
@ProviderFor(allStories)
final allStoriesProvider = AutoDisposeFutureProvider<List<StoryModel>>.internal(
  allStories,
  name: r'allStoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allStoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllStoriesRef = AutoDisposeFutureProviderRef<List<StoryModel>>;
String _$storyActivityHash() => r'1357117c2bd87da1f807ea00991a04497e3fe77e';

/// See also [storyActivity].
@ProviderFor(storyActivity)
const storyActivityProvider = StoryActivityFamily();

/// See also [storyActivity].
class StoryActivityFamily extends Family<AsyncValue<ActivityModel?>> {
  /// See also [storyActivity].
  const StoryActivityFamily();

  /// See also [storyActivity].
  StoryActivityProvider call(String storyId) {
    return StoryActivityProvider(storyId);
  }

  @override
  StoryActivityProvider getProviderOverride(
    covariant StoryActivityProvider provider,
  ) {
    return call(provider.storyId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'storyActivityProvider';
}

/// See also [storyActivity].
class StoryActivityProvider extends AutoDisposeFutureProvider<ActivityModel?> {
  /// See also [storyActivity].
  StoryActivityProvider(String storyId)
    : this._internal(
        (ref) => storyActivity(ref as StoryActivityRef, storyId),
        from: storyActivityProvider,
        name: r'storyActivityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$storyActivityHash,
        dependencies: StoryActivityFamily._dependencies,
        allTransitiveDependencies:
            StoryActivityFamily._allTransitiveDependencies,
        storyId: storyId,
      );

  StoryActivityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storyId,
  }) : super.internal();

  final String storyId;

  @override
  Override overrideWith(
    FutureOr<ActivityModel?> Function(StoryActivityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoryActivityProvider._internal(
        (ref) => create(ref as StoryActivityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storyId: storyId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ActivityModel?> createElement() {
    return _StoryActivityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoryActivityProvider && other.storyId == storyId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storyId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StoryActivityRef on AutoDisposeFutureProviderRef<ActivityModel?> {
  /// The parameter `storyId` of this provider.
  String get storyId;
}

class _StoryActivityProviderElement
    extends AutoDisposeFutureProviderElement<ActivityModel?>
    with StoryActivityRef {
  _StoryActivityProviderElement(super.provider);

  @override
  String get storyId => (origin as StoryActivityProvider).storyId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
