///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint

part of 'translations.g.dart';

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final translations = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _TranslationsAppUnlockEn appUnlock = _TranslationsAppUnlockEn._(_root);
	late final _TranslationsAuthenticationEn authentication = _TranslationsAuthenticationEn._(_root);
	late final _TranslationsHomeEn home = _TranslationsHomeEn._(_root);
	late final _TranslationsIntroEn intro = _TranslationsIntroEn._(_root);
	late final _TranslationsLogoSearchEn logoSearch = _TranslationsLogoSearchEn._(_root);
	late final _TranslationsMiscellaneousEn miscellaneous = _TranslationsMiscellaneousEn._(_root);
	late final _TranslationsScanEn scan = _TranslationsScanEn._(_root);
	late final _TranslationsSettingsEn settings = _TranslationsSettingsEn._(_root);
	late final _TranslationsStorageMigrationEn storageMigration = _TranslationsStorageMigrationEn._(_root);
	late final _TranslationsTotpEn totp = _TranslationsTotpEn._(_root);
	late final _TranslationsValidationEn validation = _TranslationsValidationEn._(_root);
}

// Path: appUnlock
class _TranslationsAppUnlockEn {
	_TranslationsAppUnlockEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsAppUnlockWidgetEn widget = _TranslationsAppUnlockWidgetEn._(_root);
	Map<String, String> get localAuthentication => {
		'openApp': 'Authenticate to access the app.',
		'enable': 'Authenticate to enable local authentication.',
		'disable': 'Authenticate to disable local authentication.',
	};
	late final _TranslationsAppUnlockMasterPasswordDialogEn masterPasswordDialog = _TranslationsAppUnlockMasterPasswordDialogEn._(_root);
}

// Path: authentication
class _TranslationsAuthenticationEn {
	_TranslationsAuthenticationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsAuthenticationEmailDialogEn emailDialog = _TranslationsAuthenticationEmailDialogEn._(_root);
	late final _TranslationsAuthenticationLogInEn logIn = _TranslationsAuthenticationLogInEn._(_root);
	String get linkErrorTimeout => 'Timed out while trying to link your account to this authentication provider. Please try again.';
	late final _TranslationsAuthenticationUnlinkEn unlink = _TranslationsAuthenticationUnlinkEn._(_root);
	late final _TranslationsAuthenticationProviderPickerDialogEn providerPickerDialog = _TranslationsAuthenticationProviderPickerDialogEn._(_root);
}

// Path: home
class _TranslationsHomeEn {
	_TranslationsHomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsHomeListEn list = _TranslationsHomeListEn._(_root);
	late final _TranslationsHomeAddDialogEn addDialog = _TranslationsHomeAddDialogEn._(_root);
}

// Path: intro
class _TranslationsIntroEn {
	_TranslationsIntroEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsIntroWelcomeEn welcome = _TranslationsIntroWelcomeEn._(_root);
	late final _TranslationsIntroLogInEn logIn = _TranslationsIntroLogInEn._(_root);
	late final _TranslationsIntroPasswordEn password = _TranslationsIntroPasswordEn._(_root);
	late final _TranslationsIntroButtonEn button = _TranslationsIntroButtonEn._(_root);
}

// Path: logoSearch
class _TranslationsLogoSearchEn {
	_TranslationsLogoSearchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get dialogTitle => 'Pick a logo';
	late final _TranslationsLogoSearchKeywordsEn keywords = _TranslationsLogoSearchKeywordsEn._(_root);
	String credits({required Object sources}) => 'Search results provided by ${sources}';
	String get noLogoFound => 'No logo found. Please try other keywords !';
}

// Path: miscellaneous
class _TranslationsMiscellaneousEn {
	_TranslationsMiscellaneousEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsMiscellaneousWaitingDialogEn waitingDialog = _TranslationsMiscellaneousWaitingDialogEn._(_root);
}

// Path: scan
class _TranslationsScanEn {
	_TranslationsScanEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsScanErrorEn error = _TranslationsScanErrorEn._(_root);
}

// Path: settings
class _TranslationsSettingsEn {
	_TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	late final _TranslationsSettingsApplicationEn application = _TranslationsSettingsApplicationEn._(_root);
	late final _TranslationsSettingsSecurityEn security = _TranslationsSettingsSecurityEn._(_root);
	late final _TranslationsSettingsSynchronizationEn synchronization = _TranslationsSettingsSynchronizationEn._(_root);
	late final _TranslationsSettingsBackupsEn backups = _TranslationsSettingsBackupsEn._(_root);
	late final _TranslationsSettingsAboutEn about = _TranslationsSettingsAboutEn._(_root);
}

