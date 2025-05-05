import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:pubspec_parse/pubspec_parse.dart';

/// Run pre-build commands and run `flutter build x` where x is the desired platform.
void main() {
  exitCode = 0;
  stdout.writeln('Running `flutter clean`...');
  Process.runSync('flutter', ['clean'], runInShell: true);
  stdout.writeln('Done.');
  stdout.writeln('Running `flutter pub get`...');
  Process.runSync('flutter', ['pub', 'get'], runInShell: true);
  stdout.writeln('Done.');
  stdout.writeln('Running `dart run slang`...');
  Process.runSync('dart', ['run', 'slang'], runInShell: true);
  stdout.writeln('Done.');
  stdout.writeln('Running `dart run build_runner build --delete-conflicting-outputs`...');
  Process.runSync('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs'], runInShell: true);
  stdout.writeln('Done.');
  stdout.writeln('For which platform do you want to build ? (android/ios/macos/windows/linux)');
  String platform = stdin.readLineSync() ?? '';
  switch (platform.toLowerCase()) {
    case 'android':
      stdout.writeln('Running `flutter build appbundle`...');
      Process.runSync('flutter', ['build', 'appbundle'], runInShell: true);
      stdout.writeln('Done.');
      break;
    case 'ios':
      stdout.writeln('Updating pods...');
      Process.runSync('pod', ['update'], workingDirectory: File('ios').path, runInShell: true);
      stdout.writeln('Done.');
      stdout.writeln('Running `flutter build ios`...');
      Process.runSync('flutter', ['build', 'ios']);
      stdout.writeln('Done.');
      break;
    case 'macos':
      stdout.writeln('Updating pods...');
      Process.runSync('pod', ['update'], workingDirectory: File('macos').path, runInShell: true);
      stdout.writeln('Done.');
      stdout.writeln('Running `flutter build macos`...');
      Process.runSync('flutter', ['build', 'macos'], runInShell: true);
      stdout.writeln('Done.');
      break;
    case 'windows':
      stdout.writeln('Running `dart run msix:create`...');
      Process.runSync('dart', ['run', 'msix:create'], runInShell: true);
      stdout.writeln('Done.');
    case 'linux':
      File pubspecFile = File('./pubspec.yaml');
      if (!pubspecFile.existsSync()) {
        stderr.writeln('Cannot find pubspec.yaml at "${pubspecFile.path}".');
        return;
      }
      String pubspecContent = pubspecFile.readAsStringSync();
      Pubspec pubspec = Pubspec.parse(pubspecContent);
      if (pubspec.version == null) {
        stderr.writeln('Cannot find current version.');
        return;
      }
      stdout.writeln('Current version is "${pubspec.version}".');
      stdout.writeln('Running `snapcraft`...');
      Process.runSync('snapcraft', [], runInShell: true);
      stdout.writeln('Done.');
      String snapName = 'open-authenticator_${pubspec.version!.major}.${pubspec.version!.minor}.${pubspec.version!.patch}_amd64.snap';
      File snap = File(snapName);
      if (!snap.existsSync()) {
        stderr.writeln('Cannot find snap at "${snap.path}".');
        return;
      }
      stdout.writeln('Running `snapcraft upload --release=stable $snapName`...');
      Process.runSync('snapcraft', ['upload', '--release=stable', snapName], runInShell: true);
      stdout.writeln('Done.');
      break;
    default:
      stderr.writeln('Invalid platform.');
      exitCode = -1;
      return;
  }
  stdout.writeln('Do you want to run `flutter clean && flutter pub get` ? (Y/N)');
  String yN = stdin.readLineSync() ?? '';
  if (yN.toLowerCase() == 'y') {
    stdout.writeln('Running `flutter clean`...');
    Process.runSync('flutter', ['clean'], runInShell: true);
    stdout.writeln('Done.');
    stdout.writeln('Running `flutter pub get`...');
    Process.runSync('flutter', ['pub', 'get'], runInShell: true);
    stdout.writeln('Done.');
  }
}
