import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:conventional_commit/conventional_commit.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:yaml_magic/yaml_magic.dart';

/// The Github repo.
String repo = 'https://github.com/Skyost/OpenAuthenticator';

/// This utility :
/// - Gets what has been commited this the latest version.
/// - Generates a changelog.
/// - Bumps the version.
/// - Makes a git tag.
/// - Commit and push the changes.
/// - Create a Github release.
Future<void> main() async {
  File pubspecFile = File('./pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Cannot find pubspec.yaml at "${pubspecFile.path}".');
    return;
  }
  YamlMagic yamlMagic = YamlMagic.load(pubspecFile.path, noWatermarkComment: true);
  if (yamlMagic['version'] == null) {
    stderr.writeln('Cannot find current version.');
    return;
  }
  Version version = await Version.parse(yamlMagic['version']);
  stdout.writeln('Current version is "$version".');
  String? lastTag = await findLastTag();
  if (lastTag == null) {
    stderr.writeln('Cannot find last tag.');
    return;
  }
  stdout.writeln('Last tag is "$lastTag".');
  ProcessResult result = await Process.run(
    'git',
    ['log', '$lastTag..HEAD', '--oneline'],
    stdoutEncoding: utf8,
  );
  ChangeLogEntry changeLogEntry = ChangeLogEntry.parseGitLog(result.stdout);
  if (changeLogEntry.isEmpty) {
    stdout.writeln('Found no change.');
    return;
  }
  if (changeLogEntry.hasBreakingChange) {
    stdout.writeln('Found a breaking change.');
  } else {
    stdout.writeln('Found no breaking change.');
  }
  Version newVersion = version.bump(changeLogEntry);
  stdout.write('Proposed new version is "$newVersion", enter "Y" to continue or type a new version proposal. Type "N" to cancel. ');
  String input = stdin.readLineSync(encoding: utf8)?.toUpperCase() ?? 'N';
  if (input == 'N') {
    return;
  }
  if (input != 'Y') {
    if (!Version._versionRegex.hasMatch(input)) {
      stderr.writeln('Invalid input.');
      return;
    }
    newVersion = await Version.parse(input);
  }
  String defaultIgnoredScopes = 'docs,version,deps';
  stdout.write('Enter a comma separated list of scopes to ignore (default is "$defaultIgnoredScopes") or "Y" to continue. ');
  input = stdin.readLineSync(encoding: utf8)?.toUpperCase() ?? 'Y';
  if (input == 'Y') {
    input = defaultIgnoredScopes;
  }
  DateTime now = DateTime.now();
  String markdownEntryTitle = '## v${newVersion.toString(includeBuild: false)}';
  String markdownEntryHeader = '''$markdownEntryTitle
Released on ${DateFormat.yMMMd().format(now)}.
''';
  String markdownEntryContent = changeLogEntry.generateMarkdownContent(ignoredScopes: input.split(','));
  File changeLogFile = File('./CHANGELOG.md');
  String changeLogHeader = '# 📰 Open Authenticator Changelog';
  String changeLogContent = '''$changeLogHeader

$markdownEntryHeader
$markdownEntryContent''';
  if (changeLogFile.existsSync()) {
    String fileContent = changeLogFile.readAsStringSync();
    changeLogContent = '''$changeLogContent
${fileContent.substring(changeLogHeader.length + 2)}''';
  }
  if (!changeLogContent.startsWith(changeLogHeader)) {
    stderr.writeln('Invalid changelog.');
    return;
  }
  stdout.writeln('Writing changelog content...');
  changeLogFile.writeAsStringSync(changeLogContent);
  stdout.writeln('Done.');
  yamlMagic['version'] = newVersion.toString();
  stdout.writeln('Writing version to "pubspec.yaml" and running `flutter pub get`...');
  await yamlMagic.save();
  String pubspecContent = pubspecFile.readAsStringSync();
  if (pubspecContent.endsWith('\n\n')) {
    pubspecContent = pubspecContent.substring(0, pubspecContent.length - '\n'.length);
    pubspecFile.writeAsStringSync(pubspecContent);
  }
  await Process.run('dart', ['pub', 'get']);
  stdout.writeln('Done.');
  bool commit = askYNQuestion('Do you want to commit the changes ?');
  if (commit) {
    stdout.writeln('Committing changes...');
    await Process.run('git', ['add', 'pubspec.yaml', 'pubspec.lock', 'CHANGELOG.md'], stdoutEncoding: utf8, stderrEncoding: utf8);
    await Process.run('git', ['commit', '-m', 'chore(version): Updated version and changelog.']);
    stdout.writeln('Done.');
    bool push = askYNQuestion('Do you want to push the changes ?');
    if (push) {
      stdout.writeln('Pushing...');
      await Process.run('git', ['push', 'origin', 'main']);
      stdout.writeln('Done.');
      DotEnv env = DotEnv()..load();
      String token = env.getOrElse('GITHUB_PAT', () => '');
      if (token.isNotEmpty) {
        bool createRelease = askYNQuestion('Do you want to create a Github release ?');
        if (createRelease) {
          stdout.writeln('Creating a release on Github...');
          http.Response response = await http.post(
            Uri(
              scheme: 'https',
              host: 'api.github.com',
              path: 'repos${Uri.parse(repo).path}/releases',
            ),
            headers: {
              HttpHeaders.acceptHeader: 'application/vnd.github+json',
              HttpHeaders.authorizationHeader: 'Bearer $token',
              'X-GitHub-Api-Version': '2022-11-28',
            },
            body: jsonEncode({
              'tag_name': newVersion.toString(includeBuild: false, includePreRelease: false),
              'name': 'v${newVersion.toString(includeBuild: false, includePreRelease: false)}',
              'body': markdownEntryContent,
            })
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            stdout.writeln('Done.');
            stdout.writeln('Fetching tags...');
            await Future.delayed(const Duration(seconds: 1));
            await Process.run(
              'git',
              ['fetch', '--tags'],
              stdoutEncoding: utf8,
            );
            stdout.writeln('Done.');
          } else {
            stderr.writeln('An error occurred (status code : ${response.statusCode}).');
          }
        }
      }
    } else {
      bool createTag = askYNQuestion('Do you want to create a tag ?');
      if (createTag) {
        stdout.writeln('Creating a tag...');
        await Process.run('git', ['tag', '-a', newVersion.toString(), '-m', 'See ']);
        stdout.writeln('Done.');
      }
    }
  }
}

