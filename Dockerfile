# This seems to break the Jenkins Docker plugin
# leaving this here for now so we can switch to it if things get fixed
# ARG  CODE_VERSION="8"
# FROM debian:${CODE_VERSION}

# set base image debian jessie
FROM debian:9

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
  && wget --no-check-certificate https://nice.freedesktop.org/releases/libnice-0.1.15.tar.gz \
  && tar xvf libnice-0.1.15.tar.gz \
  && cd libnice-0.1.15 \
  && ./configure --prefix=/usr && make && sudo make install \
  && cd .. \
  && rm -rf libnice-0.1.15

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
  && git checkout v2.1.0 \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
  && make \
  && sudo make install \
  && cd ../../ \
  && rm -rf libwebsockets

ARG JANUS_VERSION=0.6.1
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
LABEL org.label-schema.description="This provides a Janus Gateway Server for Webrtc" \
  org.label-schema.docker.cmd="\
  docker run -d \
  -p 7088:7088 \
  -p 7089:7089 \
  -p 8088:8088 \
  -p 8089:8089 \
  -p 8188:8188 \
  -p 8189:8189 \
  --name <container-name> \
  <image-name>" \
  org.label-schema.docker.debug="docker exec -it <container-name> bash" \
  org.label-schema.name="olp-janus" \
  org.label-schema.vcs-url="https://gitlab.drakephx.com/development/nextgen/olp-janus/" \
  org.label-schema.vendor="Kryterion" \
  org.label-schema.schema-version="1.0.0" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  com.kryterion.olp-janus.janus-version=$JANUS_VERSION

ENTRYPOINT ["/opt/janus/bin/janus"]
CMD ["--stun-server=stun.l.google.com:19302"]
