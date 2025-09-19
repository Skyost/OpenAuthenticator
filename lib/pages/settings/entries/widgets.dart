import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/settings/entry.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:url_launcher/url_launcher.dart';

/// Allows to configure boolean values.
class BoolSettingsEntryWidget<T extends SettingsEntry<bool>> extends CheckboxSettingsEntryWidget<T, bool> {
  /// Creates a new bool settings entry widget instance.
  const BoolSettingsEntryWidget({
    super.key,
    required super.provider,
    required super.title,
    super.subtitle,
    super.icon,
  });

  @override
  bool isEnabled(bool? value) => value == true;

  @override
  void changeValue(BuildContext context, WidgetRef ref, bool newValue) => ref.read(provider.notifier).changeValue(newValue);
}

/// A settings entry that can be configured using a checkbox.
abstract class CheckboxSettingsEntryWidget<T extends SettingsEntry<U>, U> extends ConsumerWidget {
  /// The boolean provider.
  final AsyncNotifierProvider<T, U> provider;

  /// The entry widget title.
  final String title;

  /// The entry widget subtitle.
  final String? subtitle;

  /// The icon.
  final IconData? icon;

  /// The tile padding.
  final EdgeInsets? contentPadding;

  /// Creates a new checkbox settings entry widget instance.
  const CheckboxSettingsEntryWidget({
    super.key,
    required this.provider,
    required this.title,
    this.subtitle,
    this.icon,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<U> value = ref.watch(provider);
    return switch (value) {
      AsyncData(:final value) => createListTile(context, ref, value: value),
      AsyncError() => const SizedBox.shrink(),
      _ => createListTile(context, ref, enabled: false),
    };
  }

  /// Creates the list tile widget.
  Widget createListTile(BuildContext context, WidgetRef ref, {U? value, bool enabled = true}) => ListTile(
    leading: icon == null ? null : Icon(icon),
    title: Text(title),
    subtitle: buildSubtitle(context, ref, value),
    enabled: enabled,
    contentPadding: contentPadding,
    onTap: () => changeValue(context, ref, !isEnabled(value)),
    trailing: Checkbox(
      value: isEnabled(value),
      onChanged: enabled
          ? (value) {
              if (value != null) {
                changeValue(context, ref, value);
              }
            }
          : null,
    ),
  );

  /// Whether the checkbox is enabled.
  bool isEnabled(U? value);

  /// Builds the subtitle widget.
  Widget? buildSubtitle(BuildContext context, WidgetRef ref, U? value) => subtitle == null ? null : Text(subtitle!);

  /// Changes the value.
  void changeValue(BuildContext context, WidgetRef ref, bool newValue);
}

/// A settings entry that allows to open a specific URI.
class UriSettingsEntry extends StatelessWidget {
  /// The entry widget title.
  final String title;

  /// The entry widget subtitle.
  final String? subtitle;

  /// The icon.
  final IconData? icon;

  /// The URI to open.
  final Uri uri;

  /// Creates a new URI settings entry instance.
  const UriSettingsEntry({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.uri,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: canLaunchUrl(uri),
    builder: (context, snapshot) => createListTile(context, snapshot.data),
  );

  /// Creates the list tile widget.
  Widget createListTile(BuildContext context, bool? canLaunchUri) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    onTap: canLaunchUri == null
        ? null
        : (() async {
            if (canLaunchUri) {
              await launchUrl(uri);
              return;
            }
            await Clipboard.setData(ClipboardData(text: uri.toString()));
            if (context.mounted) {
              SnackBarIcon.showSuccessSnackBar(context, text: translations.miscellaneous.urlCopiedToClipboard);
            }
          }),
  );
}

/// A list tile that is written in red.
class DangerZoneListTile extends ConsumerStatefulWidget {
  /// The title.
  final String? title;

  /// The subtitle.
  final String? subtitle;

  /// The icon.
  final IconData? icon;

  /// Whether the tile is enabled.
  final bool enabled;

  /// Triggered when tapped on.
  final VoidCallback? onTap;

  /// Creates a new danger zone list tile instance.
  const DangerZoneListTile({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.enabled = true,
    this.onTap,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DangerZoneListTileState();
}

/// The danger zone list state.
class _DangerZoneListTileState extends ConsumerState<DangerZoneListTile> with BrightnessListener {
  @override
  Widget build(BuildContext context) {
    Color? textColor;
    if (widget.enabled) {
      textColor = currentBrightness == Brightness.light ? Colors.red.shade900 : Colors.red.shade400;
    }
    return ListTile(
      leading: widget.icon == null
          ? null
          : Icon(
              widget.icon,
              color: textColor,
            ),
      title: widget.title == null
          ? null
          : Text(
              widget.title!,
              style: TextStyle(color: textColor),
            ),
      subtitle: widget.subtitle == null
          ? null
          : Text(
              widget.subtitle!,
              style: TextStyle(color: textColor),
            ),
      enabled: widget.enabled,
      onTap: widget.enabled ? widget.onTap : null,
    );
  }
}