/// Asks a Y/N question.
bool askYNQuestion(String question) {
  stdout.write('$question (Y/N) ');
  String input = stdin.readLineSync(encoding: utf8)?.toUpperCase() ?? 'Y';
  return input == 'Y' || input == 'YES';
}

/// Finds the last tag of the current git repository.
Future<String?> findLastTag({bool autoCreate = true}) async {
  ProcessResult result = await Process.run(
    'git',
    ['describe', '--tags', '--abbrev=0'],
    stdoutEncoding: utf8,
  );
  switch (result.exitCode) {
    case 0:
      return result.stdout.replaceAll('\n', '');
    case 128:
      String? firstCommit = await findLastCommit(reverse: true);
      if (firstCommit == null) {
        return null;
      }
      await Process.run(
        'git',
        ['tag', '-a', '0.0.0', firstCommit, '-m', 'First commit.'],
      );
      return findLastTag(autoCreate: false);
  }
  return null;
}

/// Finds the last commit.
Future<String?> findLastCommit({bool reverse = false}) async {
  ProcessResult result = await Process.run(
    'git',
    ['log', '--oneline', if (reverse) '--reverse'],
    stdoutEncoding: utf8,
  );
  List<String> lines = result.stdout.split('\n');
  if (lines.isEmpty) {
    return null;
  }
  return lines.first.split(' ').first;
}

/// A simple changelog entry, containing sub-entries.
class ChangeLogEntry {
  /// The types, ordered.
  static const List<String> orderedTypes = ['feat', 'fix', 'chore'];

  /// The sub-entries (ie. messages).
  final SplayTreeMap<String, List<ConventionalCommitWithHash>> _subEntries;

  /// Whether this entry has a breaking change.
  bool hasBreakingChange;

  /// Creates a new changelog entry instance.
  ChangeLogEntry({
    SplayTreeMap<String, List<ConventionalCommitWithHash>>? subEntries,
    this.hasBreakingChange = false,
  }) : _subEntries = subEntries ?? SplayTreeMap(_compareTypes);

  /// Parses a git log and returns a changelog entry.
  static ChangeLogEntry parseGitLog(String gitLog) {
    ChangeLogEntry result = ChangeLogEntry();
    List<String> lines = gitLog.split('\n');
    for (String line in lines) {
      ConventionalCommitWithHash? commit = ConventionalCommitWithHash.tryParse(line);
      if (commit?.type == null || commit?.description == null) {
        continue;
      }
      result.addSubEntry(commit!);
    }
    return result;
  }

  /// Whether this entry is empty.
  bool get isEmpty => _subEntries.isEmpty;

