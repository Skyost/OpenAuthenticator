import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/pages/contributor_plan_paywall/fallback.dart';
import 'package:open_authenticator/pages/contributor_plan_paywall/purchases_ui.dart';
import 'package:open_authenticator/utils/platform.dart';

/// Allows to pick for a billing plan (annual / monthly).
class ContributorPlanPaywallPage extends ConsumerWidget {
  /// The contributor plan paywall page.
  static const String name = '/contributor_plan';

  /// Creates a new contributor plan paywall page instance.
  const ContributorPlanPaywallPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        body: Center(
          child: currentPlatform == Platform.android || currentPlatform == Platform.iOS
              ? ContributorPlanPaywall(
                  onPurchaseCompleted: () => Navigator.pop(context, true),
                  onDismiss: () => Navigator.pop(context, false),
                )
              : ContributorPlanFallbackPaywall(
                  onPurchaseCompleted: () => Navigator.pop(context, true),
                  onDismiss: () => Navigator.pop(context, false),
                ),
        ),
      );
}
