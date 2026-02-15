import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/model/backend/synchronization/push/result.dart';
import 'package:open_authenticator/model/backend/synchronization/queue.dart';
import 'package:open_authenticator/model/database/database.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/widgets/app_scaffold.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/error.dart';
import 'package:open_authenticator/widgets/expandable_tile.dart';
import 'package:open_authenticator/widgets/image_text_buttons.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';

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
    AsyncValue<List<PushOperationResult>> errors = ref.watch(pushOperationsErrorsProvider);
    return AppScaffold.scrollable(
      header: FHeader.nested(
        prefixes: [
          ClickableHeaderAction.back(
            onPress: () => Navigator.pop(context),
          ),
        ],
        suffixes: [
          ClickableHeaderAction(
            icon: const Icon(FIcons.trash),
            onPress: () async {
              await showWaitingOverlay(
                context,
                future: ref.read(appDatabaseProvider).clearBackendPushOperationErrors(),
              );
            },
          ),
        ],
        title: const Text('Synchronization issues'), // TODO
      ),
      center: !errors.hasValue || errors.value!.isEmpty,
      children: switch (errors) {
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
                child: _PushOperationErrorWidget(
                  error: value[i],
                  onDeletePress: () async {
                    await showWaitingOverlay(
                      context,
                      future: ref.read(appDatabaseProvider).deleteBackendPushOperationError(value[i]),
                    );
                  },
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

class _PushOperationErrorWidget extends ConsumerWidget {
  final PushOperationResult error;
  final VoidCallback? onDeletePress;

  const _PushOperationErrorWidget({
    required this.error,
    this.onDeletePress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => ExpandableTile(
    title: Text('Error ${error.errorCode}'),
    children: [
      if (error.errorKind!.isPermanent)
        Text(
          'This error is permanent and the operation will not be retried.',
          style: TextStyle(
            fontSize: context.theme.typography.xs.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      Text(
        'Date : ${error.createdAt}',
        style: TextStyle(
          fontSize: context.theme.typography.xs.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        'Details :',
        style: TextStyle(
          fontSize: context.theme.typography.xs.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        error.errorDetails.toString(),
        maxLines: null,
        overflow: TextOverflow.visible,
        style: TextStyle(fontSize: context.theme.typography.xs.fontSize),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: ClickableButton(
          variant: .destructive,
          mainAxisSize: .min,
          onPress: onDeletePress,
          child: const Text('Delete'),
        ),
      ),
    ],
  );
}
