#!/usr/bin/env bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential libcairo2-dev libjpeg-dev \
                    libjpeg-turbo8-dev libpng-dev libtool-bin \
                    libossp-uuid-dev libvncserver-dev \
                    libfreerdp-dev freerdp2-dev freerdp-x11 \
                    libssh2-1-dev libtelnet-dev libwebsockets-dev
                    libpulse-dev libvorbis-dev libwebp-dev libssl-dev \
                    libpango1.0-dev libswscale-dev libavcodec-dev \
                    libavutil-dev libavformat-dev tomcat9 \
                    tomcat9-admin tomcat9-common tomcat9-user \
                    mariadb-server
