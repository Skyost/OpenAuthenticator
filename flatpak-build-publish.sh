#!/bin/bash
cd "$(dirname "$0")"

docker build \
    --platform linux/amd64 \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    -t flutterpack:1.0.0 \
    ./flatpak

rm -rf flatpak/repo
git clone https://github.com/Skyost/OpenAuthenticatorFlatpak.git flatpak/repo

cd flatpak/repo
git switch --orphan clean-main
cd ../

mv repo/.git .repo-git
cd ../

docker run \
    --rm --privileged --platform linux/amd64 \
    -u "$(id -u):$(id -g)" \
    -v "$PWD":/work \
    -w /work/flatpak \
    flutterpack:1.0.0 "./build-flutter-app.sh"

cd flatpak
mv .repo-git repo/.git

cd repo
git add --all
git commit -am "Updated Flatpak repo."
git push --force origin clean-main:main
git switch main
git reset --hard clean-main
git branch -D clean-main
cd ../
rm -rf repo
rm -rf .flatpak-builder
rm -rf build-dir
rm -rf OpenAuthenticator-Linux-Portable.tar.gz
cd ../

# docker buildx prune
# docker image remove flutterpack:1.0.0
# sudo systemctl stop docker
