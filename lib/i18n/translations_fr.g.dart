///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint

part of 'translations.g.dart';

// Path: <root>
class _TranslationsFr extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsFr.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsFr _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppUnlockFr appUnlock = _TranslationsAppUnlockFr._(_root);
	@override late final _TranslationsAuthenticationFr authentication = _TranslationsAuthenticationFr._(_root);
	@override late final _TranslationsHomeFr home = _TranslationsHomeFr._(_root);
	@override late final _TranslationsIntroFr intro = _TranslationsIntroFr._(_root);
	@override late final _TranslationsLogoSearchFr logoSearch = _TranslationsLogoSearchFr._(_root);
	@override late final _TranslationsMiscellaneousFr miscellaneous = _TranslationsMiscellaneousFr._(_root);
	@override late final _TranslationsScanFr scan = _TranslationsScanFr._(_root);
	@override late final _TranslationsSettingsFr settings = _TranslationsSettingsFr._(_root);
	@override late final _TranslationsStorageMigrationFr storageMigration = _TranslationsStorageMigrationFr._(_root);
	@override late final _TranslationsTotpFr totp = _TranslationsTotpFr._(_root);
	@override late final _TranslationsValidationFr validation = _TranslationsValidationFr._(_root);
}

// Path: appUnlock
class _TranslationsAppUnlockFr extends _TranslationsAppUnlockEn {
	_TranslationsAppUnlockFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppUnlockWidgetFr widget = _TranslationsAppUnlockWidgetFr._(_root);
	@override Map<String, String> get localAuthentication => {
		'openApp': 'Authentifiez-vous pour accéder à l\'application.',
		'enable': 'Authentifiez-vous pour activer l\'authentification locale.',
		'disable': 'Authentifiez-vous pour désactiver l\'authentification locale.',
	};
	@override late final _TranslationsAppUnlockMasterPasswordDialogFr masterPasswordDialog = _TranslationsAppUnlockMasterPasswordDialogFr._(_root);
}

// Path: authentication
class _TranslationsAuthenticationFr extends _TranslationsAuthenticationEn {
	_TranslationsAuthenticationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuthenticationEmailDialogFr emailDialog = _TranslationsAuthenticationEmailDialogFr._(_root);
	@override late final _TranslationsAuthenticationLogInFr logIn = _TranslationsAuthenticationLogInFr._(_root);
	@override String get linkErrorTimeout => 'Délai d\'attente dépassé pendant la liaison de votre compte au fournisseur d\'authentification. Veuillez réessayer.';
	@override late final _TranslationsAuthenticationUnlinkFr unlink = _TranslationsAuthenticationUnlinkFr._(_root);
	@override late final _TranslationsAuthenticationProviderPickerDialogFr providerPickerDialog = _TranslationsAuthenticationProviderPickerDialogFr._(_root);
}

// Path: home
class _TranslationsHomeFr extends _TranslationsHomeEn {
	_TranslationsHomeFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsHomeListFr list = _TranslationsHomeListFr._(_root);
	@override late final _TranslationsHomeAddDialogFr addDialog = _TranslationsHomeAddDialogFr._(_root);
}

// Path: intro
class _TranslationsIntroFr extends _TranslationsIntroEn {
	_TranslationsIntroFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsIntroWelcomeFr welcome = _TranslationsIntroWelcomeFr._(_root);
	@override late final _TranslationsIntroLogInFr logIn = _TranslationsIntroLogInFr._(_root);
	@override late final _TranslationsIntroPasswordFr password = _TranslationsIntroPasswordFr._(_root);
	@override late final _TranslationsIntroButtonFr button = _TranslationsIntroButtonFr._(_root);
}

// Path: logoSearch
class _TranslationsLogoSearchFr extends _TranslationsLogoSearchEn {
	_TranslationsLogoSearchFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Choisissez un logo';
	@override late final _TranslationsLogoSearchKeywordsFr keywords = _TranslationsLogoSearchKeywordsFr._(_root);
	@override String credits({required Object sources}) => 'Résultats fournis par ${sources}';
	@override String get noLogoFound => 'Pas de logo trouvé. Veuillez essayer d\'autres mots-clés !';
}

// Path: miscellaneous
class _TranslationsMiscellaneousFr extends _TranslationsMiscellaneousEn {
	_TranslationsMiscellaneousFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMiscellaneousWaitingDialogFr waitingDialog = _TranslationsMiscellaneousWaitingDialogFr._(_root);
}

// Path: scan
class _TranslationsScanFr extends _TranslationsScanEn {
	_TranslationsScanFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsScanErrorFr error = _TranslationsScanErrorFr._(_root);
}

// Path: settings
class _TranslationsSettingsFr extends _TranslationsSettingsEn {
	_TranslationsSettingsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres';
	@override late final _TranslationsSettingsApplicationFr application = _TranslationsSettingsApplicationFr._(_root);
	@override late final _TranslationsSettingsSecurityFr security = _TranslationsSettingsSecurityFr._(_root);
	@override late final _TranslationsSettingsSynchronizationFr synchronization = _TranslationsSettingsSynchronizationFr._(_root);
	@override late final _TranslationsSettingsBackupsFr backups = _TranslationsSettingsBackupsFr._(_root);
	@override late final _TranslationsSettingsAboutFr about = _TranslationsSettingsAboutFr._(_root);
}

// Path: storageMigration
class _TranslationsStorageMigrationFr extends _TranslationsStorageMigrationEn {
	_TranslationsStorageMigrationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsStorageMigrationMasterPasswordDialogFr masterPasswordDialog = _TranslationsStorageMigrationMasterPasswordDialogFr._(_root);
	@override String get success => 'Succès !';
	@override Map<String, String> get error => {
		'saltError': 'Erreur de "Sel" pendant la migration de vos données. Veuillez réessayer plus tard.',
		'currentStoragePasswordMismatch': 'Mot de passe maître invalide.',
		'encryptionKeyChangeFailed': 'Une erreur est survenue pendant le chiffrement de vos données. Veuillez réessayer plus tard.',
		'genericError': 'Une erreur est survenue pendant la migration de vos données. Veuillez réessayer plus tard.',
	};
	@override late final _TranslationsStorageMigrationNewStoragePasswordMismatchDialogFr newStoragePasswordMismatchDialog = _TranslationsStorageMigrationNewStoragePasswordMismatchDialogFr._(_root);
	@override late final _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogFr deletedTotpPolicyPickerDialog = _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogFr._(_root);
}

