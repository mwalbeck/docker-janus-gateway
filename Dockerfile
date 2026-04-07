FROM debian:trixie-slim@sha256:4ffb3a1511099754cddc70eb1b12e50ffdb67619aa0ab6c13fcd800a78ef7c7a

# renovate: datasource=github-tags depName=meetecho/janus-gateway versioning=semver
ENV JANUS_VERSION=v1.4.0
ENV USRSCTP_VERSION=master

RUN set -ex; \
    \
    groupadd --system --gid 602 janus; \
    useradd --no-log-init --system --gid janus --no-create-home --uid 602 janus; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Runtime dependencies
        ca-certificates \
        libconfig11 \
        libglib2.0-0 \
        libjansson4 \
        libssl3 \
        libcurl4 \
        libopus0 \
        libogg0 \
        libmicrohttpd12 \
        libwebsockets19t64 \
        libnice10 \
        libsrtp2-1 \
        # Build dependencies
        libmicrohttpd-dev \
        libjansson-dev \
        libssl-dev \
        libglib2.0-dev \
        libopus-dev \
        libogg-dev \
        libcurl4-openssl-dev \
        liblua5.3-dev \
        libconfig-dev \
        pkg-config \
        gengetopt \
        libtool \
        automake \
        git \
        make \
        gtk-doc-tools \
        ninja-build \
        cmake \
        build-essential \
        python3-mesonpy \
        libwebsockets-dev \
        libnice-dev \
        libsrtp2-dev \
    ; \
    mkdir /build; \
    git clone --branch $JANUS_VERSION https://github.com/meetecho/janus-gateway.git /build/janus-gateway; \
    git clone --branch $USRSCTP_VERSION https://github.com/sctplab/usrsctp /build/usrsctp; \
    \
    cd /build/usrsctp; \
    ./bootstrap; \
    ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6; \
    make; \
    make install; \
    \
    cd /build/janus-gateway; \
    sh autogen.sh; \
    ./configure --prefix=/opt/janus --disable-plugin-voicemail --disable-plugin-nosip --disable-plugin-sip \
        --disable-plugin-streaming --disable-plugin-recordplay --disable-unix-sockets; \
    make; \
    make install; \
    make configs; \
    cd /; \
    rm -rf /build; \
    chown -R janus:janus /opt/janus; \
    \
    apt-get purge -y --autoremove \
        libmicrohttpd-dev \
        libjansson-dev \
        libssl-dev \
        libglib2.0-dev \
        libopus-dev \
        libogg-dev \
        libcurl4-openssl-dev \
        liblua5.3-dev \
        libconfig-dev \
        pkg-config \
        gengetopt \
        libtool \
        automake \
        git \
        make \
        gtk-doc-tools \
        ninja-build \
        cmake \
        build-essential \
        python3-mesonpy \
        libwebsockets-dev \
        libnice-dev \
        libsrtp2-dev \
    ; \
    rm -rf /var/lib/apt/lists/*;

EXPOSE 8088 8188

USER janus:janus

CMD ["/opt/janus/bin/janus"]
