import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_authenticator/app.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/main.dart';
import 'package:open_authenticator/model/crypto.dart';
import 'package:open_authenticator/model/totp/algorithm.dart';
import 'package:open_authenticator/model/totp/decrypted.dart';
import 'package:open_authenticator/model/totp/repository.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home.dart';
import 'package:open_authenticator/utils/brightness_listener.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/utils/result.dart';
import 'package:open_authenticator/utils/utils.dart';
import 'package:open_authenticator/widgets/dialog/confirmation_dialog.dart';
import 'package:open_authenticator/widgets/dialog/logo_search/dialog.dart';
import 'package:open_authenticator/widgets/dialog/totp_limit.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';
import 'package:open_authenticator/widgets/list/expand_list_tile.dart';
import 'package:open_authenticator/widgets/list/list_tile_padding.dart';
import 'package:open_authenticator/widgets/snackbar_icon.dart';
import 'package:open_authenticator/widgets/totp/image.dart';
import 'package:open_authenticator/widgets/waiting_overlay.dart';
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

  /// Opens this page from a scanned [uri].
  static Future<void> openFromUri(BuildContext context, WidgetRef ref, Uri uri) async {
    CryptoStore? cryptoStore = await ref.read(cryptoStoreProvider.future);
    DecryptedTotp? totp = await DecryptedTotp.fromUri(uri, cryptoStore);
    if (!context.mounted) {
      return;
    }
    if (totp == null) {
      SnackBarIcon.showErrorSnackBar(context, text: translations.totp.page.uriError);
    }
    Navigator.pushNamedAndRemoveUntil(
      context,
      TotpPage.name,
      (route) => route.settings.name == HomePage.name,
      arguments: {
        OpenAuthenticatorApp.kRouteParameterTotp: totp,
        OpenAuthenticatorApp.kRouteParameterAddTotp: true,
      },
    );
  }
}

/// The TOTP edit page state.
class _TotpPageState extends ConsumerState<TotpPage> with BrightnessListener {
  /// The form key.
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// The TOTP image URL.
  late String? imageUrl = widget.totp?.imageUrl;

  /// The TOTP label.
  late String label = widget.totp?.label ?? '';

  /// The TOTP data.
  late String secret = widget.totp?.secret ?? '';

  /// The TOTP issuer.
  late String issuer = widget.totp?.issuer ?? '';

  /// The TOTP algorithm.
  late Algorithm? algorithm = widget.totp?.algorithm;

  /// The TOTP digits.
  late int? digits = widget.totp?.digits;

  /// The TOTP validity.
  late Duration? validity = widget.totp?.validity;

