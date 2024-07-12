import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/pages/contributor_plan_fallback_paywall.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';

/// Contains some useful methods for subscribing to the Contributor Plan.
class ContributorPlanUtils {
  /// Subscribe to the Contributor Plan.
  static Future<bool> purchase(BuildContext context, WidgetRef ref) async {
    ContributorPlan contributorPlan = ref.read(contributorPlanStateProvider.notifier);
    Result paywallResult = await contributorPlan.presentPaywall();
    switch (paywallResult) {
      case ResultError():
        if (!context.mounted) {
          return false;
        }

        Result result = await ContributorPlanFallbackPaywallPage.display(context);
        return result is ResultSuccess;
      case ResultSuccess():
        if (context.mounted) {
          SnackBarIcon.showSuccessSnackBar(context, text: translations.contributorPlan.subscribe.success);
        }
        return true;
      default:
        return false;
    }
  }
}
