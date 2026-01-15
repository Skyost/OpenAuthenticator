import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/app_unlock/methods/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/backend/synchronization/queue.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/display_copy_button.dart';
import 'package:open_authenticator/model/settings/display_search_button.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/app_bar.dart';
import 'package:open_authenticator/pages/home/dialogs/add_totp.dart';
import 'package:open_authenticator/pages/home/dialogs/totp_decrypt.dart';
import 'package:open_authenticator/pages/home/scroll/fab.dart';
import 'package:open_authenticator/pages/home/scroll/search_box.dart';
import 'package:open_authenticator/pages/home/utils/image_text_buttons.dart';
import 'package:open_authenticator/pages/home/utils/require_provider_value.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/widgets/app_scaffold.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/clickable.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/error.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/smooth_highlight.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/toast.dart';
import 'package:open_authenticator/widgets/totp/widget.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
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
                ? RefreshIndicator(
                    onRefresh: () => ref.read(synchronizationControllerProvider.notifier).forceSync(),
                    child: buildTotpListWidget(value),
                  )
                : buildTotpListWidget(value),
          ),
        ),
      ),
      AsyncError(:final error) => ImageTextButtonsWidget.icon(
        icon: FIcons.bug,
        text: translations.error.generic.withException(exception: error),
        buttons: [
          ClickableButton(
            prefix: const Icon(FIcons.refreshCcw),
            onPress: () => ref.read(synchronizationControllerProvider.notifier).forceSync(),
            child: Text(translations.home.refreshButton),
          ),
        ],
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
              _TotpListWidget.copyCode(context, totp as DecryptedTotp);
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
                child: _FloatingAddButton(
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
  Widget buildTotpListWidget(TotpList value) => _TotpListWidget(
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

/// The floating add button widget.
class _FloatingAddButton extends StatelessWidget {
  /// Whether to display the floating action button.
  final bool showFloatingActionButton;

  /// Triggered when the "Add" button is pressed.
  final Function(BuildContext) onAddButtonPress;

  /// Creates a new floating add button instance.
  const _FloatingAddButton({
    super.key,
    required this.showFloatingActionButton,
    required this.onAddButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration createGradient(double darken) => BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: context.theme.style.shadow,
      gradient: LinearGradient(
        begin: const Alignment(-1, -1),
        end: const Alignment(0.8, 0.8),
        colors: [
          for (Color color in AppTitleGradient.gradient.colors) color.darken(amount: darken),
        ],
        stops: AppTitleGradient.gradient.stops,
      ),
    );
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: showFloatingActionButton ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: showFloatingActionButton ? 1 : 0,
        child: Padding(
          padding: context.theme.style.pagePadding,
          child: ClickableButton(
            style: (style) => style.copyWith(
              decoration: FWidgetStateMap({
                WidgetState.hovered: createGradient(0.05),
                WidgetState.any: createGradient(0),
              }),
            ),
            mainAxisSize: .min,
            child: const Icon(
              FIcons.plus,
              size: 40,
            ),
            onPress: () => onAddButtonPress(context),
          ),
        ),
      ),
    );
  }
}

/// Allows to display the TOTPs list.
class _TotpListWidget extends ConsumerWidget {
  /// The TOTPs list.
  final TotpList totps;

  /// The item scroll controller.
  final ItemScrollController? itemScrollController;

  /// The TOTP to emphasis, if any.
  final int? emphasisIndex;

  /// Triggered when the highlight has been finished.
  /// Should clear the [emphasis].
  final VoidCallback? onHighlightFinished;

  /// Creates a new TOTPs list widget instance.
  const _TotpListWidget({
    super.key,
    required this.totps,
    this.itemScrollController,
    this.emphasisIndex,
    this.onHighlightFinished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isUnlocked = ref.watch(appLockStateProvider.select((state) => state.value == AppLockState.unlocked));
    bool displayCopyButton = ref.watch(displayCopyButtonSettingsEntryProvider).value ?? true;
    return totps.isEmpty
        ? ImageTextButtonsWidget.asset(
            asset: 'assets/images/home.si',
            text: translations.home.empty,
          )
        : ScrollConfiguration(
            behavior: _ScrollBehavior(),
            child: ScrollablePositionedList.separated(
              padding: context.theme.style.pagePadding,
              itemScrollController: itemScrollController,
              itemCount: totps.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, position) {
                Totp totp = totps[position];
                Widget totpWidget = TotpWidget.adaptive(
                  key: ValueKey(totp.uuid),
                  totp: totp,
                  displayCode: isUnlocked,
                  onDecryptPress: () => tryDecryptTotp(context, ref, totp),
                  onEditPress: () => editTotp(context, ref, totp),
                  onDeletePress: () => deleteTotp(context, ref, totp),
                  onTap: (!displayCopyButton || currentPlatform.isDesktop) && totp.isDecrypted ? ((_) => copyCode(context, totp as DecryptedTotp)) : null,
                  onCopyPress: (displayCopyButton && !currentPlatform.isDesktop) && totp.isDecrypted ? (() => copyCode(context, totp as DecryptedTotp)) : null,
                );
                return position == emphasisIndex
                    ? SmoothHighlight(
                        color: Theme.of(context).focusColor,
                        useInitialHighLight: true,
                        onHighlightFinished: onHighlightFinished,
                        child: totpWidget,
                      )
                    : totpWidget;
              },
              separatorBuilder: (context, position) => const SizedBox(height: kBigSpace),
            ),
          );
  }

  /// Allows to edit the TOTP.
  Future<void> editTotp(BuildContext context, WidgetRef ref, Totp totp) async {
    CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
    if (currentCryptoStore == null) {
      if (context.mounted) {
        ErrorDialog.openDialog(context);
      }
      return;
    }
    if (!(await totp.encryptedData.canDecryptData(currentCryptoStore))) {
      if (context.mounted) {
        bool shouldContinue = await ConfirmationDialog.ask(
          context,
          title: translations.totp.actions.editConfirmationDialog.title,
          message: translations.totp.actions.editConfirmationDialog.message,
        );
        if (!shouldContinue) {
          return;
        }
      }
    }
    if (context.mounted) {
      await Navigator.pushNamed(
        context,
        TotpPage.name,
        arguments: {
          OpenAuthenticatorApp.kRouteParameterTotp: totp,
        },
      );
    }
  }

  /// Allows to delete the TOTP.
  Future<void> deleteTotp(BuildContext context, WidgetRef ref, Totp totp) async {
    bool confirmation = await ConfirmationDialog.ask(
      context,
      title: translations.totp.actions.deleteConfirmationDialog.title,
      message: translations.totp.actions.deleteConfirmationDialog.message,
    );
    if (!confirmation || !context.mounted) {
      return;
    }
    Result result = await showWaitingOverlay(
      context,
      future: ref.read(totpRepositoryProvider.notifier).deleteTotp(totp.uuid),
    );
    if (result is ResultError && context.mounted) {
      ErrorDialog.openDialog(context, error: result.exception, stackTrace: result.stackTrace);
    }
  }

  /// Allows to copy the code to the clipboard.
  static Future<void> copyCode(BuildContext context, DecryptedTotp totp) async {
    await Clipboard.setData(ClipboardData(text: totp.generateCode()));
    if (context.mounted) {
      showSuccessToast(context, text: translations.totp.actions.copyConfirmation);
    }
  }

  /// Tries to decrypt the current TOTP.
  Future<void> tryDecryptTotp(BuildContext context, WidgetRef ref, Totp totp) async {
    String? password = await TextInputDialog.prompt(
      context,
      title: translations.totp.decryptDialog.title,
      message: translations.totp.decryptDialog.message,
      password: true,
    );
    if (password == null || !context.mounted) {
      return;
    }

    TotpRepository repository = ref.read(totpRepositoryProvider.notifier);
    (CryptoStore, List<DecryptedTotp>) decryptedTotps = await showWaitingOverlay(
      context,
      future: () async {
        CryptoStore previousCryptoStore = await CryptoStore.fromPassword(password, totp.encryptedData.encryptionSalt);
        Totp targetTotp = await totp.decrypt(previousCryptoStore);
        if (!targetTotp.isDecrypted) {
          return (previousCryptoStore, <DecryptedTotp>[]);
        }
        Set<DecryptedTotp> decryptedTotps = await repository.tryDecryptAll(previousCryptoStore);
        return (
          previousCryptoStore,
          [
            targetTotp as DecryptedTotp,
            for (DecryptedTotp decryptedTotp in decryptedTotps)
              if (targetTotp.uuid != decryptedTotp.uuid) decryptedTotp,
          ],
        );
      }(),
    );
    if (!context.mounted) {
      return;
    }
    if (decryptedTotps.$2.isEmpty) {
      ErrorDialog.openDialog(
        context,
        message: translations.error.totpDecrypt,
      );
      return;
    }

    TotpDecryptDialogResult? choice = await TotpDecryptDialog.show(
      context,
      decryptedTotps: decryptedTotps.$2,
    );

    if (!context.mounted) {
      return;
    }

    Future<Result> changeTotpsKey(CryptoStore oldCryptoStore, List<DecryptedTotp> totps) async {
      try {
        CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
        if (currentCryptoStore == null) {
          throw Exception('Unable to get current crypto store.');
        }
        List<DecryptedTotp> toUpdate = [];
        for (DecryptedTotp totp in totps) {
          DecryptedTotp? decryptedTotpWithNewKey = await totp.changeEncryptionKey(oldCryptoStore, currentCryptoStore);
          if (decryptedTotpWithNewKey == null || !decryptedTotpWithNewKey.isDecrypted) {
            throw Exception('Failed to encrypt TOTP with current crypto store.');
          }
          toUpdate.add(decryptedTotpWithNewKey);
        }
        return await repository.updateTotps(toUpdate);
      } catch (ex, stackTrace) {
        return ResultError(
          exception: ex,
          stackTrace: stackTrace,
        );
      }
    }

    switch (choice) {
      case TotpDecryptDialogResult.changeTotpKey:
        Result result = await showWaitingOverlay(
          context,
          future: changeTotpsKey(decryptedTotps.$1, [decryptedTotps.$2.first]),
        );
        if (context.mounted) {
          context.handleResult(result, retryIfError: true);
        }
        break;
      case TotpDecryptDialogResult.changeAllTotpsKey:
        Result result = await showWaitingOverlay(
          context,
          future: changeTotpsKey(decryptedTotps.$1, decryptedTotps.$2),
        );
        if (context.mounted) {
          context.handleResult(result, retryIfError: true);
        }
        break;
      case TotpDecryptDialogResult.changeMasterPassword:
        await MasterPasswordUtils.changeMasterPassword(context, ref, password: password);
        break;
      default:
        break;
    }
  }
}

/// Allows to display a refresh indicator on desktop platforms as well.
class _ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => kDebugMode
      ? {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }
      : super.dragDevices;
}