  /// Whether the form is enabled.
  bool enabled = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.add ? translations.totp.page.title.add : translations.totp.page.title.edit),
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Theme.of(context).colorScheme.secondaryContainer,
          ),
          actions: [
            if (!widget.add)
              IconButton(
                onPressed: () async {
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
                    future: ref.read(totpRepositoryProvider.notifier).deleteTotp(widget.totp!.uuid),
                  );
                  if (!context.mounted) {
                    return;
                  }
                  context.showSnackBarForResult(result);
                  if (result is ResultSuccess) {
                    Navigator.pop(context);
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
                  initialValue: secret,
                  onChanged: (value) {
                    setState(() => secret = value);
                  },
                  enabled: widget.add && enabled,
                  decoration: FormLabelWithIcon(
                    icon: Icons.key,
                    text: translations.totp.page.secret.text,
                    hintText: translations.totp.page.secret.hint,
                  ),
                  validator: validateSecret,
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
              if (isValidTotp)
                ExpandListTile(
                  title: Text(translations.totp.page.showQrCode),
                  enabled: enabled,
                  children: [createQrCodeWidget(context)],
                ),
            ],
          ),
        ),
        bottomNavigationBar: FilledButton.tonalIcon(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.only(
                top: 20,
                bottom: 20 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
            shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
          ),
          onPressed: isValidTotp && enabled
              ? () async {
                  bool validateResult = formKey.currentState!.validate();
                  if (!validateResult) {
                    return;
                  }
                  setState(() => enabled = false);
                  Result editResult = await (widget.add ? addTotp() : updateTotp());
                  if (!context.mounted) {
                    return;
                  }
                  setState(() => enabled = true);
                  context.showSnackBarForResult(editResult);
                  if (editResult is ResultSuccess) {
                    Navigator.pop(context);
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
            initialValue: algorithm ?? Totp.kDefaultAlgorithm,
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
            initialValue: digits?.toString(),
            onChanged: (value) {
              setState(() => digits = int.tryParse(value));
            },
            keyboardType: const TextInputType.numberWithOptions(),
            decoration: FormLabelWithIcon(
              icon: Icons.dialpad,
              text: translations.totp.page.digits,
              hintText: Totp.kDefaultDigits.toString(),
            ),
            validator: validateDigits,
            enabled: enabled,
          ),
        ),
        ListTilePadding(
          child: TextFormField(
            initialValue: validity?.inSeconds.toString(),
            onChanged: (value) {
              int? validity = int.tryParse(value);
              setState(() => this.validity = validity == null ? null : Duration(seconds: validity));
            },
            keyboardType: const TextInputType.numberWithOptions(),
            decoration: FormLabelWithIcon(
              icon: Icons.schedule,
              text: translations.totp.page.validity,
              hintText: Totp.kDefaultValidity.inSeconds.toString(),
            ),
            validator: validateValidity,
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
  Widget createQrCodeWidget(BuildContext context) {
    Color color = currentBrightness == Brightness.light ? Theme.of(context).colorScheme.primary : Colors.white;
    return ListTilePadding(
      child: Center(
        child: QrImageView(
          data: DecryptedTotp.toUri(
            secret: secret.toUpperCase(),
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
            color: color,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: color,
          ),
        ),
      ),
    );
  }

  /// Whether the TOTP is valid.
  bool get isValidTotp => validateSecret() == null && validateLabel() == null && validateIssuer() == null && validateDigits() == null && validateValidity() == null;

  /// Validates the [secret].
  String? validateSecret([String? secret]) {
    secret ??= this.secret;
    secret = secret.toUpperCase();
    if (secret.isEmpty) {
      return translations.error.validation.empty;
    }
    if (!isValidBase32(secret)) {
      return translations.error.validation.secret;
    }
    return null;
  }

  /// Validates the [label].
  String? validateLabel([String? label]) {
    label ??= this.label;
    if (label.isEmpty) {
      return translations.error.validation.empty;
    }
    return null;
  }

  /// Validates the [issuer].
  String? validateIssuer([String? issuer]) {
    issuer ??= this.issuer;
    if (issuer.isEmpty) {
      return translations.error.validation.empty;
    }
    return null;
  }

  /// Validates the [digits].
  String? validateDigits([String? digits]) {
    if (digits == null || digits.isEmpty) {
      return null;
    }
    int? parsedDigits = int.tryParse(digits);
    if (parsedDigits == null) {
      return translations.error.validation.number;
    }
    if (parsedDigits < 6) {
      return translations.error.validation.totpDigits;
    }
    return null;
  }

  /// Validates the [validity].
  String? validateValidity([String? validity]) {
    if (validity == null || validity.isEmpty) {
      return null;
    }
    int? parsedValidity = int.tryParse(validity);
    if (parsedValidity == null) {
      return translations.error.validation.number;
    }
    return null;
  }

  /// Adds the TOTP to the repository.
  Future<Result> addTotp() async {
    bool willExceed = (await ref.read(totpLimitProvider.future)).willExceedIfAddMore(count: 1);
    if (willExceed) {
      if (mounted) {
        await TotpLimitDialog.show(
          context,
          title: translations.totpLimit.addDialog.title,
          message: translations.totpLimit.addDialog.message(
            count: App.freeTotpsLimit.toString(),
          ),
          cancelButton: true,
        );
      }
      return const ResultCancelled();
    }

    DecryptedTotp? totp = await _createTotp();
    if (totp == null) {
      return ResultError();
    }
    return await ref.read(totpRepositoryProvider.notifier).addTotp(totp);
  }

  /// Updates the TOTP in the repository.
  Future<Result> updateTotp() async {
    DecryptedTotp? totp = await _createTotp();
    if (totp == null) {
      return ResultError();
    }
    return await ref.read(totpRepositoryProvider.notifier).updateTotp(totp);
  }

  /// Creates a [DecryptedTotp] corresponding to the current fields.
  Future<DecryptedTotp?> _createTotp() async => await DecryptedTotp.create(
        cryptoStore: await ref.read(cryptoStoreProvider.future),
        uuid: widget.totp?.uuid,
        secret: secret.toUpperCase(),
        label: label,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        validity: validity,
        imageUrl: imageUrl,
      );
}
