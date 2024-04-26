import 'package:flutter/foundation.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Allows to communicate with RevenueCat using its SDK.
class RevenueCatMethodChannelClient extends RevenueCatClient {
  /// Creates a new RevenueCat method channel client instance.
  RevenueCatMethodChannelClient({
    required super.purchasesConfiguration,
  });

  @override
  Future<void> initialize() => Purchases.configure(purchasesConfiguration);

  @override
  Future<bool> hasEntitlement(String entitlementId) async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active[entitlementId]?.isActive ?? false;
  }

  @override
  Future<List<PackageType>> getAvailablePackageTypes(String offeringId) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(offeringId);
    return offering?.availablePackages.map((package) => package.packageType).toList() ?? [];
  }

  @override
  Future<PaywallResult> presentPaywall(Purchasable purchasable) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(purchasable.offeringId);
    if (offering == null) {
      return PaywallResult.error;
    }

    try {
      return await RevenueCatUI.presentPaywall(offering: offering);
    } catch (ex, stacktrace) {
      if (kDebugMode) {
        print(ex);
        print(stacktrace);
      }
    }
    return PaywallResult.error;
  }

  @override
  Future<List<String>> purchaseManually(Purchasable purchasable, PackageType packageType) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(purchasable.offeringId);
    if (offering == null) {
      return [];
    }

    Package? package = offering.availablePackages.firstWhereOrNull((package) => package.packageType == packageType);
    if (package != null) {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return List.of(customerInfo.entitlements.active.keys).cast<String>();
    }
    return [];
  }

  @override
  Future<Map<PackageType, String>> getPrices(Purchasable purchasable) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(purchasable.offeringId);
    if (offering == null) {
      return {};
    }
    Map<PackageType, String> result = {};
    for (Package package in offering.availablePackages) {
      result[package.packageType] = package.storeProduct.priceString;
    }
    return result;
  }

  @override
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  @override
  Future<String?> getManagementUrl() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.managementURL;
  }
}
