<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://openauthenticator.app/images/logo.svg" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Open Authenticator</h3>

  <p align="center">
    A cross-platform OTP app, free and open-source.
    <br />
    <a href="https://openauthenticator.app/#download"><strong>Download now »</strong></a>
    <br />
    <br />
    <a href="https://openauthenticator.app">Website</a>
    ·
    <a href="https://github.com/Skyost/OpenAuthenticator/issues">Issue tracker</a>
    ·
    <a href="https://github.com/Skyost/OpenAuthenticator/#contribute">Contribute</a>
  </p>
</div>

![GitHub License](https://img.shields.io/github/license/Skyost/OpenAuthenticator)
![GitHub top language](https://img.shields.io/github/languages/top/Skyost/OpenAuthenticator)
![GitHub Repo stars](https://img.shields.io/github/stars/Skyost/OpenAuthenticator)

## Motivations

It's pretty simple : I was using Twilio Authy as my main TOTP app without any problem so far.
Back in January 2024, my Authy for Windows app started displaying me the following message :

> The Authy Desktop apps Linux, MacOS, and Windows, will reach their End-of-Life (EOL) on March 19, 2024.

Wow. So Twilio has decided to shutdown all their desktop apps, leaving only three months (!) to users like me
to find an alternative.
Add to that that there is almost no way to export your TOTPs from this app, and it was enough for me
to consider creating an alternative.

That's how **Open Authenticator** was born, with open-sourceness, interoperability and freedom in mind.

## Features

* Open-source, and will always be.
* Free to use.
* Multilanguage. Currently, only english and french are supported, but you can [help translating the app](#help-translating-it) into your language !
* Cross-platform.
* TOTPs synchronization supported through Firebase Firestore.

## Screenshots

_Coming soon !_

## Download

Download links are available on the [Open Authenticator website](https://openauthenticator.app/#download).

## Build and run

### App

First, you'll have to generate your own `app.dart` file.
It contains all credentials needed to run the app (Firebase, Sign-In providers, RevenueCat, ...).

To do so, you can run the following utility :

```shell
dart run "open_authenticator:generate"
```

Then, you'll also need to link the app to Firebase. You can follow the steps [here](https://firebase.google.com/docs/flutter/setup)*
for that.

This should allow you to run the app in its minimal state.
For advanced features, like synchronization, sign-in using providers, ... you'll also need
to configure them on your side.

Use the links below to do so :

* [Configure Firebase Auth](https://firebase.google.com/docs/auth/flutter/start).
* [Configure Firebase Firestore](https://firebase.google.com/docs/firestore).
* [Configure Firebase Dynamic Links](https://firebase.google.com/docs/dynamic-links).
* [Configure RevenueCat](https://www.revenuecat.com/docs/getting-started/entitlements).
* [Configure Stripe with RevenueCat](https://www.revenuecat.com/docs/getting-started/entitlements/stripe-products).
* [Configure Stripe payment links](https://docs.stripe.com/payment-links)

### Website

The website has been created using [Nuxt 3](https://nuxt.com/). Just run the following commands
to start a dev server :

```shell
cd docs
npm install
npm run dev
```

You'll be able to access it on [localhost:3000](http//localhost:3000).

## What's next

If this project becomes popular, I would like to provide its own backend to Open Authenticator.
Currently, it's using Firebase Auth / Firestore, which is perfect for this project in its current
state. Having a dedicated server would be too expensive for the moment.

If it's sustainable enough, we could even consider completely removing ads from the app.

## License

Open Authenticator is licensed under the [GNU General Public License v3.0](https://choosealicense.com/licenses/gpl-3.0/).

## Contribute

If you like this project, there are a lot of ways for you to contribute to it !
Please read the [contribution guide](https://github.com/Skyost/OpenAuthenticator/blob/main/CONTRIBUTING.md)
before getting started.

### Help translating it

You can translate the app into your language by submitting a pull request targeting the files located
in the `lib/i18n` folder (for the app) and `docs/locales` (for the website).
Feel also free to submit a pull request for any typo you encounter.

### Report bugs

You can report bugs in the [issue tracker](https://github.com/Skyost/OpenAuthenticator/issues).

### Donate

You can donate for this project using either [PayPal](http://paypal.me/Skyost),
[Ko-Fi](https://ko-fi.com/Skyost) or [Github sponsors](https://github.com/sponsors/Skyost).

If you don't want to donate, any [kind message](https://openauthenticator.app/contact) is also
appreciated !
