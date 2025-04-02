import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Price;

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
  Future<List<String>> purchaseManually(Purchasable purchasable, PackageType packageType) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(purchasable.offeringId);
    if (offering == null) {
      return [];
    }

    Package? package = offering.availablePackages.firstWhereOrNull((package) => package.packageType == packageType);
    if (package != null) {
      await Purchases.setEmail(purchasesConfiguration.email!);
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return List.of(customerInfo.entitlements.active.keys).cast<String>();
    }
    return [];
  }

  @override
  Future<Map<String, Offering>> getOfferings() async => (await Purchases.getOfferings()).all;

  @override
  Future<Map<PackageType, Price>> getPrices(Purchasable purchasable) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(purchasable.offeringId);
    if (offering == null) {
      return {};
    }
    Map<PackageType, Price> result = {};
    for (Package package in offering.availablePackages) {
      result[package.packageType] = Price(
        amount: package.storeProduct.price,
        formattedAmount: package.storeProduct.priceString,
      );
    }
    return result;
  }

  @override
  Future<Result> restorePurchases() async {
    await Purchases.restorePurchases();
    return const ResultSuccess();
  }

  @override
  Future<String?> getManagementUrl(String entitlementId) async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    EntitlementInfo? entitlement = customerInfo.entitlements.active[entitlementId];
    switch (entitlement?.store) {
      case Store.stripe:
        return AppContributorPlan.stripeCustomerPortalLink;
      default:
        return customerInfo.managementURL;
    }
  }

  @override
  Future<void> invalidateUserInfo() => Purchases.invalidateCustomerInfoCache();
}
