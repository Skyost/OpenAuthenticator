import 'dart:io';

/// Generates "lib/app.dart".
void main() {
  exitCode = 0;

  stdout.writeln('This utility will create the "lib/app.dart" for you.');
  stdout.writeln('If you want to ignore a specific credential, just press "ENTER".');
  stdout.writeln('Note that the specific feature may not work in this case.');
  stdout.writeln('It could even crash so badly that your computer could explode.');
  stdout.writeln('What is your Google Sign-In client ID ? (See : https://console.cloud.google.com/apis/credentials)');
  String googleSignInClientId = stdin.readLineSync() ?? '';
  stdout.writeln('What is your Azure Sign-In client ID ? (See : https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps)');
  String azureSignInClientId = stdin.readLineSync() ?? '';
  stdout.writeln('What is your Github OAuth app client ID ? (See : https://github.com/settings/developers)');
  String githubSignInClientId = stdin.readLineSync() ?? '';
  stdout.writeln('What is your Apple AppStore app ID ? (See : https://appstoreconnect.apple.com/apps)');
  String appleSignInClientId = stdin.readLineSync() ?? '';
  stdout.writeln('What is your Twitter OAuth 2.0 client ID ? (See : https://developer.twitter.com/en/portal/projects-and-apps)');
  String twitterSignInClientId = stdin.readLineSync() ?? '';
  stdout.writeln('What is your RevenueCat Android public key ? (See : https://app.revenuecat.com/overview)');
  String revenueCatPublicKeyAndroid = stdin.readLineSync() ?? '';
  stdout.writeln('What is your RevenueCat Darwin (iOS / macOS) public key ? (See : https://app.revenuecat.com/overview)');
  String revenueCatPublicKeyDarwin = stdin.readLineSync() ?? '';
  stdout.writeln('What is your RevenueCat Darwin Windows public key ? (See : https://app.revenuecat.com/overview)');
  String revenueCatPublicKeyWindows = stdin.readLineSync() ?? '';
  stdout.writeln('What is your Stripe API key ? (See : https://dashboard.stripe.com/apikeys)');
  stdout.writeln('Please always use a key that has a scope limited to "Prices > Read".');
  String stripePricesApiKey = stdin.readLineSync() ?? '';
  stdout.writeln('What is your Stripe test API key ? (See : https://dashboard.stripe.com/apikeys)');
  stdout.writeln('Please always use a key that has a scope limited to "Prices > Read".');
  String stripeTestPricesApiKey = stdin.readLineSync() ?? '';
  if (stripePricesApiKey.isNotEmpty && stripeTestPricesApiKey.isNotEmpty) {
    stripePricesApiKey = "kDebugMode ? '$stripeTestPricesApiKey' : '$stripePricesApiKey'";
  } else {
    stripePricesApiKey = stripePricesApiKey.isEmpty ? '' : "'$stripePricesApiKey'";
    stripeTestPricesApiKey = stripeTestPricesApiKey.isEmpty ? '' : "'$stripeTestPricesApiKey'";
  }

  File file = File('./lib/app.dart');
  if (file.existsSync()) {
    stdout.writeln('File "${file.path}" already exists. Do you want to overwrite it ? (Y/N)');
    String input = stdin.readLineSync() ?? '';
    while (input != 'N' && input != 'Y') {
      stdout.writeln('Please enter "Y" for "yes" and "N" for "no".');
      input = stdin.readLineSync() ?? '';
    }
    if (input == 'N') {
      stdout.writeln('Aborting...');
      return;
    }
  }

  stdout.writeln('Generating...');
  file.writeAsStringSync('''
/// Contains some app constants.
class App {
  /// The app name.
  static const String appName = 'Open Authenticator';

  /// The app author.
  static const String appAuthor = 'Skyost';

  /// The app package name.
  static const String appPackageName = 'app.openauthenticator';

  /// The Firebase login URL.
  static const String firebaseLoginUrl = 'https://login.openauthenticator.app/do';
}

/// Contains some credentials, required to use with some services.
class AppCredentials {
  /// The Google sign in client id.
  static const String googleSignInClientId = '$googleSignInClientId';

  /// The Azure sign in client id.
  static const String azureSignInClientId = '$azureSignInClientId';

  /// The Github sign in client id.
  static const String githubSignInClientId = '$githubSignInClientId';

  /// The Twitter sign in client id.
  static const String twitterSignInClientId = '$twitterSignInClientId';

  /// The Apple sign in client id.
  static const String appleSignInClientId = '$appleSignInClientId';

  /// The RevenueCat Android public key.
  static const String revenueCatPublicKeyAndroid = '$revenueCatPublicKeyAndroid';

  /// The RevenueCat iOS / macOS public key.
  static const String revenueCatPublicKeyDarwin = '$revenueCatPublicKeyDarwin';

  /// The RevenueCat Windows public key.
  static const String revenueCatPublicKeyWindows = '$revenueCatPublicKeyWindows';

  /// The RevenueCat Linux public key.
  static const String revenueCatPublicKeyLinux = revenueCatPublicKeyWindows;

  /// The Stripe API key for fetching prices.
  static const String stripePricesApiKey = $stripePricesApiKey;
}
''');
}
