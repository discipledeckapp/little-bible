import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import '../providers/profile_provider.dart';

part 'unlock_service.g.dart';

// Product ID must match what you register in App Store Connect and Google Play Console.
const kUnlockProductId = 'com.littlebible.unlock';

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
  final service = UnlockService(db, profileRepo);
  ref.onDispose(service.dispose);
  return service;
}

class UnlockService extends ChangeNotifier {
  UnlockService(this._db, this._profileRepo) {
    _init();
  }

  final AppDatabase _db;
  final ProfileRepository _profileRepo;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  UnlockState _state = const UnlockState();
  UnlockState get state => _state;

  Future<void> _init() async {
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
      final product = response.productDetails.first;
      _state = _state.copyWith(localPrice: product.price);
      notifyListeners();
    }
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

  Future<void> restore() async {
    _state = _state.copyWith(status: UnlockStatus.loading);
    notifyListeners();
    await InAppPurchase.instance.restorePurchases();
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
    // Find the active profile and mark it unlocked.
    final profiles = await _db.select(_db.childProfiles).get();
    final active = profiles.where((p) => p.isActive).firstOrNull;
    if (active != null) {
      await _profileRepo.setUnlocked(active.id);

      // Queue the store-signed verification data for fail-closed server validation.
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          profileId: active.id,
          operation: 'unlock',
          payload: _unlockPayload(purchase),
        ),
      );
    }

    _state = _state.copyWith(status: UnlockStatus.purchased);
    notifyListeners();

    if (purchase.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }

  String _unlockPayload(PurchaseDetails purchase) {
    final escapedReceipt = purchase.verificationData.serverVerificationData
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');
    final escapedSource = purchase.verificationData.source
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');
    final escapedId = (purchase.purchaseID ?? '')
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"');
    return '{"productId":"$kUnlockProductId","transactionId":"$escapedId",'
        '"source":"$escapedSource","verificationData":"$escapedReceipt"}';
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