// Path: storageMigration
class _TranslationsStorageMigrationEn {
	_TranslationsStorageMigrationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsStorageMigrationMasterPasswordDialogEn masterPasswordDialog = _TranslationsStorageMigrationMasterPasswordDialogEn._(_root);
	String get success => 'Success !';
	Map<String, String> get error => {
		'saltError': '"Salt" error while migrating your data. Please try again later.',
		'currentStoragePasswordMismatch': 'Invalid master password entered.',
		'encryptionKeyChangeFailed': 'An error occurred while encrypting your data. Please try again later.',
		'genericError': 'An error occurred while migrating your data. Please try again later.',
	};
	late final _TranslationsStorageMigrationNewStoragePasswordMismatchDialogEn newStoragePasswordMismatchDialog = _TranslationsStorageMigrationNewStoragePasswordMismatchDialogEn._(_root);
	late final _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogEn deletedTotpPolicyPickerDialog = _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogEn._(_root);
}

// Path: totp
class _TranslationsTotpEn {
	_TranslationsTotpEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsTotpActionsEn actions = _TranslationsTotpActionsEn._(_root);
	late final _TranslationsTotpDecryptDialogEn decryptDialog = _TranslationsTotpDecryptDialogEn._(_root);
	late final _TranslationsTotpPageEn page = _TranslationsTotpPageEn._(_root);
}

// Path: validation
class _TranslationsValidationEn {
	_TranslationsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get success => 'Validated with success. You can safely close this tab.';
	late final _TranslationsValidationErrorEn error = _TranslationsValidationErrorEn._(_root);
	late final _TranslationsValidationOauth2En oauth2 = _TranslationsValidationOauth2En._(_root);
	late final _TranslationsValidationGithubCodeDialogEn githubCodeDialog = _TranslationsValidationGithubCodeDialogEn._(_root);
}

// Path: appUnlock.widget
class _TranslationsAppUnlockWidgetEn {
	_TranslationsAppUnlockWidgetEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String text({required Object app}) => '${app} is locked.';
	String get button => 'Unlock';
}

// Path: appUnlock.masterPasswordDialog
class _TranslationsAppUnlockMasterPasswordDialogEn {
	_TranslationsAppUnlockMasterPasswordDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Master password';
	String get message => 'Please enter your master password to unlock the app.';
}

// Path: authentication.emailDialog
class _TranslationsAuthenticationEmailDialogEn {
	_TranslationsAuthenticationEmailDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Your email';
	String get message => 'Please enter your email, we will send you a login link.';
}

// Path: authentication.logIn
class _TranslationsAuthenticationLogInEn {
	_TranslationsAuthenticationLogInEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get waitingDialogMessage => 'Please login yourself in the opened window. Do not close the application.';
	late final _TranslationsAuthenticationLogInErrorEn error = _TranslationsAuthenticationLogInErrorEn._(_root);
	String get success => 'Logged in with success !';
	String get successNeedConfirmation => 'Success ! You will receive a confirmation email soon. Please click on the link on this device in order to log in.';
}

// Path: authentication.unlink
class _TranslationsAuthenticationUnlinkEn {
	_TranslationsAuthenticationUnlinkEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsAuthenticationUnlinkErrorEn error = _TranslationsAuthenticationUnlinkErrorEn._(_root);
	late final _TranslationsAuthenticationUnlinkConfirmationDialogEn confirmationDialog = _TranslationsAuthenticationUnlinkConfirmationDialogEn._(_root);
}

// Path: authentication.providerPickerDialog
class _TranslationsAuthenticationProviderPickerDialogEn {
	_TranslationsAuthenticationProviderPickerDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Pick a login method';
	late final _TranslationsAuthenticationProviderPickerDialogEmailEn email = _TranslationsAuthenticationProviderPickerDialogEmailEn._(_root);
	late final _TranslationsAuthenticationProviderPickerDialogGoogleEn google = _TranslationsAuthenticationProviderPickerDialogGoogleEn._(_root);
	late final _TranslationsAuthenticationProviderPickerDialogAppleEn apple = _TranslationsAuthenticationProviderPickerDialogAppleEn._(_root);
	late final _TranslationsAuthenticationProviderPickerDialogMicrosoftEn microsoft = _TranslationsAuthenticationProviderPickerDialogMicrosoftEn._(_root);
	late final _TranslationsAuthenticationProviderPickerDialogTwitterEn twitter = _TranslationsAuthenticationProviderPickerDialogTwitterEn._(_root);
	late final _TranslationsAuthenticationProviderPickerDialogGithubEn github = _TranslationsAuthenticationProviderPickerDialogGithubEn._(_root);
}

// Path: home.list
class _TranslationsHomeListEn {
	_TranslationsHomeListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get empty => 'No TOTP for the moment.\nFeel free to add one !';
	String error({required Object error}) => 'Error : ${error}. Please try to refresh the data.';
}

// Path: home.addDialog
class _TranslationsHomeAddDialogEn {
	_TranslationsHomeAddDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Add a TOTP';
	late final _TranslationsHomeAddDialogQrCodeEn qrCode = _TranslationsHomeAddDialogQrCodeEn._(_root);
	late final _TranslationsHomeAddDialogManuallyEn manually = _TranslationsHomeAddDialogManuallyEn._(_root);
}

