import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Contains some useful methods for subscribing to the Contributor Plan.
class ContributorPlanUtils {
  /// Subscribe to the Contributor Plan.
  static Future<bool> purchase(BuildContext context, WidgetRef ref) async {
    ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
    PaywallResult paywallResult = await contributorPlan.presentPaywall();
    switch (paywallResult) {
      case PaywallResult.notPresented:
      case PaywallResult.cancelled:
        return false;
      case PaywallResult.error:
        if (!context.mounted) {
          return false;
        }
        PackageType? packageType = await _ContributorPlanBillingPickerDialog.ask(context);
        Duration? timeout = await contributorPlan.getPurchaseTimeout();
        if (packageType == null || !context.mounted) {
          return false;
        }
        bool result = await showWaitingOverlay(
          context,
          future: contributorPlan.purchaseManually(packageType),
          message: translations.contributorPlan.subscribe.waitingDialogMessage,
          timeout: timeout,
          timeoutMessage: translations.error.timeout.contributorPlan,
        );
        if (!context.mounted) {
          return result;
        }
        if (result) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.contributorPlan.subscribe.success);
        } else {
          SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
        }
        return result;
      case PaywallResult.purchased:
      case PaywallResult.restored:
        if (context.mounted) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.contributorPlan.subscribe.success);
        }
        return true;
    }
  }
}

/// Allows to pick for a billing plan (annual / monthly).
class _ContributorPlanBillingPickerDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ContributorPlanBillingPickerDialogState();

  /// Asks the user to pick a package type.
  static Future<PackageType?> ask(BuildContext context) => showAdaptiveDialog<PackageType>(
    context: context,
    builder: (context) => _ContributorPlanBillingPickerDialog(),
  );
}

/// The contributor plan billing picker dialog state.
class _ContributorPlanBillingPickerDialogState extends ConsumerState<_ContributorPlanBillingPickerDialog> {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
    title: Text(translations.contributorPlan.billingPickerDialog.title),
    scrollable: true,
    content: FutureBuilder(
      future: ref.watch(contributorPlanStateProvider.notifier).getPrices(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(translations.error.generic.withException(exception: snapshot.error!)),
          );
        }
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(translations.contributorPlan.billingPickerDialog.empty),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (MapEntry<PackageType, String> entry in snapshot.data!.entries)
                _createListTile(
                  entry.key,
                  entry.value,
                ),
            ],
          );
        }
        return const CenteredCircularProgressIndicator();
      },
    ),
    actions: [
      TextButton(
        onPressed: () async {
          ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
          if (!context.mounted) {
            return;
          }
          bool result = await showWaitingOverlay(context, future: contributorPlan.restoreState());
          if (!context.mounted) {
            return;
          }
          if (result) {
            SnackBarIcon.showSuccessSnackBar(
              context,
              text: translations.contributorPlan.billingPickerDialog.restorePurchases.success,
            );
          } else {
            SnackBarIcon.showErrorSnackBar(
              context,
              text: translations.error.generic.tryAgain,
            );
          }
        },
        child: Text(translations.contributorPlan.billingPickerDialog.restorePurchases.button),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
    ],
  );

  /// Creates the list tile for the given [packageType].
  Widget _createListTile(PackageType packageType, String price) {
    String? name = translations.contributorPlan.billingPickerDialog.packageTypeName[packageType.name];
    String? interval = translations.contributorPlan.billingPickerDialog.packageTypeInterval[packageType.name];
    String? subtitle = translations.contributorPlan.billingPickerDialog.packageTypeSubtitle[packageType.name];
    if (name == null || interval == null || subtitle == null) {
      return const SizedBox.shrink();
    }
    return ListTile(
      title: Text(name),
      subtitle: Text.rich(
        translations.contributorPlan.billingPickerDialog.priceSubtitle(
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
      onTap: () => Navigator.pop(context, packageType),
    );
  }
}
