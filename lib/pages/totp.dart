import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/settings/cache_totp_pictures.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/logo_search/dialog.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';
import 'package:open_authenticator/widgets/list/expand_list_tile.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/totp/image.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Allows to edit a TOTP.
class TotpPage extends ConsumerStatefulWidget {
  /// The TOTP page name.
  static const String name = '/totp';

  /// The TOTP instance.
  final DecryptedTotp? totp;

  /// The image size.
  final double imageSize;

  /// Whether we should add a TOTP or edit a TOTP.
  final bool add;

  /// Creates a new TOTP display page instance.
  const TotpPage({
    super.key,
    this.totp,
    this.imageSize = 150,
    bool? add,
  }) : add = add ?? totp == null;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TotpPageState();
}

/// The TOTP edit page state.
class _TotpPageState extends ConsumerState<TotpPage> {
  /// The form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// The TOTP image URL.
  late String? imageUrl = widget.totp?.imageUrl;

  /// The TOTP label.
  late String label = widget.totp?.label ?? '';

  /// The TOTP data.
  late String decryptedSecret = widget.totp?.decryptedSecret ?? '';

  /// The TOTP issuer.
  late String issuer = widget.totp?.issuer ?? '';

  /// The TOTP algorithm.
  late Algorithm? algorithm = widget.totp?.algorithm;

  /// The TOTP digits.
  late int? digits = widget.totp?.digits;

  /// The TOTP validity.
  late int? validity = widget.totp?.validity;

