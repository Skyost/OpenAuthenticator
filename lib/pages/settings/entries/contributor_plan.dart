import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/model/purchases/clients/rest.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/waiting_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Allows the user to subscribe to the Contributor Plan.
class ContributorPlanEntryWidget extends ConsumerWidget {
  /// Creates a new Contributor Plan entry widget instance.
  const ContributorPlanEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ContributorPlanState> state = ref.watch(contributorPlanStateProvider);
    switch (state) {
      case AsyncData(:ContributorPlanState value):
        if (value == ContributorPlanState.impossible) {
          return const SizedBox.shrink();
        }
        return ListTile(
          leading: value == ContributorPlanState.active ? const Icon(Icons.verified) : const Icon(Icons.sentiment_dissatisfied),
          title: Text(translations.settings.application.contributorPlan.title),
          subtitle: Text(
            value == ContributorPlanState.active ? translations.settings.application.contributorPlan.subtitle.active : translations.settings.application.contributorPlan.subtitle.inactive,
          ),
          onTap: value == ContributorPlanState.active && (!kDebugMode)
              ? null
              : () async {
                  RevenueCatClient? client = await ref.read(revenueCatClientProvider.future);
                  Duration? timeout = client is RevenueCatRestClient ? client.timeout : null;
                  if (!context.mounted) {
                    return;
                  }
                  bool result = await showWaitingDialog(
                    context,
                    future: ref.read(contributorPlanStateProvider.notifier).purchase(() async {
                      if (context.mounted) {
                        return await _ContributorPlanBillingPickerDialog.ask(context);
                      }
                      return null;
                    }),
                    message: translations.settings.application.contributorPlan.subscribe.waitingDialog.message,
                    timeout: timeout,
                    timeoutMessage: translations.settings.application.contributorPlan.subscribe.waitingDialog.timedOut,
                  );
                  if (!context.mounted) {
                    return;
                  }
                  if (result) {
                    SnackBarIcon.showSuccessSnackBar(context, text: translations.settings.application.contributorPlan.subscribe.success);
                  } else {
                    SnackBarIcon.showErrorSnackBar(context, text: translations.settings.application.contributorPlan.subscribe.error);
                  }
                },
        );
      case AsyncLoading():
        return ListTile(
          leading: const CircularProgressIndicator(),
          title: Text(translations.settings.application.contributorPlan.title),
          subtitle: Text(translations.settings.application.contributorPlan.subtitle.loading),
        );
      case AsyncError():
      default:
        return const SizedBox.shrink();
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
        title: Text(translations.settings.application.contributorPlan.billingPickerDialog.title),
        scrollable: true,
        content: FutureBuilder(
          future: ref.watch(contributorPlanStateProvider.notifier).getPrices(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(translations.settings.application.contributorPlan.billingPickerDialog.error(error: snapshot.error!)),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text(translations.settings.application.contributorPlan.billingPickerDialog.empty),
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
              bool result = await showWaitingDialog(context, future: contributorPlan.restoreState());
              if (!context.mounted) {
                return;
              }
              if (result) {
                SnackBarIcon.showSuccessSnackBar(
                  context,
                  text: translations.settings.application.contributorPlan.billingPickerDialog.restorePurchases.success,
                );
              } else {
                SnackBarIcon.showErrorSnackBar(
                  context,
                  text: translations.settings.application.contributorPlan.billingPickerDialog.restorePurchases.error,
                );
              }
            },
            child: Text(translations.settings.application.contributorPlan.billingPickerDialog.restorePurchases.button),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );

  /// Creates the list tile for the given [packageType].
  Widget _createListTile(PackageType packageType, String price) {
    String? name = translations.settings.application.contributorPlan.billingPickerDialog.packageTypeName[packageType.name];
    String? interval = translations.settings.application.contributorPlan.billingPickerDialog.packageTypeInterval[packageType.name];
    String? subtitle = translations.settings.application.contributorPlan.billingPickerDialog.packageTypeSubtitle[packageType.name];
    if (name == null || interval == null || subtitle == null) {
      return const SizedBox.shrink();
    }
    return ListTile(
      title: Text(name),
      subtitle: Text.rich(
        translations.settings.application.contributorPlan.billingPickerDialog.priceSubtitle(
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
