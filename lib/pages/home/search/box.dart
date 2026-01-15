import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:open_authenticator/model/totp/totp.dart';
import 'package:open_authenticator/pages/home/search/route.dart';
import 'package:open_authenticator/widgets/clickable.dart';

/// A widget that allows to search for a TOTP.
class SearchBox extends ConsumerStatefulWidget implements PreferredSizeWidget {
  /// Triggered when a TOTP has been found by the user.
  final Function(Totp totp)? onTotpFound;

  /// The header widget.
  final Widget header;

  /// Creates a new search box instance.
  const SearchBox({
    super.key,
    this.onTotpFound,
    required this.header,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchBoxWidgetState();
}

/// The search box widget state.
class _SearchBoxWidgetState extends ConsumerState<SearchBox> {
  /// The current focus node.
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      widget.header,
      Container(
        padding: const EdgeInsets.all(10),
        color: context.theme.colors.secondary,
        child: FTextField(
          suffixBuilder: (_, _, _) => ClickableButton.icon(
            style: FButtonStyle.ghost(),
            onPress: null,
            child: const Icon(FIcons.search),
          ),
          style: (style) => style.copyWith(
            filled: true,
            fillColor: context.theme.tileStyle.decoration.resolve({})?.color,
          ),
          hint: MaterialLocalizations.of(context).searchFieldLabel,
          focusNode: focusNode,
        ),
      ),
    ],
  );

  /// Triggered when the focus changes.
  void onFocusChange() async {
    if (focusNode.hasFocus) {
      focusNode.unfocus();
      if (mounted) {
        Totp? result = await showTotpSearch(context);
        if (result != null) {
          widget.onTotpFound?.call(result);
        }
      }
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
