import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/profile_provider.dart';
import 'device_identity_service.dart';

part 'unlock_service.g.dart';

// Product ID must match what you register in App Store Connect and Google Play Console.
const kUnlockProductId = 'com.littlebible.unlock';

// Device-level flag persisted in the keychain / EncryptedSharedPreferences.
// Set once on purchase; read on every launch so profiles added later auto-unlock.
const _kDeviceUnlockKey = 'com.littlebible.device_unlock';

enum UnlockStatus { idle, loading, purchased, unavailable, error }

class UnlockState {
  const UnlockState({
    this.status = UnlockStatus.idle,
    this.localPrice,
    this.errorMessage,
  });

  final UnlockStatus status;
  final String? localPrice;
  final String? errorMessage;

  UnlockState copyWith({
    UnlockStatus? status,
    String? localPrice,
    String? errorMessage,
  }) =>
      UnlockState(
        status: status ?? this.status,
        localPrice: localPrice ?? this.localPrice,
        errorMessage: errorMessage,
      );
}

@riverpod
UnlockService unlockService(Ref ref) {
  final db = ref.watch(databaseProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final deviceIdentity = ref.watch(deviceIdentityServiceProvider);
  final service = UnlockService(db, profileRepo, deviceIdentity);
  ref.onDispose(service.dispose);
  return service;
}

class UnlockService extends ChangeNotifier {
  UnlockService(this._db, this._profileRepo, this._deviceIdentity) {
    _init();
  }

  final AppDatabase _db;
  final ProfileRepository _profileRepo;

  /// Shared with SyncService, so an entitlement and a progress row are attributed
  /// to the SAME device. Minting a second identifier here would have split one
  /// install across two device ids on the server.
  final DeviceIdentityService _deviceIdentity;
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  UnlockState _state = const UnlockState();
  UnlockState get state => _state;

  bool _deviceUnlocked = false;
  /// True when the non-consumable purchase has been made on this store account.
  bool get isDeviceUnlocked => _deviceUnlocked;

  Future<void> _init() async {
    // Re-apply the device-level unlock to any profiles created after the
    // original purchase (covers reinstalls and multi-profile households).
    final flag = await _storage.read(key: _kDeviceUnlockKey);
    if (flag == '1') {
      _deviceUnlocked = true;
      await _profileRepo.setAllUnlocked();
    }

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      _state = _state.copyWith(status: UnlockStatus.unavailable);
      notifyListeners();
      return;
    }

    // Listen to purchase updates for the lifetime of the service.
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) {
        _state = _state.copyWith(
          status: UnlockStatus.error,
          errorMessage: 'Purchase stream error',
        );
        notifyListeners();
      },
    );

    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    final response = await InAppPurchase.instance
        .queryProductDetails({kUnlockProductId});
    if (response.productDetails.isNotEmpty) {
      _state = _state.copyWith(localPrice: response.productDetails.first.price);
    } else if (response.error != null) {
      _state = _state.copyWith(
        errorMessage: 'Could not load product: ${response.error!.message}',
      );
    }
    // notFoundIDs being non-empty with no error means the product ID isn't
    // registered in the store yet — price stays null and the CTA still works
    // (purchase() re-queries and returns a clear error message).
    notifyListeners();
  }

  Future<void> purchase() async {
    if (_state.status == UnlockStatus.loading) return;

    final response = await InAppPurchase.instance
        .queryProductDetails({kUnlockProductId});

    if (response.productDetails.isEmpty) {
      _state = _state.copyWith(
        status: UnlockStatus.error,
        errorMessage: 'Product not found. Check your internet connection.',
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(status: UnlockStatus.loading);
    notifyListeners();

    final param = PurchaseParam(productDetails: response.productDetails.first);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  /// Re-applies a previous purchase made on this store account.
  ///
  /// `restorePurchases()` emits nothing at all when there is no purchase to
  /// restore, so waiting on the purchase stream alone left the button spinning
  /// forever. If nothing has arrived shortly after the call returns, drop back
  /// to idle and say so.
  Future<void> restore() async {
    if (_state.status == UnlockStatus.loading) return;
    _state = _state.copyWith(status: UnlockStatus.loading);
    notifyListeners();

    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _state = _state.copyWith(
        status: UnlockStatus.error,
        errorMessage: 'Could not reach the store. Please try again.',
      );
      notifyListeners();
      return;
    }

    // Give the purchase stream a moment to deliver any restored purchase.
    await Future.delayed(const Duration(seconds: 3));
    if (_state.status == UnlockStatus.loading) {
      _state = _state.copyWith(
        status: UnlockStatus.error,
        errorMessage: 'No previous purchase found on this store account.',
      );
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != kUnlockProductId) continue;

      if (purchase.status == PurchaseStatus.pending) {
        _state = _state.copyWith(status: UnlockStatus.loading);
        notifyListeners();
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _applyUnlock(purchase);
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        _state = _state.copyWith(
          status: UnlockStatus.error,
          errorMessage: purchase.error?.message ?? 'Purchase failed.',
        );
        notifyListeners();
        // Still complete the purchase so the OS doesn't retry indefinitely.
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        _state = _state.copyWith(status: UnlockStatus.idle);
        notifyListeners();
      }
    }
  }

  Future<void> _applyUnlock(PurchaseDetails purchase) async {
    // Write the device-level flag first — persists across profile additions.
    await _storage.write(key: _kDeviceUnlockKey, value: '1');
    _deviceUnlocked = true;

    // Unlock every profile on the device (non-consumable = whole family).
    await _profileRepo.setAllUnlocked();

    // Queue the store-signed verification data against the active profile for
    // server-side receipt validation.
    final deviceId = await _deviceIdentity.getOrCreate();
    final profiles = await _db.select(_db.childProfiles).get();
    final active = profiles.where((p) => p.isActive).firstOrNull;
    if (active != null) {
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          profileId: active.id,
          operation: 'unlock',
          payload: _unlockPayload(purchase, deviceId),
        ),
      );
    }

    _state = _state.copyWith(status: UnlockStatus.purchased);
    notifyListeners();

    if (purchase.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }

  /// Builds the unlock payload with [jsonEncode].
  ///
  /// This used to hand-roll the JSON, escaping only backslashes and quotes. Any
  /// newline or control character in a store receipt would have produced invalid
  /// JSON and a silent 400 from the server.
  String _unlockPayload(PurchaseDetails purchase, String deviceId) {
    return jsonEncode({
      'productId': kUnlockProductId,
      'transactionId': purchase.purchaseID ?? '',
      'source': purchase.verificationData.source,
      'verificationData': purchase.verificationData.serverVerificationData,
      'deviceId': deviceId,
    });
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
