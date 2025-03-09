import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/app_filled_button.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/divider_text.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Price;
import 'package:url_launcher/url_launcher_string.dart';

/// Allows to pick for a billing plan (annual / monthly).
/// Displayed only if `purchases_ui_flutter` is unavailable on the current OS.
class ContributorPlanFallbackPaywallPage extends ConsumerWidget {
  /// The contributor plan paywall page.
  static const String name = '/contributor_plan_paywall';

  /// Creates a new contributor plan fallback paywall page instance.
  const ContributorPlanFallbackPaywallPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              AppBar(
                leading: CloseButton(),
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
                title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text.rich(
                    translations.contributorPlan.fallbackPaywall.title(
                      title: (text) => WidgetSpan(
                        child: TitleWidget(
                          text: text,
                          textStyle: Theme.of(context).textTheme.headlineLarge,
                        ),
                        alignment: PlaceholderAlignment.middle,
                      ),
                    ),
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                centerTitle: true,
              ),
              const ListTilePadding(
                top: 20,
                bottom: 20,
                child: SizedBox(
                  height: 150,
                  child: SizedScalableImageWidget(
                    asset: 'assets/images/logo.si',
                  ),
                ),
              ),
              for (String feature in translations.contributorPlan.fallbackPaywall.features)
                ListTilePadding(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(feature),
                      ),
                    ],
                  ),
                ),
              ListTilePadding(
                top: 20,
                bottom: 20,
                child: DividerText(
                  text: Text(
                    translations.contributorPlan.fallbackPaywall.packageType.choose,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListTilePadding(
                child: _ContributorPlanBillingPlanPicker(
                  onContinuePressed: (packageType) => _tryPurchase(context, ref, packageType),
                ),
              ),
              ListTilePadding(
                top: 20,
                bottom: 10,
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (await canLaunchUrlString(AppContributorPlan.restPrivacyPolicyLink)) {
                          await launchUrlString(AppContributorPlan.restPrivacyPolicyLink);
                        }
                      },
                      style: ButtonStyle(
                        textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodySmall),
                      ),
                      child: Text(translations.contributorPlan.fallbackPaywall.button.privacyPolicy),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (await canLaunchUrlString(AppContributorPlan.restTermsOfServiceLink)) {
                          await launchUrlString(AppContributorPlan.restTermsOfServiceLink);
                        }
                      },
                      style: ButtonStyle(
                        textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodySmall),
                      ),
                      child: Text(translations.contributorPlan.fallbackPaywall.button.termsOfService),
                    ),
                    TextButton(
                      onPressed: () => _tryRestorePurchases(context, ref),
                      style: ButtonStyle(
                        textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.bodySmall),
                      ),
                      child: Text(translations.contributorPlan.fallbackPaywall.button.restorePurchases),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  /// Tries to do purchase the [packageType].
  Future<void> _tryPurchase(BuildContext context, WidgetRef ref, PackageType packageType) async {
    ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
    Result result = await showWaitingOverlay(
      context,
      future: contributorPlan.purchaseManually(packageType),
      message: translations.contributorPlan.subscribe.waitingDialogMessage,
      timeout: contributorPlan.getPurchaseTimeout(),
      timeoutMessage: translations.error.timeout.contributorPlan,
    );
    if (context.mounted) {
      context.showSnackBarForResult(
        result,
        successMessage: translations.contributorPlan.subscribe.success,
        retryIfError: true,
      );
      if (result is ResultSuccess) {
        Navigator.pop(context, result);
      }
    }
  }

  /// Tries to restore the purchases.
  Future<void> _tryRestorePurchases(BuildContext context, WidgetRef ref) async {
    ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
    if (!context.mounted) {
      return;
    }
    Result result = await showWaitingOverlay(context, future: contributorPlan.restoreState());
    if (context.mounted) {
      context.showSnackBarForResult(
        result,
        successMessage: translations.contributorPlan.fallbackPaywall.restorePurchasesSuccess,
        retryIfError: true,
      );
      if (result is ResultSuccess) {
        Navigator.pop(context, result);
      }
    }
  }

  /// Displays the fallback paywall.
  static Future<Result> display(BuildContext context) async {
    Object? result = await Navigator.pushNamed(context, ContributorPlanFallbackPaywallPage.name);
    return result is Result ? result : const ResultCancelled();
  }
}