// Path: totp
class _TranslationsTotpFr extends _TranslationsTotpEn {
	_TranslationsTotpFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTotpActionsFr actions = _TranslationsTotpActionsFr._(_root);
	@override late final _TranslationsTotpDecryptDialogFr decryptDialog = _TranslationsTotpDecryptDialogFr._(_root);
	@override late final _TranslationsTotpPageFr page = _TranslationsTotpPageFr._(_root);
}

// Path: validation
class _TranslationsValidationFr extends _TranslationsValidationEn {
	_TranslationsValidationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get success => 'Validation réussie. Vous pouvez fermer cet onglet.';
	@override late final _TranslationsValidationErrorFr error = _TranslationsValidationErrorFr._(_root);
	@override late final _TranslationsValidationOauth2Fr oauth2 = _TranslationsValidationOauth2Fr._(_root);
	@override late final _TranslationsValidationGithubCodeDialogFr githubCodeDialog = _TranslationsValidationGithubCodeDialogFr._(_root);
}

// Path: appUnlock.widget
class _TranslationsAppUnlockWidgetFr extends _TranslationsAppUnlockWidgetEn {
	_TranslationsAppUnlockWidgetFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String text({required Object app}) => '${app} est verrouillée.';
	@override String get button => 'Déverrouiller';
}

// Path: appUnlock.masterPasswordDialog
class _TranslationsAppUnlockMasterPasswordDialogFr extends _TranslationsAppUnlockMasterPasswordDialogEn {
	_TranslationsAppUnlockMasterPasswordDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mot de passe maître';
	@override String get message => 'Veuillez entrer votre mot de passe maître pour déverrouiller l\'application.';
}

// Path: authentication.emailDialog
class _TranslationsAuthenticationEmailDialogFr extends _TranslationsAuthenticationEmailDialogEn {
	_TranslationsAuthenticationEmailDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Votre adresse mail';
	@override String get message => 'Veuillez entrer votre adresse mail, nous vous enverrons un lien de connexion.';
}

// Path: authentication.logIn
class _TranslationsAuthenticationLogInFr extends _TranslationsAuthenticationLogInEn {
	_TranslationsAuthenticationLogInFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get waitingDialogMessage => 'Veuillez vous connecter dans la fenêtre qui vient de s\'ouvrir. Ne fermez pas l\'application.';
	@override late final _TranslationsAuthenticationLogInErrorFr error = _TranslationsAuthenticationLogInErrorFr._(_root);
	@override String get success => 'Connexion réussie !';
	@override String get successNeedConfirmation => 'Succès ! Vous recevrez un email de confirmation bientôt. Veuillez cliquer sur le lien qui se trouve à l\'intérieur avec cet appareil pour poursuivre la connexion.';
}

// Path: authentication.unlink
class _TranslationsAuthenticationUnlinkFr extends _TranslationsAuthenticationUnlinkEn {
	_TranslationsAuthenticationUnlinkFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuthenticationUnlinkErrorFr error = _TranslationsAuthenticationUnlinkErrorFr._(_root);
	@override late final _TranslationsAuthenticationUnlinkConfirmationDialogFr confirmationDialog = _TranslationsAuthenticationUnlinkConfirmationDialogFr._(_root);
}

// Path: authentication.providerPickerDialog
class _TranslationsAuthenticationProviderPickerDialogFr extends _TranslationsAuthenticationProviderPickerDialogEn {
	_TranslationsAuthenticationProviderPickerDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pick a login method';
	@override late final _TranslationsAuthenticationProviderPickerDialogEmailFr email = _TranslationsAuthenticationProviderPickerDialogEmailFr._(_root);
	@override late final _TranslationsAuthenticationProviderPickerDialogGoogleFr google = _TranslationsAuthenticationProviderPickerDialogGoogleFr._(_root);
	@override late final _TranslationsAuthenticationProviderPickerDialogAppleFr apple = _TranslationsAuthenticationProviderPickerDialogAppleFr._(_root);
	@override late final _TranslationsAuthenticationProviderPickerDialogMicrosoftFr microsoft = _TranslationsAuthenticationProviderPickerDialogMicrosoftFr._(_root);
	@override late final _TranslationsAuthenticationProviderPickerDialogTwitterFr twitter = _TranslationsAuthenticationProviderPickerDialogTwitterFr._(_root);
	@override late final _TranslationsAuthenticationProviderPickerDialogGithubFr github = _TranslationsAuthenticationProviderPickerDialogGithubFr._(_root);
}

// Path: home.list
class _TranslationsHomeListFr extends _TranslationsHomeListEn {
	_TranslationsHomeListFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Pas de TOTP pour le moment.\nEssayez d\'en ajouter un !';
	@override String error({required Object error}) => 'Erreur : ${error}. Veuillez réessayer de rafraîchir les données.';
}

// Path: home.addDialog
class _TranslationsHomeAddDialogFr extends _TranslationsHomeAddDialogEn {
	_TranslationsHomeAddDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajouter un TOTP';
	@override late final _TranslationsHomeAddDialogQrCodeFr qrCode = _TranslationsHomeAddDialogQrCodeFr._(_root);
	@override late final _TranslationsHomeAddDialogManuallyFr manually = _TranslationsHomeAddDialogManuallyFr._(_root);
}

// Path: intro.welcome
class _TranslationsIntroWelcomeFr extends _TranslationsIntroWelcomeEn {
	_TranslationsIntroWelcomeFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String firstParagraph({required Object app}) => 'Merci d\'avoir téléchargé ${app}, une application open-source qui va vous aider à tranquillement gérer vos TOTPs (Time based One Time Password).';
	@override String get secondParagraph => 'Vous allez pouvoir configurer l\'application au cours des prochaines étapes pour qu\'elle ressemble à ce que vous souhaitez.';
	@override String get thirdParagraph => 'J\'espère que vous aimerez utiliser cette application autant que j\'ai aimé la créer !';
}

