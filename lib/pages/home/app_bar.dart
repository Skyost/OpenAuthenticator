import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/settings/display_search_button.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/box.dart';
import 'package:open_authenticator/pages/home/search/button.dart';
import 'package:open_authenticator/pages/home/utils/require_provider_value.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/title.dart';

/// The app bar for the home page.
class HomePageAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// Whether to show the add button.
  final bool showAddButton;

  /// Triggered when the add button is pressed.
  final VoidCallback? onAddButtonPressed;

  /// Triggered when a TOTP is selected following a search.
  final Function(int index)? onTotpSelectedFollowingSearch;

  /// Whether to show the search box.
  final bool showSearchBox;

  /// Creates a new app bar instance.
  const HomePageAppBar({
    super.key,
    this.showAddButton = false,
    this.onAddButtonPressed,
    this.onTotpSelectedFollowingSearch,
    this.showSearchBox = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppBar(
    toolbarHeight: preferredSize.height,
    title: const _AppBarTitle(),
    bottom: showSearchBox
        ? SearchBoxWidget(
            onTotpFound: (totp) => onTotpFound(ref, totp),
          )
        : null,
    actions: [
      if (ref.watch(displaySearchButtonSettingsEntryProvider).value ?? true)
        RequireProviderValueWidget.cryptoStoreAndTotpList(
          child: Builder(
            builder: (context) => SearchButton(
              onTotpFound: (totp) => onTotpFound(ref, totp),
            ),
          ),
        ),
      if (showAddButton)
        RequireProviderValueWidget.cryptoStoreAndTotpList(
          child: IconButton(
            onPressed: onAddButtonPressed,
            icon: const Icon(Icons.add),
          ),
        ),
      if (currentPlatform.isDesktop)
        RequireProviderValueWidget.cryptoStoreAndTotpList(
          child: IconButton(
            onPressed: () => ref.read(totpRepositoryProvider.notifier).refresh(),
            icon: const Icon(Icons.sync),
          ),
        ),
      RequireProviderValueWidget.cryptoStoreAndTotpList(
        child: IconButton(
          onPressed: () => Navigator.pushNamed(context, SettingsPage.name),
          icon: const Icon(Icons.settings),
        ),
      ),
    ],
  );

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showSearchBox ? 48 : 0));

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
        double size = Theme.of(context).textTheme.titleLarge?.fontSize ?? 32;
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
