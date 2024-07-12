import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/storage/online.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/smooth_highlight.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/totp/widget.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// The home page.
class HomePage extends ConsumerStatefulWidget {
  /// The home page name.
  static const String name = '/';

  /// Creates a new home page instance.
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

/// The home page state.
class _HomePageState extends ConsumerState<HomePage> with BrightnessListener {
  /// Allows to scroll through the list of items.
  late final ItemScrollController itemScrollController = ItemScrollController();

  /// The TOTP to emphasis, if any.
  Totp? emphasis;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const TitleWidget(),
          actions: [
            _SearchButton(
              onTotpFound: (totp) async {
                TotpList totps = await ref.read(totpRepositoryProvider.future);
                int index = totps.indexOf(totp);
                if (index >= 0) {
                  itemScrollController.jumpTo(index: index);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => emphasis = totp);
                    }
                  });
                }
              },
            ),
            if (kDebugMode || currentPlatform != Platform.android)
              IconButton(
                onPressed: () => _onAddButtonPressed(context),
                icon: const Icon(Icons.add),
              ),
            if (currentPlatform.isDesktop)
              IconButton(
                onPressed: () => ref.read(totpRepositoryProvider.notifier).refresh(),
                icon: const Icon(Icons.sync),
              ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, SettingsPage.name),
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        floatingActionButton: currentPlatform == Platform.android || kDebugMode
            ? FloatingActionButton(
                child: const Icon(
                  Icons.add,
                  size: 32,
                ),
                onPressed: () => _onAddButtonPressed(context),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: _HomePageBody(
          itemScrollController: itemScrollController,
          emphasis: emphasis,
          onHighlightFinished: () {
            if (mounted && emphasis != null) {
              setState(() => emphasis = null);
            }
          },
        ),
      );

  /// Triggered when the "Add" button is pressed.
  void _onAddButtonPressed(BuildContext context) async {
    if (!currentPlatform.isMobile && !kDebugMode) {
      Navigator.pushNamed(context, TotpPage.name);
      return;
    }
    _AddTotpDialogResult? choice = await showDialog<_AddTotpDialogResult>(
      context: context,
      builder: (context) => _AddTotpDialog(),
    );
    if (choice == null || !context.mounted) {
      return;
    }
    Navigator.pushNamed(context, choice == _AddTotpDialogResult.qrCode ? ScanPage.name : TotpPage.name);
  }
}

/// The home page body, where all TOTPs are displayed.
class _HomePageBody extends ConsumerWidget {
  /// The item scroll controller.
  final ItemScrollController? itemScrollController;

  /// The TOTP to emphasis, if any.
  final Totp? emphasis;

  /// Triggered when the highlight has been finished.
  /// Should clear the [emphasis].
  final VoidCallback? onHighlightFinished;