// Path: intro.logIn
class _TranslationsIntroLogInFr extends _TranslationsIntroLogInEn {
	_TranslationsIntroLogInFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Synchroniser vos TOTPs';
	@override String get firstParagraph => 'Cliquer sur le bouton "Connexion" ci-dessous pour synchroniser vos TOTPs entre vos appareils.';
	@override String get secondParagraph => 'Cette étape est complètement optionnelle.';
	@override String get thirdParagraph => 'Veuillez noter que, si vous activez cette option, nous devrons afficher des annonces dans l\'application pour contribuer au coût des serveurs.';
	@override String fourthParagraph({required Object app}) => 'Ces annonces peuvent être supprimés à tout moment en souscrivant à l\'Abonnement Contributeur dans les paramètres d\'${app}.';
	@override late final _TranslationsIntroLogInButtonFr button = _TranslationsIntroLogInButtonFr._(_root);
}

// Path: intro.password
class _TranslationsIntroPasswordFr extends _TranslationsIntroPasswordEn {
	_TranslationsIntroPasswordFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gardez vos données au chaud';
	@override String get firstParagraph => 'Pour que vos données restent sécurisées, nous devons vous demander de définir un mot de passe maître.';
	@override String get secondParagraph => 'Ce mot de passe sera utilisé pour chiffrer vos données et ne sera jamais envoyé à aucun serveur distant.';
	@override String get thirdParagraph => 'Ainsi, si vous l\'oubliez, nous ne pourrons pas le retrouver pour vous. Assurez-vous de l\'enregistrer dans un endroit sécurisé.';
}

// Path: intro.button
class _TranslationsIntroButtonFr extends _TranslationsIntroButtonEn {
	_TranslationsIntroButtonFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get next => 'Suivant';
	@override String get finish => 'Terminer';
}

// Path: logoSearch.keywords
class _TranslationsLogoSearchKeywordsFr extends _TranslationsLogoSearchKeywordsEn {
	_TranslationsLogoSearchKeywordsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get text => 'Mots-clés';
	@override String get hint => 'microsoft.com';
}

// Path: miscellaneous.waitingDialog
class _TranslationsMiscellaneousWaitingDialogFr extends _TranslationsMiscellaneousWaitingDialogEn {
	_TranslationsMiscellaneousWaitingDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get defaultMessage => 'Veuillez patienter...';
	@override String get defaultTimeoutMessage => 'Délai d\'attente dépassé. Veuillez réessayer plus tard.';
	@override TextSpan countdown({required InlineSpan countdown}) => TextSpan(children: [
		const TextSpan(text: 'Temps restant : '),
		countdown,
		const TextSpan(text: '.'),
	]);
}

// Path: scan.error
class _TranslationsScanErrorFr extends _TranslationsScanErrorEn {
	_TranslationsScanErrorFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get noUri => 'Impossible de lire ce QR code. Assurez-vous qu\'il s\'agit d\'un QR code de TOTP valide.';
	@override late final _TranslationsScanErrorAccessDeniedDialogFr accessDeniedDialog = _TranslationsScanErrorAccessDeniedDialogFr._(_root);
	@override String scanError({required Object exception}) => 'Une erreur est survenue (erruer : ${exception}). Veuillez réessayer plus tard.';
}

// Path: settings.application
class _TranslationsSettingsApplicationFr extends _TranslationsSettingsApplicationEn {
	_TranslationsSettingsApplicationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Application';
	@override late final _TranslationsSettingsApplicationContributorPlanFr contributorPlan = _TranslationsSettingsApplicationContributorPlanFr._(_root);
	@override late final _TranslationsSettingsApplicationCacheTotpPicturesFr cacheTotpPictures = _TranslationsSettingsApplicationCacheTotpPicturesFr._(_root);
	@override late final _TranslationsSettingsApplicationThemeFr theme = _TranslationsSettingsApplicationThemeFr._(_root);
}

// Path: settings.security
class _TranslationsSettingsSecurityFr extends _TranslationsSettingsSecurityEn {
	_TranslationsSettingsSecurityFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sécurité';
	@override late final _TranslationsSettingsSecurityEnableLocalAuthFr enableLocalAuth = _TranslationsSettingsSecurityEnableLocalAuthFr._(_root);
	@override late final _TranslationsSettingsSecuritySaveDerivedKeyFr saveDerivedKey = _TranslationsSettingsSecuritySaveDerivedKeyFr._(_root);
	@override late final _TranslationsSettingsSecurityChangeMasterPasswordFr changeMasterPassword = _TranslationsSettingsSecurityChangeMasterPasswordFr._(_root);
}

// Path: settings.synchronization
class _TranslationsSettingsSynchronizationFr extends _TranslationsSettingsSynchronizationEn {
	_TranslationsSettingsSynchronizationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Synchronisation';
	@override late final _TranslationsSettingsSynchronizationAccountLinkFr accountLink = _TranslationsSettingsSynchronizationAccountLinkFr._(_root);
	@override late final _TranslationsSettingsSynchronizationAccountLoginFr accountLogin = _TranslationsSettingsSynchronizationAccountLoginFr._(_root);
	@override late final _TranslationsSettingsSynchronizationSynchronizeTotpsFr synchronizeTotps = _TranslationsSettingsSynchronizationSynchronizeTotpsFr._(_root);
}

// Path: settings.backups
class _TranslationsSettingsBackupsFr extends _TranslationsSettingsBackupsEn {
	_TranslationsSettingsBackupsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sauvegardes';
	@override late final _TranslationsSettingsBackupsBackupNowFr backupNow = _TranslationsSettingsBackupsBackupNowFr._(_root);
	@override late final _TranslationsSettingsBackupsManageBackupsFr manageBackups = _TranslationsSettingsBackupsManageBackupsFr._(_root);
}

// Path: settings.about
class _TranslationsSettingsAboutFr extends _TranslationsSettingsAboutEn {
	_TranslationsSettingsAboutFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'À propos';
	@override late final _TranslationsSettingsAboutAboutAppFr aboutApp = _TranslationsSettingsAboutAboutAppFr._(_root);
}

// Path: storageMigration.masterPasswordDialog
class _TranslationsStorageMigrationMasterPasswordDialogFr extends _TranslationsStorageMigrationMasterPasswordDialogEn {
	_TranslationsStorageMigrationMasterPasswordDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mot de passe maître';
	@override String get message => 'Veuillez entrer votre mot de passe maître pour continuer.';
}