/// Displays the billing plan list and a "Continue" button.
class _ContributorPlanBillingPlanPicker extends ConsumerStatefulWidget {
  /// Triggered when a package type has been chosen.
  final Function(PackageType) onContinuePressed;

  /// Creates a new contributor plan billing plan picker instance.
  const _ContributorPlanBillingPlanPicker({
    required this.onContinuePressed,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContributorPlanBillingPlanPickerState();
}

/// The contributor plan billing plan picker state.
class _ContributorPlanBillingPlanPickerState extends ConsumerState<_ContributorPlanBillingPlanPicker> {
  /// The selected package type.
  PackageType? packageType;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FutureBuilder(
              future: ref.read(contributorPlanStateProvider.notifier).getPrices(),
              builder: (context, snapshot) {
                if (snapshot.hasError || snapshot.data is ResultError) {
                  Object? error;
                  if (snapshot.hasError) {
                    error = snapshot.error!;
                  } else if (snapshot.data is ResultError) {
                    error = snapshot.error;
                  }
                  return Text(
                    error == null ? translations.error.generic.tryAgain : translations.error.generic.withException(exception: error),
                    textAlign: TextAlign.center,
                  );
                }
                if (snapshot.hasData) {
                  Result<Prices> result = snapshot.requireData;
                  if (result is! ResultSuccess) {
                    Object? exception = result is! ResultError || (result as ResultError).exception == null ? null : (result as ResultError).exception;
                    return Text(
                      exception == null ? translations.error.generic.tryAgain : translations.error.generic.withException(exception: exception),
                      textAlign: TextAlign.center,
                    );
                  }
                  Prices prices = (result as ResultSuccess).value;
                  if (prices.packagesPrice.isEmpty) {
                    return Text(
                      translations.contributorPlan.fallbackPaywall.packageType.empty,
                      textAlign: TextAlign.center,
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        for (MapEntry<PackageType, Price> entry in prices.packagesPrice.entries)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: _createCard(
                                context,
                                packageType: entry.key,
                                price: entry.value,
                                off: prices.promotions[entry.key],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                return const CenteredCircularProgressIndicator();
              },
            ),
          ),
          AppFilledButton(
            label: Text(MaterialLocalizations.of(context).continueButtonLabel),
            onPressed: packageType == null ? null : (() => widget.onContinuePressed(packageType!)),
          ),
        ],
      );

  /// Creates the list tile for the given [packageType].
  Widget _createCard(
    BuildContext context, {
    required PackageType packageType,
    required Price price,
    int? off,
  }) {
    String? name = translations.contributorPlan.fallbackPaywall.packageType.name[packageType.name];
    String? interval = translations.contributorPlan.fallbackPaywall.packageType.interval[packageType.name];
    String? subtitle = translations.contributorPlan.fallbackPaywall.packageType.subtitle[packageType.name];
    if (name == null || interval == null || subtitle == null) {
      return const SizedBox.shrink();
    }
    ThemeData theme = Theme.of(context);
    Widget card = Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text.rich(
                translations.contributorPlan.fallbackPaywall.packageType.priceSubtitle(
                  subtitle: TextSpan(text: subtitle),
                  price: TextSpan(
                    text: price.formattedAmount,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  interval: TextSpan(
                    text: interval.toLowerCase(),
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ),
        onTap: () {
          setState(() => this.packageType = this.packageType == packageType ? null : packageType);
        },
      ),
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        if (this.packageType == packageType)
          Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                outlineVariant: theme.colorScheme.primary,
                surface: theme.colorScheme.surfaceContainerHigh,
              ),
            ),
            child: card,
          )
        else
          card,
        if (this.packageType == packageType)
          Positioned(
            top: -6,
            right: -6,
            child: Icon(
              Icons.circle,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        if (this.packageType == packageType)
          Positioned(
            top: -6,
            right: -6,
            child: Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
            ),
          ),
        if (off != null)
          Positioned(
            top: -10,
            left: -10,
            child: Transform.rotate(
              angle: -math.pi / 16,
              child: Card(
                color: theme.colorScheme.primary,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Text(
                    '-${off.abs()}%',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