// Path: intro.welcome
class _TranslationsIntroWelcomeEn {
	_TranslationsIntroWelcomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String firstParagraph({required Object app}) => 'Thanks for downloading ${app}, an open-source app that will help you managing your TOTPs (Time based One Time Password) with ease.';
	String get secondParagraph => 'In the following steps you will be able to configure it to match your needs.';
	String get thirdParagraph => 'I hope you will enjoy using this app as much as I have enjoyed creating it !';
}

// Path: intro.logIn
class _TranslationsIntroLogInEn {
	_TranslationsIntroLogInEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Synchronize your TOTPs';
	String get firstParagraph => 'Click on the "Log in" button below to be able synchronize your TOTPs between your devices.';
	String get secondParagraph => 'This step is completely optional.';
	String get thirdParagraph => 'Note that, if you enable this option, we will have to display some ads right in the app to contribute to the servers cost.';
	String fourthParagraph({required Object app}) => 'These ads can be removed at any time by subscribing to the Contributor Plan in the ${app} settings.';
	late final _TranslationsIntroLogInButtonEn button = _TranslationsIntroLogInButtonEn._(_root);
}

// Path: intro.password
class _TranslationsIntroPasswordEn {
	_TranslationsIntroPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Keep your data safe';
	String get firstParagraph => 'In order to keep your data safe and secure, we need you to define a master password.';
	String get secondParagraph => 'This password will be used to encrypt your data and will never be sent to any remote server.';
	String get thirdParagraph => 'Therefore, if you forget it we will not be able to recover it for you. Make sure to store it somewhere safe.';
}

// Path: intro.button
class _TranslationsIntroButtonEn {
	_TranslationsIntroButtonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get next => 'Next';
	String get finish => 'Finish';
}

// Path: logoSearch.keywords
class _TranslationsLogoSearchKeywordsEn {
	_TranslationsLogoSearchKeywordsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text => 'Keywords';
	String get hint => 'microsoft.com';
}

// Path: miscellaneous.waitingDialog
class _TranslationsMiscellaneousWaitingDialogEn {
	_TranslationsMiscellaneousWaitingDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get defaultMessage => 'Please wait...';
	String get defaultTimeoutMessage => 'Timeout occurred. Please try again later.';
	TextSpan countdown({required InlineSpan countdown}) => TextSpan(children: [
		const TextSpan(text: 'Time left : '),
		countdown,
		const TextSpan(text: '.'),
	]);
}

// Path: scan.error
class _TranslationsScanErrorEn {
	_TranslationsScanErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get noUri => 'Failed to read this QR code. Please ensure it is a valid TOTP QR code.';
	late final _TranslationsScanErrorAccessDeniedDialogEn accessDeniedDialog = _TranslationsScanErrorAccessDeniedDialogEn._(_root);
	String scanError({required Object exception}) => 'An error occurred (exception : ${exception}). Please try again later.';
}

// Path: settings.application
class _TranslationsSettingsApplicationEn {
	_TranslationsSettingsApplicationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Application';
	late final _TranslationsSettingsApplicationContributorPlanEn contributorPlan = _TranslationsSettingsApplicationContributorPlanEn._(_root);
	late final _TranslationsSettingsApplicationCacheTotpPicturesEn cacheTotpPictures = _TranslationsSettingsApplicationCacheTotpPicturesEn._(_root);
	late final _TranslationsSettingsApplicationThemeEn theme = _TranslationsSettingsApplicationThemeEn._(_root);
}

// Path: settings.security
class _TranslationsSettingsSecurityEn {
	_TranslationsSettingsSecurityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Security';
	late final _TranslationsSettingsSecurityEnableLocalAuthEn enableLocalAuth = _TranslationsSettingsSecurityEnableLocalAuthEn._(_root);
	late final _TranslationsSettingsSecuritySaveDerivedKeyEn saveDerivedKey = _TranslationsSettingsSecuritySaveDerivedKeyEn._(_root);
	late final _TranslationsSettingsSecurityChangeMasterPasswordEn changeMasterPassword = _TranslationsSettingsSecurityChangeMasterPasswordEn._(_root);
}

// Path: settings.synchronization
class _TranslationsSettingsSynchronizationEn {
	_TranslationsSettingsSynchronizationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Synchronization';
	late final _TranslationsSettingsSynchronizationAccountLinkEn accountLink = _TranslationsSettingsSynchronizationAccountLinkEn._(_root);
	late final _TranslationsSettingsSynchronizationAccountLoginEn accountLogin = _TranslationsSettingsSynchronizationAccountLoginEn._(_root);
	late final _TranslationsSettingsSynchronizationSynchronizeTotpsEn synchronizeTotps = _TranslationsSettingsSynchronizationSynchronizeTotpsEn._(_root);
}