  /// Creates a new home page body instance.
  const _HomePageBody({
    this.itemScrollController,
    this.emphasis,
    this.onHighlightFinished,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<TotpList> totps = ref.watch(totpRepositoryProvider);
    AsyncValue<bool> isUnlocked = ref.watch(appUnlockStateProvider);
    switch (totps) {
      case AsyncData(:final value):
        Widget child = value.isEmpty
            ? CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          translations.home.empty,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ScrollablePositionedList.separated(
                padding: EdgeInsets.zero,
                itemScrollController: itemScrollController,
                itemCount: value.length,
                itemBuilder: (context, position) {
                  Totp totp = value[position];
                  Widget totpWidget = TotpWidget.adaptive(
                    key: ValueKey(value[position].uuid),
                    totp: totp,
                    displayCode: isUnlocked.valueOrNull ?? false,
                    onDecryptPressed: () => _tryDecryptTotp(context, ref, totp),
                    onEditPressed: () => _editTotp(context, ref, totp),
                    onDeletePressed: () => _deleteTotp(context, ref, totp),
                    onCopyPressed: totp.isDecrypted ? (() => _copyCode(context, totp as DecryptedTotp)) : null,
                  );
                  return totp == emphasis
                      ? SmoothHighlight(
                          color: Theme.of(context).focusColor,
                          useInitialHighLight: true,
                          child: totpWidget,
                        )
                      : totpWidget;
                },
                separatorBuilder: (context, position) => const Divider(),
              );
        return currentPlatform.isMobile
            ? RefreshIndicator(
                onRefresh: ref.read(totpRepositoryProvider.notifier).refresh,
                child: child,
              )
            : child;
      case AsyncError(:final error):
        return error is NotLoggedInException
            ? const CenteredCircularProgressIndicator()
            : Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        translations.error.generic.withException(exception: error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: ref.read(totpRepositoryProvider.notifier).refresh,
                      label: Text(translations.home.refreshButton),
                      icon: const Icon(Icons.sync),
                    ),
                  ],
                ),
              );
      default:
        return const CenteredCircularProgressIndicator();
    }
  }

  /// Allows to edit the TOTP.
  Future<void> _editTotp(BuildContext context, WidgetRef ref, Totp totp) async {
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
  Future<void> _deleteTotp(BuildContext context, WidgetRef ref, Totp totp) async {
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
  Future<void> _copyCode(BuildContext context, DecryptedTotp totp) async {
    await Clipboard.setData(ClipboardData(text: totp.generateCode()));
    if (context.mounted) {
      SnackBarIcon.showSuccessSnackBar(context, text: translations.totp.actions.copyConfirmation);
    }
  }

  /// Tries to decrypt the current TOTP.
  Future<void> _tryDecryptTotp(BuildContext context, WidgetRef ref, Totp totp) async {
    String? password = await TextInputDialog.prompt(
      context,
      title: translations.totp.decryptDialog.title,
      message: translations.totp.decryptDialog.message,
      password: true,
    );
    if (password == null || !context.mounted) {
      return;
    }

    late CryptoStore previousCryptoStore;
    TotpRepository repository = ref.read(totpRepositoryProvider.notifier);
    Totp decrypted = await showWaitingOverlay(
      context,
      future: () async {
        previousCryptoStore = await CryptoStore.fromPassword(password, totp.encryptedData.encryptionSalt);
        return await totp.decrypt(previousCryptoStore);
      }(),
    );
    if (!context.mounted) {
      return;
    }
    if (!decrypted.isDecrypted) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.error.totpDecrypt);
      return;
    }

    _TotpKeyDialogResult? choice = await showDialog<_TotpKeyDialogResult>(
      context: context,
      builder: (context) => _TotpKeyDialog(),
    );

    switch (choice) {
      case _TotpKeyDialogResult.changeTotpKey:
        CryptoStore? currentCryptoStore = await ref.read(cryptoStoreProvider.future);
        if (currentCryptoStore == null) {
          if (context.mounted) {
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
          }
          break;
        }
        DecryptedTotp? decryptedTotpWithNewKey = await totp.changeEncryptionKey(previousCryptoStore, currentCryptoStore);
        if (decryptedTotpWithNewKey == null || !decryptedTotpWithNewKey.isDecrypted) {
          if (context.mounted) {
            SnackBarIcon.showErrorSnackBar(context, text: translations.error.generic.tryAgain);
          }
          break;
        }
        await repository.updateTotp(totp.uuid, decryptedTotpWithNewKey);
        break;
      case _TotpKeyDialogResult.changeMasterPassword:
        if (context.mounted) {
          await MasterPasswordUtils.changeMasterPassword(context, ref, password: password);
        }
        break;
      default:
        break;
    }
    await repository.tryDecryptAll(previousCryptoStore);
  }
}

/// Displays a search button if the TOTP list is available.
class _SearchButton extends ConsumerWidget {
  /// Triggered when a TOTP has been found by the user.
  final Function(Totp totp) onTotpFound;

