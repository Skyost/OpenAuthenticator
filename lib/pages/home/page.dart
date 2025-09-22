import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/display_copy_button.dart';
import 'package:open_authenticator/model/settings/display_search_button.dart';
import 'package:open_authenticator/model/storage/online.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/image_cache.dart';
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
import 'package:open_authenticator/utils/account.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/storage_migration.dart';
import 'package:open_authenticator/widgets/app_filled_button.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/smooth_highlight.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
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
    ref.read(totpImageCacheManagerProvider.notifier).convertLegacyCacheObjects();
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
          icon: Icons.key_off,
          text: translations.home.noCryptoStore.message,
          buttons: [
            AppFilledButton(
              onPressed: () => MasterPasswordUtils.changeMasterPassword(context, ref, askForUnlock: false),
              label: Text(translations.home.noCryptoStore.resetButton),
              icon: const Icon(Icons.password),
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
                    onRefresh: () => ref.read(totpRepositoryProvider.notifier).refresh(),
                    child: buildTotpListWidget(value),
                  )
                : buildTotpListWidget(value),
          ),
        ),
      ),
      AsyncError(:final error) =>
        error is NotLoggedInException
            ? FutureBuilder(
                future: Future.delayed(const Duration(seconds: 5), () => true),
                builder: (context, snapshot) => snapshot.data == true
                    ? ImageTextButtonsWidget.icon(
                        icon: Icons.wifi_off,
                        text: translations.home.logInFailed.message,
                        buttons: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppFilledButton(
                              onPressed: () => ref.refresh(onlineStorageProvider),
                              label: Text(translations.home.logInFailed.button.retry),
                              icon: const Icon(Icons.refresh),
                            ),
                          ),
                          AppFilledButton(
                            onPressed: () => AccountUtils.trySignIn(context, ref),
                            label: Text(translations.home.logInFailed.button.relogIn),
                            icon: const Icon(Icons.login),
                            tonal: true,
                          ),
                          AppFilledButton(
                            onPressed: () => StorageMigrationUtils.changeStorageType(
                              context,
                              ref,
                              StorageType.local,
                              ignoreCurrentStorage: true,
                            ),
                            label: Text(translations.home.logInFailed.button.changeStorageType),
                            icon: const Icon(Icons.wifi),
                            tonal: true,
                          ),
                        ],
                      )
                    : const CenteredCircularProgressIndicator(),
              )
            : ImageTextButtonsWidget.icon(
                icon: Icons.bug_report,
                text: translations.error.generic.withException(exception: error),
                buttons: [
                  AppFilledButton(
                    label: Text(translations.home.refreshButton),
                    icon: const Icon(Icons.sync),
                    onPressed: ref.read(totpRepositoryProvider.notifier).refresh,
                  ),
                ],
              ),
      _ => const CenteredCircularProgressIndicator(),
    };

    return Scaffold(
      appBar: HomePageAppBar(
        showAddButton: !RevealFloatingActionButtonWidget.hasFloatingActionButton,
        onAddButtonPressed: () => onAddButtonPressed(context),
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
      body: body,
      floatingActionButton: RevealFloatingActionButtonWidget.hasFloatingActionButton
          ? RequireProviderValueWidget.cryptoStoreAndTotpList(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: showFloatingActionButton ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: showFloatingActionButton ? 1 : 0,
                  child: FloatingActionButton(
                    child: const Icon(
                      Icons.add,
                      size: 32,
                    ),
                    onPressed: () => onAddButtonPressed(context),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Triggered when the "Add" button is pressed.
  void onAddButtonPressed(BuildContext context) async {
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
              padding: EdgeInsets.zero,
              itemScrollController: itemScrollController,
              itemCount: totps.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, position) {
                Totp totp = totps[position];
                Widget totpWidget = TotpWidget.adaptive(
                  key: ValueKey(totp.uuid),
                  totp: totp,
                  displayCode: isUnlocked,
                  onDecryptPressed: () => tryDecryptTotp(context, ref, totp),
                  onEditPressed: () => editTotp(context, ref, totp),
                  onDeletePressed: () => deleteTotp(context, ref, totp),
                  onTap: !displayCopyButton && totp.isDecrypted ? ((_) => copyCode(context, totp as DecryptedTotp)) : null,
                  onCopyPressed: displayCopyButton && totp.isDecrypted ? (() => copyCode(context, totp as DecryptedTotp)) : null,
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
              separatorBuilder: (context, position) => const Divider(),
            ),
          );
  }

  /// Allows to edit the TOTP.
  Future<void> editTotp(BuildContext context, WidgetRef ref, Totp totp) async {
    CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
    if (currentCryptoStore == null) {
      if (context.mounted) {
        SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
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
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.noTryAgain);
    }
  }

  /// Allows to copy the code to the clipboard.
  static Future<void> copyCode(BuildContext context, DecryptedTotp totp) async {
    await Clipboard.setData(ClipboardData(text: totp.generateCode()));
    if (context.mounted) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.totp.actions.copyConfirmation);
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
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.totpDecrypt);
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
      } catch (ex, stacktrace) {
        return ResultError(
          exception: ex,
          stacktrace: stacktrace,
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
          context.showSnackBarForResult(result, retryIfError: true);
        }
        break;
      case TotpDecryptDialogResult.changeAllTotpsKey:
        Result result = await showWaitingOverlay(
          context,
          future: changeTotpsKey(decryptedTotps.$1, decryptedTotps.$2),
        );
        if (context.mounted) {
          context.showSnackBarForResult(result, retryIfError: true);
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
