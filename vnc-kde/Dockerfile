FROM ubuntu:jammy

EXPOSE 8888

ARG S6_VER="3.1.2.1"
ARG NO_VNC_VER="1.3.0"
ARG WEB_SOCK_VER="0.10.0"
ARG ROOT_PASSWORD="password"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y \
        xz-utils \
        gettext-base \
        unzip \
        nginx \
        plasma-desktop \
        dbus-x11 \
        binutils \
        wget \
        git \
        vim \
        openjdk-8-jdk \
        tigervnc-standalone-server \
        tigervnc-xorg-extension \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

RUN apt-get update \ 
    && apt-get install -y \
        dolphin \
        konsole \
        kate \
        fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:mozillateam/ppa \
    && printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\nPackage: firefox\nPin: version 1:1snap1-0ubuntu2\nPin-Priority: -1' >> /etc/apt/preferences.d/mozilla-firefox \
    && apt-get update \
    && apt-get install -y \
        firefox \
    && rm -rf /var/lib/apt/lists/*

ENV DISPLAY=:0 \
    SCR_WIDTH=1600 \
    SCR_HEIGHT=900

ADD https://github.com/novnc/noVNC/archive/v${NO_VNC_VER}.zip /tmp
ADD https://github.com/novnc/websockify/archive/v${WEB_SOCK_VER}.zip /tmp
RUN cd /tmp && \
    unzip v${NO_VNC_VER}.zip && \
    unzip v${WEB_SOCK_VER}.zip && \
    mv noVNC-${NO_VNC_VER} /novnc && \
    mv websockify-${WEB_SOCK_VER} /novnc/utils/websockify

ENV PATH_PREFIX=/ \
    VNC_RESIZE=remote \
    RECON_DELAY=250 \
    PAGE_TITLE=KDE

ENV PGID=1000 \
    PUID=1000 \
    ROOT_PASSWORD=${ROOT_PASSWORD} \
    HOME=/home/idies

RUN useradd -U -u 1000 -m -d "$HOME" --shell /bin/bash idies

WORKDIR /

USER idies
RUN mkdir -p $HOME/workspace
RUN cd $HOME \
    && wget -O Miniconda-install.sh -nv https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda-install.sh -b \
    && rm Miniconda-install.sh
ENV PATH /home/idies/miniconda3/bin:$PATH
USER root

COPY startup.sh /opt/startup.sh
COPY root /

# https://stackoverflow.com/a/65564226
RUN strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5

RUN sed -i 's/^Exec=konsole/Exec=konsole --workdir ~ -e bash/g' /usr/share/applications/org.kde.konsole.desktop
