import 'package:flutter/foundation.dart';
import 'package:open_authenticator/model/purchases/clients/method_channel.dart';
import 'package:open_authenticator/model/purchases/clients/rest.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';

/// A RevenueCat client.
abstract class RevenueCatClient {
  /// The RevenueCat's purchases configuration.
  final PurchasesConfiguration purchasesConfiguration;

  /// Creates a new RevenueCat client instance.
  RevenueCatClient({
    required this.purchasesConfiguration,
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

  /// Purchases the given item.
  Future<List<String>> purchase(Purchasable purchasable, PackageTypeAsker askPackageType);

  /// Returns the prices of the [purchasable].
  Future<Map<PackageType, String>> getPrices(Purchasable purchasable);

  /// Restores the user purchases, if possible.
  Future<bool> restorePurchases();
}

/// Represents a purchasable item.
enum Purchasable {
  /// Allows to subscribe to the Contributor Plan.
  contributorPlan(
    offeringId: kDebugMode ? 'contributor_plan_test' : 'contributor_plan',
    stripeBuyUrls: {
      PackageType.annual: kDebugMode ? 'test_14kbLD3PN2gFgQE001' : 'cN2eWD4Khfkxh2MdQT',
      PackageType.monthly: kDebugMode ? 'test_28og1T8639J7cAoeUU' : 'aEU8yfekR6O1dQA8wy',
    },
    stripePrices: {
      PackageType.annual: kDebugMode ? 'price_1OxUmHA6p1nUn9O0Jxqpx3xN' : 'price_1P2UzNA6p1nUn9O0Cnm3FUpe',
      PackageType.monthly: kDebugMode ? 'price_1OxH1yA6p1nUn9O04XyDgF76' : 'price_1P2V0EA6p1nUn9O0DgwzkTfj',
    },
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
