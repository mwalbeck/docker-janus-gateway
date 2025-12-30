FROM debian:bullseye-slim@sha256:c5f48c942c667e70d7e64b124cfc939c25a4a43207c0d14b45844d762dc1d50f

# renovate: datasource=github-tags depName=meetecho/janus-gateway versioning=semver
ENV JANUS_VERSION v1.3.3
# renovate: datasource=github-tags depName=cisco/libsrtp versioning=semver
ENV LIBSRTP_VERSION v2.7.0
# renovate: datasource=git-tags depName=https://gitlab.freedesktop.org/libnice/libnice versioning=semver
ENV LIBNICE_VERSION 0.1.23
# renovate: datasource=git-tags depName=https://git.walbeck.it/archive/libwebsockets versioning=semver
ENV LIBWEBSOCKETS_VERSION v4.5.2
ENV USRSCTP_VERSION master


RUN set -ex; \
    \
    groupadd --system --gid 602 janus; \
    useradd --no-log-init --system --gid janus --no-create-home --uid 602 janus; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Runtime dependencies
        ca-certificates \
        libconfig9 \
        libglib2.0-0 \
        libjansson4 \
        libssl1.1 \
        libcurl4 \
        libopus0 \
        libogg0 \
        libmicrohttpd12 \
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
        python3-pip \
        cmake \
        build-essential \
    ; \
    pip3 install meson; \
    mkdir /build; \
    git clone --branch $JANUS_VERSION https://github.com/meetecho/janus-gateway.git /build/janus-gateway; \
    git clone --branch $LIBSRTP_VERSION https://github.com/cisco/libsrtp.git /build/libsrtp; \
    git clone --branch $LIBNICE_VERSION https://gitlab.freedesktop.org/libnice/libnice.git /build/libnice; \
    git clone --branch $USRSCTP_VERSION https://github.com/sctplab/usrsctp /build/usrsctp; \
    git clone --branch $LIBWEBSOCKETS_VERSION https://git.walbeck.it/archive/libwebsockets /build/libwebsockets; \
    \
    cd /build/libnice; \
    meson --prefix=/usr build; \
    ninja -C build; \
    ninja -C build install; \
    \
    cd /build/libsrtp; \
    ./configure --prefix=/usr --enable-openssl; \
    make shared_library && make install; \
    \
    cd /build/usrsctp; \
    ./bootstrap; \
    ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6; \
    make; \
    make install; \
    \
    cd /build/libwebsockets; \
    mkdir build; \
    cd build; \
    cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..; \
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
    pip3 uninstall -y meson; \
    rm -rf /root/.cache/pip; \
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
        python3-pip \
        cmake \
        build-essential \
    ; \
    rm -rf /var/lib/apt/lists/*;

EXPOSE 8088 8188

USER janus:janus

CMD ["/opt/janus/bin/janus"]
