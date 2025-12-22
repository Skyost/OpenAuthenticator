FROM ubuntu:24.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Europe apt-get -y install tzdata
RUN apt-get -y install tree curl file git unzip xz-utils zip clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
RUN apt-get -y install libsecret-1-dev libpolkit-gobject-1-dev
RUN apt-get -y install flatpak flatpak-builder
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
RUN flatpak install -y org.freedesktop.Sdk/x86_64/25.08
RUN flatpak install -y org.freedesktop.Platform/x86_64/25.08
RUN flatpak install -y flathub org.freedesktop.appstream-glib

RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /opt/flutter
RUN flutter --disable-analytics && flutter upgrade
RUN chown -R "$(id -u):$(id -g)" /opt/flutter
