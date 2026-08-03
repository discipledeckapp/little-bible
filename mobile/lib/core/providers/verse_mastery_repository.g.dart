// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_mastery_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$verseMasteryRepositoryHash() =>
    r'271109495bb5d00f86c8c9d5dd8d464656501115';

/// See also [verseMasteryRepository].
@ProviderFor(verseMasteryRepository)
final verseMasteryRepositoryProvider =
    AutoDisposeProvider<VerseMasteryRepository>.internal(
      verseMasteryRepository,
      name: r'verseMasteryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$verseMasteryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VerseMasteryRepositoryRef =
    AutoDisposeProviderRef<VerseMasteryRepository>;
String _$allVersesForProfileHash() =>
    r'3c6ca46b4bce068f65d79cc6102a76ec0a979b84';

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

/// All tracked verses for a profile — used by Parent Hub and Bible Nav.
///
/// Copied from [allVersesForProfile].
@ProviderFor(allVersesForProfile)
const allVersesForProfileProvider = AllVersesForProfileFamily();

/// All tracked verses for a profile — used by Parent Hub and Bible Nav.
///
/// Copied from [allVersesForProfile].
class AllVersesForProfileFamily
    extends Family<AsyncValue<List<VerseMasteryData>>> {
  /// All tracked verses for a profile — used by Parent Hub and Bible Nav.
  ///
  /// Copied from [allVersesForProfile].
  const AllVersesForProfileFamily();

  /// All tracked verses for a profile — used by Parent Hub and Bible Nav.
  ///
  /// Copied from [allVersesForProfile].
  AllVersesForProfileProvider call(String profileId) {
    return AllVersesForProfileProvider(profileId);
  }

  @override
  AllVersesForProfileProvider getProviderOverride(
    covariant AllVersesForProfileProvider provider,
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
  String? get name => r'allVersesForProfileProvider';
}

/// All tracked verses for a profile — used by Parent Hub and Bible Nav.
///
/// Copied from [allVersesForProfile].
class AllVersesForProfileProvider
    extends AutoDisposeStreamProvider<List<VerseMasteryData>> {
  /// All tracked verses for a profile — used by Parent Hub and Bible Nav.
  ///
  /// Copied from [allVersesForProfile].
  AllVersesForProfileProvider(String profileId)
    : this._internal(
        (ref) => allVersesForProfile(ref as AllVersesForProfileRef, profileId),
        from: allVersesForProfileProvider,
        name: r'allVersesForProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$allVersesForProfileHash,
        dependencies: AllVersesForProfileFamily._dependencies,
        allTransitiveDependencies:
            AllVersesForProfileFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  AllVersesForProfileProvider._internal(
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
    Stream<List<VerseMasteryData>> Function(AllVersesForProfileRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllVersesForProfileProvider._internal(
        (ref) => create(ref as AllVersesForProfileRef),
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
  AutoDisposeStreamProviderElement<List<VerseMasteryData>> createElement() {
    return _AllVersesForProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllVersesForProfileProvider && other.profileId == profileId;
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
mixin AllVersesForProfileRef
    on AutoDisposeStreamProviderRef<List<VerseMasteryData>> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _AllVersesForProfileProviderElement
    extends AutoDisposeStreamProviderElement<List<VerseMasteryData>>
    with AllVersesForProfileRef {
  _AllVersesForProfileProviderElement(super.provider);

  @override
  String get profileId => (origin as AllVersesForProfileProvider).profileId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
