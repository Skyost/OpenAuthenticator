import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/utils/validation/server.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Allows to communicate with RevenueCat thanks to its REST api.
class RevenueCatRestClient extends RevenueCatClient {
  /// The HTTP client.
  final http.Client _client;

  /// The validation server instance.
  ValidationServer<String>? _validationServer;

  /// Creates a new RevenueCat REST client instance.
  RevenueCatRestClient({
    required super.purchasesConfiguration,
  }) : _client = http.Client();

  /// The validation timeout.
  Duration get timeout => const Duration(minutes: 10);

  @override
  Future<bool> hasEntitlement(String entitlementId) async {
    http.Response response = await _client.get(
      Uri.https(
        'api.revenuecat.com',
        '/v1/subscribers/${purchasesConfiguration.appUserID}',
      ),
      headers: {
        'X-Is-Sandbox': kDebugMode.toString(),
        ..._revenueCatHeaders,
      },
    );
    if (response.statusCode != 200) {
      return false;
    }
    Map<String, dynamic> json = jsonDecode(response.body);
    return _getEntitlementsFromJson(json).contains(entitlementId);
  }

  @override
  Future<List<PackageType>> getAvailablePackageTypes(String offeringId) async {
    http.Response response = await _client.get(
      Uri.https(
        'api.revenuecat.com',
        '/v1/subscribers/${purchasesConfiguration.appUserID}/offerings',
      ),
      headers: _revenueCatHeaders,
    );

    if (response.statusCode != 200) {
      return [];
    }

    List jsonOfferings = jsonDecode(response.body)['value']['offerings'];
    Map<String, dynamic>? jsonOffering = jsonOfferings.firstWhereOrNull((jsonOffering) => jsonOffering[offeringId]);
    if (jsonOffering == null) {
      return [];
    }

    List jsonPackages = jsonOffering['packages'];
    List<PackageType> result = [];
    for (Map<String, dynamic> jsonPackage in jsonPackages) {
      for (PackageType packageType in PackageType.values) {
        if (jsonPackage['identifier'] == packageType.defaultIdentifier) {
          result.add(packageType);
          break;
        }
      }
    }
    return result;
  }

  @override
  Future<List<String>> purchase(Purchasable purchasable, PackageTypeAsker askPackageType) async {
    PackageType? packageType = await askPackageType();
    if (packageType == null) {
      return [];
    }
    Uri? stripeBuyUrl = purchasable.getStripeBuyUrl(packageType);
    if (stripeBuyUrl == null || !(await canLaunchUrl(stripeBuyUrl)) || _validationServer != null) {
      return [];
    }
    Completer<List<String>> completer = Completer<List<String>>();
    _validationServer = ValidationServer<String>(
      path: 'stripe',
      urlBuilder: (_) => stripeBuyUrl,
      validate: _validateCheckout,
      onValidationCompleted: (token) async => completer.complete(await _registerReceipt(purchasable, packageType, token)),
      onValidationFailed: completer.completeError,
      onValidationCancelled: () => completer.complete([]),
      timeout: timeout,
    );
    await _validationServer!.start();
    List<String> entitlements = await completer.future;
    _validationServer = null;
    return entitlements;
  }

  /// Validates the checkout.
  Future<ValidationObject<String>> _validateCheckout(HttpRequest request) async {
    String? token = request.uri.queryParametersAll['token']?.firstOrNull;
    return token == null
        ? ValidationError<String>(
            exception: ValidationException(code: 'no_token'),
          )
        : ValidationSuccess(
            object: token,
          );
  }

  /// Registers the receipt on RevenueCat servers.
  Future<List<String>> _registerReceipt(Purchasable purchasable, PackageType packageType, String token) async {
    http.Response response = await _client.post(
      Uri.https(
        'api.revenuecat.com',
        '/v1/receipts',
      ),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        ..._revenueCatHeaders,
      },
      body: jsonEncode({
        'app_user_id': purchasesConfiguration.appUserID!,
        'fetch_token': token,
        'product_id': packageType.defaultIdentifier,
      }),
    );
    if (response.statusCode != 200) {
      return [];
    }
    Map<String, dynamic> json = jsonDecode(response.body);
    return _getEntitlementsFromJson(json);
  }

  /// Returns the user entitlements from the given [json] map.
  List<String> _getEntitlementsFromJson(Map<String, dynamic> json) => List.of(json['subscriber']['entitlements'].keys).cast<String>();

  @override
  Future<Map<PackageType, String>> getPrices(Purchasable purchasable, {String defaultCurrencyCode = 'USD'}) async {
    NumberFormat format = NumberFormat.simpleCurrency(locale: Platform.localeName);
    String currencyCode = (format.currencyName ?? defaultCurrencyCode).toLowerCase();
    Map<PackageType, String> result = {};
    for (PackageType packageType in purchasable.stripePrices.keys) {
      http.Response response = await _client.get(
        Uri.https(
          'api.stripe.com',
          '/v1/prices/${purchasable.stripePrices[packageType]}',
          {'expand[]': 'currency_options'},
        ),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${AppCredentials.stripePricesApiKey}',
          // HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        },
      );
      if (response.statusCode != 200) {
        continue;
      }
      Map<String, dynamic> json = jsonDecode(response.body);
      if (!json['active'] || !json.containsKey('currency_options')) {
        continue;
      }
      Map<String, dynamic> currencyOptions = json['currency_options'];
      if (currencyOptions.isEmpty) {
        continue;
      }
      String currentCurrencyCode = currencyCode;
      Map<String, dynamic>? currentCurrencyOptions = currencyOptions[currentCurrencyCode];
      currentCurrencyCode = defaultCurrencyCode;
      currentCurrencyOptions ??= currencyOptions[defaultCurrencyCode];
      currentCurrencyCode = currencyOptions.keys.first;
      currentCurrencyOptions ??= currencyOptions[currentCurrencyCode];
      if (currentCurrencyOptions == null) {
        continue;
      }
      NumberFormat format = NumberFormat.simpleCurrency(
        locale: Platform.localeName,
        name: currentCurrencyCode.toUpperCase(),
        decimalDigits: 2,
      );
      result[packageType] = format.format(currentCurrencyOptions['unit_amount'] / 100).toString();
    }
    return result;
  }

  @override
  Future<bool> restorePurchases() => Future.value(true);

  /// Contains all common request headers.
  Map<String, String> get _revenueCatHeaders => {
        'X-Platform': 'stripe',
        HttpHeaders.authorizationHeader: 'Bearer ${purchasesConfiguration.apiKey}',
      };
}

/// Returns the identifier automatically assigned to the current package type.
extension _DefaultIdentifier on PackageType {
  /// Returns the package type default identifier.
  String? get defaultIdentifier => switch (this) {
        PackageType.lifetime => '\$rc_lifetime',
        PackageType.annual => '\$rc_annual',
        PackageType.sixMonth => '\$rc_six_month',
        PackageType.threeMonth => '\$rc_three_month',
        PackageType.twoMonth => '\$rc_two_month',
        PackageType.monthly => '\$rc_monthly',
        PackageType.weekly => '\$rc_weekly',
        PackageType.unknown || PackageType.custom || _ => null,
      };
}
