import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/purchases/clients/method_channel.dart';
import 'package:open_authenticator/model/purchases/clients/rest.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// A RevenueCat client.
abstract class RevenueCatClient {
  /// The RevenueCat's purchases configuration.
  final PurchasesConfiguration purchasesConfiguration;

  /// The purchase timeout.
  final Duration? purchaseTimeout;

  /// Creates a new RevenueCat client instance.
  RevenueCatClient({
    required this.purchasesConfiguration,
    this.purchaseTimeout = Duration.zero,
  }) : assert(purchasesConfiguration.appUserID != null);

  /// Creates a new RevenueCat client instance that corresponds to the given [platform].
  factory RevenueCatClient.fromPlatform({
    required PurchasesConfiguration purchasesConfiguration,
    Platform? platform,
  }) {
    platform ??= currentPlatform;
    switch (platform) {
      case Platform.android:
      case Platform.iOS:
      case Platform.macOS:
        return RevenueCatMethodChannelClient(purchasesConfiguration: purchasesConfiguration);
      default:
        return RevenueCatRestClient(purchasesConfiguration: purchasesConfiguration);
    }
  }

  /// Initializes this client instance.
  Future<void> initialize() async {}

  /// Returns the available package types.
  /// Note that only RevenueCat default identifiers are supported.
  Future<List<PackageType>> getAvailablePackageTypes(String offeringId);

  /// Returns whether the user has the given [entitlementId].
  Future<bool> hasEntitlement(String entitlementId);

  /// Presents the paywall corresponding to the [purchasable].
  Future<PaywallResult> presentPaywall(Purchasable purchasable);

  /// Purchases the given item.
  Future<List<String>> purchaseManually(Purchasable purchasable, PackageType packageType);

  /// Returns the prices of the [purchasable].
  Future<Map<PackageType, String>> getPrices(Purchasable purchasable);

  /// Restores the user purchases, if possible.
  Future<bool> restorePurchases();
}

/// Represents a purchasable item.
enum Purchasable {
  /// Allows to subscribe to the Contributor Plan.
  contributorPlan(
    offeringId: AppContributorPlan.offeringId,
    stripeBuyUrls: AppContributorPlan.stripeBuyUrls,
    stripePrices: AppContributorPlan.stripePrices,
  );

  /// The offering ID.
  final String offeringId;

  /// The Stripe "buy" URLs.
  final Map<PackageType, String> stripeBuyUrls;

  /// The Stripe prices ids.
  final Map<PackageType, String> stripePrices;

  /// Creates a new purchasable instance.
  const Purchasable({
    required this.offeringId,
    required this.stripeBuyUrls,
    required this.stripePrices,
  });

  /// Returns the Stripe "buy" URL corresponding to the [packageType].
  Uri? getStripeBuyUrl(PackageType packageType) => stripeBuyUrls.containsKey(packageType) ? Uri.https('buy.stripe.com', stripeBuyUrls[packageType]!) : null;
}
