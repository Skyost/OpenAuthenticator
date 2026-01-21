import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/backend/synchronization/queue.dart';
import 'package:open_authenticator/model/settings/display_copy_button.dart';
import 'package:open_authenticator/model/settings/display_search_button.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/app_bar.dart';
import 'package:open_authenticator/pages/home/dialogs/add_totp.dart';
import 'package:open_authenticator/pages/home/list/refresh_indicator.dart';
import 'package:open_authenticator/pages/home/list/totps.dart';
import 'package:open_authenticator/pages/home/scroll/fab.dart';
import 'package:open_authenticator/pages/home/scroll/search_box.dart';
import 'package:open_authenticator/pages/home/utils/image_text_buttons.dart';
import 'package:open_authenticator/pages/home/utils/require_provider_value.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/app_scaffold.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/error.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// The home page.
class HomePage extends ConsumerStatefulWidget {
  /// The home page name.
  static const String name = Navigator.defaultRouteName;

  /// Creates a new home page instance.
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

/// The home page state.
class _HomePageState extends ConsumerState<HomePage> {
  /// Allows to scroll through the list of items.
  late final ItemScrollController itemScrollController = ItemScrollController();

  /// Whether to display the floating action button.
  bool showFloatingActionButton = RevealFloatingActionButtonWidget.hasFloatingActionButton;

  /// Whether to display the search box.
  bool showSearchBox = false;

  /// The TOTP to emphasis, if any.
  int? emphasisIndex;

  @override
  void initState() {
    super.initState();
    ref.listenManual(displaySearchButtonSettingsEntryProvider, (previous, next) {
      if (next.value == true && showSearchBox && mounted) {
        setState(() => showSearchBox = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<TotpList> totps = ref.watch(totpRepositoryProvider);
    bool displaySearchButton = ref.read(displaySearchButtonSettingsEntryProvider).value ?? true;
    Widget body = switch (totps) {
      AsyncData(:final value) => RequireProviderValueWidget.cryptoStore(
        childIfAbsent: ImageTextButtonsWidget.icon(
          icon: FIcons.lock,
          text: translations.home.noCryptoStore.message,
          buttons: [
            ClickableButton(
              onPress: () => MasterPasswordUtils.changeMasterPassword(context, ref, askForUnlock: false),
              prefix: const Icon(FIcons.rectangleEllipsis),
              child: Text(translations.home.noCryptoStore.resetButton),
            ),
          ],
        ),
        child: RevealFloatingActionButtonWidget(
          onHideFloatingActionButton: () {
            if (showFloatingActionButton) {
              setState(() => showFloatingActionButton = false);
            }
          },
          onShowFloatingActionButton: () {
            if (!showFloatingActionButton) {
              setState(() => showFloatingActionButton = true);
            }
          },
          child: RevealSearchBoxWidget(
            onHideSearchBox: () {
              if (showSearchBox) {
                setState(() => showSearchBox = false);
              }
            },
            onShowSearchBox: () {
              if (!showSearchBox) {
                setState(() => showSearchBox = true);
              }
            },
            child: (displaySearchButton || (!displaySearchButton && showSearchBox)) && (currentPlatform.isMobile || kDebugMode)
                ? TotpsRefreshIndicatorWidget(
                    onRefresh: () => ref.read(synchronizationControllerProvider.notifier).forceSync(),
                    child: buildTotpsListWidget(value),
                  )
                : buildTotpsListWidget(value),
          ),
        ),
      ),
      AsyncError(:final error, :final stackTrace) => ErrorDisplayWidget(
        error: error,
        stackTrace: stackTrace,
        onRetryPressed: () => ref.read(synchronizationControllerProvider.notifier).forceSync(),
      ),
      _ => const CenteredCircularProgressIndicator(),
    };

    return AppScaffold(
      header: HomePageHeader(
        showAddButton: !RevealFloatingActionButtonWidget.hasFloatingActionButton,
        onAddButtonPress: () => onAddButtonPress(context),
        onTotpSelectedFollowingSearch: (index) async {
          itemScrollController.jumpTo(index: index);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                showSearchBox = false;
                emphasisIndex = index;
              });
            }
          });
          if (!(await ref.read(displayCopyButtonSettingsEntryProvider.future))) {
            Totp? totp = totps.value?[index];
            if (context.mounted && totp?.isDecrypted == true) {
              TotpsListWidget.copyCode(context, totp as DecryptedTotp);
            }
          }
        },
        showSearchBox: showSearchBox,
      ),
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            body,
            if (RevealFloatingActionButtonWidget.hasFloatingActionButton)
              RequireProviderValueWidget.cryptoStoreAndTotpList(
                child: FloatingAddButton(
                  showFloatingActionButton: showFloatingActionButton,
                  onAddButtonPress: onAddButtonPress,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Triggered when the "Add" button is pressed.
  void onAddButtonPress(BuildContext context) async {
    if (!kDebugMode && !AddTotpDialog.isSupported) {
      Navigator.pushNamed(context, TotpPage.name);
      return;
    }
    AddTotpDialogResult? choice = await AddTotpDialog.show(context);
    if (choice == null || !context.mounted) {
      return;
    }
    Navigator.pushNamed(context, choice == AddTotpDialogResult.qrCode ? ScanPage.name : TotpPage.name);
  }

  /// Builds the TOTPs list widget.
  Widget buildTotpsListWidget(TotpList value) => TotpsListWidget(
    totps: value,
    itemScrollController: itemScrollController,
    emphasisIndex: emphasisIndex,
    onHighlightFinished: () {
      if (mounted && emphasisIndex != null) {
        setState(() => emphasisIndex = null);
      }
    },
  );
}
