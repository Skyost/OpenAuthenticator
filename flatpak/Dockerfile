FROM ubuntu:24.04

ARG UID=1000
ARG GID=1000

RUN groupadd --non-unique -g ${GID} auser && \
    useradd --non-unique --no-create-home -u ${UID} -g ${GID} auser || \
    usermod -u ${UID} -g ${GID} $(getent passwd ${UID} | cut -d: -f1) && \
    groupmod -g ${GID} $(getent group ${GID} | cut -d: -f1)

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Europe apt-get -y install tzdata
RUN apt-get -y install tree curl file git unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
RUN apt-get -y install libsecret-1-dev libpolkit-gobject-1-dev
RUN apt-get -y install flatpak flatpak-builder
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
RUN flatpak install -y org.freedesktop.Sdk/x86_64/25.08
RUN flatpak install -y org.freedesktop.Platform/x86_64/25.08
RUN flatpak install -y flathub org.freedesktop.appstream-glib

RUN mkdir -p /home/auser
RUN chown -R ${UID}:${GID} /home/auser
USER ${UID}
ENV HOME=/home/auser
WORKDIR /home/auser

RUN git clone https://github.com/flutter/flutter.git -b stable /home/auser/flutter
ENV PATH="$PATH:/home/auser/flutter/bin:/home/auser/flutter/bin/cache/dart-sdk/bin"
RUN flutter --disable-analytics
RUN flutter config --enable-linux-desktop \
                   --no-enable-windows-desktop \
                   --no-enable-macos-desktop \
                   --no-enable-web \
                   --no-enable-android \
                   --no-enable-ios
RUN flutter precache
RUN flutter upgrade
RUN chown -R ${UID}:${GID} /home/auser/flutter

RUN git config --global --add safe.directory /home/auser/flutter
