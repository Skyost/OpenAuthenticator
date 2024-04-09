import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/pages/settings/entries/bool_entry.dart';
import 'package:open_authenticator/utils/storage_migration.dart';

/// Allows the user to choose its storage type.
class SynchronizeSettingsEntryWidget extends CheckboxSettingsEntryWidget<StorageTypeSettingsEntry, StorageType> {
  /// Creates a new synchronize settings entry widget instance.
  SynchronizeSettingsEntryWidget({
    super.key,
    super.contentPadding,
  }) : super(
          provider: storageTypeSettingsEntryProvider,
          icon: Icons.sync,
          title: translations.settings.synchronization.synchronizeTotps.title,
          subtitle: translations.settings.synchronization.synchronizeTotps.subtitle,
        );

  /// Creates a new synchronize settings entry widget instance for the intro page.
  SynchronizeSettingsEntryWidget.intro({
    Key? key,
  }) : this(
          key: key,
          contentPadding: EdgeInsets.zero,
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState? state = ref.watch(firebaseAuthenticationProvider);
    if (state is! FirebaseAuthenticationStateLoggedIn || ref.watch(userAuthenticationProviders.notifier).availableProviders.isEmpty) {
      return const SizedBox.shrink();
    }
    return super.build(context, ref);
  }

  @override
  void changeValue(BuildContext context, WidgetRef ref, bool newValue) => StorageMigrationUtils.changeStorageType(context, ref, newValue ? StorageType.online : StorageType.local);

  @override
  bool isEnabled(StorageType? storageType) => storageType == StorageType.online;
}
