// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentChildHash() => r'56f802820be451221f7299b05505ff1f3d25cbd1';

/// See also [CurrentChild].
@ProviderFor(CurrentChild)
final currentChildProvider =
    AutoDisposeNotifierProvider<CurrentChild, ChildProfile?>.internal(
  CurrentChild.new,
  name: r'currentChildProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentChildHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentChild = AutoDisposeNotifier<ChildProfile?>;
String _$childrenListHash() => r'71e4b5497b8cbc729d3bb294d99af29e3f81f10e';

/// See also [ChildrenList].
@ProviderFor(ChildrenList)
final childrenListProvider =
    AutoDisposeAsyncNotifierProvider<ChildrenList, List<ChildProfile>>.internal(
  ChildrenList.new,
  name: r'childrenListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$childrenListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChildrenList = AutoDisposeAsyncNotifier<List<ChildProfile>>;
String _$selectedChildIdHash() => r'1052eca7da7886dd951d68c1d08b7d651607947e';

/// See also [SelectedChildId].
@ProviderFor(SelectedChildId)
final selectedChildIdProvider =
    AutoDisposeNotifierProvider<SelectedChildId, String?>.internal(
  SelectedChildId.new,
  name: r'selectedChildIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedChildIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedChildId = AutoDisposeNotifier<String?>;
String _$childProgressHash() => r'cb6fdfd0297a578e45c856f2d03b5454be335d86';

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

abstract class _$ChildProgress
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final String childId;

  FutureOr<Map<String, dynamic>> build(
    String childId,
  );
}

/// See also [ChildProgress].
@ProviderFor(ChildProgress)
const childProgressProvider = ChildProgressFamily();

/// See also [ChildProgress].
class ChildProgressFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [ChildProgress].
  const ChildProgressFamily();

  /// See also [ChildProgress].
  ChildProgressProvider call(
    String childId,
  ) {
    return ChildProgressProvider(
      childId,
    );
  }

  @override
  ChildProgressProvider getProviderOverride(
    covariant ChildProgressProvider provider,
  ) {
    return call(
      provider.childId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'childProgressProvider';
}

/// See also [ChildProgress].
class ChildProgressProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ChildProgress, Map<String, dynamic>> {
  /// See also [ChildProgress].
  ChildProgressProvider(
    String childId,
  ) : this._internal(
          () => ChildProgress()..childId = childId,
          from: childProgressProvider,
          name: r'childProgressProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$childProgressHash,
          dependencies: ChildProgressFamily._dependencies,
          allTransitiveDependencies:
              ChildProgressFamily._allTransitiveDependencies,
          childId: childId,
        );

  ChildProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.childId,
  }) : super.internal();

  final String childId;

  @override
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant ChildProgress notifier,
  ) {
    return notifier.build(
      childId,
    );
  }

  @override
  Override overrideWith(ChildProgress Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChildProgressProvider._internal(
        () => create()..childId = childId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        childId: childId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChildProgress, Map<String, dynamic>>
      createElement() {
    return _ChildProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildProgressProvider && other.childId == childId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, childId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChildProgressRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `childId` of this provider.
  String get childId;
}

class _ChildProgressProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChildProgress,
        Map<String, dynamic>> with ChildProgressRef {
  _ChildProgressProviderElement(super.provider);

  @override
  String get childId => (origin as ChildProgressProvider).childId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