// Path: settings.backups
class _TranslationsSettingsBackupsEn {
	_TranslationsSettingsBackupsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Backups';
	late final _TranslationsSettingsBackupsBackupNowEn backupNow = _TranslationsSettingsBackupsBackupNowEn._(_root);
	late final _TranslationsSettingsBackupsManageBackupsEn manageBackups = _TranslationsSettingsBackupsManageBackupsEn._(_root);
}

// Path: settings.about
class _TranslationsSettingsAboutEn {
	_TranslationsSettingsAboutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'About';
	late final _TranslationsSettingsAboutAboutAppEn aboutApp = _TranslationsSettingsAboutAboutAppEn._(_root);
}

// Path: storageMigration.masterPasswordDialog
class _TranslationsStorageMigrationMasterPasswordDialogEn {
	_TranslationsStorageMigrationMasterPasswordDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Master password';
	String get message => 'Please enter your master password to continue.';
}

// Path: storageMigration.newStoragePasswordMismatchDialog
class _TranslationsStorageMigrationNewStoragePasswordMismatchDialogEn {
	_TranslationsStorageMigrationNewStoragePasswordMismatchDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Storage master password';
	String get defaultMessage => 'The remote storage has been encrypted using another master password. Please enter it below in order to continue.\nNote that this will define your new master password. You can still change it at any time.';
	String get errorMessage => 'The remote storage has been encrypted using another master password. You\'ve entered a wrong one, please try again.\nNote that this will define your new master password. You can still change it at any time.';
}

// Path: storageMigration.deletedTotpPolicyPickerDialog
class _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogEn {
	_TranslationsStorageMigrationDeletedTotpPolicyPickerDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Migrate TOTPs';
	String get message => 'Some TOTPs have been deleted on this device, but not on the remote storage. What do you want to do with them ?';
	late final _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteEn delete = _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteEn._(_root);
	late final _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreEn restore = _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreEn._(_root);
}

// Path: totp.actions
class _TranslationsTotpActionsEn {
	_TranslationsTotpActionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get decrypt => 'Decrypt';
	late final _TranslationsTotpActionsMobileDialogEn mobileDialog = _TranslationsTotpActionsMobileDialogEn._(_root);
	late final _TranslationsTotpActionsDesktopButtonsEn desktopButtons = _TranslationsTotpActionsDesktopButtonsEn._(_root);
	String get copyConfirmation => 'Copied to clipboard.';
	late final _TranslationsTotpActionsDeleteConfirmationDialogEn deleteConfirmationDialog = _TranslationsTotpActionsDeleteConfirmationDialogEn._(_root);
}

// Path: totp.decryptDialog
class _TranslationsTotpDecryptDialogEn {
	_TranslationsTotpDecryptDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Decrypt TOTP';
	String get message => 'This TOTP has been encrypted using a different a master password. Please enter it below in order to decrypt it.';
	String get success => 'Success !';
	String get error => 'Invalid password entered.';
}

// Path: totp.page
class _TranslationsTotpPageEn {
	_TranslationsTotpPageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsTotpPageTitleEn title = _TranslationsTotpPageTitleEn._(_root);
	late final _TranslationsTotpPageLabelEn label = _TranslationsTotpPageLabelEn._(_root);
	late final _TranslationsTotpPageSecretEn secret = _TranslationsTotpPageSecretEn._(_root);
	late final _TranslationsTotpPageIssuerEn issuer = _TranslationsTotpPageIssuerEn._(_root);
	String get algorithm => 'Algorithm';
	String get digits => 'Digit count';
	String get validity => 'Validity (in seconds)';
	String get advancedOptions => 'Advanced options';
	String get showQrCode => 'Show QR code';
	String get save => 'Save';
	String get success => 'Success !';
	late final _TranslationsTotpPageErrorEn error = _TranslationsTotpPageErrorEn._(_root);
}

// Path: validation.error
class _TranslationsValidationErrorEn {
	_TranslationsValidationErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String incorrectPath({required Object path}) => 'Something went wrong (path is \'${path}\'). Please report this error.';
	String generic({required Object exception}) => 'Unable to validate request (exception : ${exception}). Please try again later.';
}

// Path: validation.oauth2
class _TranslationsValidationOauth2En {
	_TranslationsValidationOauth2En._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String title({required Object name}) => 'Login with ${name}';
	String loading({required Object link}) => 'Loading... Click <a href="${link}">here</a> if you are not being redirected.';
	String error({required Object name}) => 'Unable to login using ${name}. Please try again later.';
}

// Path: validation.githubCodeDialog
class _TranslationsValidationGithubCodeDialogEn {
	_TranslationsValidationGithubCodeDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Code';
	String get message => 'Please enter the following code in the opened browser tab to complete login :';
	TextSpan countdown({required InlineSpan countdown}) => TextSpan(children: [
		const TextSpan(text: 'Time left : '),
		countdown,
		const TextSpan(text: '.'),
	]);
}