  /// Adds a sub-entry to the list.
  void addSubEntry(ConventionalCommitWithHash commit) {
    List<ConventionalCommitWithHash>? commitsOfType = _subEntries[commit.type!];
    if (commitsOfType == null) {
      _subEntries[commit.type!] = [commit];
    } else {
      for (ConventionalCommitWithHash commitWithHash in commitsOfType) {
        if (commitWithHash.description == commit.description) {
          return;
        }
      }
      commitsOfType.add(commit);
      commitsOfType.sort(_compareConventionalCommits);
    }
    hasBreakingChange = hasBreakingChange || commit.isBreakingChange;
  }

  /// Allows to compare two commit types.
  static int _compareTypes(String a, String b) {
    int aIndex = orderedTypes.indexOf(a);
    int bIndex = orderedTypes.indexOf(b);
    if (aIndex == -1) {
      if (bIndex == -1) {
        return a.compareTo(b);
      }
      return -1;
    }
    return aIndex.compareTo(bIndex);
  }

  /// Compares two conventional commits based on their description.
  int _compareConventionalCommits(ConventionalCommitWithHash a, ConventionalCommitWithHash b) {
    if ((a.isBreakingChange && b.isBreakingChange) || (!a.isBreakingChange && !b.isBreakingChange)) {
      return a.description!.compareTo(b.description!);
    }
    return a.isBreakingChange ? -1 : 1;
  }

  /// Generates the Markdown content corresponding to this entry.
  String generateMarkdownContent({List<String> ignoredScopes = const []}) {
    String result = '';
    for (String type in _subEntries.keys) {
      for (ConventionalCommitWithHash entry in _subEntries[type]!) {
        if (entry.scopes.firstWhere(ignoredScopes.contains, orElse: () => '').isNotEmpty) {
          continue;
        }
        result += '* **${entry.isBreakingChange ? 'BREAKING ' : ''}${type.toUpperCase()}** : ${entry.description} ([#${entry.hash}]($repo/commit/${entry.hash}))\n';
      }
    }
    return result;
  }
}

/// Thanks to https://github.com/dartninja/version/blob/master/lib/version.dart.
class Version implements Comparable<Version> {
  /// The version regex.
  static final RegExp _versionRegex = RegExp(r'^([\d.]+)(-([0-9A-Za-z\-.]+))?(\+([0-9A-Za-z\-.]+))?$');

  /// The major number of the version, incremented when making breaking changes.
  final int major;

  /// The minor number of the version, incremented when adding new functionality in a backwards-compatible manner.
  final int minor;

  /// The patch number of the version, incremented when making backwards-compatible bug fixes.
  final int patch;

  /// Build information relevant to the version. Does not contribute to sorting.
  final String? build;

  /// Whether this is an alpha, a beta, a pre-release, ...
  final List<String> preRelease;

  /// Creates a new protocol version using the specified parameters.
  const Version._internal({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease = const [],
    this.build = '',
  });

  /*{
    assert(major != null),
    assert(minor != null),
    assert(patch != null),
    assert(build != null),
    assert(preRelease != null)
    for (int i = 0; i < preRelease.length; i++) {
      assert(preRelease[i] != null && preRelease[i].toString().trim().isNotEmpty);
      preRelease[i] = preRelease[i].toString();
      assert(_preReleaseRegex.hasMatch(preRelease[i]));
    }

    assert(build.isEmpty || _buildRegex.hasMatch(build));
    assert(major >= 0 && minor >= 0 && patch >= 0);
    assert(major > 0 || minor > 0 || patch > 0);
  }*/

  /// Creates a new version instance.
  static Future<Version> parse(String semanticVersion) async {
    RegExpMatch? match = _versionRegex.firstMatch(semanticVersion);
    String? version = match?.group(1);

    int? major, minor, patch;
    List<String>? parts = version?.split('.');
    if (parts != null) {
      major = int.parse(parts[0]);
      if (parts.length > 1) {
        minor = int.parse(parts[1]);
        if (parts.length > 2) {
          patch = int.parse(parts[2]);
        }
      }
    }

    String? preReleaseString = match?.group(3) ?? '';
    List<String> preReleaseList = [];
    if (preReleaseString.trim().isNotEmpty) {
      preReleaseList = preReleaseString.split('.');
    }

    String build = match?.group(5) ?? '';
    return Version._internal(
      major: major ?? 0,
      minor: minor ?? 0,
      patch: patch ?? 0,
      build: build,
      preRelease: preReleaseList,
    );
  }

  @override
  String toString({ bool includePreRelease = true, bool includeBuild = true }) {
    StringBuffer output = StringBuffer('$major.$minor.$patch');
    if (includePreRelease && preRelease.isNotEmpty) {
      output.write("-${preRelease.join('.')}");
    }
    if (includeBuild && build != null && build!.trim().isNotEmpty) {
      output.write('+${build!.trim()}');
    }
    return output.toString();
  }

  @override
  int get hashCode => toString().hashCode;

