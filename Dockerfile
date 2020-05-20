FROM debian:buster-slim

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
    git clone --branch v0.9.5 https://github.com/meetecho/janus-gateway.git /build/janus-gateway; \
    git clone --branch v2.3.0 https://github.com/cisco/libsrtp.git /build/libsrtp; \
    git clone --branch 0.1.16 https://gitlab.freedesktop.org/libnice/libnice.git /build/libnice; \
    git clone https://github.com/sctplab/usrsctp /build/usrsctp; \

RUN set -ex; \
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