  /// Whether the form is enabled.
  bool enabled = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.add ? translations.totp.page.title.add : translations.totp.page.title.edit),
          actions: [
            if (!widget.add)
              IconButton(
                onPressed: () async {
                  bool confirmation = await ConfirmationDialog.ask(
                    context,
                    title: translations.totp.actions.deleteConfirmationDialog.title,
                    message: translations.totp.actions.deleteConfirmationDialog.message,
                  );
                  if (!confirmation) {
                    return;
                  }
                  if (!await ref.read(totpRepositoryProvider.notifier).deleteTotp(widget.totp!.uuid) && context.mounted) {
                    SnackBarIcon.showErrorSnackBar(context, text: translations.totp.actions.deleteConfirmationDialog.error);
                  }
                },
                icon: const Icon(Icons.delete),
              ),
          ],
        ),
        body: Form(
          key: formKey,
          child: ListView(
            children: [
              UnconstrainedBox(
                child: SizedBox(
                  width: widget.imageSize,
                  child: enabled
                      ? InkWell(
                          onTap: () async {
                            String? imageUrl = await LogoPickerDialog.openDialog(context, initialSearchKeywords: issuer);
                            if (imageUrl != null && mounted) {
                              setState(() => this.imageUrl = imageUrl);
                            }
                          },
                          child: createImageWidget(),
                        )
                      : createImageWidget(),
                ),
              ),
              ListTilePadding(
                child: TextFormField(
                  initialValue: label,
                  onChanged: (value) {
                    setState(() => label = value);
                  },
                  decoration: FormLabelWithIcon(
                    icon: Icons.label,
                    text: translations.totp.page.label.text,
                    hintText: translations.totp.page.label.hint,
                  ),
                  validator: validateLabel,
                  enabled: enabled,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              ListTilePadding(
                child: PasswordFormField(
                  initialValue: decryptedSecret,
                  onChanged: (value) {
                    setState(() => decryptedSecret = value);
                  },
                  enabled: widget.add && enabled,
                  decoration: FormLabelWithIcon(
                    icon: Icons.key,
                    text: translations.totp.page.secret.text,
                    hintText: translations.totp.page.secret.hint,
                  ),
                  validator: validateDecryptedSecret,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              ListTilePadding(
                child: TextFormField(
                  initialValue: issuer,
                  onChanged: (value) {
                    setState(() => issuer = value);
                  },
                  decoration: FormLabelWithIcon(
                    icon: Icons.web,
                    text: translations.totp.page.issuer.text,
                    hintText: translations.totp.page.issuer.hint,
                  ),
                  validator: validateIssuer,
                  enabled: enabled,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ExpandListTile(
                  title: Text(translations.totp.page.advancedOptions),
                  enabled: enabled,
                  children: createAdvancedOptionsWidgets(),
                ),
              ),
              ExpandListTile(
                title: Text(translations.totp.page.showQrCode),
                enabled: enabled,
                children: [createQrCodeWidget()],
              ),
            ],
          ),
        ),
        bottomNavigationBar: FilledButton.tonalIcon(
          style: const ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
            shape: MaterialStatePropertyAll(RoundedRectangleBorder()),
          ),
          onPressed: isValidTotp && enabled
              ? () async {
                  bool result = formKey.currentState!.validate();
                  if (!result) {
                    return;
                  }
                  setState(() => enabled = false);
                  bool cacheTotpImage = await ref.read(cacheTotpPicturesSettingsEntryProvider.future);
                  if (widget.add) {
                    AsyncValue<CryptoStore?> cryptoStore = ref.read(cryptoStoreProvider);
                    DecryptedTotp? totp = await DecryptedTotp.create(
                      cryptoStore: cryptoStore.value,
                      decryptedSecret: decryptedSecret,
                      label: label,
                      issuer: issuer,
                      algorithm: algorithm,
                      digits: digits,
                      validity: validity,
                      imageUrl: imageUrl,
                    );
                    if (totp == null) {
                      result = false;
                    } else {
                      result = await ref.read(totpRepositoryProvider.notifier).addTotp(totp, cacheTotpImage: cacheTotpImage);
                    }
                  } else {
                    result = await ref.read(totpRepositoryProvider.notifier).updateTotp(
                          widget.totp!.uuid,
                          label: label,
                          issuer: issuer,
                          algorithm: algorithm,
                          digits: digits,
                          validity: validity,
                          imageUrl: imageUrl,
                          cacheTotpImage: cacheTotpImage && imageUrl != widget.totp!.imageUrl,
                        );
                  }
                  if (!context.mounted) {
                    return;
                  }
                  setState(() => enabled = true);
                  if (result) {
                    SnackBarIcon.showSuccessSnackBar(context, text: translations.totp.page.success);
                    Navigator.pop(context);
                  } else {
                    SnackBarIcon.showErrorSnackBar(context, text: translations.totp.page.error.save);
                  }
                }
              : null,
          icon: const Icon(Icons.check),
          label: Text(translations.totp.page.save),
        ),
      );

  /// Creates the advanced options widgets.
  List<Widget> createAdvancedOptionsWidgets() => [
        ListTilePadding(
          child: DropdownButtonFormField<Algorithm>(
            value: algorithm ?? Totp.kDefaultAlgorithm,
            decoration: FormLabelWithIcon(
              icon: Icons.tag,
              text: translations.totp.page.algorithm,
            ),
            items: [
              for (Algorithm algorithm in Algorithm.values)
                DropdownMenuItem<Algorithm>(
                  value: algorithm,
                  child: Text(algorithm.name.toUpperCase()),
                ),
            ],
            onChanged: enabled
                ? (value) {
                    if (value != null) {
                      setState(() => algorithm = value);
                    }
                  }
                : null,
          ),
        ),
        ListTilePadding(
          child: TextFormField(
            onChanged: (value) {
              setState(() => digits = int.tryParse(value));
            },
            keyboardType: const TextInputType.numberWithOptions(),
            decoration: FormLabelWithIcon(
              icon: Icons.dialpad,
              text: translations.totp.page.digits,
              hintText: Totp.kDefaultDigits.toString(),
            ),
            enabled: enabled,
          ),
        ),
        ListTilePadding(
          child: TextFormField(
            onChanged: (value) {
              setState(() => validity = int.tryParse(value));
            },
            keyboardType: const TextInputType.numberWithOptions(),
            decoration: FormLabelWithIcon(
              icon: Icons.schedule,
              text: translations.totp.page.validity,
              hintText: Totp.kDefaultValidity.toString(),
            ),
            enabled: enabled,
          ),
        ),
      ];

  /// Creates the image widget.
  Widget createImageWidget() => TotpImageWidget(
        label: label,
        issuer: issuer,
        imageUrl: imageUrl,
        size: widget.imageSize,
      );

  /// Creates the QR code widget.
  Widget createQrCodeWidget() => ListTilePadding(
        child: Center(
          child: isValidTotp
              ? QrImageView(
                  data: DecryptedTotp.toUri(
                    decryptedSecret: decryptedSecret,
                    label: label,
                    issuer: issuer,
                    algorithm: algorithm,
                    digits: digits,
                    validity: validity,
                  ).toString(),
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  size: 200,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Text(
                  translations.totp.page.error.qrCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
        ),
      );

  /// Whether the TOTP is valid.
  bool get isValidTotp => validateDecryptedSecret() == null && validateLabel() == null && validateIssuer() == null;

  /// Validates the [decryptedSecret].
  String? validateDecryptedSecret([String? decryptedSecret]) {
    decryptedSecret ??= this.decryptedSecret;
    if (decryptedSecret.isEmpty) {
      return translations.totp.page.error.emptySecret;
    }
    if (!RegExp(r'^[A-Z2-7]{16,128}$').hasMatch(decryptedSecret)) {
      return translations.totp.page.error.invalidSecret;
    }
    return null;
  }

  /// Validates the [label].
  String? validateLabel([String? label]) {
    label ??= this.label;
    if (label.isEmpty) {
      return translations.totp.page.error.emptyLabel;
    }
    return null;
  }

  /// Validates the [issuer].
  String? validateIssuer([String? issuer]) {
    issuer ??= this.issuer;
    if (issuer.isEmpty) {
      return translations.totp.page.error.emptyIssuer;
    }
    return null;
  }
}
