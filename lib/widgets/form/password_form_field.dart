import 'package:flutter/material.dart';

/// A form field for entering passwords.
class PasswordFormField extends StatefulWidget {
  /// The form field key, if needed.
  final GlobalKey<FormState>? formFieldKey;

  /// The reveal button builder.
  final Widget Function(BuildContext, VoidCallback, bool) revealButtonBuilder;

  /// Whether this field is enabled.
  final bool enabled;

  /// Whether to auto focus this field.
  final bool autofocus;

  /// Triggered when the field has been submitted.
  final ValueChanged<String>? onFieldSubmitted;

  /// The text input action.
  final TextInputAction? textInputAction;

  /// The field decoration.
  final InputDecoration decoration;

  /// Triggered when the value has changed.
  final ValueChanged<String>? onChanged;

  /// The initial value.
  final String? initialValue;

  /// The field validator.
  final FormFieldValidator<String>? validator;

  /// The keyboard type.
  final TextInputType? keyboardType;

  /// The auto validate mode.
  final AutovalidateMode? autovalidateMode;

  /// Creates a new password form field instance.
  const PasswordFormField({
    super.key,
    this.formFieldKey,
    this.revealButtonBuilder = _defaultRevealButtonBuilder,
    this.enabled = true,
    this.autofocus = false,
    this.onFieldSubmitted,
    this.textInputAction,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.autovalidateMode,
  });

  @override
  State<StatefulWidget> createState() => _PasswordFormFieldState();

  /// The default reveal button builder.
  static Widget _defaultRevealButtonBuilder(BuildContext context, VoidCallback reveal, bool state) => IconButton(
        onPressed: reveal,
        icon: Icon(state ? Icons.visibility : Icons.visibility_off),
      );
}

/// The password form field.
class _PasswordFormFieldState extends State<PasswordFormField> {
  /// Whether the password is revealed.
  bool isRevealed = false;

  @override
  Widget build(BuildContext context) => TextFormField(
        key: widget.formFieldKey,
        obscureText: !isRevealed,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: widget.autofocus,
        onFieldSubmitted: widget.onFieldSubmitted,
        textInputAction: widget.textInputAction,
        readOnly: !widget.enabled,
        decoration: widget.decoration.copyWith(
          suffixIcon: widget.revealButtonBuilder(context, toggleObscuration, isRevealed),
          enabledBorder: widget.enabled ? null : Theme.of(context).inputDecorationTheme.disabledBorder,
          focusedBorder: widget.enabled ? null : Theme.of(context).inputDecorationTheme.disabledBorder,
        ),
        onChanged: widget.onChanged,
        initialValue: widget.initialValue,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        autovalidateMode: widget.autovalidateMode,
      );

  /// Toggles the obscuration state.
  void toggleObscuration() {
    setState(() => isRevealed = !isRevealed);
  }
}