// Path: storageMigration.newStoragePasswordMismatchDialog
class _TranslationsStorageMigrationNewStoragePasswordMismatchDialogFr extends _TranslationsStorageMigrationNewStoragePasswordMismatchDialogEn {
	_TranslationsStorageMigrationNewStoragePasswordMismatchDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mot de passe maître du stockage';
	@override String get defaultMessage => 'Le stockage distant a été chiffré avec un mot de passe maître différent du vôtre. Veuillez l\'entrer ci-dessous pour continuer.\nNotez que cela va définir votre nouveau mot de passe maître. Vous pourrez tout de même le changer à n\'importe quel moment.';
	@override String get errorMessage => 'Le stockage distant a été chiffré avec un mot de passe maître différent du vôtre. Vous en avez entré un mauvais, veuillez réessayer.\nNotez que cela va définir votre nouveau mot de passe maître. Vous pourrez tout de même le changer à n\'importe quel moment.';
}

// Path: storageMigration.deletedTotpPolicyPickerDialog
class _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogFr extends _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogEn {
	_TranslationsStorageMigrationDeletedTotpPolicyPickerDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Migrer les TOTPs';
	@override String get message => 'Certains TOTPs ont été supprimés sur votre appareil, mais pas sur le stockage distant. Que voulez-vous faire ?';
	@override late final _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteFr delete = _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteFr._(_root);
	@override late final _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreFr restore = _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreFr._(_root);
}

// Path: totp.actions
class _TranslationsTotpActionsFr extends _TranslationsTotpActionsEn {
	_TranslationsTotpActionsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get decrypt => 'Déchiffrer';
	@override late final _TranslationsTotpActionsMobileDialogFr mobileDialog = _TranslationsTotpActionsMobileDialogFr._(_root);
	@override late final _TranslationsTotpActionsDesktopButtonsFr desktopButtons = _TranslationsTotpActionsDesktopButtonsFr._(_root);
	@override String get copyConfirmation => 'Copié dans le presse-papier.';
	@override late final _TranslationsTotpActionsDeleteConfirmationDialogFr deleteConfirmationDialog = _TranslationsTotpActionsDeleteConfirmationDialogFr._(_root);
}

// Path: totp.decryptDialog
class _TranslationsTotpDecryptDialogFr extends _TranslationsTotpDecryptDialogEn {
	_TranslationsTotpDecryptDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Déchiffrement du TOTP';
	@override String get message => 'Ce TOTP a été chiffré en utilisant un mot de passe maître différent. Veuillez l\'entrer ci-dessous pour le déchiffrer.';
	@override String get success => 'Succès !';
	@override String get error => 'Mot de passe invalide.';
}

// Path: totp.page
class _TranslationsTotpPageFr extends _TranslationsTotpPageEn {
	_TranslationsTotpPageFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTotpPageTitleFr title = _TranslationsTotpPageTitleFr._(_root);
	@override late final _TranslationsTotpPageLabelFr label = _TranslationsTotpPageLabelFr._(_root);
	@override late final _TranslationsTotpPageSecretFr secret = _TranslationsTotpPageSecretFr._(_root);
	@override late final _TranslationsTotpPageIssuerFr issuer = _TranslationsTotpPageIssuerFr._(_root);
	@override String get algorithm => 'Algorithme';
	@override String get digits => 'Nombre de chiffres';
	@override String get validity => 'Validité (en secondes)';
	@override String get advancedOptions => 'Options avancées';
	@override String get showQrCode => 'Afficher le QR code';
	@override String get save => 'Enregistrer';
	@override String get success => 'Succès !';
	@override late final _TranslationsTotpPageErrorFr error = _TranslationsTotpPageErrorFr._(_root);
}

// Path: validation.error
class _TranslationsValidationErrorFr extends _TranslationsValidationErrorEn {
	_TranslationsValidationErrorFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String incorrectPath({required Object path}) => 'Une erreur est survenue (le chemin est \'${path}\'). Veuillez reporter cette erreur.';
	@override String generic({required Object exception}) => 'Impossible de valider votre requête (erreur : ${exception}). Veuillez réessayer plus tard.';
}

// Path: validation.oauth2
class _TranslationsValidationOauth2Fr extends _TranslationsValidationOauth2En {
	_TranslationsValidationOauth2Fr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String title({required Object name}) => 'Connexion avec ${name}';
	@override String loading({required Object link}) => 'Chargement... Cliquez <a href="${link}">ici</a> si vous n\'êtes pas redirigé.';
	@override String error({required Object name}) => 'Impossible de se connecter avec ${name}. Veuillez réessayer plus tard.';
}

// Path: validation.githubCodeDialog
class _TranslationsValidationGithubCodeDialogFr extends _TranslationsValidationGithubCodeDialogEn {
	_TranslationsValidationGithubCodeDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Code';
	@override String get message => 'Veuillez entrer le code ci-dessous dans l\'onglet qui vient de s\'ouvrir pour vous connecter :';
	@override TextSpan countdown({required InlineSpan countdown}) => TextSpan(children: [
		const TextSpan(text: 'Temps restant : '),
		countdown,
		const TextSpan(text: '.'),
	]);
}

// Path: authentication.logIn.error
class _TranslationsAuthenticationLogInErrorFr extends _TranslationsAuthenticationLogInErrorEn {
	_TranslationsAuthenticationLogInErrorFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get generic => 'Quelque-chose s\'est mal passé. Veuillez réessayer plus tard.';
	@override String get timeout => 'Délai d\'attente dépassé pendant la connexion au fournisseur sélectionné. Veuillez réessayer.';
	@override late final _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogFr accountExistsWithDifferentCredentialsDialog = _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogFr._(_root);
	@override String get invalidCredential => 'Identifiants incorrects.';
	@override String get operationNotAllowed => 'Opération non autorisée. Cela ne doit pas arriver, veuillez reporter cette erreur.';
	@override String get userDisabled => 'Votre compte a été désactivé.';
	@override String firebaseException({required Object exception}) => 'Une erreur est survenue pendant la connexion à votre compte (erreur : ${exception}). Veuillez réessayer plus tard.';
	@override String exception({required Object exception}) => 'Une erreur est survenue (erreur : ${exception}). Veuillez réessayer plus tard.';
}

// Path: authentication.unlink.error
class _TranslationsAuthenticationUnlinkErrorFr extends _TranslationsAuthenticationUnlinkErrorEn {
	_TranslationsAuthenticationUnlinkErrorFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get timeout => 'Délai d\'attente dépassé pendant la suppression de la liaison de votre compte au fournisseur d\'authentification. Veuillez réessayer.';
}

