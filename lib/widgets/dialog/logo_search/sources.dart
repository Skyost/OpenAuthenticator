import 'dart:convert';

import 'package:http/http.dart' as http;

/// A logo search source.
mixin Source {
  /// All logo sources.
  static const List<Source> sources = [
    ClearbitSource(),
    UpLeadSource(),
    WikimediaSource(),
  ];

  /// The source name (to display attributions).
  String get name;

  /// Searches using this source.
  Future<List<String>> search(http.Client client, String userKeywords);

  /// Check whether the given [imageUrl] is good to display.
  static Future<bool> check(http.Client client, String imageUrl) async {
    http.Response response = await client.head(Uri.parse(imageUrl));
    return response.statusCode == 200;
  }
}

/// Used on sources that provide a direct download link.
mixin DirectApiSource on Source {
  /// The API path.
  String get apiPath;

  @override
  Future<List<String>> search(http.Client client, String userKeywords) => Future.value([
        '$apiPath/$userKeywords',
        '$apiPath/${userKeywords.replaceAll(' ', '')}',
        '$apiPath/${userKeywords.replaceAll(' ', '')}.com',
      ]);
}

/// Search using Wikimedia.
class WikimediaSource with Source {
  /// Creates a new Wikimedia source instance.
  const WikimediaSource();

  @override
  String get name => 'Wikimedia';

  @override
  Future<List<String>> search(http.Client client, String userKeywords) async {
    List<String> result = [];
    http.Response response = await client.get(Uri.parse(buildEndpointUrl(userKeywords)));
    Map<String, dynamic> json = jsonDecode(response.body);
    dynamic query = json['query'];
    if (query is Map<String, dynamic>) {
      dynamic search = query['search'];
      if (search is List) {
        for (dynamic element in search) {
          if (element is Map<String, dynamic>) {
            String logo = element['title'];
            if (logo.endsWith('.png') || logo.endsWith('.jpg') || logo.endsWith('.jpeg') || logo.endsWith('.tiff') || logo.endsWith('.svg')) {
              result.add(logo);
            }
          }
        }
      }
    }
    return result.map(buildImageUrl).toList();
  }

  /// The endpoint URL.
  String buildEndpointUrl(String keywords) => 'https://commons.wikimedia.org/w/api.php?action=query&format=json&list=search&srsearch=${Uri.encodeComponent(keywords)}%20logo&srnamespace=6&srlimit=20';

  /// Builds the image URL.
  String buildImageUrl(String imageFile) => 'https://commons.wikimedia.org/wiki/Special:FilePath/$imageFile';
}

/// Search using Clearbit.
class ClearbitSource with Source, DirectApiSource {
  /// Creates a new Clearbit source instance.
  const ClearbitSource();

  @override
  String get name => 'Clearbit';

  @override
  String get apiPath => 'https://logo.clearbit.com';
}

/// Search using UpLead.
class UpLeadSource with Source, DirectApiSource {
  /// Creates a new UpLead source instance.
  const UpLeadSource();

  @override
  String get name => 'UpLead';

  @override
  String get apiPath => 'https://logo.uplead.com';
}

/// Allows to quickly search on a source list.
extension Search on List<Source> {
  /// Searches using these sources, avoiding errors.
  Future<List<String>> search(http.Client client, String userKeywords) async => [
        for (Source source in this) //
          ...await source.search(client, userKeywords),
      ];
}
