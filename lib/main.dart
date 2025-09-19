import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/firebase_options.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_links.dart';
import 'package:open_authenticator/model/authentication/providers/email_link.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/show_intro.dart';
import 'package:open_authenticator/model/settings/theme.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/pages/contributor_plan_paywall/page.dart';
import 'package:open_authenticator/pages/home.dart';
import 'package:open_authenticator/pages/intro/page.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/firebase.dart';
import 'package:open_authenticator/utils/firebase_app_check/firebase_app_check.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/rate_my_app.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/totp_limit.dart';
import 'package:open_authenticator/widgets/unlock_challenge.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:window_manager/window_manager.dart';

/// Hello world !
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleSecureStorage.initialize(_OpenAuthenticatorSSSInitializationOptions());
  if (currentPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(
      const WindowOptions(
        title: App.appName,
        size: Size(800, 600),
        minimumSize: Size(400, 400),
        center: true,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }
  if (isFirebaseSupported) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAppCheck.instance.activate();
    if (isCrashlyticsEnabled) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }
  await LocaleSettings.useDeviceLocale();
  runApp(
    ProviderScope(
      child: TranslationProvider(
        child: const OpenAuthenticatorApp(),
      ),
    ),
  );
}

/// Allows to initialize [SimpleSecureStorage] with parameters that depend on the current mode.
class _OpenAuthenticatorSSSInitializationOptions extends InitializationOptions {
  /// Creates a new Open Authenticator SimpleSecureStorage initialization options.
  _OpenAuthenticatorSSSInitializationOptions()
    : super(
        appName: App.appName + (kDebugMode ? ' Debug' : ''),
        namespace: App.appPackageName + (kDebugMode ? '.debug' : ''),
      );
}

/// The main widget class.
class OpenAuthenticatorApp extends ConsumerWidget {
  /// The route "TOTP" argument.
  static const String kRouteParameterTotp = 'totp';

  /// The route "add TOTP" argument.
  static const String kRouteParameterAddTotp = 'addTotp';

  /// Creates a new open authenticator app instance.
  const OpenAuthenticatorApp({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<bool> showIntro = ref.watch(showIntroSettingsEntryProvider);
    AsyncValue<ThemeMode> theme = ref.watch(themeSettingsEntryProvider);
    Locale locale = TranslationProvider.of(context).flutterLocale;
    return switch (showIntro) {
      AsyncData(:bool value) => _createMaterialApp(
        showIntroState: 'data',
        theme: theme,
        locale: locale,
        initialRoute: value ? IntroPage.name : HomePage.name,
      ),
      AsyncError(:final error) => _createMaterialApp(
        showIntroState: 'error',
        theme: theme,
        locale: locale,
        home: Center(
          child: Text('Error : $error.'),
        ),
      ),
      _ => _createMaterialApp(
        showIntroState: 'loading',
        theme: theme,
        locale: locale,
        home: const CenteredCircularProgressIndicator(),
      ),
    };
  }

  /// Creates a [MaterialApp] widget.
  Widget _createMaterialApp({
    required String showIntroState,
    required AsyncValue<ThemeMode> theme,
    required Locale locale,
    String? initialRoute,
    Widget? home,
  }) {
    ColorScheme light = ColorScheme.fromSeed(
      seedColor: Colors.green,
    );
    ColorScheme dark = ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      key: ValueKey('materialApp.$showIntroState'),
      title: App.appName,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocaleUtils.supportedLocales,
      themeMode: theme.value,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: dark.surface,
          ),
          shape: const RoundedRectangleBorder(),
          surfaceTintColor: Colors.green,
        ),
        colorScheme: dark,
        // iconButtonTheme: IconButtonThemeData(
        //   style: ButtonStyle(
        //     foregroundColor: MaterialStatePropertyAll(Colors.green.shade300),
        //   ),
        // ),
        buttonTheme: const ButtonThemeData(
          alignedDropdown: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: const CircleBorder(),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.green.shade50,
        ),
      ),
      theme: ThemeData(
        colorScheme: light,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: light.surface,
          ),
          shape: const RoundedRectangleBorder(),
        ),
        buttonTheme: const ButtonThemeData(
          alignedDropdown: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: const CircleBorder(),
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green.shade700,
        ),
        inputDecorationTheme: InputDecorationTheme(
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.black12,
        ),
      ),
      routes: home == null
          ? {
              IntroPage.name: (_) => const _RouteWidget(
                child: IntroPage(),
              ),
              HomePage.name: (_) => const _RouteWidget(
                listen: true,
                rateMyApp: true,
                child: HomePage(),
              ),
              ScanPage.name: (_) => const _RouteWidget(
                child: ScanPage(),
              ),
              SettingsPage.name: (_) => const _RouteWidget(
                child: SettingsPage(),
              ),
              TotpPage.name: (context) {
                Map<String, dynamic>? arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
                return _RouteWidget(
                  child: TotpPage(
                    totp: arguments?[kRouteParameterTotp],
                    add: arguments?[kRouteParameterAddTotp],
                  ),
                );
              },
              ContributorPlanPaywallPage.name: (_) => const _RouteWidget(
                child: ContributorPlanPaywallPage(),
              ),
            }
          : {},
      initialRoute: home == null ? initialRoute : null,
      home: home,
    );
  }
}

