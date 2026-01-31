import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/model/backend/synchronization/operation.dart';
import 'package:open_authenticator/model/backend/synchronization/queue.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/widgets/app_scaffold.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/error.dart';
import 'package:open_authenticator/widgets/expandable_tile.dart';
import 'package:open_authenticator/widgets/image_text_buttons.dart';

/// The sync issues page.
class SyncIssuesPage extends ConsumerWidget {
  /// The scan page name.
  static const String name = '/syncIssues';

  /// Creates a new sync issues page instance.
  const SyncIssuesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<PushOperation>> withErrors = ref.watch(pushOperationsQueueProvider.selectWithErrors());
    return AppScaffold.scrollable(
      header: FHeader.nested(
        prefixes: [
          ClickableHeaderAction.back(
            onPress: () => Navigator.pop(context),
          ),
        ],
        title: const Text('Synchronization issues'), // TODO
      ),
      center: !withErrors.hasValue || withErrors.value!.isEmpty,
      children: switch (withErrors) {
        AsyncData(:final value) => [
          if (value.isEmpty)
            ImageTextButtonsWidget.icon(
              icon: FIcons.checkCheck,
              text: "It's all good !",
            )
          else
            for (int i = 0; i < value.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i < value.length - 1 ? kBigSpace : 0),
                child: _PushOperationWidget(
                  operation: value[i],
                ),
              ),
        ],
        AsyncError(:final error, :final stackTrace) => [
          ErrorDisplayWidget(
            error: error,
            stackTrace: stackTrace,
          ),
        ],
        AsyncLoading() => [
          const CenteredCircularProgressIndicator(),
        ],
      },
    );
  }
}

class _PushOperationWidget extends StatelessWidget {
  final PushOperation operation;

  const _PushOperationWidget({
    required this.operation,
  });

  @override
  Widget build(BuildContext context) => ExpandableTile(
    title: Text(
      switch (operation.kind) {
        PushOperationKind.set => 'An error occurred while editing a TOTP',
        PushOperationKind.delete => 'An error occurred while deleting a TOTP',
      },
    ),
    children: [
      Text(
        'JSON payload :',
        style: TextStyle(
          fontSize: context.theme.typography.xs.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        operation.payload.toString(),
        maxLines: null,
        overflow: TextOverflow.visible,
        style: TextStyle(fontSize: context.theme.typography.xs.fontSize),
      ),
      Text(
        'Error : ${operation.lastError?.error?.name}',
        style: TextStyle(
          fontSize: context.theme.typography.xs.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Details : ${operation.lastError?.details}',
        style: TextStyle(
          fontSize: context.theme.typography.xs.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Attempt : #${operation.attempt}',
        style: TextStyle(
          fontSize: context.theme.typography.xs.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
