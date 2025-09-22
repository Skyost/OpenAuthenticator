import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/utils/debounce.dart';
import 'package:open_authenticator/utils/form_label.dart';
import 'package:open_authenticator/widgets/centered_circular_progress_indicator.dart';
import 'package:open_authenticator/widgets/dialog/logo_search/sources.dart';
import 'package:open_authenticator/widgets/smart_image.dart';

/// Allows to search for logos on various sources.
class LogoSearchWidget extends StatefulWidget {
  /// The initial search keywords to use.
  final String? initialSearchKeywords;

  /// Triggered when a logo has been clicked.
  final ValueChanged<String>? onLogoClicked;

  /// The logos display width.
  final double imageWidth;

  /// Creates a new Wikimedia logo search instance.
  const LogoSearchWidget({
    super.key,
    this.initialSearchKeywords,
    this.onLogoClicked,
    this.imageWidth = 100,
  });

  @override
  State<StatefulWidget> createState() => _LogoSearchWidgetState();
}

/// The Wikimedia logo search state.
class _LogoSearchWidgetState extends State<LogoSearchWidget> {
  /// The default search term.
  static const String kDefaultSearch = 'microsoft';

  /// The debounce instance.
  final Debounce debounce = Debounce();

  /// The HTTP client.
  final http.Client client = http.Client();

  /// The search keywords.
  late String? searchKeywords = widget.initialSearchKeywords;

  /// All searches triggered by the user.
  final Map<String, List<String>> searches = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debounce.milliseconds(100, search);
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextFormField(
        initialValue: searchKeywords,
        decoration: FormLabelWithIcon(
          icon: Icons.search,
          text: translations.logoSearch.keywords.text,
          hintText: translations.logoSearch.keywords.hint,
        ),
        onChanged: (value) {
          searchKeywords = value;
          debounce.milliseconds(500, search);
        },
      ),
      SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            translations.logoSearch.credits(sources: Source.sources.map((source) => source.name).join(' / ')),
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.right,
          ),
        ),
      ),
      if (searches[filteredSearchKeywords]?.isNotEmpty == true)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: widget.imageWidth / 10,
          children: [
            for (String logo in searches[filteredSearchKeywords]!) //
              buildImageWidget(logo),
          ],
        )
      else if (searches.isNotEmpty)
        const CenteredCircularProgressIndicator()
      else
        Text(
          translations.logoSearch.noLogoFound,
          textAlign: TextAlign.center,
        ),
    ],
  );

  /// Returns the search keywords, non null and lowercased.
  String get filteredSearchKeywords => searchKeywords == null || searchKeywords!.trim().isEmpty ? kDefaultSearch : searchKeywords!.toLowerCase();

  /// Triggers the search.
  Future<void> search() async {
    if (!mounted || searches.containsKey(searchKeywords)) {
      return;
    }

    setState(searches.clear);
    String keywords = filteredSearchKeywords;
    List<Uri> logos = await Source.sources.search(client, keywords);
    setState(() => searches.putIfAbsent(keywords, () => []));
    for (Uri logo in logos) {
      if (await Source.check(client, logo) && mounted && searches.containsKey(keywords)) {
        setState(() => searches[keywords]?.add(logo.toString()));
      }
      if (!searches.containsKey(keywords)) {
        break;
      }
    }
    if (searches[keywords]?.isEmpty == true) {
      setState(() => searches.remove(keywords));
    }
  }

  /// Builds the image widget that corresponds to the [imageUrl].
  Widget buildImageWidget(String imageUrl) {
    Widget image = UnconstrainedBox(
      child: SizedBox(
        width: widget.imageWidth,
        child: SmartImageWidget(
          source: imageUrl,
          height: widget.imageWidth,
          width: widget.imageWidth,
          errorBuilder: (context) => const SizedBox.shrink(),
        ),
      ),
    );
    if (kDebugMode) {
      image = Stack(
        children: [
          image,
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              imageUrl,
              style: const TextStyle(color: Colors.red, fontSize: 6),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      );
    }
    return widget.onLogoClicked == null
        ? image
        : InkWell(
            onTap: () => widget.onLogoClicked!.call(imageUrl),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: image,
            ),
          );
  }
}
