FROM ubuntu:22.04

RUN useradd -m idies \
    && mkdir /home/idies/workspace \
    && chown idies:idies /home/idies/workspace

ARG DEBIAN_FRONTEND=noninteractive

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        sudo \
        wget \
        curl \
        git \
        vim \
        htop \
        locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen "en_US.UTF-8" \
    && update-locale "LANG=en_US.UTF-8"

RUN apt-get update \
    && apt-get install -y texlive-full \
    && rm -rf /var/lib/apt/lists/*
