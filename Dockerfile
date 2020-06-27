FROM debian:buster-slim

# renovate: datasource=github-tags depName=meetecho/janus-gateway versioning=semver
ENV JANUS_VERSION v0.9.5

# renovate: datasource=github-tags depName=cisco/libsrtp versioning=semver
ENV LIBSRTP_VERSION v2.3.0

# renovate: datasource=git-tags depName=https://gitlab.freedesktop.org/libnice/libnice versioning=semver
ENV LIBNICE_VERSION 0.1.16

ENV USRSCTP_VERSION master

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libmicrohttpd-dev \
        libjansson-dev \
        libssl-dev \
        libsofia-sip-ua-dev \
        libglib2.0-dev \
	    libopus-dev \
        libogg-dev \
        libcurl4-openssl-dev \
        liblua5.3-dev \
	    libconfig-dev \
        libwebsockets-dev \
        pkg-config \
        gengetopt \
        libtool \
        automake \
        git \
        make \
        gtk-doc-tools \
    ; \
    mkdir /build; \
    git clone --branch $JANUS_VERSION https://github.com/meetecho/janus-gateway.git /build/janus-gateway; \
    git clone --branch $LIBSRTP_VERSION https://github.com/cisco/libsrtp.git /build/libsrtp; \
    git clone --branch $LIBNICE_VERSION https://gitlab.freedesktop.org/libnice/libnice.git /build/libnice; \
    git clone --branch $USRSCTP_VERSION https://github.com/sctplab/usrsctp /build/usrsctp; \
    \
    cd /build/libnice; \
    ./autogen.sh --prefix=/usr; \
    make && make install; \
    \
    cd /build/libsrtp; \
    ./configure --prefix=/usr --enable-openssl; \
    make shared_library && make install; \
    \
    cd /build/usrsctp; \
    ./bootstrap; \
    ./configure --prefix=/usr; \
    make; \
    make install; \
    \
    cd /build/janus-gateway; \
    sh autogen.sh; \
    ./configure --prefix=/opt/janus; \
    make; \
    make install; \
    make configs; \
    rm -rf /build;

CMD ["/opt/janus/bin/janus"]