// Path: authentication.logIn.error
class _TranslationsAuthenticationLogInErrorEn {
	_TranslationsAuthenticationLogInErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get generic => 'Something went wrong. Please try again later.';
	String get timeout => 'Timed out while logging in using the selected provider. Please try again.';
	late final _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogEn accountExistsWithDifferentCredentialsDialog = _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogEn._(_root);
	String get invalidCredential => 'Invalid credentials provided.';
	String get operationNotAllowed => 'Operation not allowed. This should not happen, please report this error.';
	String get userDisabled => 'Your account has been disabled.';
	String firebaseException({required Object exception}) => 'An error occurred while trying to authenticate your account (exception : ${exception}). Please try again later.';
	String exception({required Object exception}) => 'An error occurred (exception : ${exception}). Please try again later.';
}

// Path: authentication.unlink.error
class _TranslationsAuthenticationUnlinkErrorEn {
	_TranslationsAuthenticationUnlinkErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get timeout => 'Timed out while trying to unlink your account from this authentication provider. Please try again.';
}

// Path: authentication.unlink.confirmationDialog
class _TranslationsAuthenticationUnlinkConfirmationDialogEn {
	_TranslationsAuthenticationUnlinkConfirmationDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Unlink provider';
	String get message => 'Are you sure you want to unlink this authentication provider from your account ?';
}

// Path: authentication.providerPickerDialog.email
class _TranslationsAuthenticationProviderPickerDialogEmailEn {
	_TranslationsAuthenticationProviderPickerDialogEmailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Email';
	String get subtitle => 'Use your email to login. No password required, a confirmation link will be sent.';
}

// Path: authentication.providerPickerDialog.google
class _TranslationsAuthenticationProviderPickerDialogGoogleEn {
	_TranslationsAuthenticationProviderPickerDialogGoogleEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Google';
	String get subtitle => 'Sign in with your Google account.';
}

// Path: authentication.providerPickerDialog.apple
class _TranslationsAuthenticationProviderPickerDialogAppleEn {
	_TranslationsAuthenticationProviderPickerDialogAppleEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Apple';
	String get subtitle => 'Sign in with your Apple account.';
}

// Path: authentication.providerPickerDialog.microsoft
class _TranslationsAuthenticationProviderPickerDialogMicrosoftEn {
	_TranslationsAuthenticationProviderPickerDialogMicrosoftEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Microsoft';
	String get subtitle => 'Sign in with your Microsoft account.';
}

// Path: authentication.providerPickerDialog.twitter
class _TranslationsAuthenticationProviderPickerDialogTwitterEn {
	_TranslationsAuthenticationProviderPickerDialogTwitterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'X';
	String get subtitle => 'Sign in with your X account.';
}

// Path: authentication.providerPickerDialog.github
class _TranslationsAuthenticationProviderPickerDialogGithubEn {
	_TranslationsAuthenticationProviderPickerDialogGithubEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Github';
	String get subtitle => 'Sign in with your Github account.';
}

// Path: home.addDialog.qrCode
class _TranslationsHomeAddDialogQrCodeEn {
	_TranslationsHomeAddDialogQrCodeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Add using a QR code';
	String get subtitle => 'Scan a TOTP QR code and automatically add it to the app !';
}

// Path: home.addDialog.manually
class _TranslationsHomeAddDialogManuallyEn {
	_TranslationsHomeAddDialogManuallyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Add manually';
	String get subtitle => 'Manually enter your TOTP details (eg. secret, label, issuer, ...).';
}

// Path: intro.logIn.button
class _TranslationsIntroLogInButtonEn {
	_TranslationsIntroLogInButtonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loggedOut => 'Log in';
	String get waitingForConfirmation => 'Waiting for confirmation';
	String get loggedIn => 'Logged in with success';
	String get error => 'Cannot authenticate';
}

// Path: scan.error.accessDeniedDialog
class _TranslationsScanErrorAccessDeniedDialogEn {
	_TranslationsScanErrorAccessDeniedDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Access denied';
	String message({required Object exception}) => 'Failed to access your camera (access denied : ${exception}). Do you want to retry ?';
}

// Path: settings.application.contributorPlan
class _TranslationsSettingsApplicationContributorPlanEn {
	_TranslationsSettingsApplicationContributorPlanEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Contributor Plan';
	late final _TranslationsSettingsApplicationContributorPlanSubtitleEn subtitle = _TranslationsSettingsApplicationContributorPlanSubtitleEn._(_root);
	late final _TranslationsSettingsApplicationContributorPlanSubscribeEn subscribe = _TranslationsSettingsApplicationContributorPlanSubscribeEn._(_root);
	late final _TranslationsSettingsApplicationContributorPlanBillingPickerDialogEn billingPickerDialog = _TranslationsSettingsApplicationContributorPlanBillingPickerDialogEn._(_root);
}

// Path: settings.application.cacheTotpPictures
class _TranslationsSettingsApplicationCacheTotpPicturesEn {
	_TranslationsSettingsApplicationCacheTotpPicturesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Cache TOTP pictures';
	String get subtitle => 'Ensure that your TOTP pictures will always be available by caching them on your device.';
}

