import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/authentication/firebase_authentication.dart';
import 'package:open_authenticator/model/authentication/providers/provider.dart';
import 'package:open_authenticator/model/authentication/state.dart';
import 'package:open_authenticator/model/purchases/contributor_plan.dart';
import 'package:open_authenticator/model/settings/storage_type.dart';
import 'package:open_authenticator/model/storage/type.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/intro/slides/slide.dart';
import 'package:open_authenticator/pages/settings/entries/bool_entry.dart';
import 'package:open_authenticator/utils/storage_migration.dart';

/// Allows the user to choose its storage type.
class SynchronizeSettingsEntryWidget extends CheckboxSettingsEntryWidget<StorageTypeSettingsEntry, StorageType> {
  /// Creates a new synchronize settings entry widget instance.
  SynchronizeSettingsEntryWidget({
    super.key,
    super.contentPadding,
    super.icon = Icons.sync,
  }) : super(
          provider: storageTypeSettingsEntryProvider,
          title: translations.settings.synchronization.synchronizeTotps.title,
          subtitle: translations.settings.synchronization.synchronizeTotps.subtitle.description,
        );

  /// Creates a new synchronize settings entry widget instance for the intro page.
  SynchronizeSettingsEntryWidget.intro({
    Key? key,
  }) : this(
          key: key,
          icon: null,
          contentPadding: const EdgeInsets.only(
            bottom: IntroPageSlideParagraphWidget.kDefaultPadding,
          ),
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FirebaseAuthenticationState? state = ref.watch(firebaseAuthenticationProvider);
    if (state is! FirebaseAuthenticationStateLoggedIn || ref.read(userAuthenticationProviders.notifier).availableProviders.isEmpty) {
      return const SizedBox.shrink();
    }
    return super.build(context, ref);
  }

  @override
  Widget createListTile(BuildContext context, WidgetRef ref, {StorageType? value, bool enabled = true}) {
    AsyncValue<ContributorPlanState> state = ref.watch(contributorPlanStateProvider);
    StorageType? storageType = value;
    switch (state) {
      case AsyncData(:final value):
        switch (value) {
          case ContributorPlanState.inactive:
            List<Totp>? totps = ref.watch(totpRepositoryProvider).valueOrNull;
            return super.createListTile(
              context,
              ref,
              value: storageType,
              enabled: totps != null && totps.length < App.freeTotpsLimit,
            );
          case ContributorPlanState.active:
            return super.createListTile(
              context,
              ref,
              value: storageType,
              enabled: enabled,
            );
          default:
            return const SizedBox.shrink();
        }
      case AsyncLoading():
      default:
        return super.createListTile(
          context,
          ref,
          value: value,
          enabled: false,
        );
    }
  }

  @override
  Widget? buildSubtitle(BuildContext context, WidgetRef ref, StorageType? storageType) {
    AsyncValue<ContributorPlanState> state = ref.watch(contributorPlanStateProvider);
    if (state is! AsyncData || state.value == ContributorPlanState.active || state.value == ContributorPlanState.impossible) {
      return super.buildSubtitle(
        context,
        ref,
        storageType,
      );
    }
    AsyncValue<List<Totp>> totps = ref.watch(totpRepositoryProvider);
    if (totps is! AsyncData<List<Totp>>) {
      return Text(translations.settings.synchronization.synchronizeTotps.subtitle.description);
    }
    return Text.rich(
      TextSpan(
        text: translations.settings.synchronization.synchronizeTotps.subtitle.description,
        children: [
          const TextSpan(text: '\n'),
          translations.settings.synchronization.synchronizeTotps.subtitle.totpLimit.limit(
            limit: TextSpan(
              text: App.freeTotpsLimit.toString(),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            count: TextSpan(
              text: totps.value.length.toString(),
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          const TextSpan(text: '\n'),
          if (storageType == StorageType.local && totps.value.length > App.freeTotpsLimit)
            TextSpan(
              text: '\n${translations.settings.synchronization.synchronizeTotps.subtitle.totpLimit.notEnabled}',
            ),
          if (storageType == StorageType.online)
            TextSpan(
              text: '\n${translations.settings.synchronization.synchronizeTotps.subtitle.totpLimit.enabled}',
            ),
        ],
      ),
    );
  }

  @override
  void changeValue(BuildContext context, WidgetRef ref, bool newValue) => StorageMigrationUtils.changeStorageType(context, ref, newValue ? StorageType.online : StorageType.local);

  @override
  bool isEnabled(StorageType? storageType) => storageType == StorageType.online;
}