// Path: authentication.unlink.confirmationDialog
class _TranslationsAuthenticationUnlinkConfirmationDialogFr extends _TranslationsAuthenticationUnlinkConfirmationDialogEn {
	_TranslationsAuthenticationUnlinkConfirmationDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Supprimer la liaison au fournisseur';
	@override String get message => 'Voulez-vous vraiment supprimer la liaison e votre compte à ce fournisseur d\'authentification ?';
}

// Path: authentication.providerPickerDialog.email
class _TranslationsAuthenticationProviderPickerDialogEmailFr extends _TranslationsAuthenticationProviderPickerDialogEmailEn {
	_TranslationsAuthenticationProviderPickerDialogEmailFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Email';
	@override String get subtitle => 'Utilisez votre adresse mail pour vous connecter. Pas besoin de mot de passe, nous vous enverrons un lien de confirmation.';
}

// Path: authentication.providerPickerDialog.google
class _TranslationsAuthenticationProviderPickerDialogGoogleFr extends _TranslationsAuthenticationProviderPickerDialogGoogleEn {
	_TranslationsAuthenticationProviderPickerDialogGoogleFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Google';
	@override String get subtitle => 'Connectez-vous avec votre compte Google.';
}

// Path: authentication.providerPickerDialog.apple
class _TranslationsAuthenticationProviderPickerDialogAppleFr extends _TranslationsAuthenticationProviderPickerDialogAppleEn {
	_TranslationsAuthenticationProviderPickerDialogAppleFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Apple';
	@override String get subtitle => 'Connectez-vous avec votre compte Apple.';
}

// Path: authentication.providerPickerDialog.microsoft
class _TranslationsAuthenticationProviderPickerDialogMicrosoftFr extends _TranslationsAuthenticationProviderPickerDialogMicrosoftEn {
	_TranslationsAuthenticationProviderPickerDialogMicrosoftFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Microsoft';
	@override String get subtitle => 'Connectez-vous avec votre compte Microsoft.';
}

// Path: authentication.providerPickerDialog.twitter
class _TranslationsAuthenticationProviderPickerDialogTwitterFr extends _TranslationsAuthenticationProviderPickerDialogTwitterEn {
	_TranslationsAuthenticationProviderPickerDialogTwitterFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'X';
	@override String get subtitle => 'Connectez-vous avec votre compte X.';
}

// Path: authentication.providerPickerDialog.github
class _TranslationsAuthenticationProviderPickerDialogGithubFr extends _TranslationsAuthenticationProviderPickerDialogGithubEn {
	_TranslationsAuthenticationProviderPickerDialogGithubFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Github';
	@override String get subtitle => 'Connectez-vous avec votre compte Github.';
}

// Path: home.addDialog.qrCode
class _TranslationsHomeAddDialogQrCodeFr extends _TranslationsHomeAddDialogQrCodeEn {
	_TranslationsHomeAddDialogQrCodeFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajouter avec un QR code';
	@override String get subtitle => 'Scanner le QR code d\'un TOTP et ajoutez le automatiquement à l\'application !';
}

// Path: home.addDialog.manually
class _TranslationsHomeAddDialogManuallyFr extends _TranslationsHomeAddDialogManuallyEn {
	_TranslationsHomeAddDialogManuallyFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajouter manuellement';
	@override String get subtitle => 'Entrer manuellement les détails du TOTP (ex. secret, étiquette, émetteur, ...).';
}

// Path: intro.logIn.button
class _TranslationsIntroLogInButtonFr extends _TranslationsIntroLogInButtonEn {
	_TranslationsIntroLogInButtonFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get loggedOut => 'Connexion';
	@override String get waitingForConfirmation => 'En attente de confirmation';
	@override String get loggedIn => 'Connecté avec succès';
	@override String get error => 'Impossible de se connecter';
}

// Path: scan.error.accessDeniedDialog
class _TranslationsScanErrorAccessDeniedDialogFr extends _TranslationsScanErrorAccessDeniedDialogEn {
	_TranslationsScanErrorAccessDeniedDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Accès refusé';
	@override String message({required Object exception}) => 'Impossible d\'accéder à votre caméra (accès refusé : ${exception}). Voulez-vous réessayer ?';
}

// Path: settings.application.contributorPlan
class _TranslationsSettingsApplicationContributorPlanFr extends _TranslationsSettingsApplicationContributorPlanEn {
	_TranslationsSettingsApplicationContributorPlanFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Abonnement Contributeur';
	@override late final _TranslationsSettingsApplicationContributorPlanSubtitleFr subtitle = _TranslationsSettingsApplicationContributorPlanSubtitleFr._(_root);
	@override late final _TranslationsSettingsApplicationContributorPlanSubscribeFr subscribe = _TranslationsSettingsApplicationContributorPlanSubscribeFr._(_root);
	@override late final _TranslationsSettingsApplicationContributorPlanBillingPickerDialogFr billingPickerDialog = _TranslationsSettingsApplicationContributorPlanBillingPickerDialogFr._(_root);
}

// Path: settings.application.cacheTotpPictures
class _TranslationsSettingsApplicationCacheTotpPicturesFr extends _TranslationsSettingsApplicationCacheTotpPicturesEn {
	_TranslationsSettingsApplicationCacheTotpPicturesFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cacher les images des TOTPs';
	@override String get subtitle => 'S\'assure que les images de vos TOTPs soient toujours disponibles en les cachant sur votre appareil.';
}

// Path: settings.application.theme
class _TranslationsSettingsApplicationThemeFr extends _TranslationsSettingsApplicationThemeEn {
	_TranslationsSettingsApplicationThemeFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thème';
	@override Map<String, String> get values => {
		'system': 'Système',
		'light': 'Lumineux',
		'dark': 'Sombre',
	};
}

// Path: settings.security.enableLocalAuth
class _TranslationsSettingsSecurityEnableLocalAuthFr extends _TranslationsSettingsSecurityEnableLocalAuthEn {
	_TranslationsSettingsSecurityEnableLocalAuthFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Activer l\'authentification locale';
	@override String get subtitle => 'Permet d\'ajouter un niveau de sécurité en demandant un déverrouillage à chaque fois que vous ouvrez l\'application.';
}

