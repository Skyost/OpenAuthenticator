import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/app_filled_button.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/divider_text.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
              ListTilePadding(
                bottom: 20,
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
              const ListTilePadding(
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
              _ContributorPlanBillingPlans(
                onPackageTypePicked: (packageType) => _tryPurchase(context, ref, packageType),
              ),
              ListTilePadding(
                top: 20,
                bottom: 10,
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: Text(translations.contributorPlan.fallbackPaywall.button.privacyPolicy),
                      onPressed: () async {
                        if (await canLaunchUrlString(AppContributorPlan.restPrivacyPolicyLink)) {
                          await launchUrlString(AppContributorPlan.restPrivacyPolicyLink);
                        }
                      },
                    ),
                    TextButton(
                      child: Text(translations.contributorPlan.fallbackPaywall.button.termsOfService),
                      onPressed: () async {
                        if (await canLaunchUrlString(AppContributorPlan.restTermsOfServiceLink)) {
                          await launchUrlString(AppContributorPlan.restTermsOfServiceLink);
                        }
                      },
                    ),
                    TextButton(
                      child: Text(translations.contributorPlan.fallbackPaywall.button.restorePurchases),
                      onPressed: () => _tryRestorePurchases(context, ref),
                    ),
                  ],
                ),
              ),
              ListTilePadding(
                top: 20,
                bottom: 20,
                child: AppFilledButton(
                  tonal: true,
                  onPressed: () => Navigator.pop(context, const ResultCancelled()),
                  label: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  icon: Icon(Icons.close),
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

/// Displays the billing plans list.
class _ContributorPlanBillingPlans extends ConsumerWidget {
  /// Triggered when a package type has been chosen.
  final Function(PackageType) onPackageTypePicked;

  /// Creates a new contributor plan billing plans instance.
  const _ContributorPlanBillingPlans({
    required this.onPackageTypePicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
        future: ref.read(contributorPlanStateProvider.notifier).getPrices(),
        builder: (context, snapshot) {
          if (snapshot.hasError || snapshot.data is ResultError) {
            Object? error;
            if (snapshot.hasError) {
              error = snapshot.error!;
            } else if (snapshot.data is ResultError) {
              error = snapshot.error;
            }
            return ListTilePadding(
              child: Text(
                error == null ? translations.error.generic.tryAgain : translations.error.generic.withException(exception: error),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (snapshot.hasData) {
            ResultSuccess<Map<PackageType, String>> result = snapshot.data as ResultSuccess<Map<PackageType, String>>;
            if (result.value.isEmpty) {
              return ListTilePadding(
                child: Text(
                  translations.contributorPlan.fallbackPaywall.packageType.empty,
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (MapEntry<PackageType, String> entry in result.value.entries)
                  _createListTile(
                    context,
                    entry.key,
                    entry.value,
                  ),
              ],
            );
          }
          return const CenteredCircularProgressIndicator();
        },
      );

  /// Creates the list tile for the given [packageType].
  Widget _createListTile(BuildContext context, PackageType packageType, String price) {
    String? name = translations.contributorPlan.fallbackPaywall.packageType.name[packageType.name];
    String? interval = translations.contributorPlan.fallbackPaywall.packageType.interval[packageType.name];
    String? subtitle = translations.contributorPlan.fallbackPaywall.packageType.subtitle[packageType.name];
    if (name == null || interval == null || subtitle == null) {
      return const SizedBox.shrink();
    }
    return ListTile(
      title: Text(name),
      subtitle: Text.rich(
        translations.contributorPlan.fallbackPaywall.packageType.priceSubtitle(
          subtitle: TextSpan(text: subtitle),
          price: TextSpan(
            text: price,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          interval: TextSpan(
            text: interval.toLowerCase(),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ),
      onTap: () => onPackageTypePicked(packageType),
    );
  }
}
