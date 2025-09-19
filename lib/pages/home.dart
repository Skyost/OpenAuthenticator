import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/app_unlock/method.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/display_copy_button.dart';
import 'package:open_authenticator/model/storage/online.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/image_cache.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/master_password.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/widgets/app_filled_button.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/app_dialog.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/text_input_dialog.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/smooth_highlight.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/title.dart';
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
class _HomePageState extends ConsumerState<HomePage> with BrightnessListener {
  /// Whether to display the floating action button initially.
  static bool initiallyShowFloatingActionButton = currentPlatform == Platform.android || kDebugMode;

  /// Allows to scroll through the list of items.
  late final ItemScrollController itemScrollController = ItemScrollController();

  /// Whether to display the floating action button.
  bool showFloatingActionButton = initiallyShowFloatingActionButton;

  /// The TOTP to emphasis, if any.
  Totp? emphasis;

  @override
  void initState() {
    super.initState();
    ref.read(totpImageCacheManagerProvider.notifier).convertLegacyCacheObjects();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _HomePageBody(
      itemScrollController: itemScrollController,
      emphasis: emphasis,
      onHighlightFinished: () {
        if (mounted && emphasis != null) {
          setState(() => emphasis = null);
        }
      },
    );
    if (initiallyShowFloatingActionButton) {
      body = NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          ScrollDirection direction = notification.direction;
          if (direction == ScrollDirection.reverse) {
            setState(() => showFloatingActionButton = false);
          } else if (direction == ScrollDirection.forward) {
            setState(() => showFloatingActionButton = true);
          }
          return true;
        },
        child: body,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const _AppBarTitle(),
        actions: [
          _RequireCryptoStore(
            child: Builder(
              builder: (context) => _SearchButton(
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
                  if (!(await ref.read(displayCopyButtonSettingsEntryProvider.future)) && totp.isDecrypted && context.mounted) {
                    _HomePageBody.copyCode(context, totp as DecryptedTotp);
                  }
                },
              ),
            ),
          ),
          if (!initiallyShowFloatingActionButton || kDebugMode)
            _RequireCryptoStore(
              child: IconButton(
                onPressed: () => onAddButtonPressed(context),
                icon: const Icon(Icons.add),
              ),
            ),
          if (currentPlatform.isDesktop)
            _RequireCryptoStore(
              child: IconButton(
                onPressed: () => ref.read(totpRepositoryProvider.notifier).refresh(),
                icon: const Icon(Icons.sync),
              ),
            ),
          _RequireCryptoStore(
            child: IconButton(
              onPressed: () => Navigator.pushNamed(context, SettingsPage.name),
              icon: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
      floatingActionButton: initiallyShowFloatingActionButton
          ? _RequireCryptoStore(
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
      body: body,
    );
  }

  /// Triggered when the "Add" button is pressed.
  void onAddButtonPressed(BuildContext context) async {
    if (!kDebugMode && !_AddTotpDialog.isSupported) {
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

/// Allows to require a crypto store.
class _RequireCryptoStore extends ConsumerWidget {
  /// The child to show if the crypto store is non null.
  final Widget child;

  /// The child to show if the crypto store is null.
  final Widget childIfAbsent;

  /// Whether to display the child if the app is locked.
  final bool showChildIfLocked;

  /// Creates a new require crypto store widget instance.
  const _RequireCryptoStore({
    required this.child,
    this.childIfAbsent = const SizedBox.shrink(),
    this.showChildIfLocked = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showChildIfLocked) {
      bool isUnlocked = ref.watch(appLockStateProvider).value == AppLockState.unlocked;
      if (!isUnlocked) {
        return child;
      }
    }
    CryptoStore? cryptoStore = ref.watch(cryptoStoreProvider).value;
    return cryptoStore == null ? childIfAbsent : child;
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
    switch (totps) {
      case AsyncData(:final value):
        bool isUnlocked = ref.watch(appLockStateProvider.select((state) => state.value == AppLockState.unlocked));
        bool displayCopyButton = ref.watch(displayCopyButtonSettingsEntryProvider).value ?? true;
        Widget child = value.isEmpty
            ? CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: SizedScalableImageWidget(
                                height: 80,
                                asset: 'assets/images/home.si',
                              ),
                            ),
                            Text(
                              translations.home.empty,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                    displayCode: isUnlocked,
                    onDecryptPressed: () => tryDecryptTotp(context, ref, totp),
                    onEditPressed: () => editTotp(context, ref, totp),
                    onDeletePressed: () => deleteTotp(context, ref, totp),
                    onTap: !displayCopyButton && totp.isDecrypted ? ((_) => copyCode(context, totp as DecryptedTotp)) : null,
                    onCopyPressed: displayCopyButton && totp.isDecrypted ? (() => copyCode(context, totp as DecryptedTotp)) : null,
                  );
                  return totp == emphasis
                      ? SmoothHighlight(
                          color: Theme.of(context).focusColor,
                          useInitialHighLight: true,
                          onHighlightFinished: onHighlightFinished,
                          child: totpWidget,
                        )
                      : totpWidget;
                },
                separatorBuilder: (context, position) => const Divider(),
              );
        return _RequireCryptoStore(
          childIfAbsent: createErrorWidget(
            context,
            ref,
            message: translations.home.noCryptoStore.message,
            buttonLabel: translations.home.noCryptoStore.resetButton,
            buttonIcon: Icons.key,
            onButtonPressed: () => MasterPasswordUtils.changeMasterPassword(context, ref, askForUnlock: false),
          ),
          child: currentPlatform.isMobile
              ? RefreshIndicator(
                  onRefresh: ref.read(totpRepositoryProvider.notifier).refresh,
                  child: child,
                )
              : child,
        );
      case AsyncError(:final error):
        return error is NotLoggedInException
            ? const CenteredCircularProgressIndicator()
            : createErrorWidget(
                context,
                ref,
                message: translations.error.generic.withException(exception: error),
                buttonLabel: translations.home.refreshButton,
                buttonIcon: Icons.sync,
                onButtonPressed: ref.read(totpRepositoryProvider.notifier).refresh,
              );
      default:
        return const CenteredCircularProgressIndicator();
    }
  }

  /// Creates an error widget.
  Widget createErrorWidget(
    BuildContext context,
    WidgetRef ref, {
    String? message,
    String? buttonLabel,
    IconData? buttonIcon,
    VoidCallback? onButtonPressed,
  }) => Center(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: buttonLabel == null ? 0 : 20),
          child: Text(
            message ?? translations.error.generic.noTryAgain,
            textAlign: TextAlign.center,
          ),
        ),
        if (buttonLabel != null)
          Center(
            child: AppFilledButton(
              onPressed: onButtonPressed,
              label: Text(buttonLabel),
              icon: buttonIcon == null ? null : Icon(buttonIcon),
            ),
          ),
      ],
    ),
  );

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

    _TotpKeyDialogResult? choice = await showDialog<_TotpKeyDialogResult>(
      context: context,
      builder: (context) => _TotpKeyDialog(
        decryptedTotps: decryptedTotps.$2,
      ),
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
      case _TotpKeyDialogResult.changeTotpKey:
        Result result = await showWaitingOverlay(
          context,
          future: changeTotpsKey(decryptedTotps.$1, [decryptedTotps.$2.first]),
        );
        if (context.mounted) {
          context.showSnackBarForResult(result, retryIfError: true);
        }
        break;
      case _TotpKeyDialogResult.changeAllTotpsKey:
        Result result = await showWaitingOverlay(
          context,
          future: changeTotpsKey(decryptedTotps.$1, decryptedTotps.$2),
        );
        if (context.mounted) {
          context.showSnackBarForResult(result, retryIfError: true);
        }
        break;
      case _TotpKeyDialogResult.changeMasterPassword:
        await MasterPasswordUtils.changeMasterPassword(context, ref, password: password);
        break;
      default:
        break;
    }
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
      AsyncData<TotpList>(:final value) =>
        value.isEmpty
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
          key: ValueKey(totp.uuid),
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
  /// Whether this dialog is supported on the current platform.
  static final bool isSupported = currentPlatform.isMobile;

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(translations.home.addDialog.title),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
    ],
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
  );
}