// Path: settings.security.saveDerivedKey
class _TranslationsSettingsSecuritySaveDerivedKeyFr extends _TranslationsSettingsSecuritySaveDerivedKeyEn {
	_TranslationsSettingsSecuritySaveDerivedKeyFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Enregistrer la clé de chiffrement / déchiffrement';
	@override String get subtitle => 'Enregistre votre clé de chiffrement / déchiffrement pour ne pas avoir à entrer votre mot de passe maître à chaque fois que vous démarrez l\'application.';
}

// Path: settings.security.changeMasterPassword
class _TranslationsSettingsSecurityChangeMasterPasswordFr extends _TranslationsSettingsSecurityChangeMasterPasswordEn {
	_TranslationsSettingsSecurityChangeMasterPasswordFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Changer le mot de passe maître';
	@override TextSpan subtitle({required InlineSpanBuilder italic}) => TextSpan(children: [
		const TextSpan(text: 'Vous pouvez changer votre mot de passe maître quand vous le souhaitez.\n'),
		italic('Veuillez noter que vous devrez le réentrer dans toutes les instances d\'Open Authenticator qui sont synchronisées ensemble.'),
	]);
	@override late final _TranslationsSettingsSecurityChangeMasterPasswordDialogFr dialog = _TranslationsSettingsSecurityChangeMasterPasswordDialogFr._(_root);
}

// Path: settings.synchronization.accountLink
class _TranslationsSettingsSynchronizationAccountLinkFr extends _TranslationsSettingsSynchronizationAccountLinkEn {
	_TranslationsSettingsSynchronizationAccountLinkFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Relier d\'autres fournisseurs';
	@override late final _TranslationsSettingsSynchronizationAccountLinkSubtitleFr subtitle = _TranslationsSettingsSynchronizationAccountLinkSubtitleFr._(_root);
}

// Path: settings.synchronization.accountLogin
class _TranslationsSettingsSynchronizationAccountLoginFr extends _TranslationsSettingsSynchronizationAccountLoginEn {
	_TranslationsSettingsSynchronizationAccountLoginFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSettingsSynchronizationAccountLoginLogInFr logIn = _TranslationsSettingsSynchronizationAccountLoginLogInFr._(_root);
	@override late final _TranslationsSettingsSynchronizationAccountLoginConfirmEmailFr confirmEmail = _TranslationsSettingsSynchronizationAccountLoginConfirmEmailFr._(_root);
	@override late final _TranslationsSettingsSynchronizationAccountLoginLogOutFr logOut = _TranslationsSettingsSynchronizationAccountLoginLogOutFr._(_root);
}

// Path: settings.synchronization.synchronizeTotps
class _TranslationsSettingsSynchronizationSynchronizeTotpsFr extends _TranslationsSettingsSynchronizationSynchronizeTotpsEn {
	_TranslationsSettingsSynchronizationSynchronizeTotpsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Synchroniser vos TOTPs';
	@override String get subtitle => 'Synchroniser vos TOTPs avec tous les appareils connectés.';
}

// Path: settings.backups.backupNow
class _TranslationsSettingsBackupsBackupNowFr extends _TranslationsSettingsBackupsBackupNowEn {
	_TranslationsSettingsBackupsBackupNowFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sauvegarder maintenant';
	@override String get subtitle => 'Créer une sauvegarde de vos TOTPs.';
	@override late final _TranslationsSettingsBackupsBackupNowPasswordDialogFr passwordDialog = _TranslationsSettingsBackupsBackupNowPasswordDialogFr._(_root);
	@override String get error => 'Une erreur est survenue pendant la sauvegarde de vos données.';
	@override String get success => 'Succès !';
}

