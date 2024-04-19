import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/contributor_plan.dart';

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
          onTap: value == ContributorPlanState.active && (!kDebugMode) ? null : () => ContributorPlanUtils.purchase(context, ref),
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