// Path: settings.application.theme
class _TranslationsSettingsApplicationThemeEn {
	_TranslationsSettingsApplicationThemeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Theme';
	Map<String, String> get values => {
		'system': 'System',
		'light': 'Light',
		'dark': 'Dark',
	};
}

// Path: settings.security.enableLocalAuth
class _TranslationsSettingsSecurityEnableLocalAuthEn {
	_TranslationsSettingsSecurityEnableLocalAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Enable local authentication';
	String get subtitle => 'Adds an additional security layer by asking for unlocking everytime you open the app.';
}

// Path: settings.security.saveDerivedKey
class _TranslationsSettingsSecuritySaveDerivedKeyEn {
	_TranslationsSettingsSecuritySaveDerivedKeyEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Save encryption / decryption key';
	String get subtitle => 'Save your encryption / decryption key so that you do not have to reenter your master password everytime you open the app.';
}

// Path: settings.security.changeMasterPassword
class _TranslationsSettingsSecurityChangeMasterPasswordEn {
	_TranslationsSettingsSecurityChangeMasterPasswordEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Change master password';
	TextSpan subtitle({required InlineSpanBuilder italic}) => TextSpan(children: [
		const TextSpan(text: 'You can change your master password at any time.\n'),
		italic('Note that you will have to reenter it in all your Open Authenticator instances that are synced together.'),
	]);
	late final _TranslationsSettingsSecurityChangeMasterPasswordDialogEn dialog = _TranslationsSettingsSecurityChangeMasterPasswordDialogEn._(_root);
}

// Path: settings.synchronization.accountLink
class _TranslationsSettingsSynchronizationAccountLinkEn {
	_TranslationsSettingsSynchronizationAccountLinkEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Link other providers';
	late final _TranslationsSettingsSynchronizationAccountLinkSubtitleEn subtitle = _TranslationsSettingsSynchronizationAccountLinkSubtitleEn._(_root);
}

// Path: settings.synchronization.accountLogin
class _TranslationsSettingsSynchronizationAccountLoginEn {
	_TranslationsSettingsSynchronizationAccountLoginEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsSettingsSynchronizationAccountLoginLogInEn logIn = _TranslationsSettingsSynchronizationAccountLoginLogInEn._(_root);
	late final _TranslationsSettingsSynchronizationAccountLoginConfirmEmailEn confirmEmail = _TranslationsSettingsSynchronizationAccountLoginConfirmEmailEn._(_root);
	late final _TranslationsSettingsSynchronizationAccountLoginLogOutEn logOut = _TranslationsSettingsSynchronizationAccountLoginLogOutEn._(_root);
}

// Path: settings.synchronization.synchronizeTotps
class _TranslationsSettingsSynchronizationSynchronizeTotpsEn {
	_TranslationsSettingsSynchronizationSynchronizeTotpsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Synchronize TOTPs';
	String get subtitle => 'Synchronize your TOTPs with all your logged in devices.';
}

// Path: settings.backups.backupNow
class _TranslationsSettingsBackupsBackupNowEn {
	_TranslationsSettingsBackupsBackupNowEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Backup now';
	String get subtitle => 'Backup your TOTPs now.';
	late final _TranslationsSettingsBackupsBackupNowPasswordDialogEn passwordDialog = _TranslationsSettingsBackupsBackupNowPasswordDialogEn._(_root);
	String get error => 'Error while trying to backup your data.';
	String get success => 'Success !';
}

