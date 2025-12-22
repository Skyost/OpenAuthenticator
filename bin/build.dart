import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:pubspec_parse/pubspec_parse.dart';

/// Run pre-build commands and run `flutter build x` where x is the desired platform.
void main() {
  exitCode = 0;
  stdout.writeln('Running `flutter clean`...');
  runSync('flutter', ['clean']);
  stdout.writeln('Done.');
  stdout.writeln('Running `flutter pub get`...');
  runSync('flutter', ['pub', 'get']);
  stdout.writeln('Done.');
  stdout.writeln('Running `dart run build_runner build --delete-conflicting-outputs`...');
  runSync('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
  stdout.writeln('Done.');
  stdout.writeln('Running `dart run slang`...');
  runSync('dart', ['run', 'slang']);
  stdout.writeln('Done.');
  stdout.writeln('For which platform do you want to build ? (android/ios/macos/windows/linux)');
  String platform = stdin.readLineSync() ?? '';
  switch (platform.toLowerCase()) {
    case 'android':
      stdout.writeln('Running `flutter build appbundle`...');
      runSync('flutter', ['build', 'appbundle']);
      stdout.writeln('Done.');
      break;
    case 'ios':
      stdout.writeln('Updating pods...');
      runSync('pod', ['update'], workingDirectory: File('ios').path);
      stdout.writeln('Done.');
      stdout.writeln('Running `flutter build ios`...');
      runSync('flutter', ['build', 'ios']);
      stdout.writeln('Done.');
      break;
    case 'macos':
      stdout.writeln('Updating pods...');
      runSync('pod', ['update'], workingDirectory: File('macos').path);
      stdout.writeln('Done.');
      stdout.writeln('Running `flutter build macos`...');
      runSync('flutter', ['build', 'macos']);
      stdout.writeln('Done.');
      break;
    case 'windows':
      stdout.writeln('Running `dart run msix:create`...');
      runSync('dart', ['run', 'msix:create']);
      stdout.writeln('Done.');
    case 'linux':
      stdout.writeln('For which variant do you want to build ? (snap/flatpak)');
      String variant = stdin.readLineSync() ?? '';
      switch (variant) {
        case 'snap':
          File pubspecFile = File('./pubspec.yaml');
          if (!pubspecFile.existsSync()) {
            stderr.writeln('Cannot find pubspec.yaml at "${pubspecFile.path}".');
            break;
          }
          String pubspecContent = pubspecFile.readAsStringSync();
          Pubspec pubspec = Pubspec.parse(pubspecContent);
          if (pubspec.version == null) {
            stderr.writeln('Cannot find current version.');
            break;
          }
          stdout.writeln('Current version is "${pubspec.version}".');
          stdout.writeln('Running `snapcraft`...');
          runSync('snapcraft', []);
          stdout.writeln('Done.');
          String snapName = 'open-authenticator_${pubspec.version!.major}.${pubspec.version!.minor}.${pubspec.version!.patch}_amd64.snap';
          File snap = File(snapName);
          if (!snap.existsSync()) {
            stderr.writeln('Cannot find snap at "${snap.path}".');
            break;
          }
          stdout.writeln('Do you want to upload it ? (Y/N)');
          String yN = stdin.readLineSync() ?? '';
          if (yN.toLowerCase() == 'y') {
            stdout.writeln('Running `snapcraft upload --release=stable $snapName`...');
            runSync('snapcraft', ['upload', '--release=stable', snapName]);
            stdout.writeln('Done.');
          }
          break;
        case 'flatpak':
          stdout.writeln('Building Docker image...');
          runSync('docker', ['build', '--platform', 'linux/amd64', '-t', 'flutterpack:1.0.0', './flatpak']);
          stdout.writeln('Done.');
          stdout.writeln('Building Flatpak file...');
          runSync('docker', ['run', '--rm', '--privileged', '--platform', 'linux/amd64', '-u', 'root', '-v', './work', '-w', '/work/flatpak', 'flutterpack:1.0.0', './build-flutter-app.sh']);
          stdout.writeln('Done.');
          break;
        default:
          stderr.writeln('Invalid variant.');
          exitCode = -1;
          return;
      }
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
    runSync('flutter', ['clean']);
    stdout.writeln('Done.');
    stdout.writeln('Running `flutter pub get`...');
    runSync('flutter', ['pub', 'get']);
    stdout.writeln('Done.');
  }
}

void runSync(String executable, List<String> arguments, {String? workingDirectory}) {
  ProcessResult result = Process.runSync(executable, arguments);
  if (result.exitCode != 0) {
    stderr.writeln('Error : ${result.stderr}');
    stderr.write(result.stderr);
    exitCode = result.exitCode;
  } else if (result.stdout.isNotEmpty) {
    stdout.write(result.stdout);
  }
}
