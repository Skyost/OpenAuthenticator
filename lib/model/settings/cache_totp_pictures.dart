import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/model/settings/entry.dart';

/// The cache TOTP pictures settings entry provider.
final cacheTotpPicturesSettingsEntryProvider = AsyncNotifierProvider.autoDispose<CacheTotpPicturesSettingsEntry, bool>(CacheTotpPicturesSettingsEntry.new);

/// A settings entry that allows to control whether we have to cache TOTP pictures.
class CacheTotpPicturesSettingsEntry extends SettingsEntry<bool> {
  /// Creates a new cache TOTP pictures settings entry instance.
  CacheTotpPicturesSettingsEntry()
      : super(
          key: 'cacheTotpPictures',
          defaultValue: true,
        );
}
