import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/app_unlock/state.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/scan.dart';
import 'package:open_authenticator/pages/settings/page.dart';
import 'package:open_authenticator/pages/totp.dart';
import 'package:open_authenticator/utils/platform.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/title.dart';
import 'package:open_authenticator/widgets/totp/widget.dart';

/// The home page.
class HomePage extends ConsumerWidget {
  /// The home page name.
  static const String name = '/';

  /// Creates a new home page instance.
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: const TitleWidget(),
          actions: [
            if (currentPlatform != Platform.android)
              IconButton(
                onPressed: () => _onAddButtonPressed(context),
                icon: const Icon(Icons.add),
              ),
            if (currentPlatform.isDesktop)
              IconButton(
                onPressed: ref.read(totpRepositoryProvider.notifier).refresh,
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
        body: _HomePageBody(),
      );

  /// Triggered when the "Add" button is pressed.
  void _onAddButtonPressed(BuildContext context) async {
    if (!currentPlatform.isMobile && !kDebugMode) {
      Navigator.pushNamed(context, TotpPage.name);
      return;
    }
    _AddTotpDialogResult? choice = await showAdaptiveDialog<_AddTotpDialogResult>(
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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Totp>> totps = ref.watch(totpRepositoryProvider);
    AsyncValue<bool> isUnlocked = ref.watch(appUnlockStateProvider);
    return switch (totps) {
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: ref.read(totpRepositoryProvider.notifier).refresh,
          child: value.isEmpty
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
              : ListView.separated(
                  itemCount: value.length,
                  itemBuilder: (context, position) => TotpWidget(
                    totp: value[position],
                    displayCode: isUnlocked.valueOrNull ?? false,
                  ),
                  separatorBuilder: (context, position) => const Divider(),
                ),
        ),
      AsyncError(:final error) => Center(
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
      ),
      _ => const CenteredCircularProgressIndicator(),
    };
  }
}

/// A dialog that allows to choose a method to add a TOTP.
class _AddTotpDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
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
