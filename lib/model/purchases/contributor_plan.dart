import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Price;
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// The Contributor Plan provider.
final contributorPlanStateProvider = AsyncNotifierProvider<ContributorPlan, ContributorPlanState>(ContributorPlan.new);

/// Allows to read and change the Contributor Plan state.
class ContributorPlan extends AsyncNotifier<ContributorPlanState> {
  @override
  FutureOr<ContributorPlanState> build() async {
    RevenueCatClient? client = await ref.watch(revenueCatClientProvider);
    if (client == null) {
      return ContributorPlanState.impossible;
    }
    await client.initialize();
    return await client.hasEntitlement(AppContributorPlan.entitlementId) ? ContributorPlanState.active : ContributorPlanState.inactive;
  }

  /// Changes the state to [newState].
  void debugChangeState(ContributorPlanState newState) {
    if (kDebugMode) {
      state = AsyncData(newState);
    }
  }

  /// Returns the purchase timeout.
  Duration? getPurchaseTimeout() => ref.read(revenueCatClientProvider)?.purchaseTimeout;

  /// Returns the prices of the contributor plan.
  Future<Result<Prices>> getPrices() async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      if (revenueCatClient == null) {
        throw _NoRevenueCatClientException();
      }
      Map<PackageType, Price> packagesPrice = await revenueCatClient.getPrices(Purchasable.contributorPlan);
      List<PackageType> packages = List.of(packagesPrice.keys);
      packages.sort((a, b) => b.index.compareTo(a.index));
      PackageType? reference = packages.firstOrNull;
      Map<PackageType, int> promotions = {};
      if (reference != null && reference.inAYear != null) {
        double referencePricePerYear = packagesPrice[reference]!.amount * reference.inAYear!;
        for (MapEntry<PackageType, Price> entry in packagesPrice.entries) {
          if (entry.key.inAYear == null) {
            continue;
          }
          double pricePerYear = entry.value.amount * entry.key.inAYear!;
          if (pricePerYear < referencePricePerYear) {
            promotions[entry.key] = (((pricePerYear / referencePricePerYear) - 1) * 100).round();
          }
        }
      }
      return ResultSuccess(
        value: Prices._(
          packagesPrice: packagesPrice,
          promotions: promotions,
        ),
      );
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Tries to restore the subscription state.
  Future<Result> restoreState() async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      if (revenueCatClient == null) {
        throw _NoRevenueCatClientException();
      }
      Result result = await revenueCatClient.restorePurchases();
      if (result is! ResultSuccess) {
        return result;
      }
      state = AsyncData(await revenueCatClient.hasEntitlement(AppContributorPlan.entitlementId) ? ContributorPlanState.active : ContributorPlanState.inactive);
      return const ResultSuccess();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Presents the paywall.
  Future<Result<PaywallResult>> presentPaywall() async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      PaywallResult paywallResult = await revenueCatClient!.presentPaywall(Purchasable.contributorPlan);
      switch (paywallResult) {
        case PaywallResult.error:
          throw _InvalidPaywallResult(result: paywallResult);
        case PaywallResult.notPresented:
        case PaywallResult.cancelled:
          return const ResultCancelled();
        case PaywallResult.purchased:
        case PaywallResult.restored:
          await revenueCatClient.invalidateUserInfo();
          if (await revenueCatClient.hasEntitlement(AppContributorPlan.entitlementId)) {
            state = const AsyncData(ContributorPlanState.active);
          }
          return ResultSuccess(value: paywallResult);
      }
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }

  /// Purchases the given item.
  Future<Result> purchaseManually(PackageType packageType) async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      List<String>? entitlements = await revenueCatClient?.purchaseManually(Purchasable.contributorPlan, packageType);
      if (entitlements != null && entitlements.contains(AppContributorPlan.entitlementId)) {
        state = const AsyncData(ContributorPlanState.active);
        return const ResultSuccess();
      }
      return const ResultCancelled();
    } catch (ex, stacktrace) {
      return ResultError(
        exception: ex,
        stacktrace: stacktrace,
      );
    }
  }
}

/// Allows to get the duration of a given package type.
extension PackageTypeDuration on PackageType {
  /// Returns the duration of the package.
  int? get inAYear => switch (this) {
        PackageType.weekly => 52,
        PackageType.monthly => 12,
        PackageType.twoMonth => 6,
        PackageType.threeMonth => 4,
        PackageType.sixMonth => 2,
        PackageType.annual => 1,
        _ => null,
      };
}

/// The Contributor Plan prices.
class Prices {
  /// The price map.
  final Map<PackageType, Price> packagesPrice;

  /// The promotions map.
  final Map<PackageType, int> promotions;

  /// Creates a new prices instance.
  const Prices._({
    this.packagesPrice = const {},
    this.promotions = const {},
  });
}

/// The Contributor Plan state.
enum ContributorPlanState {
  /// Whether there is no Contributor Plan available.
  impossible,

  /// Whether the user has not subscribed to the Contributor Plan yet.
  inactive,

  /// Whether the user has subscribed to the Contributor Plan.
  active;
}

/// Thrown when no RevenueCat client is available.
class _NoRevenueCatClientException implements Exception {
  @override
  String toString() => 'No RevenueCat client available';
}

/// Thrown when an invalid paywall result has been returned.
class _InvalidPaywallResult implements Exception {
  /// The result.
  final PaywallResult result;

  /// Creates a new invalid paywall result instance.
  const _InvalidPaywallResult({
    required this.result,
  });

  @override
  String toString() => 'Invalid paywall result : $result';
}