  /// Creates a new search button instance.
  const _SearchButton({
    required this.onTotpFound,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<TotpList> totps = ref.watch(totpRepositoryProvider);
    return switch (totps) {
      AsyncData<TotpList>(:final value) => value.isEmpty
          ? const SizedBox.shrink()
          : IconButton(
              onPressed: () async {
                Totp? result = await showSearch(
                  context: context,
                  delegate: _TotpSearchDelegate(
                    totpList: value,
                  ),
                );
                if (result != null) {
                  onTotpFound(result);
                }
              },
              icon: const Icon(Icons.search),
            ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// Allows to search through the TOTP list.
class _TotpSearchDelegate extends SearchDelegate<Totp> {
  /// The TOTP list.
  final TotpList totpList;

  /// Creates a new TOTP search delegate instance.
  _TotpSearchDelegate({
    required this.totpList,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    ThemeData theme = super.appBarTheme(context);
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: theme.inputDecorationTheme,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => const BackButton();

  @override
  Widget buildResults(BuildContext context) {
    String lowercaseQuery = query.toLowerCase();
    List<Totp> searchResults = [];
    for (Totp totp in totpList) {
      if (!totp.isDecrypted) {
        if (totp.uuid.contains(lowercaseQuery)) {
          searchResults.add(totp);
        }
        continue;
      }
      DecryptedTotp decryptedTotp = totp as DecryptedTotp;
      if ((decryptedTotp.label != null && decryptedTotp.label!.contains(lowercaseQuery)) || (decryptedTotp.issuer != null && decryptedTotp.issuer!.contains(lowercaseQuery))) {
        searchResults.add(decryptedTotp);
      }
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        Totp totp = searchResults[index];
        return TotpWidget(
          totp: totp,
          onTap: (context) => close(context, totp),
        );
      },
      separatorBuilder: (context, position) => const Divider(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}

/// A dialog that allows to choose a method to add a TOTP.
class _AddTotpDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(translations.home.addDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              onTap: () => Navigator.pop(context, _AddTotpDialogResult.qrCode),
              title: Text(translations.home.addDialog.qrCode.title),
              subtitle: Text(translations.home.addDialog.qrCode.subtitle),
            ),
            ListTile(
              leading: const Icon(Icons.short_text),
              onTap: () => Navigator.pop(context, _AddTotpDialogResult.manually),
              title: Text(translations.home.addDialog.manually.title),
              subtitle: Text(translations.home.addDialog.manually.subtitle),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );
}

/// The [_AddTotpDialog] result.
enum _AddTotpDialogResult {
  /// When the user wants to use a QR code to add a TOTP.
  qrCode,

  /// When the user wants to manually add the TOTP.
  manually;
}

/// Allows the user to choose an action to execute when a TOTP decryption has been done with success.
class _TotpKeyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(translations.totp.totpKeyDialog.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translations.totp.totpKeyDialog.message,
            ),
            ListTile(
              leading: const Icon(Icons.key),
              onTap: () => Navigator.pop(context, _TotpKeyDialogResult.changeTotpKey),
              title: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.title),
              subtitle: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.subtitle),
            ),
            ListTile(
              leading: const Icon(Icons.password),
              onTap: () => Navigator.pop(context, _TotpKeyDialogResult.changeMasterPassword),
              title: Text(translations.totp.totpKeyDialog.choices.changeMasterPassword.title),
              subtitle: Text(translations.totp.totpKeyDialog.choices.changeMasterPassword.subtitle),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              onTap: () => Navigator.pop(context),
              title: Text(translations.totp.totpKeyDialog.choices.doNothing.title),
              subtitle: Text(translations.totp.totpKeyDialog.choices.doNothing.subtitle),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );
}

/// The [_TotpKeyDialog] result.
enum _TotpKeyDialogResult {
  /// Allows to change the TOTP key.
  changeTotpKey,

  /// Allows to change the current master password.
  changeMasterPassword;
}
