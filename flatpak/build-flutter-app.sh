#!/bin/bash
set -e
set -x

projectName=OpenAuthenticator
archiveName=$projectName-Linux-Portable.tar.gz
baseDir=$(pwd)
bundle_dir="build/linux/x64/release/bundle"

pushd .

cd ..

# Build Flutter app
flutter clean
# flutter gen-l10n
export APPLICATION_ID=app.openauthenticator.OpenAuthenticator
flutter build linux --release

mkdir -p "$bundle_dir/lib"
cp -av /usr/lib/x86_64-linux-gnu/libpolkit-gobject-1.so* "$bundle_dir/lib/"
cp -av /usr/lib/x86_64-linux-gnu/libsecret-1.so* "$bundle_dir/lib/"

cd $bundle_dir || exit 1
tar -czaf $archiveName ./*
mv $archiveName "$baseDir"/
popd

flatpak-builder --force-clean build-dir app.yaml --repo=repo
flatpak build-bundle repo app.openauthenticator.OpenAuthenticator.flatpak app.openauthenticator.OpenAuthenticator
