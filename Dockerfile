# This seems to break the Jenkins Docker plugin
# leaving this here for now so we can switch to it if things get fixed
# ARG  CODE_VERSION="8"
# FROM debian:${CODE_VERSION}

# set base image debian jessie
FROM debian:10

WORKDIR /work

RUN apt-get update -y \
  && apt-get install -y \
  libmicrohttpd-dev \
  libjansson-dev \
  libssl-dev \
  libsofia-sip-ua-dev \
  libglib2.0-dev \
  libopus-dev \
  libogg-dev \
  libavutil-dev \
  libavcodec-dev \
  libavformat-dev \
  libini-config-dev \
  libcollection-dev \
  pkg-config \
  libconfig-dev \
  gengetopt \
  libtool \
  automake \
  wget \
  sudo \
  make \
  git \
  cmake \
  && rm -rf /var/lib/apt/lists/*

RUN cd /work \
  && wget --no-check-certificate https://libnice.freedesktop.org/releases/libnice-0.1.17.tar.gz \
  && tar xvf libnice-0.1.17.tar.gz \
  && cd libnice-0.1.17 \
  && ./configure --prefix=/usr && make && sudo make install \
  && cd .. \
  && rm -rf libnice-0.1.17

RUN cd /work \
  && git clone https://github.com/cisco/libsrtp.git \
  && cd libsrtp \
  && git checkout v2.2.0 \
  && ./configure --prefix=/usr --enable-openssl \
  && make shared_library \
  && sudo make install \
  && cd .. \
  && rm -rf libsrtp

RUN wget https://github.com/sctplab/usrsctp/archive/0.9.3.0.tar.gz \
  && tar xvf 0.9.3.0.tar.gz \
  && cd usrsctp-0.9.3.0 \
  && ./bootstrap \
  && ./configure --prefix=/usr \
  && make \
  && sudo make install \
  && cd .. \
  && rm -rf usrsctp

RUN git clone https://github.com/warmcat/libwebsockets.git \
  && cd libwebsockets \
  && git checkout v4.0-stable \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
  && make \
  && sudo make install \
  && cd ../../ \
  && rm -rf libwebsockets

ARG JANUS_VERSION=0.10.2
RUN wget -O janus-gateway.tar.gz https://github.com/meetecho/janus-gateway/archive/v${JANUS_VERSION}.tar.gz \
  && mkdir janus-gateway \
  && tar xvf janus-gateway.tar.gz -C janus-gateway --strip-components 1 \
  && cd janus-gateway \
  && sh autogen.sh \
  && ./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt --enable-post-processing \
  && make \
  && make install \
  && make configs \
  && cd ../ \
  && rm -rf janus-gateway.tar.gz janus-gateway

# Declare the ports we use
EXPOSE 7088 8088 8188 7089 8089 8189

ARG BUILD_DATE
ARG VCS_REF

ENTRYPOINT ["/opt/janus/bin/janus"]
CMD ["--stun-server=stun.l.google.com:19302"]