/// The [_AddTotpDialog] result.
enum _AddTotpDialogResult {
  /// When the user wants to use a QR code to add a TOTP.
  qrCode,

  /// When the user wants to manually add the TOTP.
  manually,
}

/// Allows the user to choose an action to execute when a TOTP decryption has been done with success.
class _TotpKeyDialog extends StatelessWidget {
  /// Contains all decrypted TOTPs.
  final List<DecryptedTotp> decryptedTotps;

  /// Creates a new TOTP key dialog instance.
  const _TotpKeyDialog({
    this.decryptedTotps = const [],
  });

  @override
  Widget build(BuildContext context) => AppDialog(
    title: Text(translations.totp.totpKeyDialog.title),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
      ),
    ],
    children: [
      ListTilePadding(
        bottom: 10,
        child: Text(
          translations.totp.totpKeyDialog.message(n: decryptedTotps.length),
        ),
      ),
      if (decryptedTotps.length > 1)
        ListTile(
          leading: const Icon(Icons.done_all),
          onTap: () => Navigator.pop(context, _TotpKeyDialogResult.changeAllTotpsKey),
          title: Text(translations.totp.totpKeyDialog.choices.changeAllDecryptedTotpsKey.title),
          subtitle: Text(translations.totp.totpKeyDialog.choices.changeAllDecryptedTotpsKey.subtitle),
        ),
      ListTile(
        leading: const Icon(Icons.key),
        onTap: () => Navigator.pop(context, _TotpKeyDialogResult.changeTotpKey),
        title: Text(translations.totp.totpKeyDialog.choices.changeTotpKey.title(n: decryptedTotps.length)),
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
  );
}

/// The [_TotpKeyDialog] result.
enum _TotpKeyDialogResult {
  /// Allows to change the TOTP key.
  changeTotpKey,

  /// Allows to change all TOTPs key (the current one and those that have been decrypted additionally).
  changeAllTotpsKey,

  /// Allows to change the current master password.
  changeMasterPassword,
}
