import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/contributor_plan.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        switch (value) {
          case ContributorPlanState.impossible:
            return const SizedBox.shrink();
          case ContributorPlanState.inactive:
            return ListTile(
              leading: const Icon(Icons.sentiment_dissatisfied),
              title: Text(translations.settings.application.contributorPlan.title),
              subtitle: Text(translations.settings.application.contributorPlan.subtitle.inactive),
              onTap: () => ContributorPlanUtils.purchase(context, ref),
            );
          case ContributorPlanState.active:
            return ListTile(
              leading: const Icon(Icons.verified),
              title: Text(translations.settings.application.contributorPlan.title),
              subtitle: Text(translations.settings.application.contributorPlan.subtitle.active),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AppDialog(
                  title: Text(translations.settings.application.contributorPlan.subscriptionDialog.title),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        RevenueCatClient? client = ref.read(revenueCatClientProvider);
                        String? url = await showWaitingOverlay(
                          context,
                          future: client?.getManagementUrl(AppContributorPlan.offeringId),
                        );
                        if (url != null) {
                          launchUrlString(url);
                          return;
                        }
                        if (context.mounted) {
                          SnackBarIcon.showErrorSnackBar(
                            context,
                            text: translations.settings.application.contributorPlan.subscriptionDialog.manageSubscription.error,
                          );
                        }
                      },
                      child: Text(translations.settings.application.contributorPlan.subscriptionDialog.manageSubscription.button),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                    ),
                  ],
                  children: [
                    Text(translations.settings.application.contributorPlan.subscriptionDialog.message),
                  ],
                ),
              ),
            );
        }
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
