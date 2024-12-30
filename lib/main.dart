import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
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
import 'package:open_authenticator/model/settings/show_intro.dart';
import 'package:open_authenticator/model/settings/theme.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/pages/contributor_plan_fallback_paywall.dart';
import 'package:open_authenticator/pages/home.dart';
import 'package:open_authenticator/pages/intro/page.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/rate_my_app.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/totp_limit.dart';
import 'package:open_authenticator/widgets/route/unlock_challenge.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:window_manager/window_manager.dart';

/// Hello world !
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (currentPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(
        const WindowOptions(
          title: App.appName,
          size: Size(800, 600),
          center: true,
        ), () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (currentPlatform.isMobile || currentPlatform == Platform.macOS) {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttestWithDeviceCheckFallback,
    );
    if (!kDebugMode) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  }
  await SimpleSecureStorage.initialize(_OpenAuthenticatorSSSInitializationOptions());
  LocaleSettings.useDeviceLocale();
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
    ColorScheme light = ColorScheme.fromSeed(
      seedColor: Colors.green,
    );
    ColorScheme dark = ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    );
    return switch (showIntro) {
      AsyncData(:bool value) => MaterialApp(
          title: App.appName,
          locale: TranslationProvider.of(context).flutterLocale,
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
          routes: {
            IntroPage.name: (_) => _RouteWidget(
                  listen: currentPlatform.isMobile || kDebugMode,
                  child: const IntroPage(),
                ),
            HomePage.name: (_) => _RouteWidget(
                  listen: currentPlatform.isMobile || kDebugMode,
                  rateMyApp: true,
                  child: const HomePage(),
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
            ContributorPlanFallbackPaywallPage.name: (_) => const _RouteWidget(
                  child: ContributorPlanFallbackPaywallPage(),
                ),
          },
          initialRoute: value ? IntroPage.name : HomePage.name,
        ),
      AsyncError(:final error) => Text('Error : $error.'),
      _ => const CenteredCircularProgressIndicator(),
    };
  }
}

/// A route that allows to listen to dynamic links and [totpLimitExceededProvider].
class _RouteWidget extends ConsumerStatefulWidget {
  /// The route widget.
  final Widget child;

  /// Listen to [appLinksListenerProvider] and [totpLimitExceededProvider].
  final bool listen;

  /// Whether to provide an [UnlockChallengeRouteWidget].
  final bool unlock;

  /// Whether to initialize and run RateMyApp.
  final bool rateMyApp;

  /// Creates a route widget instance.
  const _RouteWidget({
    required this.child,
    this.listen = false,
    this.unlock = true,
    this.rateMyApp = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RouteWidgetState();
}

/// The route widget state.
class _RouteWidgetState extends ConsumerState<_RouteWidget> {
  /// The [RateMyApp] instance.
  RateMyApp? rateMyApp;

  @override
  void initState() {
    super.initState();
    if (widget.listen) {
      if (currentPlatform.isMobile) {
        ref.listenManual(
          appLinksListenerProvider,
          (previous, next) async {
            if (next.valueOrNull == null || previous == next) {
              return;
            }
            Uri uri = next.value!;
            if (uri.host == Uri.parse(App.firebaseLoginUrl).host) {
              handleLoginLink(uri);
              return;
            }
            if (uri.scheme == 'otpauth') {
              handleTotpLink(uri);
              return;
            }
          },
        );
      }
      ref.listenManual(
        totpLimitProvider,
        (previous, next) async {
          if (next.valueOrNull?.isExceeded == true && mounted) {
            TotpLimitDialog.showAndBlock(context);
          }
        },
        fireImmediately: true,
      );
    }
    if (widget.rateMyApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) => initializeRateMyApp());
    }
  }

  @override
  Widget build(BuildContext context) => widget.unlock
      ? UnlockChallengeRouteWidget(
          child: widget.child,
        )
      : widget.child;

  /// Initializes [RateMyApp] and shows the dialog, if needed.
  Future<void> initializeRateMyApp() async {
    if (rateMyApp == null) {
      rateMyApp = RateMyApp.customConditions(
        appStoreIdentifier: Stores.appStoreIdentifier,
        googlePlayIdentifier: Stores.googlePlayIdentifier,
        conditions: [
          SupportedPlatformsCondition(),
        ],
      );
      rateMyApp!.populateWithDefaultConditions();
      await rateMyApp!.init();
    }
    if (rateMyApp!.shouldOpenDialog && mounted) {
      rateMyApp!.showRateDialog(context);
    }
  }

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
        EmailLinkAuthenticationProvider emailAuthenticationProvider = ref.read(emailLinkAuthenticationProvider);
        if (!(await emailAuthenticationProvider.isWaitingForConfirmation())) {
          return;
        }
        if (!mounted) {
          return;
        }
        Result<AuthenticationObject> result = await emailAuthenticationProvider.confirm(context, link.toString());
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
}
