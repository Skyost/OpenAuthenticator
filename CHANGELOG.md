# 📰 Open Authenticator Changelog

## v1.1.3
Released on Jan 21, 2025.

* **FIX** : Fixed a problem with permissions on iOS. ([#6f330ab](https://github.com/Skyost/OpenAuthenticator/commit/6f330ab))
* **FIX** : Fixed various problems with backups. ([#68e16bd](https://github.com/Skyost/OpenAuthenticator/commit/68e16bd))

## v1.1.2
Released on Jan 21, 2025.

* **REFACTOR** : Put all settings entry widgets at the same place and copying URLs if they can't be opened. ([#f1d51c6](https://github.com/Skyost/OpenAuthenticator/commit/f1d51c6))
* **FEAT** : Improved backup manager. ([#6f0e559](https://github.com/Skyost/OpenAuthenticator/commit/6f0e559))
* **FIX** : Fixed some icons display in the settings page. ([#38de554](https://github.com/Skyost/OpenAuthenticator/commit/38de554))
* **CHORE** : Updated top padding on intro page. ([#3404fbd](https://github.com/Skyost/OpenAuthenticator/commit/3404fbd))

## v1.1.1
Released on Jan 13, 2025.

* **FIX** : Better handling of HTTPS links in the app settings. ([#78c5cf3](https://github.com/Skyost/OpenAuthenticator/commit/78c5cf3))

## v1.1.0
Released on Jan 11, 2025.

* **REFACTOR** : More coherence with `try` functions in unlock methods. ([#02c29fd](https://github.com/Skyost/OpenAuthenticator/commit/02c29fd))
* **REFACTOR** : Riverpod notifiers fields are now private. ([#f1fbe0b](https://github.com/Skyost/OpenAuthenticator/commit/f1fbe0b))
* **REFACTOR** : Using `Navigator.defaultRouteName` instead of `/` and `logIn` instead of `login`. ([#f83d479](https://github.com/Skyost/OpenAuthenticator/commit/f83d479))
* **FEAT** : Added a link to the translation platform in the app settings. ([#c0013eb](https://github.com/Skyost/OpenAuthenticator/commit/c0013eb))
* **FEAT** : Now allowing to decrypt and save more than one TOTP on home page. ([#a73b9db](https://github.com/Skyost/OpenAuthenticator/commit/a73b9db))
* **FIX** : Fixed a bug where text fields were not accepting any input after local authentication. ([#152628e](https://github.com/Skyost/OpenAuthenticator/commit/152628e))
* **FIX** : Only scanning one QR code at once. ([#82e0770](https://github.com/Skyost/OpenAuthenticator/commit/82e0770))
* **FIX** : Various fixes with deep links. ([#4da5b09](https://github.com/Skyost/OpenAuthenticator/commit/4da5b09))
* **CHORE** : Improved Windows icon. ([#250c50f](https://github.com/Skyost/OpenAuthenticator/commit/250c50f))
* **CHORE** : Not storing the common salt using `Storage`. ([#f23577a](https://github.com/Skyost/OpenAuthenticator/commit/f23577a))
* **CHORE** : Saving shared preferences in a different file in debug mode. ([#7ea7b1e](https://github.com/Skyost/OpenAuthenticator/commit/7ea7b1e))

## v1.0.8
Released on Nov 4, 2024.

* **FEAT** : Now directly copying TOTP code when tapped on by search (if enabled in the app settings). ([#e1d2447](https://github.com/Skyost/OpenAuthenticator/commit/e1d2447))
* **CHORE** : Now using `mobile_scanner` instead of `google_mlkit_barcode_scanning`. ([#f684564](https://github.com/Skyost/OpenAuthenticator/commit/f684564))

## v1.0.7
Released on Oct 28, 2024.

* **FEAT** : Added the ability to export a given backup. Fixes #3. ([#5a7ce70](https://github.com/Skyost/OpenAuthenticator/commit/5a7ce70))
* **FEAT** : Improved `ExpandListTile` widget with an animation. ([#2cd61bc](https://github.com/Skyost/OpenAuthenticator/commit/2cd61bc))
* **FIX** : Better handling of durations. Fixes #4. ([#61b58f4](https://github.com/Skyost/OpenAuthenticator/commit/61b58f4))

## v1.0.6
Released on Oct 24, 2024.

* **FEAT** : Added a fade-in to `SmartImageWidget`. ([#69be9e9](https://github.com/Skyost/OpenAuthenticator/commit/69be9e9))
* **FEAT** : Dropped `flutter_svg` support in favor of `jovial_svg`. ([#dbb7302](https://github.com/Skyost/OpenAuthenticator/commit/dbb7302))
* **FEAT** : Improved overall app speed by compiling SVG files into SI. ([#27c9d4f](https://github.com/Skyost/OpenAuthenticator/commit/27c9d4f))
* **FIX** : Fixed some SI files that were not loading. ([#be0cf0c](https://github.com/Skyost/OpenAuthenticator/commit/be0cf0c))
* **CHORE** : Did some refactoring with `jovial_svg`. ([#e230f94](https://github.com/Skyost/OpenAuthenticator/commit/e230f94))
* **CHORE** : Made `SizedScalableImageWidget` only supporting project assets, not files. ([#9f60f63](https://github.com/Skyost/OpenAuthenticator/commit/9f60f63))
* **CHORE** : Various improvements made to `SmartImageWidget`. ([#eabba24](https://github.com/Skyost/OpenAuthenticator/commit/eabba24))

## v1.0.5
Released on Jul 25, 2024.

* **FIX** : Fixed a problem with Firebase authentication. ([#23e5f25](https://github.com/Skyost/OpenAuthenticator/commit/23e5f25))

## v1.0.4
Released on Jul 25, 2024.

* **FEAT** : Added a settings entry for displaying a copy button next to TOTPs. ([#0f040e0](https://github.com/Skyost/OpenAuthenticator/commit/0f040e0))
* **FEAT** : Fully localized `local_auth` messages. ([#8625688](https://github.com/Skyost/OpenAuthenticator/commit/8625688))
* **FIX** : Fixed a bug where the search page was displaying wrong TOTP codes. ([#f738109](https://github.com/Skyost/OpenAuthenticator/commit/f738109))
* **FIX** : Fixed an error occurring with type casting. ([#e7f82e1](https://github.com/Skyost/OpenAuthenticator/commit/e7f82e1))
* **FIX** : Fixed app exiting on iOS. ([#7e8c8f2](https://github.com/Skyost/OpenAuthenticator/commit/7e8c8f2))

## v1.0.3
Released on Jul 12, 2024.

* **FEAT** : Added a back button to the scan page. ([#756794f](https://github.com/Skyost/OpenAuthenticator/commit/756794f))
* **FEAT** : Added a fallback paywall. ([#e9c9f8a](https://github.com/Skyost/OpenAuthenticator/commit/e9c9f8a))
* **FEAT** : Added a settings entry for clearing all data. ([#db2bc6e](https://github.com/Skyost/OpenAuthenticator/commit/db2bc6e))
* **FEAT** : Implemented a search button. ([#8f92304](https://github.com/Skyost/OpenAuthenticator/commit/8f92304))
* **FIX** : Fixed a bug with the image cache. ([#087101c](https://github.com/Skyost/OpenAuthenticator/commit/087101c))
* **FIX** : Fixed a problem with deep links callbacks being triggered multiple times. ([#94f0c29](https://github.com/Skyost/OpenAuthenticator/commit/94f0c29))
* **FIX** : Not displaying desktop action on mobile in debug mode anymore. ([#7467218](https://github.com/Skyost/OpenAuthenticator/commit/7467218))
* **CHORE** : Not using the same storage location in debug mode. ([#23e5b47](https://github.com/Skyost/OpenAuthenticator/commit/23e5b47))
* **CHORE** : Removed some safe margins. ([#67f51a5](https://github.com/Skyost/OpenAuthenticator/commit/67f51a5))

## v1.0.2
Released on Jul 11, 2024.

* **FEAT** : Added a cache manager for easily handling cached images. ([#9b6b2d2](https://github.com/Skyost/OpenAuthenticator/commit/9b6b2d2))
* **FEAT** : Lowercase secrets are now accepted. ([#07d9aba](https://github.com/Skyost/OpenAuthenticator/commit/07d9aba))
* **FIX** : Fixed errors with secret validation. ([#6f61c3c](https://github.com/Skyost/OpenAuthenticator/commit/6f61c3c))

## v1.0.1
Released on Jul 11, 2024.

* **FIX** : Fixed an issue with QR code scanning on Android. ([#d711b50](https://github.com/Skyost/OpenAuthenticator/commit/d711b50))
* **FIX** : Fixed some remaining problems with QR code scanning and URI parsing. ([#be3a739](https://github.com/Skyost/OpenAuthenticator/commit/be3a739))
* **FIX** : Fixed various problems with deep links. ([#dcfa646](https://github.com/Skyost/OpenAuthenticator/commit/dcfa646))

## v1.0.0
Released on Jul 11, 2024.

* **FEAT** : Added `otpauth` protocol support on Android. ([#b0de12d](https://github.com/Skyost/OpenAuthenticator/commit/b0de12d))
* **FEAT** : Added a way to clear a RevenueCat user cache. ([#6d0904c](https://github.com/Skyost/OpenAuthenticator/commit/6d0904c))
* **FEAT** : Enabled `otpauth` protocol support on iOS. ([#ba3aded](https://github.com/Skyost/OpenAuthenticator/commit/ba3aded))
* **BREAKING FIX** : Fixed incorrect TOTP generation. ([#42c6801](https://github.com/Skyost/OpenAuthenticator/commit/42c6801))
* **FIX** : Fixed various Firebase related problems. ([#2e06a5b](https://github.com/Skyost/OpenAuthenticator/commit/2e06a5b))
* **FIX** : Fixed various remaining bugs. ([#48e3a2b](https://github.com/Skyost/OpenAuthenticator/commit/48e3a2b))
* **CHORE** : Removed various remaining `print` calls. ([#cb3254f](https://github.com/Skyost/OpenAuthenticator/commit/cb3254f))
* **CHORE** : Updated README. ([#a34df82](https://github.com/Skyost/OpenAuthenticator/commit/a34df82))
* **CHORE** : Updated dependencies. ([#6805c3e](https://github.com/Skyost/OpenAuthenticator/commit/6805c3e))
