import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/purchases/clients/client.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Allows to pick for a billing plan (annual / monthly).
/// Displayed only if `purchases_ui_flutter` is available on the current OS.
class ContributorPlanPaywall extends ConsumerWidget {
  /// Triggered when the purchase has completed.
  final VoidCallback onPurchaseCompleted;

  /// Triggered on dismiss.
  final VoidCallback onDismiss;

  /// Creates a new contributor plan fallback paywall instance.
  const ContributorPlanPaywall({
    super.key,
    required this.onPurchaseCompleted,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.watch(revenueCatClientProvider)?.getOfferings(),
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
        Future<void> handleSuccess() async {
          Result<ContributorPlanState> result = await ref.read(contributorPlanStateProvider.notifier).refresh();
          if (!context.mounted) {
            return;
          }
          if (result is! ResultSuccess<ContributorPlanState>) {
            context.showSnackBarForResult(
              result,
              retryIfError: true,
            );
            return;
          }
          if (result.value == ContributorPlanState.active) {
            SnackBarIcon.showSuccessSnackBar(
              context,
              text: translations.contributorPlan.subscribe.success,
            );
            onPurchaseCompleted();
          } else {
            SnackBarIcon.showErrorSnackBar(
              context,
              text: translations.error.generic.tryAgain,
            );
          }
        }

        return PaywallView(
          offering: snapshot.data?[Purchasable.contributorPlan.offeringId],
          onDismiss: onDismiss,
          onPurchaseCompleted: (customerInfo, transaction) async => await handleSuccess(),
          onRestoreCompleted: (customerInfo) async => await handleSuccess(),
          onPurchaseError: (error) {
            handleException(error, StackTrace.current);
            if (context.mounted) {
              SnackBarIcon.showErrorSnackBar(
                context,
                text: translations.error.generic.withException(exception: error),
              );
            }
          },
          onRestoreError: (error) {
            handleException(error, StackTrace.current);
            if (context.mounted) {
              SnackBarIcon.showErrorSnackBar(
                context,
                text: translations.error.generic.withException(exception: error),
              );
            }
          },
        );
      }
      return const CenteredCircularProgressIndicator();
    },
  );
}
