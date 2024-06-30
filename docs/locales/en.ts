export default {
  navbar: {
    index: 'Home',
    privacyPolicy: 'Privacy policy',
    termsOfService: 'Terms of services',
    contact: 'Contact',
    downloadButton: 'Download',
  },
  footer: {
    app: {
      title: 'App',
      index: 'Home',
      download: 'Download',
    },
    legal: {
      title: 'Legal',
      license: 'License',
      privacyPolicy: 'Privacy policy',
      termsOfService: 'Terms of services',
      contact: 'Contact',
    },
    language: 'Language',
  },
  index: {
    main: {
      title: {
        1: 'Secure your online accounts',
        2: 'with a <strong>free</strong>, <strong>open-source</strong> and <strong>lovely-crafted</strong> app',
      },
      features: {
        1: '<strong>Free</strong> & <strong>open-source</strong>.',
        2: 'Easily <strong>synchronize</strong> your TOTPs (<em>Time-based One-Time Password</em>).',
        3: '<strong>Protect</strong> your data.',
        4: 'Use it on (almost) <strong>any platform</strong>.',
      },
      downloadButton: 'Download now',
    },
    download: {
      title: '<strong>Download</strong> the app',
      description: `Open Authenticator has been built using Flutter. Therefore, you can use it on <strong>Android</strong>
and <strong>iOS</strong>, but also on <strong>macOS</strong>, <strong>Windows</strong> and <strong>Linux</strong> !`,
      storeButtons: {
        loading: 'Loading links...',
        availableSoonTemplate: 'Available for %s soon !',
        availableOnTemplate: 'Download for %s',
        morePlatformsButton: 'Want another platform ?',
      },
    },
    openSource: {
      title: 'Open-source',
      description: {
        1: `Open Authenticator is an open-source app and is completely free to use.
It's licensed under <a class="underline" href="https://github.com/Skyost/OpenAuthenticator">GNU GPL v3</a>.
Feel free to contribute to the project by submitting your <strong>pull requests</strong> on Github,
by <strong>donating</strong> or just by <strong>starring it</strong> on Github !`,
        2: 'Thanks a lot to <a class="underline" href="https://github.com/Skyost/OpenAuthenticator/contributors">all contributors</a> !',
      },
      linkButtons: {
        github: 'Github',
        paypal: 'Donate',
      },
    },
  },
  privacyPolicy: {
    title: 'Privacy policy',
    lastUpdated: 'Last updated April 01, 2024',
    intro: 'This privacy policy is applicable to the Open Authenticator app (hereinafter referred to as <q>Application</q>) for mobile devices, which was developed by Skyost (hereinafter referred to as <q>Service Provider</q>) as a subscription supported service. This service is provided <q>AS IS</q>.',
    userProvidedInfo: {
      title: 'User Provided Information',
      content: `The Application acquires the information you supply when you download and register the
Application. Registration with the Service Provider is not mandatory.
However, bear in mind that you might not be able to utilize some of the features offered by the
Application unless you register with them. The Service Provider may also use the information you provided
them to contact you from time to time to provide you with important information, required notices,
and marketing promotions.`,
    },
    automaticallyCollectedInfo: {
      title: 'Automatically Collected Information',
      content: `In addition, the Application may collect certain information automatically, including,
but not limited to, the type of mobile device you use, your mobile device\`s unique device ID, the IP address
of your mobile device, your mobile operating system, the type of mobile Internet browsers you use,
and information about the way you use the Application.
This data collection is needed in order to better understand crash logs.`,
    },
    locationInfo: {
      title: 'Does the Application collect precise real-time location information of the device ?',
      content: 'This Application does not gather precise information about the location of your mobile device.',
    },
    thirdPartyAccess: {
      title: 'Do third parties see and/or have access to information obtained by the Application ?',
      content: `Only aggregated, anonymized data is periodically transmitted to external services to aid the
Service Provider in improving the Application and their service. The Service Provider may share your
information with third parties in the ways that are described in this privacy statement.`,
    },
    thirdPartyProviders: {
      title: 'Third-Party Providers',
      content: `Please note that the Application utilizes third-party services that have their own
Privacy Policy about handling data. Below are the links to the Privacy Policy of the
third-party service providers used by the Application :`,
      list: {
        googlePlayServices: '<a href="https://www.google.com/policies/privacy/" target="_blank">Google Play Services</a>',
        firebase: '<a href="https://firebase.google.com/support/privacy/" target="_blank">Firebase (including but not limited to Crashlytics, Cloud Firestore, ...)</a>',
        revenueCat: '<a href="https://www.revenuecat.com/privacy" target="_blank">RevenueCat</a>',
      },
    },
    disclosure: {
      title: 'Disclosure of Information',
      content: 'The Service Provider may disclose User Provided and Automatically Collected Information :',
      list: {
        1: 'as required by law, such as to comply with a subpoena, or similar legal process;',
        2: 'when they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request;',
        3: 'with their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement.',
      },
    },
    optOut: {
      title: 'What are my opt-out rights?',
      content: `You can halt all collection of information by the Application easily by uninstalling the
Application. You may use the standard uninstall processes as may be available as part of your mobile device
or via the mobile application marketplace or network.`,
    },
    dataRetention: {
      title: 'Data Retention Policy, Managing Your Information',
      content: `The Service Provider will retain User Provided data for as long as you use the
Application and for a reasonable time thereafter. The Service Provider will retain Automatically Collected
information for up to 24 months and thereafter may store it in aggregate.
If you'd like the Service Provider to delete User Provided Data that you have provided via the Application,
please <a href="/contact">contact them</a> and they will respond in a reasonable time.
Please note that some or all of the User Provided Data may be required in order for the Application
to function properly.
Your master password is not transmitted to any remote server.
<strong>If you forget it, we cannot help your recovering it.</strong>
Please be aware that, although we endeavor provide reasonable security for
information we process and maintain, no security system can prevent all potential security breaches.`,
    },
    children: {
      title: 'Children',
      content: `The Service Provider does not use the Application to knowingly solicit data from or market
to children under the age of 13. The Application does not address anyone under the age of 13.
The Service Provider does not knowingly collect personally identifiable information from children under
13 years of age.`,
    },
    security: {
      title: 'Security',
      content: `The Service Provider is concerned about safeguarding the confidentiality of your information.
The Service Provider provides physical, electronic, and procedural safeguards to protect information we
process and maintain. For example, if you choose to synchronize your data between your devices,
we use Firebase Cloud Firestore to store your TOTPs.
Their <a href="https://en.wikipedia.org/wiki/Time-based_one-time_password#Security">secret & metadata</a> are
encrypted using an <a href="https://en.wikipedia.org/wiki/Galois/Counter_Mode">AES-GCM</a> algorithm with an
<a href="https://en.wikipedia.org/wiki/Argon2">Argon2</a> derived key based on your master password and a random salt.`,
    },
    changes: {
      title: 'Changes',
      content: `This Privacy Policy may be updated from time to time for any reason.
The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new
Privacy Policy.`,
      effectiveDate: 'This privacy policy is effective as of 2024-04-01.',
    },
    contact: {
      title: 'Contact Us',
      content: `If you have any questions regarding privacy while using the Application, or
have questions about the practices, please <a href="/contact">contact</a> the Service Provider.`,
    },
    credit: 'Thanks to <a href="https://app-privacy-policy-generator.firebaseapp.com/"><em>nisrulz</em></a> for this privacy policy.',
  },
  termsOfService: {
    title: 'Terms & Conditions',
    lastUpdated: 'Last updated April 01, 2024',
    intro: `These terms and conditions applies to the Open Authenticator app (hereby referred to as <q>Application</q>)
for mobile devices that was created by Skyost (hereby referred to as <q>Service Provider</q>) as a subscription supported service.`,
    agreement: `Upon downloading or utilizing the Application, you are automatically agreeing to the following terms
and to the <nuxt-link to="/privacy-policy">Privacy policy</nuxt-link>.
It is strongly advised that you thoroughly read and understand these terms prior to using the Application.
Unauthorized copying, modification of the Application, any part of the Application, or our trademarks
is strictly prohibited.
Any attempts to create derivative versions or <q>copycats</q> are not permitted.
All trademarks, copyrights, database rights, and other intellectual property rights related to the
Application remain the property of the Service Provider.`,
    modification: `The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as
possible. As such, they reserve the right to modify the Application or charge for their services at
any time and for any reason. The Service Provider assures you that any charges for the Application or
its services will be clearly communicated to you.`,
    dataProcessing: `The Application stores and processes personal data that you have provided to the Service Provider in
order to provide the Service. It is your responsibility to maintain the security of your phone and
access to the Application. The Service Provider strongly advise against jailbreaking or rooting your
phone, which involves removing software restrictions and limitations imposed by the official operating
system of your device. Such actions could expose your phone to malware, viruses, malicious programs,
compromise your phone's security features, and may result in the Application not functioning correctly
or at all.`,
    thirdPartyTerms: `Please note that the Application utilizes third-party services that have their own Terms and Conditions.
Below are the links to the Terms and Conditions of the third-party service providers used by the
Application :`,
    thirdPartyTermsList: {
      googlePlayServices: '<a href="https://www.google.com/policies/privacy/" target="_blank">Google Play Services</a>',
      firebase: '<a href="https://firebase.google.com/support/privacy/" target="_blank">Firebase (including but not limited to Crashlytics, Cloud Firestore, ...)</a>',
      revenueCat: '<a href="https://www.revenuecat.com/privacy" target="_blank">RevenueCat</a>',
    },
    responsibility: `Please be aware that the Service Provider does not assume responsibility for certain aspects.
Some functions of the Application require an active internet connection, which can be Wi-Fi or provided
by your mobile network provider. The Service Provider cannot be held responsible if the Application does
not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.`,
    charges: `If you are using the application outside of a Wi-Fi area, please be aware that your mobile network
provider's agreement terms still apply. Consequently, you may incur charges from your mobile provider
for data usage during the connection to the application, or other third-party charges.
By using the application, you accept responsibility for any such charges, including roaming data
charges if you use the application outside of your home territory (i.e., region or country) without
disabling data roaming.
If you are not the bill payer for the device on which you are using the application, they assume
that you have obtained permission from the bill payer.`,
    battery: `Similarly, the Service Provider cannot always assume responsibility for your usage of the application.
For instance, it is your responsibility to ensure that your device remains charged.
If your device runs out of battery and you are unable to access the Service, the Service Provider
cannot be held responsible.`,
    termination: `The Service Provider may wish to update the application at some point.
The application is currently available as per the requirements for the operating system
(and for any additional systems they decide to extend the availability of the application to) may change,
and you will need to download the updates if you want to continue using the application.
The Service Provider does not guarantee that it will always update the application so that it is relevant
to you and/or compatible with the particular operating system version installed on your device.
However, you agree to always accept updates to the application when offered to you.
The Service Provider may also wish to cease providing the application and may terminate its use at any
time without providing termination notice to you. Unless they inform you otherwise, upon any termination,
(a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application,
and (if necessary) delete it from your device.`,
    legalRiskResponsibility: {
      title: 'Legal risk and responsibility',
      noWarranty: {
        title: 'No warranty',
        content: `All Content (including but not limited to your TOTPs) is made available AS IS and the Service Provider
does not offer any warranty of any kind, or represent that the Content will be accurate, complete,
or error-free.`,
      },
      synchronizationSecurity: {
        title: 'Synchronization and security',
        content: `If you choose to synchronize your Data (including but not limited to : your TOTPs, your
mail address, your Firebase automatically generated user id, etc.) between your devices, you acknowledge
that it will be stored on Firebase servers.
Please be aware that, although we endeavor provide reasonable security for information we process and
maintain, no security system can prevent all potential security breaches.
Therefore, we are not liable for any data loss, any leak or any damage resulting from the use of
the application.`,
      },
      releaseIndemnity: {
        title: 'Release and indemnity',
        content: `To the extent permitted by applicable law, you agree to release and waive any and all
claims and/or liability against the Service Provider arising from connection with your use of the
Application or any subscription to the Application. You also agree to defend, indemnify and hold harmless
the Service Provider, officers, directors, employees, partners, contributors, or licensors from and
against any and all claims, damages, obligations, losses, liabilities, (including but not limited to
attorney's fees) arising from : (i) your use of and access to the Application; (ii) your violation of any
term of these terms of use; and (iii) your violation of any third party right, including without limitation
any copyright, property, or privacy right.`,
      },
      limitationOfLiability: {
        title: 'Limitation of Liability',
        content: `As stated before, under no circonstances, including negligence, shall the Service Provider, officers, directors,
employees, partners, contributors, or licensors be liable for any direct, indirect, incidental, special,
punitive or consequential damages that may result from the access of, use or inability to use the Application content,
including without limitation, use of or reliance on information, interruptions, errors, defects, mistakes,
omissions, deletions of files, delays in operations or transmission, non-delivery of information, disclosure of
communications, or any other failure of performance.`,
      },
    },
    changes: {
      title: 'Changes to These Terms and Conditions',
      content: `The Service Provider may periodically update their Terms and Conditions.
Therefore, you are advised to review this page regularly for any changes.
The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.`,
      effectiveDate: 'These terms and conditions are effective as of 2024-04-01.',
    },
    contact: {
      title: 'Contact Us',
      content: `If you have any questions or suggestions about the Terms and Conditions,
please do not hesitate to <nuxt-link to="/contact">contact</nuxt-link> the Service Provider.`,
    },
    credit: 'Thanks to <a href="https://app-privacy-policy-generator.firebaseapp.com/"><em>nisrulz</em></a> for these terms of service.',
  },
  contact: {
    title: 'Contact',
    description: `If you want to contact me for Open Authenticator development and related subjects
(eg. you want to report a bug), please open a new issue on <a href="https://github.com/Skyost/OpenAuthenticator">Github</a>.
If you want to contact me for anything else or for deleting your account, please use the contact form below.`,
    form: {
      name: {
        label: 'Your name',
        placeholder: 'Input your name here',
      },
      email: {
        label: 'Your email',
        placeholder: 'Input your email here',
      },
      subject: {
        label: 'Your message subject',
        options: {
          accountDeletion: 'Account deletion',
          moreInfoNeeded: 'More info needed',
          commercial: 'Commercial',
          other: 'Other',
        },
      },
      message: {
        label: 'Your message content',
        placeholder: 'Input your message here',
      },
      success: 'Your request has been sent with success.',
      error: 'An error occurred while sending your request.',
      send: 'Send',
    },
  },
}