  int _comparePreReleases(Version other) {
    if (preRelease.isEmpty) {
      if (other.preRelease.isEmpty) {
        return 0;
      } else {
        return 1;
      }
    } else if (other.preRelease.isEmpty) {
      return -1;
    } else {
      int preReleaseMax = preRelease.length;
      if (other.preRelease.length > preRelease.length) {
        preReleaseMax = other.preRelease.length;
      }

      for (int i = 0; i < preReleaseMax; i++) {
        if (other.preRelease.length <= i) {
          return 1;
        } else if (preRelease.length <= i) {
          return -1;
        }

        if (preRelease[i] == other.preRelease[i]) {
          continue;
        }

        double? aNumber = double.tryParse(preRelease[i]);
        bool aNumeric = aNumber != null;
        double? bNumber = double.tryParse(other.preRelease[i]);
        bool bNumeric = bNumber != null;

        if (aNumeric && bNumeric) {
          if (aNumber > bNumber) {
            return 1;
          } else {
            return -1;
          }
        } else if (bNumeric) {
          return 1;
        } else if (aNumeric) {
          return -1;
        } else {
          return preRelease[i].compareTo(other.preRelease[i]);
        }
      }
    }
    return 0;
  }

  @override
  int compareTo(Version other) {
    if (major > other.major) return 1;
    if (major < other.major) return -1;

    if (minor > other.minor) return 1;
    if (minor < other.minor) return -1;

    if (patch > other.patch) return 1;
    if (patch < other.patch) return -1;

    return _comparePreReleases(other);
  }

  /// Determines whether the left-hand protocol version represents a lower precedence than the right-hand protocol version.
  bool operator <(dynamic other) => other is Version && compareTo(other) < 0;

  /// Determines whether the left-hand protocol version represents an equal or lower precedence than the right-hand protocol version.
  bool operator <=(dynamic other) => other is Version && compareTo(other) <= 0;

  /// Determines whether the left-hand protocol version represents an equal precedence to the right-hand protocol version.
  @override
  bool operator ==(dynamic other) => other is Version && compareTo(other) == 0;

  /// Determines whether the left-hand protocol version represents a greater precedence than the right-hand protocol version.
  bool operator >(dynamic other) => other is Version && compareTo(other) > 0;

  /// Determines whether the left-hand protocol version represents an equal or greater precedence than the right-hand protocol version.
  bool operator >=(dynamic other) => other is Version && compareTo(other) >= 0;

  /// Creates a new version, bumped from the current one.
  Version bump(ChangeLogEntry changeLogEntry) {
    int? buildNumber = int.tryParse(build ?? '');
    return Version._internal(
      major: major,
      minor: changeLogEntry.hasBreakingChange ? (minor + 1) : minor,
      patch: changeLogEntry.hasBreakingChange ? patch : (patch + 1),
      build: buildNumber == null ? null : (buildNumber + 1).toString(),
    );
  }
}

/// Just a wrapper for a [ConventionalCommit] holding a [hash].
class ConventionalCommitWithHash {
  /// The [ConventionalCommit] instance.
  final ConventionalCommit commit;

  /// The commit hash.
  final String hash;

  /// Creates a new conventional commit
  ConventionalCommitWithHash({
    required this.commit,
    required this.hash,
  });

  /// Tries to parse a git log line.
  static ConventionalCommitWithHash? tryParse(String gitLogLine) {
    if (!gitLogLine.startsWith(RegExp('[a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9][a-f0-9] '))) {
      return null;
    }
    ConventionalCommit? commit = ConventionalCommit.tryParse(gitLogLine.substring(8));
    if (commit == null) {
      return null;
    }
    return ConventionalCommitWithHash(
      commit: commit,
      hash: gitLogLine.substring(0, 7),
    );
  }

  /// Maps to [commit.scopes].
  List<String> get scopes => commit.scopes;

  /// Maps to [commit.type].
  String? get type => commit.type;

  /// Maps to [commit.isFeature].
  bool get isFeature => commit.isFeature;

  /// Maps to [commit.isFix].
  bool get isFix => commit.isFix;

  /// Maps to [commit.isBreakingChange].
  bool get isBreakingChange => commit.isBreakingChange;

  /// Maps to [commit.breakingChangeDescription].
  String? get breakingChangeDescription => commit.breakingChangeDescription;

  /// Maps to [commit.isMergeCommit].
  bool get isMergeCommit => commit.isMergeCommit;

  /// Maps to [commit.description].
  String? get description => commit.description;

  /// Maps to [commit.header].
  String get header => commit.header;

  /// Maps to [commit.body].
  String? get body => commit.body;

  /// Maps to [commit.footers].
  List<String> get footers => commit.footers;
}
