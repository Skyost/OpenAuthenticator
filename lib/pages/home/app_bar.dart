import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/model/backend/synchronization/queue.dart';
import 'package:open_authenticator/model/settings/display_search_button.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/action.dart';
import 'package:open_authenticator/pages/home/search/box.dart';
import 'package:open_authenticator/pages/home/utils/require_provider_value.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/title.dart';

/// The app bar for the home page.
class HomePageHeader extends ConsumerWidget {
  /// Whether to show the add button.
  final bool showAddButton;

  /// Triggered when the add button is pressed.
  final VoidCallback? onAddButtonPress;

  /// Triggered when a TOTP is selected following a search.
  final Function(int index)? onTotpSelectedFollowingSearch;

  /// Whether to show the search box.
  final bool showSearchBox;

  /// Creates a new app bar instance.
  const HomePageHeader({
    super.key,
    this.showAddButton = false,
    this.onAddButtonPress,
    this.onTotpSelectedFollowingSearch,
    this.showSearchBox = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget header = FHeader.nested(
      title: const _AppBarTitle(),
      prefixes: [
        RequireProviderValueWidget.cryptoStoreAndTotpList(
          child: ClickableHeaderAction(
            onPress: () => Navigator.pushNamed(context, SettingsPage.name),
            icon: const Icon(FIcons.settings),
          ),
        ),
      ],
      suffixes: [
        if (ref.watch(displaySearchButtonSettingsEntryProvider).value ?? true)
          RequireProviderValueWidget.cryptoStoreAndTotpList(
            child: Builder(
              builder: (context) => SearchAction(
                onTotpFound: (totp) => onTotpFound(ref, totp),
              ),
            ),
          ),
        if (showAddButton)
          RequireProviderValueWidget.cryptoStoreAndTotpList(
            child: ClickableHeaderAction(
              onPress: onAddButtonPress,
              icon: const Icon(FIcons.plus),
            ),
          ),
        if (currentPlatform.isDesktop)
          RequireProviderValueWidget.cryptoStoreAndTotpList(
            child: ClickableHeaderAction(
              onPress: () => ref.read(synchronizationControllerProvider.notifier).forceSync(),
              icon: const Icon(FIcons.refreshCcw),
            ),
          ),
      ],
    );
    return showSearchBox ? SearchBox(header: header) : header;
  }

  Future<void> onTotpFound(WidgetRef ref, Totp totp) async {
    TotpList totps = await ref.read(totpRepositoryProvider.future);
    int index = totps.indexOf(totp);
    if (index >= 0) {
      onTotpSelectedFollowingSearch?.call(index);
    }
  }
}

/// The app bar title.
class _AppBarTitle extends StatelessWidget {
  /// The text max width.
  /// Above this value, the app logo will be displayed.
  final double? textMaxWidth;

  /// Creates a new app bar title instance.
  const _AppBarTitle({
    this.textMaxWidth = 210,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (textMaxWidth != null && constraints.maxWidth <= textMaxWidth!) {
        double size = context.theme.typography.xl3.fontSize ?? 32;
        return SizedScalableImageWidget(
          height: size,
          width: size,
          asset: 'assets/images/logo.si',
        );
      }
      return const TitleWidget();
    },
  );
}
