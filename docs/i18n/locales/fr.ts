export default {
  navbar: {
    index: 'Accueil',
    faq: 'FAQ',
    privacyPolicy: 'Politique de confidentialité',
    termsOfService: 'Conditions d\'utilisation',
    contact: 'Contact',
    downloadButton: 'Télécharger',
  },
  footer: {
    app: {
      title: 'Application',
      index: 'Accueil',
      download: 'Téléchargement',
      translation: 'Traduction',
    },
    legal: {
      title: 'Légal',
      license: 'Licence',
      privacyPolicy: 'Politique de confidentialité',
      termsOfService: 'Conditions d\'utilisation',
      contact: 'Contact',
    },
    language: 'Langage',
  },
  index: {
    main: {
      title: {
        1: 'Sécurisez vos comptes',
        2: 'avec une appli <strong>gratuite</strong>, <strong>open-source</strong> et <strong>faîte avec amour</strong>',
      },
      features: {
        1: '<strong>Gratuit</strong> & <strong>open-source</strong>.',
        2: '<strong>Synchronisez</strong> facilement vos TOTPs (<em>Time-based One-Time Password</em>).',
        3: '<strong>Protégez</strong> vos données.',
        4: 'Utilisable sur (presque) <strong>toutes les plateformes</strong>.',
      },
      downloadButton: 'Télécharger',
      latestVersion: {
        text: 'Dernière version :',
        changelog: 'Changelog',
      },
    },
    download: {
      title: '<strong>Télécharger</strong> l\'appli',
      description: `Open Authenticator a été créé avec Flutter. Ainsi, vous pouvez l'utiliser aussi bien sur <strong>Android</strong>
que sur <strong>iOS</strong>, ou encore <strong>macOS</strong>, <strong>Windows</strong> et même <strong>Linux</strong> !`,
      storeButtons: {
        availableSoonTemplate: 'Bientôt disponible pour %s !',
        availableOnTemplate: 'Télécharger pour %s',
        morePlatformsButton: 'Une autre plateforme ?',
      },
    },
    openSource: {
      title: 'Open-source',
      description: {
        1: `Open Authenticator est une application open-source que vous pouvez utiliser de manière complétement gratuite.
Elle est disponible sous licence <a class="underline" href="https://github.com/Skyost/OpenAuthenticator">GNU GPL v3</a>.
Vous pouvez contribuer au projet en soumettant vos <strong>pull requests</strong> sur Github,
en <strong>faisant un don</strong> ou tout simplement en lui <strong>attribuant une étoile</strong> sur Github !`,
        2: `Vous avez aussi la possibilité d'aider à traduire l'application. Pour ce faire, rendez-vous sur la
page de <a href="/translate/">traduction</a>. Un grand merci à <a class="underline" href="https://github.com/Skyost/OpenAuthenticator/contributors">tous les contributeurs</a> !`,
      },
      linkButtons: {
        github: 'Github',
        translate: 'Traduire l\'application',
        paypal: 'Faire un don',
      },
    },
  },
  faq: {
    title: 'Foire aux questions',
    lastUpdated: 'Dernière mise à jour le 12 juillet 2024',
    questions: {
      1: {
        question: 'Que faire si j\'oublie mon mot de passe principal ?',
        answer: `<p>Nous ne pouvons rien faire. Pour de vrai. Vos TOTPs sont chiffrés à l'aide d'une clé dérivée de votre mot de passe principal
avec l'algorithme <a href="https://fr.wikipedia.org/wiki/Argon2">Argon2</a>. Nous ne pourrons pas récupérer
vos données si vous oubliez votre mot de passe principal. Pour cette raison, il est fortement recommandé de faire des sauvegardes régulières.</p>
<p>L'application vous demande automatiquement de faire une sauvegarde avant des opérations sensibles, mais vous pouvez en créer
manuellement dans les paramètres de l'application.</p>`,
      },
      2: {
        question: 'Où sont stockées mes données ?',
        answer: `<p>Si vous n'avez pas activé la synchronisation des données, tout est stocké localement dans une base de données SQLite
gérée à l'aide de <a href="https://drift.simonbinder.eu/">Drift</a>. Même dans ce cas, tout est chiffré.
Si vous avez activé la synchronisation des données, nous utilisons Firestore pour stocker vos données. Si l'application devient populaire,
nous prévoyons de créer notre propre backend.</p>`,
      },
      3: {
        question: 'Qu\'est-ce que l\'Abonnement Contributeur ?',
        answer: `<p>Comme vous le savez peut-être, les serveurs ne sont pas gratuits. Dans notre cas, comme nous nous appuyons sur Firebase, plus nous avons
d'utilisateurs, plus nous devons payer. Donc, soit nous :</p>
<ol>
  <li>mettons des publicités dans notre application ;</li>
  <li>comptons exclusivement sur les dons ;</li>
  <li>demandons à nos utilisateurs de payer un peu d'argent.</li>
</ol>
<p>L'option 2 n'est pas réaliste du tout. L'option 1 pourrait être une solution, mais les publicités entraînent généralement une mauvaise
expérience utilisateur. Par conséquent, le choix que nous avons fait pour amortir les coûts est de créer un modèle d'abonnement
appelé <q>Abonnement Contributeur</q>. Actuellement, vous pouvez stocker et synchroniser jusqu'à six TOTPs gratuitement,
avec tous vos appareils. En vous abonnant au Abonnement Contributeur, vous pourrez synchroniser autant de TOTPs que vous le souhaitez.</p>
<p>À l'avenir, nous espérons pouvoir lever ces limitations, voire les supprimer ! Dans tous les cas, vous
pouvez utiliser l'application en local sans aucune limitation ni publicité.</p>`,
      },
    },
    questionLeft: {
      text: 'Il vous reste une question ?',
      askButton: 'Posez-la !',
    },
  },
  privacyPolicy: {
    title: 'Politique de confidentialité',
    lastUpdated: 'Dernière mise à jour le 01 avril 2024',
    intro: `Cette politique de confidentialité s'applique à l'application Open Authenticator
(ci-après dénommée <q>Application</q>) pour appareils mobiles, développée par Skyost
(ci-après dénommée <q>Fournisseur de services</q>) en tant que service pris en charge par abonnement.
Ce service est fourni <q>TEL QUEL</q>.`,
    userProvidedInfo: {
      title: 'Informations fournies par l\'utilisateur',
      content: `L'Application acquiert les informations que vous fournissez lors du téléchargement
et de l'enregistrement de l'Application. L'inscription auprès du Fournisseur de services n'est pas obligatoire.
Cependant, veuillez noter que vous pourriez ne pas pouvoir utiliser certaines fonctionnalités proposées
par l'Application à moins de vous inscrire auprès d'eux. Le Fournisseur de services peut également
utiliser les informations que vous lui avez fournies pour vous contacter de temps en temps afin de vous
fournir des informations importantes, des avis nécessaires et des promotions marketing.`,
    },
    automaticallyCollectedInfo: {
      title: 'Informations collectées automatiquement',
      content: `En outre, l'Application peut collecter certaines informations automatiquement, y compris,
mais sans s'y limiter, le type d'appareil mobile que vous utilisez, l'identifiant unique de votre appareil
mobile, l'adresse IP de votre appareil mobile, votre système d'exploitation mobile, le type de navigateurs
Internet mobiles que vous utilisez, et des informations sur la manière dont vous utilisez l'Application.
Cette collecte de données est nécessaire pour mieux comprendre les journaux d'erreurs.`,
    },
    locationInfo: {
      title: 'L\'Application collecte-t-elle des informations sur la localisation en temps réel précise de l\'appareil ?',
      content: `Cette Application ne recueille pas d'informations précises sur la localisation de votre
appareil mobile.`,
    },
    thirdPartyAccess: {
      title: 'Les tiers voient-ils et/ou ont-ils accès aux informations obtenues par l\'Application ?',
      content: `Seules les données agrégées et anonymisées sont périodiquement transmises à des services
externes pour aider le Fournisseur de services à améliorer l'Application et leur service.
Le Fournisseur de services peut partager vos informations avec des tiers de la manière décrite dans cette
déclaration de confidentialité.`,
    },
    thirdPartyProviders: {
      title: 'Fournisseurs tiers',
      content: 'Veuillez noter que l\'Application utilise des services tiers qui ont leur propre politique de confidentialité concernant la gestion des données. Vous trouverez ci-dessous les liens vers la politique de confidentialité des fournisseurs de services tiers utilisés par l\'Application :',
      list: {
        googlePlayServices: '<a href="https://www.google.com/policies/privacy/" target="_blank">Services Google Play</a>',
        firebase: '<a href="https://firebase.google.com/support/privacy/" target="_blank">Firebase (y compris, mais sans s\'y limiter, Crashlytics, Cloud Firestore, ...)</a>',
        revenueCat: '<a href="https://www.revenuecat.com/privacy" target="_blank">RevenueCat</a>',
      },
    },
    disclosure: {
      title: 'Divulgation des informations',
      content: 'Le Fournisseur de services peut divulguer les informations fournies par l\'utilisateur et collectées automatiquement :',
      list: {
        1: `si cela est exigé par la loi, tel que pour se conformer à une assignation à comparaître ou
à une procédure judiciaire similaire ;`,
        2: `lorsqu'ils croient de bonne foi que la divulgation est nécessaire pour protéger leurs droits,
assurer votre sécurité ou celle des autres, enquêter sur la fraude ou répondre à une demande du
gouvernement ;`,
        3: `avec leurs fournisseurs de services de confiance qui travaillent en leur nom,
n'ont pas d'utilisation indépendante des informations que nous leur divulguons et ont accepté de respecter
les règles énoncées dans cette déclaration de confidentialité.`,
      },
    },
    optOut: {
      title: 'Quels sont mes droits de désinscription ?',
      content: `Vous pouvez arrêter toute collecte d'informations par l'Application facilement en
désinstallant l'Application. Vous pouvez utiliser les processus de désinstallation standard disponibles
dans le cadre de votre appareil mobile ou via le marché ou le réseau d'applications mobiles.`,
    },
    dataRetention: {
      title: 'Politique de conservation des données, Gestion de vos informations',
      content: `Le Fournisseur de services conservera les données fournies par l'utilisateur aussi longtemps
que vous utiliserez l'Application et pendant un certain temps raisonnable par la suite. Le Fournisseur
de services conservera les informations collectées automatiquement jusqu'à 24 mois,
puis pourra les stocker de manière agrégée. Si vous souhaitez que le Fournisseur de services supprime
les données fournies par l'utilisateur transmises via l'Application,
veuillez <a href="/contact">les contacter</a> et ils vous répondront dans un délai raisonnable.
Veuillez noter que certaines ou toutes les données fournies par l'utilisateur peuvent être nécessaires
pour que l'Application fonctionne correctement.
Votre mot de passe maître n'est pas transmis à un serveur distant.
<strong>Si vous l'oubliez, nous ne pouvons pas vous aider à le récupérer.</strong>
Veuillez noter que, bien que nous nous efforcions de fournir une sécurité raisonnable
pour les informations que nous traitons et que nous conservons, aucun système de sécurité ne peut
empêcher toutes les violations de sécurité potentielles.`,
    },
    children: {
      title: 'Enfants',
      content: `Le Fournisseur de services n'utilise pas l'Application pour solliciter sciemment
des données auprès d'enfants de moins de 13 ans. L'Application ne s'adresse à personne de moins de 13 ans.
Le Fournisseur de services ne collecte sciemment aucune information d'identification personnelle auprès
d'enfants de moins de 13 ans.`,
    },
    security: {
      title: 'Sécurité',
      content: `Le Fournisseur de services est soucieux de protéger la confidentialité de vos informations.
Le Fournisseur de services fournit des garanties physiques, électroniques et procédurales pour protéger
les informations que nous traitons et conservons. Par exemple, si vous choisissez de synchroniser vos
données entre vos appareils, nous utilisons Firebase Cloud Firestore pour stocker vos TOTP.
Leur <a href="https://en.wikipedia.org/wiki/Time-based_one-time_password#Security">secret et métadonnées</a>
sont cryptés à l'aide d'un algorithme <a href="https://en.wikipedia.org/wiki/Galois/Counter_Mode">AES-GCM</a>
avec une clé dérivée <a href="https://en.wikipedia.org/wiki/Argon2">Argon2</a> basée sur votre mot de
passe maître et un sel aléatoire.`,
    },
    changes: {
      title: 'Changements',
      content: 'Cette politique de confidentialité peut être mise à jour de temps à autre pour quelque raison que ce soit. Le Fournisseur de services vous informera de tout changement apporté à la politique de confidentialité en mettant à jour cette page avec la nouvelle politique de confidentialité.',
      effectiveDate: 'Cette politique de confidentialité est en vigueur à compter du 01 avril 2024.',
    },
    contact: {
      title: 'Contactez-nous',
      content: `Si vous avez des questions concernant la confidentialité lors de l'utilisation de
l'Application, ou si vous avez des questions sur les pratiques, veuillez <a href="/contact">nous contacter</a>.`,
    },
    credit: 'Merci à <a href="https://app-privacy-policy-generator.firebaseapp.com/"><em>nisrulz</em></a> pour cette politique de confidentialité.',
  },
  termsOfService: {
    title: 'Conditions générales d\'utilisation',
    lastUpdated: 'Dernière mise à jour le 01 avril 2024',
    intro: `Ces conditions générales s'appliquent à l'application Open Authenticator (ci-après dénommée <q>Application</q>)
pour appareils mobiles créée par Skyost (ci-après dénommée <q>Fournisseur de services</q>) en tant que
service pris en charge par un abonnement.`,
    agreement: `En téléchargeant ou en utilisant l'Application, vous acceptez automatiquement les conditions suivantes
et la <nuxt-link to="/privacy-policy">Politique de confidentialité</nuxt-link>.
Il est fortement recommandé de lire et de comprendre ces conditions avant d'utiliser l'Application.
La copie non autorisée, la modification de l'Application, de toute partie de l'Application ou de nos marques commerciales
est strictement interdite.
Toute tentative de créer des versions dérivées ou des <q>copies</q> n'est pas autorisée.
Toutes les marques commerciales, droits d'auteur, droits de base de données et autres droits de propriété intellectuelle
liés à l'Application restent la propriété du Fournisseur de services.`,
    modification: `Le Fournisseur de services est déterminé à garantir que l'Application soit aussi bénéfique et efficace que possible.
À ce titre, il se réserve le droit de modifier l'Application ou de facturer ses services à tout moment et pour quelque raison que ce soit.
Le Fournisseur de services vous assure que toute facturation pour l'Application ou ses services vous sera clairement communiquée.`,
    dataProcessing: `L'Application stocke et traite les données personnelles que vous avez fournies au Fournisseur de services afin de fournir le Service.
Il est de votre responsabilité de maintenir la sécurité de votre téléphone et l'accès à l'Application.
Le Fournisseur de services déconseille fortement de jailbreaker ou de rooter votre téléphone, ce qui consiste à supprimer
les restrictions et limitations logicielles imposées par le système d'exploitation officiel de votre appareil.
De telles actions pourraient exposer votre téléphone à des logiciels malveillants, à des virus, à des programmes malveillants,
compromettre les fonctionnalités de sécurité de votre téléphone et entraîner un dysfonctionnement, voire une absence de fonctionnement, de l'Application.`,
    thirdPartyTerms: `Veuillez noter que l'Application utilise des services tiers qui ont leurs propres conditions générales.
Ci-dessous sont les liens vers les conditions générales des fournisseurs de services tiers utilisés par l'Application :`,
    thirdPartyTermsList: {
      googlePlayServices: '<a href="https://www.google.com/policies/privacy/" target="_blank">Services Google Play</a>',
      firebase: '<a href="https://firebase.google.com/support/privacy/" target="_blank">Firebase (y compris, mais sans s\'y limiter, Crashlytics, Cloud Firestore, ...)</a>',
      revenueCat: '<a href="https://www.revenuecat.com/privacy" target="_blank">RevenueCat</a>',
    },
    responsibility: `Veuillez noter que le Fournisseur de services ne assume pas la responsabilité pour certains aspects.
Certaines fonctions de l'Application nécessitent une connexion Internet active, qui peut être Wi-Fi ou fournie
par votre fournisseur de réseau mobile. Le Fournisseur de services ne peut être tenu responsable si l'Application
ne fonctionne pas à pleine capacité en raison du manque d'accès au Wi-Fi ou si vous avez épuisé votre allocation de données.`,
    charges: `Si vous utilisez l'application en dehors d'une zone Wi-Fi, veuillez noter que les conditions de l'accord de
votre fournisseur de réseau mobile s'appliquent toujours. Par conséquent, vous pouvez encourir des frais de votre fournisseur mobile
pour l'utilisation de données lors de la connexion à l'application, ou d'autres frais tiers.
En utilisant l'application, vous acceptez la responsabilité de ces frais, y compris les frais d'itinérance des données
si vous utilisez l'application en dehors de votre territoire domestique (c'est-à-dire, région ou pays) sans désactiver l'itinérance des données.
Si vous n'êtes pas le payeur de la facture pour l'appareil sur lequel vous utilisez l'application, ils supposent
que vous avez obtenu l'autorisation du payeur de la facture.`,
    battery: `De même, le Fournisseur de services ne peut pas toujours assumer la responsabilité de votre utilisation de l'application.
Par exemple, il est de votre responsabilité de veiller à ce que votre appareil reste chargé.
Si votre appareil est déchargé et que vous ne pouvez pas accéder au Service, le Fournisseur de services ne peut pas être tenu responsable.`,
    termination: `Le Fournisseur de services peut souhaiter mettre à jour l'application à un moment donné.
L'application est actuellement disponible selon les exigences du système d'exploitation
(et pour tout système supplémentaire qu'ils décident d'étendre la disponibilité de l'application à) peuvent changer,
et vous devrez télécharger les mises à jour si vous souhaitez continuer à utiliser l'application.
Le Fournisseur de services ne garantit pas qu'il mettra toujours à jour l'application afin qu'elle soit pertinente
pour vous et/ou compatible avec la version particulière du système d'exploitation installée sur votre appareil.
Cependant, vous acceptez toujours d'accepter les mises à jour de l'application lorsqu'elles vous sont proposées.
Le Fournisseur de services peut également souhaiter cesser de fournir l'application et peut résilier son utilisation à tout moment
sans vous fournir de préavis de résiliation. Sauf s'ils vous informent autrement, à la résiliation,
(a) les droits et licences qui vous sont accordés dans ces conditions prendront fin ; (b) vous devez cesser d'utiliser l'application,
et (si nécessaire) le supprimer de votre appareil.`,
    legalRiskResponsibility: {
      title: 'Risque légal et responsabilité',
      noWarranty: {
        title: 'Aucune garantie',
        content: `Tout le contenu (y compris, mais sans s'y limiter, vos TOTP) est mis à disposition TEL QUEL et le Fournisseur de services
ne propose aucune garantie d'aucune sorte, ou ne garantit que le Contenu sera exact, complet ou exempt d'erreurs.`,
      },
      synchronizationSecurity: {
        title: 'Synchronisation et sécurité',
        content: `Si vous choisissez de synchroniser vos données (y compris, mais sans s'y limiter : vos TOTP, votre
adresse e-mail, votre identifiant d'utilisateur généré automatiquement par Firebase, etc.) entre vos appareils, vous reconnaissez
qu'elles seront stockées sur les serveurs Firebase.
Veuillez noter que, bien que nous nous efforcions de fournir une sécurité raisonnable pour les informations que nous traitons et
maintenons, aucun système de sécurité ne peut prévenir toutes les violations potentielles de la sécurité.
Par conséquent, nous ne sommes pas responsables de toute perte de données, de toute fuite ou de tout dommage résultant de l'utilisation de
l'application.`,
      },
      releaseIndemnity: {
        title: 'Délivrance et indemnisation',
        content: `Dans la mesure permise par la loi applicable, vous acceptez de libérer et de renoncer à toute réclamation et/ou responsabilité contre
le Fournisseur de services découlant de votre utilisation de l'Application ou de tout abonnement à l'Application. Vous acceptez également de défendre,
indemniser et dégager de toute responsabilité le Fournisseur de services, ses dirigeants, directeurs, employés, partenaires, contributeurs ou concédants de licence de et
contre toute réclamation, dommage, obligation, perte, responsabilité, (y compris, mais sans s'y limiter, les honoraires d'avocat) découlant de : (i) votre utilisation de et
accès à l'Application ; (ii) votre violation de l'une quelconque des conditions de ces conditions d'utilisation ; et (iii) votre violation de tout droit de tiers, y compris, sans limitation,
tout droit d'auteur, de propriété ou de confidentialité.`,
      },
      limitationOfLiability: {
        title: 'Limitation de responsabilité',
        content: `Comme indiqué précédemment, en aucune circonstance, y compris la négligence, le Fournisseur de services, ses dirigeants, directeurs,
employés, partenaires, contributeurs ou concédants de licence ne peuvent être tenus responsables de tout dommage direct, indirect, accessoire, spécial,
punitif ou consécutif pouvant résulter de l'accès, de l'utilisation ou de l'incapacité d'accéder au contenu de l'Application, y compris, sans limitation,
l'utilisation ou la confiance en les informations, les interruptions, les erreurs, les défauts, les erreurs,
omissions, suppressions de fichiers, retards dans les opérations ou la transmission, non-livraison d'informations, divulgation de
communications, ou tout autre défaillance de performance.`,
      },
    },
    changes: {
      title: 'Modifications de ces conditions générales d\'utilisation',
      content: `Le Fournisseur de services peut mettre périodiquement à jour ses conditions générales.
Par conséquent, il est conseillé de consulter régulièrement cette page pour connaître les changements éventuels.
Le Fournisseur de services vous informera de tout changement en publiant les nouvelles conditions générales sur cette page.`,
      effectiveDate: 'Ces conditions générales sont en vigueur à compter du 01 avril 2024.',
    },
    contact: {
      title: 'Contactez-nous',
      content: `Si vous avez des questions ou des suggestions concernant les Conditions générales d'utilisation,
n'hésitez pas à <nuxt-link to="/contact">nous contacter</nuxt-link>.`,
    },
    credit: 'Merci à <a href="https://app-privacy-policy-generator.firebaseapp.com/"><em>nisrulz</em></a> pour ces conditions générales d\'utilisation.',
  },
  contact: {
    title: 'Contact',
    description: `Si vous souhaitez me contacter à propos du développement d'Open Authenticator ou un autre sujet en rapport
(par exemple, pour rapporter un bug), veuillez ouvrir une issue sur <a href="https://github.com/Skyost/OpenAuthenticator">Github</a>.
Si vous souhaitez me contacter pour n'importe quelle autre raison ou pour supprimer votre compte, vous pouvez utiliser le formulaire de contact
ci-dessous.`,
    form: {
      name: {
        label: 'Votre nom',
        placeholder: 'Entrez votre nom ici',
      },
      email: {
        label: 'Votre e-mail',
        placeholder: 'Entrez votre adresse e-mail ici',
      },
      subject: {
        label: 'Sujet de votre message',
        options: {
          accountDeletion: 'Suppression de mon compte',
          moreInfoNeeded: 'Demande d\'informations complémentaires',
          commercial: 'Commercial',
          other: 'Autre',
        },
      },
      message: {
        label: 'Contenu de votre message',
        placeholder: 'Entrez votre message ici',
      },
      success: 'Votre requête a été transmise avec succès.',
      error: 'Une erreur est survenue pendant l\'envoi de votre message.',
      send: 'Envoyer',
    },
  },
  translate: {
    pageTitle: 'Traduction',
    title: 'Aider à traduire Open Authenticator',
    notYourLanguage: 'Pas votre langue ?',
    description: `Vous parlez une autre langue ? Vous souhaitez contributer à un projet open-source ? N'en dites pas plus,
Open Authenticator cherche des traducteurs !`,
    pickLanguage: 'D\'abord, choisissez votre langage.',
    languageDescription: `<p>La traduction s'organise en plusieurs fichiers. Pour en traduire un, il faut d'abord le dérouler.
Une fois fait, vous verrez s'afficher les textes originaux dans la colonne de gauche, et la traduction existante dans la colonne
de droite. Lorsque vous aurez terminé la traduction d'un fichier, vous pouvez l'envoyer en cliquant sur le bouton de soumission vert.</p>
<p>Il est possible de sauvegarder votre progression à tout moment en utilisant le bouton <q>Sauvegarder</q>.
Le bouton <q>Charger</q> permettra alors de reprendre la traduction.</p>`,
    accordion: {
      load: 'Charger',
      save: 'Sauvegarder',
      submit: 'Soumettre',
    },
    table: {
      originalText: 'Texte original',
      translation: 'Traduction',
    },
    modal: {
      modalTitle: 'Envoyer votre traduction',
      title: 'Merci beaucoup de contribuer à Open Authenticator !',
      subtitle: 'Suivez les étapes ci-dessous pour envoyer votre traduction.',
      grabCode: {
        title: 'Copier le code',
        copyCode: 'Vous devez tout d\'abord copier le code ci-dessous.',
        copyToClipboard: 'Copier dans le presse-papier',
        translationData: 'Cela contient vos données de traduction.',
      },
      openGithub: {
        title: 'Ouvrir Github',
        click: 'Cliquez sur le lien ci-dessous pour éditer le fichier sur Github.',
        note: `<strong>Note.</strong> Vous avez besoin d'un compte Github.
Veuillez en <a class="link-danger" href="https://github.com/">créer un</a> avant d'aller plus loin.`,
      },
      fork: {
        title: 'Forker le dépôt',
        fork: 'Cliquez sur <button class="btn btn-success text-button">Fork this repository</button>.',
        pasteTheCode: 'Une fois fait, collez le code copié à l\'<em>Étape <strong>#1</strong></em>.',
        commit: 'Puis, cliquez sur <button class="btn btn-success text-button">Commit changes...</button> et sur <button class="btn btn-success text-button">Propose changes</button>.',
      },
      pullRequest: {
        title: 'Créer une pull request',
        beforeCreate: 'Cliquez sur <button class="btn btn-success text-button">Create pull request</button>, et compléter le formulaire.',
        form: {
          title: 'Vous pouvez écrire quelque-chose comme <q><span class="font-monospace">feat: Translated `(file)` into `(language)`.</span></q> (en anglais).',
          message: 'Toujours en anglais, laissez un message détaillant ce que vous avez traduit, et ce qui reste à traduire.',
        },
        create: 'Puis, cliquez sur <button class="btn btn-success text-button">Create pull request</button>.',
      },
      done: {
        title: 'Fini !',
        message: 'Vous soumission sera examinée, et sera vraisemblablement approuvée si elle suit les standards de qualité d\'Open Authenticator 😎',
      },
      close: 'Fermer',
    },
    unsavedChanges: 'Il semble que vous avez des changements non enregistrés. Ils seront perdus si vous quittez cette page. Voulez-vous continuer ?',
    error: 'Une erreur est survenue durant l\'obtention des données de traduction.',
  },
}
