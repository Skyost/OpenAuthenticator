import 'package:flutter/material.dart';
import 'package:open_authenticator/widgets/form/password_form_field.dart';

/// Shows a dialog for prompting text.
class TextInputDialog extends StatefulWidget {
  /// The dialog title.
  final String title;

  /// The prompt message.
  final String message;

  /// Whether we're prompting for a password.
  final bool password;

  /// The form field validator.
  final FormFieldValidator<String>? validator;

  /// The keyboard type.
  final TextInputType? keyboardType;

  /// The initial value.
  final String initialValue;

  /// Creates a new text input dialog instance.
  const TextInputDialog({
    super.key,
    required this.title,
    required this.message,
    this.password = false,
    this.validator,
    this.keyboardType,
    String? initialValue,
  }) : initialValue = initialValue ?? '';

  @override
  State<StatefulWidget> createState() => _TextInputDialogState();

  /// Prompts for a string.
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    required String message,
    bool password = false,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    String? initialValue,
  }) =>
      showAdaptiveDialog<String>(
        context: context,
        builder: (context) => TextInputDialog(
          title: title,
          message: message,
          password: password,
          validator: validator,
          keyboardType: keyboardType,
          initialValue: initialValue,
        ),
      );

  /// Validates the given mail.
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return null;
    }
    if (!RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email)) {
      return 'Invalid email';
    }
    return null;
  }
}

/// The text input dialog state.
class _TextInputDialogState extends State<TextInputDialog> {
  /// The current value.
  late String value = widget.initialValue;

  /// Whether the input is valid.
  late bool valid = widget.validator == null ? true : (widget.validator!.call(value) != null);

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: Text(widget.title),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message,
              textAlign: TextAlign.left,
            ),
            if (widget.password)
              PasswordFormField(
                initialValue: value,
                onChanged: onChanged,
                autofocus: true,
                onFieldSubmitted: (value) => Navigator.pop(context, value),
                textInputAction: TextInputAction.go,
                validator: widget.validator,
                keyboardType: widget.keyboardType,
                autovalidateMode: AutovalidateMode.always,
              )
            else
              TextFormField(
                initialValue: value,
                onChanged: onChanged,
                autofocus: true,
                onFieldSubmitted: (value) => Navigator.pop(context, value),
                textInputAction: TextInputAction.go,
                validator: widget.validator,
                keyboardType: widget.keyboardType,
                autovalidateMode: AutovalidateMode.always,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: valid ? (() => Navigator.pop(context, value)) : null,
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      );

  /// Triggered when changed.
  void onChanged(String newValue) {
    value = newValue;
    if (widget.validator != null) {
      bool result = widget.validator!(newValue) == null;
      setState(() => valid = result);
    }
  }
}
