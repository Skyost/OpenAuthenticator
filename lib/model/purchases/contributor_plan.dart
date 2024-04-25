import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// The RevenueCat client provider.
final revenueCatClientProvider = Provider((ref) {
  FirebaseAuthenticationState authenticationState = ref.watch(firebaseAuthenticationProvider);
  if (authenticationState is! FirebaseAuthenticationStateLoggedIn) {
    return null;
  }
  PurchasesConfiguration? configuration = switch (currentPlatform) {
    Platform.android => PurchasesConfiguration(AppCredentials.revenueCatPublicKeyAndroid),
    Platform.iOS || Platform.macOS => PurchasesConfiguration(AppCredentials.revenueCatPublicKeyDarwin),
    Platform.windows => PurchasesConfiguration(AppCredentials.revenueCatPublicKeyWindows),
    Platform.linux => PurchasesConfiguration(AppCredentials.revenueCatPublicKeyLinux),
    _ => null,
  };
  if (configuration == null) {
    return null;
  }
  configuration = configuration..appUserID = authenticationState.user.uid;
  return RevenueCatClient.fromPlatform(purchasesConfiguration: configuration);
});

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

  /// Returns the purchase timeout.
  Duration? getPurchaseTimeout() => ref.read(revenueCatClientProvider)?.purchaseTimeout;

  /// Returns the prices of the contributor plan.
  Future<Map<PackageType, String>> getPrices() async {
    RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
    if (revenueCatClient == null) {
      return {};
    }
    return revenueCatClient.getPrices(Purchasable.contributorPlan);
  }

  /// Tries to restore the subscription state.
  Future<bool> restoreState() async {
    RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
    if (revenueCatClient == null || !(await revenueCatClient.restorePurchases())) {
      return false;
    }
    state = AsyncData(await revenueCatClient.hasEntitlement(AppContributorPlan.entitlementId) ? ContributorPlanState.active : ContributorPlanState.inactive);
    return true;
  }

  /// Presents the paywall.
  Future<PaywallResult> presentPaywall() async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      PaywallResult paywallResult = await revenueCatClient!.presentPaywall(Purchasable.contributorPlan);
      if ((paywallResult == PaywallResult.purchased || paywallResult == PaywallResult.restored) && await revenueCatClient.hasEntitlement(AppContributorPlan.entitlementId)) {
        state = const AsyncData(ContributorPlanState.active);
        return paywallResult;
      }
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return PaywallResult.error;
  }

  /// Purchases the given item.
  Future<bool> purchaseManually(PackageType packageType) async {
    try {
      RevenueCatClient? revenueCatClient = ref.read(revenueCatClientProvider);
      List<String>? entitlements = await revenueCatClient?.purchaseManually(Purchasable.contributorPlan, packageType);
      if (entitlements != null && entitlements.contains(AppContributorPlan.entitlementId)) {
        state = const AsyncData(ContributorPlanState.active);
        return true;
      }
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return false;
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
