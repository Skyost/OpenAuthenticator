import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';

/// Allows to change the Contributor Plan state for debugging purposes.
class ContributorPlanStateEntryWidget extends ConsumerWidget {
  /// Creates a new Contributor Plan state entry widget instance.
  const ContributorPlanStateEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    AsyncValue<ContributorPlanState> state = ref.watch(contributorPlanStateProvider);
    return ListTile(
      leading: const Icon(Icons.bug_report),
      enabled: state.hasValue,
      title: DropdownButtonFormField<ContributorPlanState>(
        value: state.valueOrNull,
        decoration: const InputDecoration(
          labelText: 'Contributor Plan state',
        ),
        items: [
          for (ContributorPlanState state in ContributorPlanState.values)
            DropdownMenuItem<ContributorPlanState>(
              value: state,
              child: Text(state.name),
            ),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(contributorPlanStateProvider.notifier).debugChangeState(value);
          }
        },
      ),
    );
  }
}
