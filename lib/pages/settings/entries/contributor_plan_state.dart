import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/widgets/form/dropdown_list_tile.dart';

/// Allows to change the Contributor Plan state for debugging purposes.
class ContributorPlanStateEntryWidget extends ConsumerWidget {
  /// Creates a new Contributor Plan state entry widget instance.
  const ContributorPlanStateEntryWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<ContributorPlanState> state = ref.watch(contributorPlanStateProvider);
    return DropdownListTile(
      leading: const Icon(Icons.bug_report),
      enabled: state.hasValue,
      title: const Text('Contributor Plan state'),
      value: state.value,
      choices: [
        for (ContributorPlanState state in ContributorPlanState.values)
          DropdownListTileChoice(
            title: state.name,
            value: state,
          ),
      ],
      onChoiceSelected: (choice) => ref.read(contributorPlanStateProvider.notifier).debugChangeState(choice.value),
    );
  }
}
