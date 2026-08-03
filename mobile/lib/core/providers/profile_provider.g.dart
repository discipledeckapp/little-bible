// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeProfileHash() => r'e10c087f8b1b4d75759a3b22a3ba722f66202e2e';

/// See also [activeProfile].
@ProviderFor(activeProfile)
final activeProfileProvider = AutoDisposeStreamProvider<ChildProfile?>.internal(
  activeProfile,
  name: r'activeProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveProfileRef = AutoDisposeStreamProviderRef<ChildProfile?>;
String _$hasActiveProfileHash() => r'5c89ff521e318ae820dc87b8729a7aa8527761dd';

/// See also [hasActiveProfile].
@ProviderFor(hasActiveProfile)
final hasActiveProfileProvider = AutoDisposeProvider<bool>.internal(
  hasActiveProfile,
  name: r'hasActiveProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasActiveProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasActiveProfileRef = AutoDisposeProviderRef<bool>;
String _$allProfilesHash() => r'1accf379e2d257d50f29b3f3e4f4d5f8cefc2f62';

/// See also [allProfiles].
@ProviderFor(allProfiles)
final allProfilesProvider =
    AutoDisposeStreamProvider<List<ChildProfile>>.internal(
      allProfiles,
      name: r'allProfilesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allProfilesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllProfilesRef = AutoDisposeStreamProviderRef<List<ChildProfile>>;
String _$profileRepositoryHash() => r'f5b7ac46f741708073081a4c5a5fb46c9f4b1d49';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
