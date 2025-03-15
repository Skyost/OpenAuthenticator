# Note on Linux support

Currently, Linux is yet to be supported because Firebase is also yet to support Linux. We have four options :

1. Wait for Cloud Firestore to support Linux (https://github.com/firebase/flutterfire/discussions/5557).
2. Write a REST implementation of Cloud Firestore for Linux that hooks with our existing custom Firebase Auth implementation.
   This could be used on Windows as well and would remove some platform native code.
   We could use code from existing libraries like https://github.com/appsup-dart/firebase_dart and https://github.com/cachapa/firedart.
3. Ship Firebase-free version of Open Authenticator for Linux.
4. Build the app for web first, then package it for release on Linux. This also means non-native.

Currently, option 1. is what has been chosen. Any contributor is welcomed to give his/her opinion
though.