// Path: settings.backups.manageBackups
class _TranslationsSettingsBackupsManageBackupsFr extends _TranslationsSettingsBackupsManageBackupsEn {
	_TranslationsSettingsBackupsManageBackupsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gestion des sauvegardes';
	@override String subtitle({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		zero: 'Vous n\'avez aucune sauvegarde.',
		one: 'Vous avez actuellement ${n} sauvegarde.',
		other: 'Vous avez actuellement ${n} sauvegardes.',
	);
	@override late final _TranslationsSettingsBackupsManageBackupsBackupsDialogFr backupsDialog = _TranslationsSettingsBackupsManageBackupsBackupsDialogFr._(_root);
	@override late final _TranslationsSettingsBackupsManageBackupsRestoreBackupFr restoreBackup = _TranslationsSettingsBackupsManageBackupsRestoreBackupFr._(_root);
	@override late final _TranslationsSettingsBackupsManageBackupsDeleteBackupFr deleteBackup = _TranslationsSettingsBackupsManageBackupsDeleteBackupFr._(_root);
}

// Path: settings.about.aboutApp
class _TranslationsSettingsAboutAboutAppFr extends _TranslationsSettingsAboutAboutAppEn {
	_TranslationsSettingsAboutAboutAppFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String title({required Object appName}) => '${appName}';
	@override TextSpan subtitle({required InlineSpan appName, required InlineSpan appVersion, required InlineSpan appAuthor}) => TextSpan(children: [
		appName,
		const TextSpan(text: ' v'),
		appVersion,
		const TextSpan(text: ', par '),
		appAuthor,
		const TextSpan(text: '.'),
	]);
	@override String dialogLegalese({required Object appName, required Object appAuthor}) => '${appName} est une application open-source, créée par ${appAuthor}.';
}

// Path: storageMigration.deletedTotpPolicyPickerDialog.delete
class _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteFr extends _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteEn {
	_TranslationsStorageMigrationDeletedTotpPolicyPickerDialogDeleteFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Les supprimer';
	@override String get subtitle => 'Supprimer les TOTPs conflictuels. Cette action est irréversible.';
}

// Path: storageMigration.deletedTotpPolicyPickerDialog.restore
class _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreFr extends _TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreEn {
	_TranslationsStorageMigrationDeletedTotpPolicyPickerDialogRestoreFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Les garder';
	@override String get subtitle => 'Annule la suppression et garde tous vos TOTPs.';
}

// Path: totp.actions.mobileDialog
class _TranslationsTotpActionsMobileDialogFr extends _TranslationsTotpActionsMobileDialogEn {
	_TranslationsTotpActionsMobileDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Actions sur le TOTP';
	@override String get edit => 'Éditer le TOTP';
	@override String get delete => 'Supprimier le TOTP';
}

// Path: totp.actions.desktopButtons
class _TranslationsTotpActionsDesktopButtonsFr extends _TranslationsTotpActionsDesktopButtonsEn {
	_TranslationsTotpActionsDesktopButtonsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get copy => 'Copier code';
	@override String get edit => 'Éditer';
	@override String get delete => 'Supprimer';
}

// Path: totp.actions.deleteConfirmationDialog
class _TranslationsTotpActionsDeleteConfirmationDialogFr extends _TranslationsTotpActionsDeleteConfirmationDialogEn {
	_TranslationsTotpActionsDeleteConfirmationDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Supprimer ce TOTP';
	@override String get message => 'Voulez-vous vraiment supprimer ce TOTP ?';
	@override String get error => 'Impossible de supprimer ce TOTP.';
}

// Path: totp.page.title
class _TranslationsTotpPageTitleFr extends _TranslationsTotpPageTitleEn {
	_TranslationsTotpPageTitleFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get edit => 'Éditer le TOTP';
	@override String get add => 'Ajouter un TOTP';
}

// Path: totp.page.label
class _TranslationsTotpPageLabelFr extends _TranslationsTotpPageLabelEn {
	_TranslationsTotpPageLabelFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get text => 'Étiquette';
	@override String get hint => 'me@exemple.com';
}

// Path: totp.page.secret
class _TranslationsTotpPageSecretFr extends _TranslationsTotpPageSecretEn {
	_TranslationsTotpPageSecretFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get text => 'Clé secrète';
	@override String get hint => 'JBSWY3DPEHPK3PXP';
}

// Path: totp.page.issuer
class _TranslationsTotpPageIssuerFr extends _TranslationsTotpPageIssuerEn {
	_TranslationsTotpPageIssuerFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get text => 'Émetteur';
	@override String get hint => 'exemple.com';
}

// Path: totp.page.error
class _TranslationsTotpPageErrorFr extends _TranslationsTotpPageErrorEn {
	_TranslationsTotpPageErrorFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get save => 'Une erreur est survenue lors de la sauvegarde de votre TOTP.';
	@override String get qrCode => 'Veuillez remplir les champs "clé secrète", "étiquette" et "émetteur" pour pouvoir générer un QR code.';
	@override String get emptySecret => 'Le secret doit être spécifié';
	@override String get invalidSecret => 'Clé secrète invalide';
	@override String get emptyLabel => 'L\'étiquette doit être spécifiée';
	@override String get emptyIssuer => 'L\'émetteur doit être spécifié';
}

// Path: authentication.logIn.error.accountExistsWithDifferentCredentialsDialog
class _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogFr extends _TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogEn {
	_TranslationsAuthenticationLogInErrorAccountExistsWithDifferentCredentialsDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Un compte existe déjà';
	@override String get message => 'Un compte avec la même adresse mail existe dans notre base de données, mais le fournisseur d\'authentification sélectionné n\'y est pas relié.\nVeuillez vous connecter en utilisant un fournisseur d\'authentification qui y est déjà relié.';
}

// Path: settings.application.contributorPlan.subtitle
class _TranslationsSettingsApplicationContributorPlanSubtitleFr extends _TranslationsSettingsApplicationContributorPlanSubtitleEn {
	_TranslationsSettingsApplicationContributorPlanSubtitleFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Vérification de l\'état de votre abonnement...';
	@override String get active => 'Vous avez souscrit à l\'Abonnement Contributeur. Merci beaucoup !';
	@override String get inactive => 'Vous n\'avez pas encore souscrit à l\'Abonnement Contributeur. Nous devons afficher des annonces pour contribuer au coût des serveurs.';
}

// Path: settings.application.contributorPlan.subscribe
class _TranslationsSettingsApplicationContributorPlanSubscribeFr extends _TranslationsSettingsApplicationContributorPlanSubscribeEn {
	_TranslationsSettingsApplicationContributorPlanSubscribeFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogFr waitingDialog = _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogFr._(_root);
	@override String get success => 'Vous avez souscrit à l\'Abonnement Contributeur avec succès. Merci beaucoup !';
	@override String get error => 'Une erreur est survenue pendant votre souscription à l\'Abonnement Contributeur. Veuillez réessayer plus tard.';
}

// Path: settings.application.contributorPlan.billingPickerDialog
class _TranslationsSettingsApplicationContributorPlanBillingPickerDialogFr extends _TranslationsSettingsApplicationContributorPlanBillingPickerDialogEn {
	_TranslationsSettingsApplicationContributorPlanBillingPickerDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Choisissez votre souscription';
	@override TextSpan priceSubtitle({required InlineSpan subtitle, required InlineSpan price, required InlineSpan interval}) => TextSpan(children: [
		subtitle,
		const TextSpan(text: '\n'),
		price,
		const TextSpan(text: ' / '),
		interval,
		const TextSpan(text: '.'),
	]);
	@override String get empty => 'Vous ne pouvez pas souscrire à l\'Abonnement Contributeur actuellement.';
	@override String error({required Object error}) => 'Erreur : ${error}.';
	@override Map<String, String> get packageTypeName => {
		'annual': 'Annuelle',
		'monthly': 'Mensuelle',
	};
	@override Map<String, String> get packageTypeInterval => {
		'annual': 'An',
		'monthly': 'Mois',
	};
	@override Map<String, String> get packageTypeSubtitle => {
		'annual': 'Une facturation par an.',
		'monthly': 'Une facturation par mois.',
	};
	@override late final _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesFr restorePurchases = _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesFr._(_root);
}

// Path: settings.security.changeMasterPassword.dialog
class _TranslationsSettingsSecurityChangeMasterPasswordDialogFr extends _TranslationsSettingsSecurityChangeMasterPasswordDialogEn {
	_TranslationsSettingsSecurityChangeMasterPasswordDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Changer votre mot de passe maître';
	@override late final _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentFr current = _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentFr._(_root);
	@override String get newLabel => 'Votre nouveau mot de passe maître';
	@override String get errorIncorrectPassword => 'Mot de passe incorrect';
}

// Path: settings.synchronization.accountLink.subtitle
class _TranslationsSettingsSynchronizationAccountLinkSubtitleFr extends _TranslationsSettingsSynchronizationAccountLinkSubtitleEn {
	_TranslationsSettingsSynchronizationAccountLinkSubtitleFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get text => 'Relier d\'autres fournisseurs d\'authentification à votre compte afin que vous puissiez les utiliser pour vous connecter.';
	@override String providers({required Object providers}) => '\nCompte actuellement relié à : ${providers}.';
}

// Path: settings.synchronization.accountLogin.logIn
class _TranslationsSettingsSynchronizationAccountLoginLogInFr extends _TranslationsSettingsSynchronizationAccountLoginLogInEn {
	_TranslationsSettingsSynchronizationAccountLoginLogInFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Connexion';
	@override String get subtitle => 'Connectez vous pour synchroniser vos TOTPs entre vos appareils.';
}

// Path: settings.synchronization.accountLogin.confirmEmail
class _TranslationsSettingsSynchronizationAccountLoginConfirmEmailFr extends _TranslationsSettingsSynchronizationAccountLoginConfirmEmailEn {
	_TranslationsSettingsSynchronizationAccountLoginConfirmEmailFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Confirmer votre adresse mail';
	@override TextSpan subtitle({required InlineSpan email}) => TextSpan(children: [
		const TextSpan(text: 'Un email de confirmation a été envoyé à votre adresse mail : '),
		email,
		const TextSpan(text: '.\nVeuillez cliquer sur le lien pour poursuivre la connexion. Vous pouvez également taper ici pour l\'entrer manuellement.'),
	]);
	@override String get waitingDialogMessage => 'Veuillez patienter pendant que nous confirmons votre adresse mail... Ne fermez pas l\'application.';
	@override String get error => 'Quelque chose s\'est mal passé. Veuillez réessayer plus tard.';
	@override String get success => 'Adresse mail confirmée avec succès.';
	@override late final _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogFr linkDialog = _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogFr._(_root);
}

// Path: settings.synchronization.accountLogin.logOut
class _TranslationsSettingsSynchronizationAccountLoginLogOutFr extends _TranslationsSettingsSynchronizationAccountLoginLogOutEn {
	_TranslationsSettingsSynchronizationAccountLoginLogOutFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Déconnexion';
	@override TextSpan subtitle({required InlineSpan email}) => TextSpan(children: [
		const TextSpan(text: 'Se déconnecter pour arrêter la synchronisation des TOTPs avec cet appareil.\nActuellement connecté en tant que : '),
		email,
		const TextSpan(text: '.'),
	]);
}

// Path: settings.backups.backupNow.passwordDialog
class _TranslationsSettingsBackupsBackupNowPasswordDialogFr extends _TranslationsSettingsBackupsBackupNowPasswordDialogEn {
	_TranslationsSettingsBackupsBackupNowPasswordDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mot de passe de la sauvegarde';
	@override String get message => 'Veuillez entrer un mot de passe pour la sauvegarde. Veuillez noter que nous ne pouvons sauvegarder que les TOTPs déchiffrés (ceux qui affichent un code).';
}

// Path: settings.backups.manageBackups.backupsDialog
class _TranslationsSettingsBackupsManageBackupsBackupsDialogFr extends _TranslationsSettingsBackupsManageBackupsBackupsDialogEn {
	_TranslationsSettingsBackupsManageBackupsBackupsDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gestion des sauvegardes';
	@override String get errorLoadingBackups => 'Impossible de charger la liste des sauvegardes. Veuillez réessayer plus tard.';
}

// Path: settings.backups.manageBackups.restoreBackup
class _TranslationsSettingsBackupsManageBackupsRestoreBackupFr extends _TranslationsSettingsBackupsManageBackupsRestoreBackupEn {
	_TranslationsSettingsBackupsManageBackupsRestoreBackupFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogFr passwordDialog = _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogFr._(_root);
	@override String get success => 'Succès !';
	@override String get error => 'Impossible de restaurer la sauvegarde. Assurez-vous d\'avoir entré le bon mot de passe.';
}

// Path: settings.backups.manageBackups.deleteBackup
class _TranslationsSettingsBackupsManageBackupsDeleteBackupFr extends _TranslationsSettingsBackupsManageBackupsDeleteBackupEn {
	_TranslationsSettingsBackupsManageBackupsDeleteBackupFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogFr confirmationDialog = _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogFr._(_root);
	@override String get success => 'Succès !';
	@override String get error => 'Impossible de supprimer cette sauvegarde. Veuillez réessayer plus tard.';
}

// Path: settings.application.contributorPlan.subscribe.waitingDialog
class _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogFr extends _TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogEn {
	_TranslationsSettingsApplicationContributorPlanSubscribeWaitingDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get message => 'En attente de votre paiement...';
	@override String get timedOut => 'Délai d\'attente de la souscription à l\'Abonnement Contributeur dépassé. Veuillez réessayer.';
}

// Path: settings.application.contributorPlan.billingPickerDialog.restorePurchases
class _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesFr extends _TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesEn {
	_TranslationsSettingsApplicationContributorPlanBillingPickerDialogRestorePurchasesFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get button => 'Restaurer les achats';
	@override String get success => 'Vos achats ont été restauré avec succès !';
	@override String get error => 'Une erreur est survenue. Veuillez réessayer plus tard.';
}

// Path: settings.security.changeMasterPassword.dialog.current
class _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentFr extends _TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentEn {
	_TranslationsSettingsSecurityChangeMasterPasswordDialogCurrentFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get label => 'Mot de passe maître actuel';
	@override String get hint => 'Entrer votre mot de passe maître actuel';
}

// Path: settings.synchronization.accountLogin.confirmEmail.linkDialog
class _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogFr extends _TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogEn {
	_TranslationsSettingsSynchronizationAccountLoginConfirmEmailLinkDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lien de confirmation';
	@override String get message => 'Visitez le lien de confirmation avec cet appareil ou collez-le ci-dessous pour confirmer votre adresse mail.';
}

// Path: settings.backups.manageBackups.restoreBackup.passwordDialog
class _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogFr extends _TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogEn {
	_TranslationsSettingsBackupsManageBackupsRestoreBackupPasswordDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mot de passe de la sauvegarde';
	@override String get message => 'Veuillez entrer un mot de passe pour la sauvegarde.';
}

// Path: settings.backups.manageBackups.deleteBackup.confirmationDialog
class _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogFr extends _TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogEn {
	_TranslationsSettingsBackupsManageBackupsDeleteBackupConfirmationDialogFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Supprimer la sauvegarde';
	@override String get message => 'Voulez-vous vraiment supprimer cette sauvegarde ?';
}
