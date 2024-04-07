///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint

part of 'translations.g.dart';

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'appUnlock.widget.text': return ({required Object app}) => '${app} is locked.';
			case 'appUnlock.widget.button': return 'Unlock';
			case 'appUnlock.localAuthentication.openApp': return 'Authenticate to access the app.';
			case 'appUnlock.localAuthentication.enable': return 'Authenticate to enable local authentication.';
			case 'appUnlock.localAuthentication.disable': return 'Authenticate to disable local authentication.';
			case 'appUnlock.masterPasswordDialog.title': return 'Master password';
			case 'appUnlock.masterPasswordDialog.message': return 'Please enter your master password to unlock the app.';
			case 'authentication.emailDialog.title': return 'Your email';
			case 'authentication.emailDialog.message': return 'Please enter your email, we will send you a login link.';
			case 'authentication.logIn.waitingDialogMessage': return 'Please login yourself in the opened window. Do not close the application.';
			case 'authentication.logIn.error.generic': return 'Something went wrong. Please try again later.';
			case 'authentication.logIn.error.timeout': return 'Timed out while logging in using the selected provider. Please try again.';
			case 'authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.title': return 'An account already exists';
			case 'authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.message': return 'An account with the same email address exists in our database, but the selected authentication provider has not yet been linked to it.\nPlease try to log in using an already linked authentication provider.';
			case 'authentication.logIn.error.invalidCredential': return 'Invalid credentials provided.';
			case 'authentication.logIn.error.operationNotAllowed': return 'Operation not allowed. This should not happen, please report this error.';
			case 'authentication.logIn.error.userDisabled': return 'Your account has been disabled.';
			case 'authentication.logIn.error.firebaseException': return ({required Object exception}) => 'An error occurred while trying to authenticate your account (exception : ${exception}). Please try again later.';
			case 'authentication.logIn.error.exception': return ({required Object exception}) => 'An error occurred (exception : ${exception}). Please try again later.';
			case 'authentication.logIn.success': return 'Logged in with success !';
			case 'authentication.logIn.successNeedConfirmation': return 'Success ! You will receive a confirmation email soon. Please click on the link on this device in order to log in.';
			case 'authentication.linkErrorTimeout': return 'Timed out while trying to link your account to this authentication provider. Please try again.';
			case 'authentication.unlink.error.timeout': return 'Timed out while trying to unlink your account from this authentication provider. Please try again.';
			case 'authentication.unlink.confirmationDialog.title': return 'Unlink provider';
			case 'authentication.unlink.confirmationDialog.message': return 'Are you sure you want to unlink this authentication provider from your account ?';
			case 'authentication.providerPickerDialog.title': return 'Pick a login method';
			case 'authentication.providerPickerDialog.email.title': return 'Email';
			case 'authentication.providerPickerDialog.email.subtitle': return 'Use your email to login. No password required, a confirmation link will be sent.';
			case 'authentication.providerPickerDialog.google.title': return 'Google';
			case 'authentication.providerPickerDialog.google.subtitle': return 'Sign in with your Google account.';
			case 'authentication.providerPickerDialog.apple.title': return 'Apple';
			case 'authentication.providerPickerDialog.apple.subtitle': return 'Sign in with your Apple account.';
			case 'authentication.providerPickerDialog.microsoft.title': return 'Microsoft';
			case 'authentication.providerPickerDialog.microsoft.subtitle': return 'Sign in with your Microsoft account.';
			case 'authentication.providerPickerDialog.twitter.title': return 'X';
			case 'authentication.providerPickerDialog.twitter.subtitle': return 'Sign in with your X account.';
			case 'authentication.providerPickerDialog.github.title': return 'Github';
			case 'authentication.providerPickerDialog.github.subtitle': return 'Sign in with your Github account.';
			case 'home.list.empty': return 'No TOTP for the moment.\nFeel free to add one !';
			case 'home.list.error': return ({required Object error}) => 'Error : ${error}. Please try to refresh the data.';
			case 'home.addDialog.title': return 'Add a TOTP';
			case 'home.addDialog.qrCode.title': return 'Add using a QR code';
			case 'home.addDialog.qrCode.subtitle': return 'Scan a TOTP QR code and automatically add it to the app !';
			case 'home.addDialog.manually.title': return 'Add manually';
			case 'home.addDialog.manually.subtitle': return 'Manually enter your TOTP details (eg. secret, label, issuer, ...).';
			case 'intro.welcome.firstParagraph': return ({required Object app}) => 'Thanks for downloading ${app}, an open-source app that will help you managing your TOTPs (Time based One Time Password) with ease.';
			case 'intro.welcome.secondParagraph': return 'In the following steps you will be able to configure it to match your needs.';
			case 'intro.welcome.thirdParagraph': return 'I hope you will enjoy using this app as much as I have enjoyed creating it !';
			case 'intro.logIn.title': return 'Synchronize your TOTPs';
			case 'intro.logIn.firstParagraph': return 'Click on the "Log in" button below to be able synchronize your TOTPs between your devices.';
			case 'intro.logIn.secondParagraph': return 'This step is completely optional.';
			case 'intro.logIn.thirdParagraph': return 'Note that, if you enable this option, we will have to display some ads right in the app to contribute to the servers cost.';
			case 'intro.logIn.fourthParagraph': return ({required Object app}) => 'These ads can be removed at any time by subscribing to the Contributor Plan in the ${app} settings.';
			case 'intro.logIn.button.loggedOut': return 'Log in';
			case 'intro.logIn.button.waitingForConfirmation': return 'Waiting for confirmation';
			case 'intro.logIn.button.loggedIn': return 'Logged in with success';
			case 'intro.logIn.button.error': return 'Cannot authenticate';
			case 'intro.password.title': return 'Keep your data safe';
			case 'intro.password.firstParagraph': return 'In order to keep your data safe and secure, we need you to define a master password.';
			case 'intro.password.secondParagraph': return 'This password will be used to encrypt your data and will never be sent to any remote server.';
			case 'intro.password.thirdParagraph': return 'Therefore, if you forget it we will not be able to recover it for you. Make sure to store it somewhere safe.';
			case 'intro.button.next': return 'Next';
			case 'intro.button.finish': return 'Finish';
			case 'logoSearch.dialogTitle': return 'Pick a logo';
			case 'logoSearch.keywords.text': return 'Keywords';
			case 'logoSearch.keywords.hint': return 'microsoft.com';
			case 'logoSearch.credits': return ({required Object sources}) => 'Search results provided by ${sources}';
			case 'logoSearch.noLogoFound': return 'No logo found. Please try other keywords !';
			case 'miscellaneous.waitingDialog.defaultMessage': return 'Please wait...';
			case 'miscellaneous.waitingDialog.defaultTimeoutMessage': return 'Timeout occurred. Please try again later.';
			case 'miscellaneous.waitingDialog.countdown': return ({required InlineSpan countdown}) => TextSpan(children: [
				const TextSpan(text: 'Time left : '),
				countdown,
				const TextSpan(text: '.'),
			]);
			case 'scan.error.noUri': return 'Failed to read this QR code. Please ensure it is a valid TOTP QR code.';
			case 'scan.error.accessDeniedDialog.title': return 'Access denied';
			case 'scan.error.accessDeniedDialog.message': return ({required Object exception}) => 'Failed to access your camera (access denied : ${exception}). Do you want to retry ?';
			case 'scan.error.scanError': return ({required Object exception}) => 'An error occurred (exception : ${exception}). Please try again later.';
			case 'settings.title': return 'Settings';
			case 'settings.application.title': return 'Application';
			case 'settings.application.contributorPlan.title': return 'Contributor Plan';
			case 'settings.application.contributorPlan.subtitle.loading': return 'Checking your subscription status...';
			case 'settings.application.contributorPlan.subtitle.active': return 'You have subscribed to the Contributor Plan. Thanks a lot !';
			case 'settings.application.contributorPlan.subtitle.inactive': return 'You currently have not subscribed to the Contributor Plan. We have to display some ads in order to contribute to the servers costs.';
			case 'settings.application.contributorPlan.subscribe.waitingDialog.message': return 'Waiting for your purchase...';
			case 'settings.application.contributorPlan.subscribe.waitingDialog.timedOut': return 'Timed out while waiting for your Contributor Plan subscription purchase. Please try again.';
			case 'settings.application.contributorPlan.subscribe.success': return 'You have successfully subscribed to the Contributor Plan. Thanks a lot !';
			case 'settings.application.contributorPlan.subscribe.error': return 'An error occurred while trying to subscribe to the Contributor Plan. Please try again later.';
			case 'settings.application.contributorPlan.billingPickerDialog.title': return 'Choose your billing';
			case 'settings.application.contributorPlan.billingPickerDialog.priceSubtitle': return ({required InlineSpan subtitle, required InlineSpan price, required InlineSpan interval}) => TextSpan(children: [
				subtitle,
				const TextSpan(text: '\n'),
				price,
				const TextSpan(text: ' / '),
				interval,
				const TextSpan(text: '.'),
			]);
			case 'settings.application.contributorPlan.billingPickerDialog.empty': return 'There isn\'t any option for you to subscribe to the Contributor Plan.';
			case 'settings.application.contributorPlan.billingPickerDialog.error': return ({required Object error}) => 'Error : ${error}.';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeName.annual': return 'Annual';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeName.monthly': return 'Monthly';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeInterval.annual': return 'Year';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeInterval.monthly': return 'Month';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeSubtitle.annual': return 'Get billed every year.';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeSubtitle.monthly': return 'Get billed every month.';
			case 'settings.application.contributorPlan.billingPickerDialog.restorePurchases.button': return 'Restore purchases';
			case 'settings.application.contributorPlan.billingPickerDialog.restorePurchases.success': return 'Your purchases have been restored with success !';
			case 'settings.application.contributorPlan.billingPickerDialog.restorePurchases.error': return 'An error occurred. Please try again later.';
			case 'settings.application.cacheTotpPictures.title': return 'Cache TOTP pictures';
			case 'settings.application.cacheTotpPictures.subtitle': return 'Ensure that your TOTP pictures will always be available by caching them on your device.';
			case 'settings.application.theme.title': return 'Theme';
			case 'settings.application.theme.values.system': return 'System';
			case 'settings.application.theme.values.light': return 'Light';
			case 'settings.application.theme.values.dark': return 'Dark';
			case 'settings.security.title': return 'Security';
			case 'settings.security.enableLocalAuth.title': return 'Enable local authentication';
			case 'settings.security.enableLocalAuth.subtitle': return 'Adds an additional security layer by asking for unlocking everytime you open the app.';
			case 'settings.security.saveDerivedKey.title': return 'Save encryption / decryption key';
			case 'settings.security.saveDerivedKey.subtitle': return 'Save your encryption / decryption key so that you do not have to reenter your master password everytime you open the app.';
			case 'settings.security.changeMasterPassword.title': return 'Change master password';
			case 'settings.security.changeMasterPassword.subtitle': return ({required InlineSpanBuilder italic}) => TextSpan(children: [
				const TextSpan(text: 'You can change your master password at any time.\n'),
				italic('Note that you will have to reenter it in all your Open Authenticator instances that are synced together.'),
			]);
			case 'settings.security.changeMasterPassword.dialog.title': return 'Change your master password';
			case 'settings.security.changeMasterPassword.dialog.current.label': return 'Current master password';
			case 'settings.security.changeMasterPassword.dialog.current.hint': return 'Enter your current master password here';
			case 'settings.security.changeMasterPassword.dialog.newLabel': return 'Your new master password';
			case 'settings.security.changeMasterPassword.dialog.errorIncorrectPassword': return 'Incorrect password';
			case 'settings.synchronization.title': return 'Synchronization';
			case 'settings.synchronization.accountLink.title': return 'Link other providers';
			case 'settings.synchronization.accountLink.subtitle.text': return 'Link your account to other authentication providers so that you can use them to log in yourself.';
			case 'settings.synchronization.accountLink.subtitle.providers': return ({required Object providers}) => '\nAccount currently linked to : ${providers}.';
			case 'settings.synchronization.accountLogin.logIn.title': return 'Log in';
			case 'settings.synchronization.accountLogin.logIn.subtitle': return 'Log in to synchronize your TOTPs between your devices.';
			case 'settings.synchronization.accountLogin.confirmEmail.title': return 'Confirm your email';
			case 'settings.synchronization.accountLogin.confirmEmail.subtitle': return ({required InlineSpan email}) => TextSpan(children: [
				const TextSpan(text: 'A confirmation email has been sent to your email address : '),
				email,
				const TextSpan(text: '.\nPlease click on the link to finish your login. You can also tap on this tile to enter it manually.'),
			]);
			case 'settings.synchronization.accountLogin.confirmEmail.waitingDialogMessage': return 'Please wait while we are confirming your account... Do not close the application.';
			case 'settings.synchronization.accountLogin.confirmEmail.error': return 'Something went wrong. Please try again later.';
			case 'settings.synchronization.accountLogin.confirmEmail.success': return 'Email confirmed with success.';
			case 'settings.synchronization.accountLogin.confirmEmail.linkDialog.title': return 'Confirmation link';
			case 'settings.synchronization.accountLogin.confirmEmail.linkDialog.message': return 'Either visit the link with this device or paste it below to confirm your email address.';
			case 'settings.synchronization.accountLogin.logOut.title': return 'Log out';
			case 'settings.synchronization.accountLogin.logOut.subtitle': return ({required InlineSpan email}) => TextSpan(children: [
				const TextSpan(text: 'Log out to stop synchronizing your TOTPs with this device.\nCurrently signed in as : '),
				email,
				const TextSpan(text: '.'),
			]);
			case 'settings.synchronization.synchronizeTotps.title': return 'Synchronize TOTPs';
			case 'settings.synchronization.synchronizeTotps.subtitle': return 'Synchronize your TOTPs with all your logged in devices.';
			case 'settings.backups.title': return 'Backups';
			case 'settings.backups.backupNow.title': return 'Backup now';
			case 'settings.backups.backupNow.subtitle': return 'Backup your TOTPs now.';
			case 'settings.backups.backupNow.passwordDialog.title': return 'Backup password';
			case 'settings.backups.backupNow.passwordDialog.message': return 'Please enter a password for your backup. Note that we can only save the decrypted TOTPs (those that are displaying a code).';
			case 'settings.backups.backupNow.error': return 'Error while trying to backup your data.';
			case 'settings.backups.backupNow.success': return 'Success !';
			case 'settings.backups.manageBackups.title': return 'Manage backups';
			case 'settings.backups.manageBackups.subtitle': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(n,
				zero: 'You do not have any backup stored.',
				one: 'You currently have ${n} backup stored.',
				other: 'You currently have ${n} backups stored.',
			);
			case 'settings.backups.manageBackups.backupsDialog.title': return 'Manage backups';
			case 'settings.backups.manageBackups.backupsDialog.errorLoadingBackups': return 'Unable to load backups. Please try again later.';
			case 'settings.backups.manageBackups.restoreBackup.passwordDialog.title': return 'Backup password';
			case 'settings.backups.manageBackups.restoreBackup.passwordDialog.message': return 'Please enter your backup password.';
			case 'settings.backups.manageBackups.restoreBackup.success': return 'Success !';
			case 'settings.backups.manageBackups.restoreBackup.error': return 'Error while trying to restore your data. Make sure that you have entered the correct password.';
			case 'settings.backups.manageBackups.deleteBackup.confirmationDialog.title': return 'Delete backup';
			case 'settings.backups.manageBackups.deleteBackup.confirmationDialog.message': return 'Do you want to delete this backup ?';
			case 'settings.backups.manageBackups.deleteBackup.success': return 'Success !';
			case 'settings.backups.manageBackups.deleteBackup.error': return 'Error while trying to delete this backup. Please try again later.';
			case 'settings.about.title': return 'About';
			case 'settings.about.aboutApp.title': return ({required Object appName}) => '${appName}';
			case 'settings.about.aboutApp.subtitle': return ({required InlineSpan appName, required InlineSpan appVersion, required InlineSpan appAuthor}) => TextSpan(children: [
				appName,
				const TextSpan(text: ' v'),
				appVersion,
				const TextSpan(text: ', by '),
				appAuthor,
				const TextSpan(text: '.'),
			]);
			case 'settings.about.aboutApp.dialogLegalese': return ({required Object appName, required Object appAuthor}) => '${appName} is an open-source application, created by ${appAuthor}.';
			case 'storageMigration.masterPasswordDialog.title': return 'Master password';
			case 'storageMigration.masterPasswordDialog.message': return 'Please enter your master password to continue.';
			case 'storageMigration.success': return 'Success !';
			case 'storageMigration.error.saltError': return '"Salt" error while migrating your data. Please try again later.';
			case 'storageMigration.error.currentStoragePasswordMismatch': return 'Invalid master password entered.';
			case 'storageMigration.error.encryptionKeyChangeFailed': return 'An error occurred while encrypting your data. Please try again later.';
			case 'storageMigration.error.genericError': return 'An error occurred while migrating your data. Please try again later.';
			case 'storageMigration.newStoragePasswordMismatchDialog.title': return 'Storage master password';
			case 'storageMigration.newStoragePasswordMismatchDialog.defaultMessage': return 'The remote storage has been encrypted using another master password. Please enter it below in order to continue.\nNote that this will define your new master password. You can still change it at any time.';
			case 'storageMigration.newStoragePasswordMismatchDialog.errorMessage': return 'The remote storage has been encrypted using another master password. You\'ve entered a wrong one, please try again.\nNote that this will define your new master password. You can still change it at any time.';
			case 'storageMigration.deletedTotpPolicyPickerDialog.title': return 'Migrate TOTPs';
			case 'storageMigration.deletedTotpPolicyPickerDialog.message': return 'Some TOTPs have been deleted on this device, but not on the remote storage. What do you want to do with them ?';
			case 'storageMigration.deletedTotpPolicyPickerDialog.delete.title': return 'Delete them';
			case 'storageMigration.deletedTotpPolicyPickerDialog.delete.subtitle': return 'Delete the conflicting TOTPs. This cannot be undone.';
			case 'storageMigration.deletedTotpPolicyPickerDialog.restore.title': return 'Keep them';
			case 'storageMigration.deletedTotpPolicyPickerDialog.restore.subtitle': return 'Undo the deletion, and keep all TOTPs.';
			case 'totp.actions.decrypt': return 'Decrypt';
			case 'totp.actions.mobileDialog.title': return 'TOTP actions';
			case 'totp.actions.mobileDialog.edit': return 'Edit TOTP';
			case 'totp.actions.mobileDialog.delete': return 'Delete TOTP';
			case 'totp.actions.desktopButtons.copy': return 'Copy code';
			case 'totp.actions.desktopButtons.edit': return 'Edit';
			case 'totp.actions.desktopButtons.delete': return 'Delete';
			case 'totp.actions.copyConfirmation': return 'Copied to clipboard.';
			case 'totp.actions.deleteConfirmationDialog.title': return 'Delete this TOTP';
			case 'totp.actions.deleteConfirmationDialog.message': return 'Do you really want to delete this TOTP ?';
			case 'totp.actions.deleteConfirmationDialog.error': return 'Failed to delete TOTP.';
			case 'totp.decryptDialog.title': return 'Decrypt TOTP';
			case 'totp.decryptDialog.message': return 'This TOTP has been encrypted using a different a master password. Please enter it below in order to decrypt it.';
			case 'totp.decryptDialog.success': return 'Success !';
			case 'totp.decryptDialog.error': return 'Invalid password entered.';
			case 'totp.page.title.edit': return 'Edit TOTP';
			case 'totp.page.title.add': return 'Add a TOTP';
			case 'totp.page.label.text': return 'Label';
			case 'totp.page.label.hint': return 'me@example.com';
			case 'totp.page.secret.text': return 'Secret key';
			case 'totp.page.secret.hint': return 'JBSWY3DPEHPK3PXP';
			case 'totp.page.issuer.text': return 'Issuer';
			case 'totp.page.issuer.hint': return 'example.com';
			case 'totp.page.algorithm': return 'Algorithm';
			case 'totp.page.digits': return 'Digit count';
			case 'totp.page.validity': return 'Validity (in seconds)';
			case 'totp.page.advancedOptions': return 'Advanced options';
			case 'totp.page.showQrCode': return 'Show QR code';
			case 'totp.page.save': return 'Save';
			case 'totp.page.success': return 'Success !';
			case 'totp.page.error.save': return 'Error while saving your TOTP.';
			case 'totp.page.error.qrCode': return 'Please fill the "secret", "label" and "issuer" fields in order to generate a QR code.';
			case 'totp.page.error.emptySecret': return 'Secret should not be empty';
			case 'totp.page.error.invalidSecret': return 'Invalid secret provided';
			case 'totp.page.error.emptyLabel': return 'Label should not be empty';
			case 'totp.page.error.emptyIssuer': return 'Issuer should not be empty';
			case 'validation.success': return 'Validated with success. You can safely close this tab.';
			case 'validation.error.incorrectPath': return ({required Object path}) => 'Something went wrong (path is \'${path}\'). Please report this error.';
			case 'validation.error.generic': return ({required Object exception}) => 'Unable to validate request (exception : ${exception}). Please try again later.';
			case 'validation.oauth2.title': return ({required Object name}) => 'Login with ${name}';
			case 'validation.oauth2.loading': return ({required Object link}) => 'Loading... Click <a href="${link}">here</a> if you are not being redirected.';
			case 'validation.oauth2.error': return ({required Object name}) => 'Unable to login using ${name}. Please try again later.';
			case 'validation.githubCodeDialog.title': return 'Code';
			case 'validation.githubCodeDialog.message': return 'Please enter the following code in the opened browser tab to complete login :';
			case 'validation.githubCodeDialog.countdown': return ({required InlineSpan countdown}) => TextSpan(children: [
				const TextSpan(text: 'Time left : '),
				countdown,
				const TextSpan(text: '.'),
			]);
			default: return null;
		}
	}
}

