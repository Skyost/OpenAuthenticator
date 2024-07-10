import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  Future<Result<Map<PackageType, String>>> getPrices() async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      if (revenueCatClient == null) {
        throw _NoRevenueCatClientException();
      }
      return ResultSuccess(value: await revenueCatClient.getPrices(Purchasable.contributorPlan));
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
  _InvalidPaywallResult({
    required this.result,
  });

  @override
  String toString() => 'Invalid paywall result : $result';
}
