// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_progress_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storyProgressRepositoryHash() =>
    r'4ffd15650219e6fe30d2dbe69228c1dd91c798d2';

/// See also [storyProgressRepository].
@ProviderFor(storyProgressRepository)
final storyProgressRepositoryProvider =
    AutoDisposeProvider<StoryProgressRepository>.internal(
      storyProgressRepository,
      name: r'storyProgressRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storyProgressRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StoryProgressRepositoryRef =
    AutoDisposeProviderRef<StoryProgressRepository>;
String _$completedStoryIdsHash() => r'0669fe6db6e30c5809e68165852902ec1779b494';

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

/// Live set of completed story IDs for a given profile.
///
/// Copied from [completedStoryIds].
@ProviderFor(completedStoryIds)
const completedStoryIdsProvider = CompletedStoryIdsFamily();

/// Live set of completed story IDs for a given profile.
///
/// Copied from [completedStoryIds].
class CompletedStoryIdsFamily extends Family<AsyncValue<Set<String>>> {
  /// Live set of completed story IDs for a given profile.
  ///
  /// Copied from [completedStoryIds].
  const CompletedStoryIdsFamily();

  /// Live set of completed story IDs for a given profile.
  ///
  /// Copied from [completedStoryIds].
  CompletedStoryIdsProvider call(String profileId) {
    return CompletedStoryIdsProvider(profileId);
  }

  @override
  CompletedStoryIdsProvider getProviderOverride(
    covariant CompletedStoryIdsProvider provider,
  ) {
    return call(provider.profileId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'completedStoryIdsProvider';
}

/// Live set of completed story IDs for a given profile.
///
/// Copied from [completedStoryIds].
class CompletedStoryIdsProvider extends AutoDisposeStreamProvider<Set<String>> {
  /// Live set of completed story IDs for a given profile.
  ///
  /// Copied from [completedStoryIds].
  CompletedStoryIdsProvider(String profileId)
    : this._internal(
        (ref) => completedStoryIds(ref as CompletedStoryIdsRef, profileId),
        from: completedStoryIdsProvider,
        name: r'completedStoryIdsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$completedStoryIdsHash,
        dependencies: CompletedStoryIdsFamily._dependencies,
        allTransitiveDependencies:
            CompletedStoryIdsFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  CompletedStoryIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileId,
  }) : super.internal();

  final String profileId;

  @override
  Override overrideWith(
    Stream<Set<String>> Function(CompletedStoryIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CompletedStoryIdsProvider._internal(
        (ref) => create(ref as CompletedStoryIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileId: profileId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Set<String>> createElement() {
    return _CompletedStoryIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedStoryIdsProvider && other.profileId == profileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CompletedStoryIdsRef on AutoDisposeStreamProviderRef<Set<String>> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _CompletedStoryIdsProviderElement
    extends AutoDisposeStreamProviderElement<Set<String>>
    with CompletedStoryIdsRef {
  _CompletedStoryIdsProviderElement(super.provider);

  @override
  String get profileId => (origin as CompletedStoryIdsProvider).profileId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