// Path: settings.backups.manageBackups
class _TranslationsSettingsBackupsManageBackupsEn {
	_TranslationsSettingsBackupsManageBackupsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Manage backups';
	String subtitle({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
		zero: 'You do not have any backup stored.',
		one: 'You currently have ${n} backup stored.',
		other: 'You currently have ${n} backups stored.',
	);
	late final _TranslationsSettingsBackupsManageBackupsBackupsDialogEn backupsDialog = _TranslationsSettingsBackupsManageBackupsBackupsDialogEn._(_root);
	late final _TranslationsSettingsBackupsManageBackupsRestoreBackupEn restoreBackup = _TranslationsSettingsBackupsManageBackupsRestoreBackupEn._(_root);
	late final _TranslationsSettingsBackupsManageBackupsDeleteBackupEn deleteBackup = _TranslationsSettingsBackupsManageBackupsDeleteBackupEn._(_root);
}

// Path: settings.about.aboutApp
class _TranslationsSettingsAboutAboutAppEn {
	_TranslationsSettingsAboutAboutAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String title({required Object appName}) => '${appName}';
	TextSpan subtitle({required InlineSpan appName, required InlineSpan appVersion, required InlineSpan appAuthor}) => TextSpan(children: [
		appName,
		const TextSpan(text: ' v'),
		appVersion,
		const TextSpan(text: ', by '),
		appAuthor,
		const TextSpan(text: '.'),
	]);
	String dialogLegalese({required Object appName, required Object appAuthor}) => '${appName} is an open-source application, created by ${appAuthor}.';
}

// Path: storageMigration.deletedTotpPolicyPickerDialog.delete
class _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteEn {
	_TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Delete them';
	String get subtitle => 'Delete the conflicting TOTPs. This cannot be undone.';
}

// Path: storageMigration.deletedTotpPolicyPickerDialog.restore
class _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreEn {
	_TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Keep them';
	String get subtitle => 'Undo the deletion, and keep all TOTPs.';
}

// Path: totp.actions.mobileDialog
class _TranslationsTotpActionsMobileDialogEn {
	_TranslationsTotpActionsMobileDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'TOTP actions';
	String get edit => 'Edit TOTP';
	String get delete => 'Delete TOTP';
}

// Path: totp.actions.desktopButtons
class _TranslationsTotpActionsDesktopButtonsEn {
	_TranslationsTotpActionsDesktopButtonsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get copy => 'Copy code';
	String get edit => 'Edit';
	String get delete => 'Delete';
}

// Path: totp.actions.deleteConfirmationDialog
class _TranslationsTotpActionsDeleteConfirmationDialogEn {
	_TranslationsTotpActionsDeleteConfirmationDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Delete this TOTP';
	String get message => 'Do you really want to delete this TOTP ?';
	String get error => 'Failed to delete TOTP.';
}

// Path: totp.page.title
class _TranslationsTotpPageTitleEn {
	_TranslationsTotpPageTitleEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get edit => 'Edit TOTP';
	String get add => 'Add a TOTP';
}

// Path: totp.page.label
class _TranslationsTotpPageLabelEn {
	_TranslationsTotpPageLabelEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text => 'Label';
	String get hint => 'me@example.com';
}

// Path: totp.page.secret
class _TranslationsTotpPageSecretEn {
	_TranslationsTotpPageSecretEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text => 'Secret key';
	String get hint => 'JBSWY3DPEHPK3PXP';
}

// Path: totp.page.issuer
class _TranslationsTotpPageIssuerEn {
	_TranslationsTotpPageIssuerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text => 'Issuer';
	String get hint => 'example.com';
}

// Path: totp.page.error
class _TranslationsTotpPageErrorEn {
	_TranslationsTotpPageErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get save => 'Error while saving your TOTP.';
	String get qrCode => 'Please fill the "secret", "label" and "issuer" fields in order to generate a QR code.';
	String get emptySecret => 'Secret should not be empty';
	String get invalidSecret => 'Invalid secret provided';
	String get emptyLabel => 'Label should not be empty';
	String get emptyIssuer => 'Issuer should not be empty';
}

// Path: authentication.logIn.error.accountExistsWithDifferentCredentialsDialog
class _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogEn {
	_TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'An account already exists';
	String get message => 'An account with the same email address exists in our database, but the selected authentication provider has not yet been linked to it.\nPlease try to log in using an already linked authentication provider.';
}

// Path: settings.application.contributorPlan.subtitle
class _TranslationsSettingsApplicationContributorPlanSubtitleEn {
	_TranslationsSettingsApplicationContributorPlanSubtitleEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loading => 'Checking your subscription status...';
	String get active => 'You have subscribed to the Contributor Plan. Thanks a lot !';
	String get inactive => 'You currently have not subscribed to the Contributor Plan. We have to display some ads in order to contribute to the servers costs.';
}

// Path: settings.application.contributorPlan.subscribe
class _TranslationsSettingsApplicationContributorPlanSubscribeEn {
	_TranslationsSettingsApplicationContributorPlanSubscribeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogEn waitingDialog = _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogEn._(_root);
	String get success => 'You have successfully subscribed to the Contributor Plan. Thanks a lot !';
	String get error => 'An error occurred while trying to subscribe to the Contributor Plan. Please try again later.';
}

// Path: settings.application.contributorPlan.billingPickerDialog
class _TranslationsSettingsApplicationContributorPlanBillingPickerDialogEn {
	_TranslationsSettingsApplicationContributorPlanBillingPickerDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Choose your billing';
	TextSpan priceSubtitle({required InlineSpan subtitle, required InlineSpan price, required InlineSpan interval}) => TextSpan(children: [
		subtitle,
		const TextSpan(text: '\n'),
		price,
		const TextSpan(text: ' / '),
		interval,
		const TextSpan(text: '.'),
	]);
	String get empty => 'There isn\'t any option for you to subscribe to the Contributor Plan.';
	String error({required Object error}) => 'Error : ${error}.';
	Map<String, String> get packageTypeName => {
		'annual': 'Annual',
		'monthly': 'Monthly',
	};
	Map<String, String> get packageTypeInterval => {
		'annual': 'Year',
		'monthly': 'Month',
	};
	Map<String, String> get packageTypeSubtitle => {
		'annual': 'Get billed every year.',
		'monthly': 'Get billed every month.',
	};
	late final _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesEn restorePurchases = _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesEn._(_root);
}

// Path: settings.security.changeMasterPassword.dialog
class _TranslationsSettingsSecurityChangeMasterPasswordDialogEn {
	_TranslationsSettingsSecurityChangeMasterPasswordDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Change your master password';
	late final _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentEn current = _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentEn._(_root);
	String get newLabel => 'Your new master password';
	String get errorIncorrectPassword => 'Incorrect password';
}

// Path: settings.synchronization.accountLink.subtitle
class _TranslationsSettingsSynchronizationAccountLinkSubtitleEn {
	_TranslationsSettingsSynchronizationAccountLinkSubtitleEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get text => 'Link your account to other authentication providers so that you can use them to log in yourself.';
	String providers({required Object providers}) => '\nAccount currently linked to : ${providers}.';
}

// Path: settings.synchronization.accountLogin.logIn
class _TranslationsSettingsSynchronizationAccountLoginLogInEn {
	_TranslationsSettingsSynchronizationAccountLoginLogInEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Log in';
	String get subtitle => 'Log in to synchronize your TOTPs between your devices.';
}

// Path: settings.synchronization.accountLogin.confirmEmail
class _TranslationsSettingsSynchronizationAccountLoginConfirmEmailEn {
	_TranslationsSettingsSynchronizationAccountLoginConfirmEmailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Confirm your email';
	TextSpan subtitle({required InlineSpan email}) => TextSpan(children: [
		const TextSpan(text: 'A confirmation email has been sent to your email address : '),
		email,
		const TextSpan(text: '.\nPlease click on the link to finish your login. You can also tap on this tile to enter it manually.'),
	]);
	String get waitingDialogMessage => 'Please wait while we are confirming your account... Do not close the application.';
	String get error => 'Something went wrong. Please try again later.';
	String get success => 'Email confirmed with success.';
	late final _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogEn linkDialog = _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogEn._(_root);
}

// Path: settings.synchronization.accountLogin.logOut
class _TranslationsSettingsSynchronizationAccountLoginLogOutEn {
	_TranslationsSettingsSynchronizationAccountLoginLogOutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Log out';
	TextSpan subtitle({required InlineSpan email}) => TextSpan(children: [
		const TextSpan(text: 'Log out to stop synchronizing your TOTPs with this device.\nCurrently signed in as : '),
		email,
		const TextSpan(text: '.'),
	]);
}

// Path: settings.backups.backupNow.passwordDialog
class _TranslationsSettingsBackupsBackupNowPasswordDialogEn {
	_TranslationsSettingsBackupsBackupNowPasswordDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Backup password';
	String get message => 'Please enter a password for your backup. Note that we can only save the decrypted TOTPs (those that are displaying a code).';
}

// Path: settings.backups.manageBackups.backupsDialog
class _TranslationsSettingsBackupsManageBackupsBackupsDialogEn {
	_TranslationsSettingsBackupsManageBackupsBackupsDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Manage backups';
	String get errorLoadingBackups => 'Unable to load backups. Please try again later.';
}

// Path: settings.backups.manageBackups.restoreBackup
class _TranslationsSettingsBackupsManageBackupsRestoreBackupEn {
	_TranslationsSettingsBackupsManageBackupsRestoreBackupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogEn passwordDialog = _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogEn._(_root);
	String get success => 'Success !';
	String get error => 'Error while trying to restore your data. Make sure that you have entered the correct password.';
}

// Path: settings.backups.manageBackups.deleteBackup
class _TranslationsSettingsBackupsManageBackupsDeleteBackupEn {
	_TranslationsSettingsBackupsManageBackupsDeleteBackupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogEn confirmationDialog = _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogEn._(_root);
	String get success => 'Success !';
	String get error => 'Error while trying to delete this backup. Please try again later.';
}

// Path: settings.application.contributorPlan.subscribe.waitingDialog
class _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogEn {
	_TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get message => 'Waiting for your purchase...';
	String get timedOut => 'Timed out while waiting for your Contributor Plan subscription purchase. Please try again.';
}

// Path: settings.application.contributorPlan.billingPickerDialog.restorePurchases
class _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesEn {
	_TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get button => 'Restore purchases';
	String get success => 'Your purchases have been restored with success !';
	String get error => 'An error occurred. Please try again later.';
}

// Path: settings.security.changeMasterPassword.dialog.current
class _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentEn {
	_TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get label => 'Current master password';
	String get hint => 'Enter your current master password here';
}

// Path: settings.synchronization.accountLogin.confirmEmail.linkDialog
class _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogEn {
	_TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Confirmation link';
	String get message => 'Either visit the link with this device or paste it below to confirm your email address.';
}

// Path: settings.backups.manageBackups.restoreBackup.passwordDialog
class _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogEn {
	_TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Backup password';
	String get message => 'Please enter your backup password.';
}

// Path: settings.backups.manageBackups.deleteBackup.confirmationDialog
class _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogEn {
	_TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Delete backup';
	String get message => 'Do you want to delete this backup ?';
}
