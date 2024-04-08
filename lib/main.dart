import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/firebase_options.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/settings/show_intro.dart';
import 'package:open_authenticator/model/settings/theme.dart';
import 'package:open_authenticator/pages/home.dart';
import 'package:open_authenticator/pages/intro/page.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/route/unlock_challenge.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
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
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  await SimpleSecureStorage.initialize(const InitializationOptions(
    appName: App.appName,
    namespace: App.appPackageName,
  ));
  LocaleSettings.useDeviceLocale();
  runApp(
    TranslationProvider(
      child: const ProviderScope(
        child: OpenAuthenticatorApp(),
      ),
    ),
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
            ),
            iconButtonTheme: IconButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Colors.green.shade300),
              ),
            ),
            buttonTheme: const ButtonThemeData(
              alignedDropdown: true,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              shape: CircleBorder(),
            ),
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            // iconButtonTheme: IconButtonThemeData(
            //   style: ButtonStyle(
            //     foregroundColor: MaterialStatePropertyAll(Colors.green.shade700),
            //   ),
            // ),
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
          ),
          routes: {
            IntroPage.name: (_) => const _RouteWidget(child: IntroPage()),
            HomePage.name: (_) => const _RouteWidget(child: HomePage()),
            ScanPage.name: (_) => const _RouteWidget(child: ScanPage()),
            SettingsPage.name: (_) => const _RouteWidget(child: SettingsPage()),
            TotpPage.name: (context) {
              Map<String, dynamic>? arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
              return _RouteWidget(
                child: TotpPage(
                  totp: arguments?[kRouteParameterTotp],
                  add: arguments?[kRouteParameterAddTotp],
                ),
              );
            },
          },
          initialRoute: value ? IntroPage.name : HomePage.name,
        ),
      AsyncError(:final error) => Text('Error : $error.'),
      _ => const CenteredCircularProgressIndicator(),
    };
  }
}

/// A simple route widget, using [MasterPasswordLockedRouteWidget] and [LocalAuthLockedRouteWidget].
class _RouteWidget extends ConsumerStatefulWidget {
  /// The route widget.
  final Widget child;

  /// Creates a route widget instance.
  const _RouteWidget({
    required this.child,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RouteWidgetState();
}

/// The route widget state.
class _RouteWidgetState extends ConsumerState<_RouteWidget> {
  /// The dynamic links subscription.
  StreamSubscription<PendingDynamicLinkData>? dynamicLinksSubscription;

  @override
  void initState() {
    super.initState();
    if (currentPlatform.isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((_) => listenDynamicLinks());
    }
  }

  @override
  Widget build(BuildContext context) => UnlockChallengeRouteWidget(
        child: widget.child,
      );

  @override
  void dispose() {
    dynamicLinksSubscription?.cancel();
    dynamicLinksSubscription = null;
    super.dispose();
  }

  /// Listen for dynamic links.
  Future<void> listenDynamicLinks() async {
    PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      dynamicLinkCallback(initialLink);
    }
    dynamicLinksSubscription = FirebaseDynamicLinks.instance.onLink.listen(dynamicLinkCallback);
  }

  /// Triggered when a dynamic link has been received.
  Future<void> dynamicLinkCallback(PendingDynamicLinkData link) async {
    if (await ref.read(firebaseAuthenticationProvider.notifier).tryConfirm(link.link.toString()) && mounted) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.authentication.logIn.success);
    }
  }
}