extension on _TranslationsFr {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'appUnlock.widget.text': return ({required Object app}) => '${app} est verrouillée.';
			case 'appUnlock.widget.button': return 'Déverrouiller';
			case 'appUnlock.localAuthentication.openApp': return 'Authentifiez-vous pour accéder à l\'application.';
			case 'appUnlock.localAuthentication.enable': return 'Authentifiez-vous pour activer l\'authentification locale.';
			case 'appUnlock.localAuthentication.disable': return 'Authentifiez-vous pour désactiver l\'authentification locale.';
			case 'appUnlock.masterPasswordDialog.title': return 'Mot de passe maître';
			case 'appUnlock.masterPasswordDialog.message': return 'Veuillez entrer votre mot de passe maître pour déverrouiller l\'application.';
			case 'authentication.emailDialog.title': return 'Votre adresse mail';
			case 'authentication.emailDialog.message': return 'Veuillez entrer votre adresse mail, nous vous enverrons un lien de connexion.';
			case 'authentication.logIn.waitingDialogMessage': return 'Veuillez vous connecter dans la fenêtre qui vient de s\'ouvrir. Ne fermez pas l\'application.';
			case 'authentication.logIn.error.generic': return 'Quelque-chose s\'est mal passé. Veuillez réessayer plus tard.';
			case 'authentication.logIn.error.timeout': return 'Délai d\'attente dépassé pendant la connexion au fournisseur sélectionné. Veuillez réessayer.';
			case 'authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.title': return 'Un compte existe déjà';
			case 'authentication.logIn.error.accountExistsWithDifferentCredentialsDialog.message': return 'Un compte avec la même adresse mail existe dans notre base de données, mais le fournisseur d\'authentification sélectionné n\'y est pas relié.\nVeuillez vous connecter en utilisant un fournisseur d\'authentification qui y est déjà relié.';
			case 'authentication.logIn.error.invalidCredential': return 'Identifiants incorrects.';
			case 'authentication.logIn.error.operationNotAllowed': return 'Opération non autorisée. Cela ne doit pas arriver, veuillez reporter cette erreur.';
			case 'authentication.logIn.error.userDisabled': return 'Votre compte a été désactivé.';
			case 'authentication.logIn.error.firebaseException': return ({required Object exception}) => 'Une erreur est survenue pendant la connexion à votre compte (erreur : ${exception}). Veuillez réessayer plus tard.';
			case 'authentication.logIn.error.exception': return ({required Object exception}) => 'Une erreur est survenue (erreur : ${exception}). Veuillez réessayer plus tard.';
			case 'authentication.logIn.success': return 'Connexion réussie !';
			case 'authentication.logIn.successNeedConfirmation': return 'Succès ! Vous recevrez un email de confirmation bientôt. Veuillez cliquer sur le lien qui se trouve à l\'intérieur avec cet appareil pour poursuivre la connexion.';
			case 'authentication.linkErrorTimeout': return 'Délai d\'attente dépassé pendant la liaison de votre compte au fournisseur d\'authentification. Veuillez réessayer.';
			case 'authentication.unlink.error.timeout': return 'Délai d\'attente dépassé pendant la suppression de la liaison de votre compte au fournisseur d\'authentification. Veuillez réessayer.';
			case 'authentication.unlink.confirmationDialog.title': return 'Supprimer la liaison au fournisseur';
			case 'authentication.unlink.confirmationDialog.message': return 'Voulez-vous vraiment supprimer la liaison e votre compte à ce fournisseur d\'authentification ?';
			case 'authentication.providerPickerDialog.title': return 'Pick a login method';
			case 'authentication.providerPickerDialog.email.title': return 'Email';
			case 'authentication.providerPickerDialog.email.subtitle': return 'Utilisez votre adresse mail pour vous connecter. Pas besoin de mot de passe, nous vous enverrons un lien de confirmation.';
			case 'authentication.providerPickerDialog.google.title': return 'Google';
			case 'authentication.providerPickerDialog.google.subtitle': return 'Connectez-vous avec votre compte Google.';
			case 'authentication.providerPickerDialog.apple.title': return 'Apple';
			case 'authentication.providerPickerDialog.apple.subtitle': return 'Connectez-vous avec votre compte Apple.';
			case 'authentication.providerPickerDialog.microsoft.title': return 'Microsoft';
			case 'authentication.providerPickerDialog.microsoft.subtitle': return 'Connectez-vous avec votre compte Microsoft.';
			case 'authentication.providerPickerDialog.twitter.title': return 'X';
			case 'authentication.providerPickerDialog.twitter.subtitle': return 'Connectez-vous avec votre compte X.';
			case 'authentication.providerPickerDialog.github.title': return 'Github';
			case 'authentication.providerPickerDialog.github.subtitle': return 'Connectez-vous avec votre compte Github.';
			case 'home.list.empty': return 'Pas de TOTP pour le moment.\nEssayez d\'en ajouter un !';
			case 'home.list.error': return ({required Object error}) => 'Erreur : ${error}. Veuillez réessayer de rafraîchir les données.';
			case 'home.addDialog.title': return 'Ajouter un TOTP';
			case 'home.addDialog.qrCode.title': return 'Ajouter avec un QR code';
			case 'home.addDialog.qrCode.subtitle': return 'Scanner le QR code d\'un TOTP et ajoutez le automatiquement à l\'application !';
			case 'home.addDialog.manually.title': return 'Ajouter manuellement';
			case 'home.addDialog.manually.subtitle': return 'Entrer manuellement les détails du TOTP (ex. secret, étiquette, émetteur, ...).';
			case 'intro.welcome.firstParagraph': return ({required Object app}) => 'Merci d\'avoir téléchargé ${app}, une application open-source qui va vous aider à tranquillement gérer vos TOTPs (Time based One Time Password).';
			case 'intro.welcome.secondParagraph': return 'Vous allez pouvoir configurer l\'application au cours des prochaines étapes pour qu\'elle ressemble à ce que vous souhaitez.';
			case 'intro.welcome.thirdParagraph': return 'J\'espère que vous aimerez utiliser cette application autant que j\'ai aimé la créer !';
			case 'intro.logIn.title': return 'Synchroniser vos TOTPs';
			case 'intro.logIn.firstParagraph': return 'Cliquer sur le bouton "Connexion" ci-dessous pour synchroniser vos TOTPs entre vos appareils.';
			case 'intro.logIn.secondParagraph': return 'Cette étape est complètement optionnelle.';
			case 'intro.logIn.thirdParagraph': return 'Veuillez noter que, si vous activez cette option, nous devrons afficher des annonces dans l\'application pour contribuer au coût des serveurs.';
			case 'intro.logIn.fourthParagraph': return ({required Object app}) => 'Ces annonces peuvent être supprimés à tout moment en souscrivant à l\'Abonnement Contributeur dans les paramètres d\'${app}.';
			case 'intro.logIn.button.loggedOut': return 'Connexion';
			case 'intro.logIn.button.waitingForConfirmation': return 'En attente de confirmation';
			case 'intro.logIn.button.loggedIn': return 'Connecté avec succès';
			case 'intro.logIn.button.error': return 'Impossible de se connecter';
			case 'intro.password.title': return 'Gardez vos données au chaud';
			case 'intro.password.firstParagraph': return 'Pour que vos données restent sécurisées, nous devons vous demander de définir un mot de passe maître.';
			case 'intro.password.secondParagraph': return 'Ce mot de passe sera utilisé pour chiffrer vos données et ne sera jamais envoyé à aucun serveur distant.';
			case 'intro.password.thirdParagraph': return 'Ainsi, si vous l\'oubliez, nous ne pourrons pas le retrouver pour vous. Assurez-vous de l\'enregistrer dans un endroit sécurisé.';
			case 'intro.button.next': return 'Suivant';
			case 'intro.button.finish': return 'Terminer';
			case 'logoSearch.dialogTitle': return 'Choisissez un logo';
			case 'logoSearch.keywords.text': return 'Mots-clés';
			case 'logoSearch.keywords.hint': return 'microsoft.com';
			case 'logoSearch.credits': return ({required Object sources}) => 'Résultats fournis par ${sources}';
			case 'logoSearch.noLogoFound': return 'Pas de logo trouvé. Veuillez essayer d\'autres mots-clés !';
			case 'miscellaneous.waitingDialog.defaultMessage': return 'Veuillez patienter...';
			case 'miscellaneous.waitingDialog.defaultTimeoutMessage': return 'Délai d\'attente dépassé. Veuillez réessayer plus tard.';
			case 'miscellaneous.waitingDialog.countdown': return ({required InlineSpan countdown}) => TextSpan(children: [
				const TextSpan(text: 'Temps restant : '),
				countdown,
				const TextSpan(text: '.'),
			]);
			case 'scan.error.noUri': return 'Impossible de lire ce QR code. Assurez-vous qu\'il s\'agit d\'un QR code de TOTP valide.';
			case 'scan.error.accessDeniedDialog.title': return 'Accès refusé';
			case 'scan.error.accessDeniedDialog.message': return ({required Object exception}) => 'Impossible d\'accéder à votre caméra (accès refusé : ${exception}). Voulez-vous réessayer ?';
			case 'scan.error.scanError': return ({required Object exception}) => 'Une erreur est survenue (erruer : ${exception}). Veuillez réessayer plus tard.';
			case 'settings.title': return 'Paramètres';
			case 'settings.application.title': return 'Application';
			case 'settings.application.contributorPlan.title': return 'Abonnement Contributeur';
			case 'settings.application.contributorPlan.subtitle.loading': return 'Vérification de l\'état de votre abonnement...';
			case 'settings.application.contributorPlan.subtitle.active': return 'Vous avez souscrit à l\'Abonnement Contributeur. Merci beaucoup !';
			case 'settings.application.contributorPlan.subtitle.inactive': return 'Vous n\'avez pas encore souscrit à l\'Abonnement Contributeur. Nous devons afficher des annonces pour contribuer au coût des serveurs.';
			case 'settings.application.contributorPlan.subscribe.waitingDialog.message': return 'En attente de votre paiement...';
			case 'settings.application.contributorPlan.subscribe.waitingDialog.timedOut': return 'Délai d\'attente de la souscription à l\'Abonnement Contributeur dépassé. Veuillez réessayer.';
			case 'settings.application.contributorPlan.subscribe.success': return 'Vous avez souscrit à l\'Abonnement Contributeur avec succès. Merci beaucoup !';
			case 'settings.application.contributorPlan.subscribe.error': return 'Une erreur est survenue pendant votre souscription à l\'Abonnement Contributeur. Veuillez réessayer plus tard.';
			case 'settings.application.contributorPlan.billingPickerDialog.title': return 'Choisissez votre souscription';
			case 'settings.application.contributorPlan.billingPickerDialog.priceSubtitle': return ({required InlineSpan subtitle, required InlineSpan price, required InlineSpan interval}) => TextSpan(children: [
				subtitle,
				const TextSpan(text: '\n'),
				price,
				const TextSpan(text: ' / '),
				interval,
				const TextSpan(text: '.'),
			]);
			case 'settings.application.contributorPlan.billingPickerDialog.empty': return 'Vous ne pouvez pas souscrire à l\'Abonnement Contributeur actuellement.';
			case 'settings.application.contributorPlan.billingPickerDialog.error': return ({required Object error}) => 'Erreur : ${error}.';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeName.annual': return 'Annuelle';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeName.monthly': return 'Mensuelle';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeInterval.annual': return 'An';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeInterval.monthly': return 'Mois';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeSubtitle.annual': return 'Une facturation par an.';
			case 'settings.application.contributorPlan.billingPickerDialog.packageTypeSubtitle.monthly': return 'Une facturation par mois.';
			case 'settings.application.contributorPlan.billingPickerDialog.restorePurchases.button': return 'Restaurer les achats';
			case 'settings.application.contributorPlan.billingPickerDialog.restorePurchases.success': return 'Vos achats ont été restauré avec succès !';
			case 'settings.application.contributorPlan.billingPickerDialog.restorePurchases.error': return 'Une erreur est survenue. Veuillez réessayer plus tard.';
			case 'settings.application.cacheTotpPictures.title': return 'Cacher les images des TOTPs';
			case 'settings.application.cacheTotpPictures.subtitle': return 'S\'assure que les images de vos TOTPs soient toujours disponibles en les cachant sur votre appareil.';
			case 'settings.application.theme.title': return 'Thème';
			case 'settings.application.theme.values.system': return 'Système';
			case 'settings.application.theme.values.light': return 'Lumineux';
			case 'settings.application.theme.values.dark': return 'Sombre';
			case 'settings.security.title': return 'Sécurité';
			case 'settings.security.enableLocalAuth.title': return 'Activer l\'authentification locale';
			case 'settings.security.enableLocalAuth.subtitle': return 'Permet d\'ajouter un niveau de sécurité en demandant un déverrouillage à chaque fois que vous ouvrez l\'application.';
			case 'settings.security.saveDerivedKey.title': return 'Enregistrer la clé de chiffrement / déchiffrement';
			case 'settings.security.saveDerivedKey.subtitle': return 'Enregistre votre clé de chiffrement / déchiffrement pour ne pas avoir à entrer votre mot de passe maître à chaque fois que vous démarrez l\'application.';
			case 'settings.security.changeMasterPassword.title': return 'Changer le mot de passe maître';
			case 'settings.security.changeMasterPassword.subtitle': return ({required InlineSpanBuilder italic}) => TextSpan(children: [
				const TextSpan(text: 'Vous pouvez changer votre mot de passe maître quand vous le souhaitez.\n'),
				italic('Veuillez noter que vous devrez le réentrer dans toutes les instances d\'Open Authenticator qui sont synchronisées ensemble.'),
			]);
			case 'settings.security.changeMasterPassword.dialog.title': return 'Changer votre mot de passe maître';
			case 'settings.security.changeMasterPassword.dialog.current.label': return 'Mot de passe maître actuel';
			case 'settings.security.changeMasterPassword.dialog.current.hint': return 'Entrer votre mot de passe maître actuel';
			case 'settings.security.changeMasterPassword.dialog.newLabel': return 'Votre nouveau mot de passe maître';
			case 'settings.security.changeMasterPassword.dialog.errorIncorrectPassword': return 'Mot de passe incorrect';
			case 'settings.synchronization.title': return 'Synchronisation';
			case 'settings.synchronization.accountLink.title': return 'Relier d\'autres fournisseurs';
			case 'settings.synchronization.accountLink.subtitle.text': return 'Relier d\'autres fournisseurs d\'authentification à votre compte afin que vous puissiez les utiliser pour vous connecter.';
			case 'settings.synchronization.accountLink.subtitle.providers': return ({required Object providers}) => '\nCompte actuellement relié à : ${providers}.';
			case 'settings.synchronization.accountLogin.logIn.title': return 'Connexion';
			case 'settings.synchronization.accountLogin.logIn.subtitle': return 'Connectez vous pour synchroniser vos TOTPs entre vos appareils.';
			case 'settings.synchronization.accountLogin.confirmEmail.title': return 'Confirmer votre adresse mail';
			case 'settings.synchronization.accountLogin.confirmEmail.subtitle': return ({required InlineSpan email}) => TextSpan(children: [
				const TextSpan(text: 'Un email de confirmation a été envoyé à votre adresse mail : '),
				email,
				const TextSpan(text: '.\nVeuillez cliquer sur le lien pour poursuivre la connexion. Vous pouvez également taper ici pour l\'entrer manuellement.'),
			]);
			case 'settings.synchronization.accountLogin.confirmEmail.waitingDialogMessage': return 'Veuillez patienter pendant que nous confirmons votre adresse mail... Ne fermez pas l\'application.';
			case 'settings.synchronization.accountLogin.confirmEmail.error': return 'Quelque chose s\'est mal passé. Veuillez réessayer plus tard.';
			case 'settings.synchronization.accountLogin.confirmEmail.success': return 'Adresse mail confirmée avec succès.';
			case 'settings.synchronization.accountLogin.confirmEmail.linkDialog.title': return 'Lien de confirmation';
			case 'settings.synchronization.accountLogin.confirmEmail.linkDialog.message': return 'Visitez le lien de confirmation avec cet appareil ou collez-le ci-dessous pour confirmer votre adresse mail.';
			case 'settings.synchronization.accountLogin.logOut.title': return 'Déconnexion';
			case 'settings.synchronization.accountLogin.logOut.subtitle': return ({required InlineSpan email}) => TextSpan(children: [
				const TextSpan(text: 'Se déconnecter pour arrêter la synchronisation des TOTPs avec cet appareil.\nActuellement connecté en tant que : '),
				email,
				const TextSpan(text: '.'),
			]);
			case 'settings.synchronization.synchronizeTotps.title': return 'Synchroniser vos TOTPs';
			case 'settings.synchronization.synchronizeTotps.subtitle': return 'Synchroniser vos TOTPs avec tous les appareils connectés.';
			case 'settings.backups.title': return 'Sauvegardes';
			case 'settings.backups.backupNow.title': return 'Sauvegarder maintenant';
			case 'settings.backups.backupNow.subtitle': return 'Créer une sauvegarde de vos TOTPs.';
			case 'settings.backups.backupNow.passwordDialog.title': return 'Mot de passe de la sauvegarde';
			case 'settings.backups.backupNow.passwordDialog.message': return 'Veuillez entrer un mot de passe pour la sauvegarde. Veuillez noter que nous ne pouvons sauvegarder que les TOTPs déchiffrés (ceux qui affichent un code).';
			case 'settings.backups.backupNow.error': return 'Une erreur est survenue pendant la sauvegarde de vos données.';
			case 'settings.backups.backupNow.success': return 'Succès !';
			case 'settings.backups.manageBackups.title': return 'Gestion des sauvegardes';
			case 'settings.backups.manageBackups.subtitle': return ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
				zero: 'Vous n\'avez aucune sauvegarde.',
				one: 'Vous avez actuellement ${n} sauvegarde.',
				other: 'Vous avez actuellement ${n} sauvegardes.',
			);
			case 'settings.backups.manageBackups.backupsDialog.title': return 'Gestion des sauvegardes';
			case 'settings.backups.manageBackups.backupsDialog.errorLoadingBackups': return 'Impossible de charger la liste des sauvegardes. Veuillez réessayer plus tard.';
			case 'settings.backups.manageBackups.restoreBackup.passwordDialog.title': return 'Mot de passe de la sauvegarde';
			case 'settings.backups.manageBackups.restoreBackup.passwordDialog.message': return 'Veuillez entrer un mot de passe pour la sauvegarde.';
			case 'settings.backups.manageBackups.restoreBackup.success': return 'Succès !';
			case 'settings.backups.manageBackups.restoreBackup.error': return 'Impossible de restaurer la sauvegarde. Assurez-vous d\'avoir entré le bon mot de passe.';
			case 'settings.backups.manageBackups.deleteBackup.confirmationDialog.title': return 'Supprimer la sauvegarde';
			case 'settings.backups.manageBackups.deleteBackup.confirmationDialog.message': return 'Voulez-vous vraiment supprimer cette sauvegarde ?';
			case 'settings.backups.manageBackups.deleteBackup.success': return 'Succès !';
			case 'settings.backups.manageBackups.deleteBackup.error': return 'Impossible de supprimer cette sauvegarde. Veuillez réessayer plus tard.';
			case 'settings.about.title': return 'À propos';
			case 'settings.about.aboutApp.title': return ({required Object appName}) => '${appName}';
			case 'settings.about.aboutApp.subtitle': return ({required InlineSpan appName, required InlineSpan appVersion, required InlineSpan appAuthor}) => TextSpan(children: [
				appName,
				const TextSpan(text: ' v'),
				appVersion,
				const TextSpan(text: ', par '),
				appAuthor,
				const TextSpan(text: '.'),
			]);
			case 'settings.about.aboutApp.dialogLegalese': return ({required Object appName, required Object appAuthor}) => '${appName} est une application open-source, créée par ${appAuthor}.';
			case 'storageMigration.masterPasswordDialog.title': return 'Mot de passe maître';
			case 'storageMigration.masterPasswordDialog.message': return 'Veuillez entrer votre mot de passe maître pour continuer.';
			case 'storageMigration.success': return 'Succès !';
			case 'storageMigration.error.saltError': return 'Erreur de "Sel" pendant la migration de vos données. Veuillez réessayer plus tard.';
			case 'storageMigration.error.currentStoragePasswordMismatch': return 'Mot de passe maître invalide.';
			case 'storageMigration.error.encryptionKeyChangeFailed': return 'Une erreur est survenue pendant le chiffrement de vos données. Veuillez réessayer plus tard.';
			case 'storageMigration.error.genericError': return 'Une erreur est survenue pendant la migration de vos données. Veuillez réessayer plus tard.';
			case 'storageMigration.newStoragePasswordMismatchDialog.title': return 'Mot de passe maître du stockage';
			case 'storageMigration.newStoragePasswordMismatchDialog.defaultMessage': return 'Le stockage distant a été chiffré avec un mot de passe maître différent du vôtre. Veuillez l\'entrer ci-dessous pour continuer.\nNotez que cela va définir votre nouveau mot de passe maître. Vous pourrez tout de même le changer à n\'importe quel moment.';
			case 'storageMigration.newStoragePasswordMismatchDialog.errorMessage': return 'Le stockage distant a été chiffré avec un mot de passe maître différent du vôtre. Vous en avez entré un mauvais, veuillez réessayer.\nNotez que cela va définir votre nouveau mot de passe maître. Vous pourrez tout de même le changer à n\'importe quel moment.';
			case 'storageMigration.deletedTotpPolicyPickerDialog.title': return 'Migrer les TOTPs';
			case 'storageMigration.deletedTotpPolicyPickerDialog.message': return 'Certains TOTPs ont été supprimés sur votre appareil, mais pas sur le stockage distant. Que voulez-vous faire ?';
			case 'storageMigration.deletedTotpPolicyPickerDialog.delete.title': return 'Les supprimer';
			case 'storageMigration.deletedTotpPolicyPickerDialog.delete.subtitle': return 'Supprimer les TOTPs conflictuels. Cette action est irréversible.';
			case 'storageMigration.deletedTotpPolicyPickerDialog.restore.title': return 'Les garder';
			case 'storageMigration.deletedTotpPolicyPickerDialog.restore.subtitle': return 'Annule la suppression et garde tous vos TOTPs.';
			case 'totp.actions.decrypt': return 'Déchiffrer';
			case 'totp.actions.mobileDialog.title': return 'Actions sur le TOTP';
			case 'totp.actions.mobileDialog.edit': return 'Éditer le TOTP';
			case 'totp.actions.mobileDialog.delete': return 'Supprimier le TOTP';
			case 'totp.actions.desktopButtons.copy': return 'Copier code';
			case 'totp.actions.desktopButtons.edit': return 'Éditer';
			case 'totp.actions.desktopButtons.delete': return 'Supprimer';
			case 'totp.actions.copyConfirmation': return 'Copié dans le presse-papier.';
			case 'totp.actions.deleteConfirmationDialog.title': return 'Supprimer ce TOTP';
			case 'totp.actions.deleteConfirmationDialog.message': return 'Voulez-vous vraiment supprimer ce TOTP ?';
			case 'totp.actions.deleteConfirmationDialog.error': return 'Impossible de supprimer ce TOTP.';
			case 'totp.decryptDialog.title': return 'Déchiffrement du TOTP';
			case 'totp.decryptDialog.message': return 'Ce TOTP a été chiffré en utilisant un mot de passe maître différent. Veuillez l\'entrer ci-dessous pour le déchiffrer.';
			case 'totp.decryptDialog.success': return 'Succès !';
			case 'totp.decryptDialog.error': return 'Mot de passe invalide.';
			case 'totp.page.title.edit': return 'Éditer le TOTP';
			case 'totp.page.title.add': return 'Ajouter un TOTP';
			case 'totp.page.label.text': return 'Étiquette';
			case 'totp.page.label.hint': return 'me@exemple.com';
			case 'totp.page.secret.text': return 'Clé secrète';
			case 'totp.page.secret.hint': return 'JBSWY3DPEHPK3PXP';
			case 'totp.page.issuer.text': return 'Émetteur';
			case 'totp.page.issuer.hint': return 'exemple.com';
			case 'totp.page.algorithm': return 'Algorithme';
			case 'totp.page.digits': return 'Nombre de chiffres';
			case 'totp.page.validity': return 'Validité (en secondes)';
			case 'totp.page.advancedOptions': return 'Options avancées';
			case 'totp.page.showQrCode': return 'Afficher le QR code';
			case 'totp.page.save': return 'Enregistrer';
			case 'totp.page.success': return 'Succès !';
			case 'totp.page.error.save': return 'Une erreur est survenue lors de la sauvegarde de votre TOTP.';
			case 'totp.page.error.qrCode': return 'Veuillez remplir les champs "clé secrète", "étiquette" et "émetteur" pour pouvoir générer un QR code.';
			case 'totp.page.error.emptySecret': return 'Le secret doit être spécifié';
			case 'totp.page.error.invalidSecret': return 'Clé secrète invalide';
			case 'totp.page.error.emptyLabel': return 'L\'étiquette doit être spécifiée';
			case 'totp.page.error.emptyIssuer': return 'L\'émetteur doit être spécifié';
			case 'validation.success': return 'Validation réussie. Vous pouvez fermer cet onglet.';
			case 'validation.error.incorrectPath': return ({required Object path}) => 'Une erreur est survenue (le chemin est \'${path}\'). Veuillez reporter cette erreur.';
			case 'validation.error.generic': return ({required Object exception}) => 'Impossible de valider votre requête (erreur : ${exception}). Veuillez réessayer plus tard.';
			case 'validation.oauth2.title': return ({required Object name}) => 'Connexion avec ${name}';
			case 'validation.oauth2.loading': return ({required Object link}) => 'Chargement... Cliquez <a href="${link}">ici</a> si vous n\'êtes pas redirigé.';
			case 'validation.oauth2.error': return ({required Object name}) => 'Impossible de se connecter avec ${name}. Veuillez réessayer plus tard.';
			case 'validation.githubCodeDialog.title': return 'Code';
			case 'validation.githubCodeDialog.message': return 'Veuillez entrer le code ci-dessous dans l\'onglet qui vient de s\'ouvrir pour vous connecter :';
			case 'validation.githubCodeDialog.countdown': return ({required InlineSpan countdown}) => TextSpan(children: [
				const TextSpan(text: 'Temps restant : '),
				countdown,
				const TextSpan(text: '.'),
			]);
			default: return null;
		}
	}
}
