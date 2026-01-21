import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/divider_text.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide Price;
import 'package:url_launcher/url_launcher_string.dart';

/// The contributor plan fallback paywall header.
class ContributorPlanFallbackPaywallHeader extends StatelessWidget {
  /// Triggered on dismiss.
  final VoidCallback onDismiss;

  /// Creates a new contributor plan fallback paywall header instance.
  const ContributorPlanFallbackPaywallHeader({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) => FHeader.nested(
    prefixes: [
      ClickableHeaderAction.x(
        onPress: onDismiss,
      ),
    ],
    title: FittedBox(
      fit: BoxFit.fitWidth,
      child: Text.rich(
        translations.contributorPlan.fallbackPaywall.title(
          title: (text) => WidgetSpan(
            child: TitleWidget(
              text: text,
              textStyle: context.theme.typography.xl3,
            ),
            alignment: PlaceholderAlignment.middle,
          ),
        ),
        style: context.theme.typography.xl3,
        textAlign: TextAlign.center,
      ),
    ),
  );
}

/// Allows to pick for a billing plan (annual / monthly).
/// Displayed only if `purchases_ui_flutter` is unavailable on the current OS.
class ContributorPlanFallbackPaywall extends ConsumerWidget {
  /// Triggered when the purchase has completed.
  final VoidCallback onPurchaseCompleted;

  /// Creates a new contributor plan fallback paywall instance.
  const ContributorPlanFallbackPaywall({
    super.key,
    required this.onPurchaseCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FBaseButtonStyle Function(FButtonStyle) bottomButtonsStyle = FButtonStyle.ghost(
      (buttonStyle) => buttonStyle.copyWith(
        contentStyle: (contentStyle) => contentStyle.copyWith(
          textStyle: contentStyle.textStyle.map(
            (textStyle) => textStyle.copyWith(
              fontSize: context.theme.typography.sm.fontSize,
            ),
          ),
        ),
      ),
    );
    return ListView(
      shrinkWrap: true,
      children: [
        Container(
          height: 150,
          margin: const EdgeInsets.only(bottom: kBigSpace),
          child: const SizedScalableImageWidget(
            asset: 'assets/images/logo.si',
          ),
        ),
        for (String feature in translations.contributorPlan.fallbackPaywall.features)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kSpace / 2),
                child: Icon(
                  FIcons.check,
                  color: context.theme.colors.primary,
                ),
              ),
              Expanded(
                child: Text(feature),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(top: kBigSpace, bottom: kSpace),
          child: DividerText(
            text: Text(
              translations.contributorPlan.fallbackPaywall.packageType.choose,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: kSpace),
          child: _ContributorPlanBillingPlanPicker(
            onContinuePress: (packageType) => _tryPurchase(context, ref, packageType),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          children: [
            ClickableButton(
              onPress: () async {
                if (await canLaunchUrlString(AppContributorPlan.privacyPolicyLink)) {
                  await launchUrlString(AppContributorPlan.privacyPolicyLink);
                }
              },
              mainAxisSize: .min,
              style: bottomButtonsStyle,
              child: Text(translations.contributorPlan.fallbackPaywall.button.privacyPolicy),
            ),
            ClickableButton(
              onPress: () async {
                if (await canLaunchUrlString(AppContributorPlan.termsOfServiceLink)) {
                  await launchUrlString(AppContributorPlan.termsOfServiceLink);
                }
              },
              mainAxisSize: .min,
              style: bottomButtonsStyle,
              child: Text(translations.contributorPlan.fallbackPaywall.button.termsOfService),
            ),
            ClickableButton(
              onPress: () => _tryRestorePurchases(context, ref),
              mainAxisSize: .min,
              style: bottomButtonsStyle,
              child: Text(translations.contributorPlan.fallbackPaywall.button.restorePurchases),
            ),
          ],
        ),
      ],
    );
  }

  /// Tries to do purchase the [packageType].
  Future<void> _tryPurchase(BuildContext context, WidgetRef ref, PackageType packageType) async {
    ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
    Result result = await showWaitingOverlay(
      context,
      future: contributorPlan.purchase(packageType),
    );
    if (context.mounted) {
      context.handleResult(
        result,
        successMessage: translations.contributorPlan.subscribeSuccess,
        retryIfError: true,
      );
      if (result is ResultSuccess) {
        onPurchaseCompleted();
      }
    }
  }

  /// Tries to restore the purchases.
  Future<void> _tryRestorePurchases(BuildContext context, WidgetRef ref) async {
    ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
    if (!context.mounted) {
      return;
    }
    Result result = await showWaitingOverlay(context, future: contributorPlan.restore());
    if (context.mounted) {
      context.handleResult(
        result,
        successMessage: translations.contributorPlan.fallbackPaywall.restorePurchasesSuccess,
        retryIfError: true,
      );
      if (result is ResultSuccess) {
        onPurchaseCompleted();
      }
    }
  }
}

/// Displays the billing plan list and a "Continue" button.
class _ContributorPlanBillingPlanPicker extends ConsumerStatefulWidget {
  /// Triggered when a package type has been chosen.
  final Function(PackageType) onContinuePress;

  /// Creates a new contributor plan billing plan picker instance.
  const _ContributorPlanBillingPlanPicker({
    required this.onContinuePress,
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
                          padding: const EdgeInsets.symmetric(horizontal: kSpace),
                          child: _createTile(
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
      ClickableButton(
        onPress: packageType == null ? null : (() => widget.onContinuePress(packageType!)),
        child: Text(MaterialLocalizations.of(context).continueButtonLabel),
      ),
    ],
  );

  /// Creates the list tile for the given [packageType].
  Widget _createTile(
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
    Widget tile = FTile.raw(
      style: (tileStyle) => tileStyle.copyWith(
        contentStyle: (contentStyle) => contentStyle.copyWith(
          padding: const EdgeInsets.symmetric(vertical: kSpace, horizontal: kBigSpace),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kSpace / 2),
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
            style: TextStyle(color: context.theme.colors.primaryForeground),
          ),
        ],
      ),
      onPress: () {
        setState(() => this.packageType = this.packageType == packageType ? null : packageType);
      },
    );
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        if (this.packageType == packageType)
          FTheme(
            data: context.theme.copyWith(
              tileStyle: (tileStyle) => tileStyle.copyWith(
                decoration: tileStyle.decoration.map(
                  (decoration) => decoration?.copyWith(
                    color: decoration.color?.highlight(),
                  ),
                ),
              ),
            ),
            child: tile,
          )
        else
          tile,
        if (this.packageType == packageType)
          Positioned(
            top: -kSpace / 2,
            right: -kSpace / 2,
            child: Icon(
              FIcons.circle,
              color: context.theme.colors.primaryForeground,
            ),
          ),
        if (this.packageType == packageType)
          Positioned(
            top: -kSpace / 2,
            right: -kSpace / 2,
            child: Icon(
              FIcons.circleCheck,
              color: context.theme.colors.primaryForeground,
            ),
          ),
        if (off != null)
          Positioned(
            top: -kSpace,
            left: -kSpace,
            child: Transform.rotate(
              angle: -math.pi / 16,
              child: FBadge(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kSpace, vertical: kSpace / 2),
                  child: Text(
                    '-${off.abs()}%',
                    style: TextStyle(color: context.theme.colors.primaryForeground),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
