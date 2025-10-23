#!/usr/bin/env bash
sudo apt update && sudo apt upgrade -y
sudo apt install build-essential libcairo2-dev libjpeg-turbo8-dev \
    libpng-dev libtool-bin uuid-dev libossp-uuid-dev libvncserver-dev \
    freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev \
    libpulse-dev libvorbis-dev libwebp-dev libssl-dev libpulse-dev\
    libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev \
    libavformat-dev