/// A route that allows to listen to dynamic links and [totpLimitExceededProvider].
class _RouteWidget extends ConsumerStatefulWidget {
  /// The route widget.
  final Widget child;

  /// Listen to [appLinksListenerProvider], [totpLimitProvider], [appUnlockStateProvider] and [cryptoStoreProvider].
  final bool listen;

  /// Whether to initialize and run RateMyApp.
  final bool rateMyApp;

  /// Creates a route widget instance.
  const _RouteWidget({
    required this.child,
    this.listen = false,
    this.rateMyApp = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RouteWidgetState();
}

/// The route widget state.
class _RouteWidgetState extends ConsumerState<_RouteWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.listen) {
      ref.listenManual(
        appLinksListenerProvider,
        (previous, next) async {
          if (previous == next || next is! AsyncData<Uri?> || next.value == null) {
            return;
          }
          Uri uri = next.value!;
          if (uri.host == Uri.parse(App.firebaseLoginUrl).host) {
            WidgetsBinding.instance.addPostFrameCallback((_) => handleLoginLink(uri));
            return;
          }
          if (uri.scheme == 'otpauth') {
            WidgetsBinding.instance.addPostFrameCallback((_) => handleTotpLink(uri));
            return;
          }
        },
        fireImmediately: true,
      );
      ref.listenManual(
        totpLimitProvider,
        (previous, next) async {
          if (previous == next || next is! AsyncData<TotpLimit> || !next.value.isExceeded) {
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) => handleTotpLimitExceeded());
        },
        fireImmediately: true,
      );
    }
    if (widget.rateMyApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        RateMyApp rateMyApp = RateMyApp.customConditions(
          preferencesPrefix: kDebugMode ? 'flutterDebug.rateMyApp.' : 'flutter.rateMyApp.',
          appStoreIdentifier: Stores.appStoreIdentifier,
          googlePlayIdentifier: Stores.googlePlayIdentifier,
          conditions: [
            SupportedPlatformsCondition(),
          ],
        )..populateWithDefaultConditions();
        await rateMyApp.init();
        if (rateMyApp.shouldOpenDialog && mounted) {
          rateMyApp.showRateDialog(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => UnlockChallengeWidget(
    child: widget.child,
  );

  /// Handles a login link.
  Future<void> handleLoginLink(Uri loginLink) async {
    if (!mounted) {
      return;
    }
    Uri? link = Uri.tryParse(loginLink.queryParameters['link'] ?? '');
    if (link == null) {
      return;
    }
    String? mode = link.queryParameters['mode'];
    switch (mode) {
      case 'signIn':
        String? emailToConfirm = await ref.read(emailLinkConfirmationStateProvider.future);
        if (emailToConfirm == null || !mounted) {
          return;
        }
        Result<AuthenticationObject> result = await ref.read(emailLinkConfirmationStateProvider.notifier).confirm(context, link.toString());
        if (mounted) {
          AccountUtils.handleAuthenticationResult(context, ref, result);
        }
        break;
    }
  }

  /// Handles a TOTP link.
  Future<void> handleTotpLink(Uri totpLink) async {
    if (mounted) {
      await showWaitingOverlay(
        context,
        future: TotpPage.openFromUri(context, ref, totpLink),
      );
    }
  }

  /// Handles TOTP limit exceeded.
  Future<void> handleTotpLimitExceeded() async {
    if (mounted) {
      TotpLimitDialog.showAndBlock(context);
    }
  }
}
