FROM debian:buster-slim@sha256:b586cf8c850cada85a47599f08eb34ede4a7c473551fd7c68cbf20ce5f8dbbf1

# renovate: datasource=github-tags depName=meetecho/janus-gateway versioning=semver
ENV JANUS_VERSION v0.11.2
# renovate: datasource=github-tags depName=cisco/libsrtp versioning=semver
ENV LIBSRTP_VERSION v2.3.0
# renovate: datasource=git-tags depName=https://gitlab.freedesktop.org/libnice/libnice versioning=semver
ENV LIBNICE_VERSION 0.1.18
# renovate: datasource=git-tags depName=https://libwebsockets.org/repo/libwebsockets versioning=semver
ENV LIBWEBSOCKETS_VERSION v4.2.0
ENV USRSCTP_VERSION master


RUN set -ex; \
    \
    groupadd --system --gid 602 janus; \
    useradd --no-log-init --system --gid janus --no-create-home --uid 602 janus; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        libconfig9 \
        libglib2.0-0 \
        libjansson4 \
        libssl1.1 \
        libcurl4 \
        libopus0 \
        libogg0 \
        libmicrohttpd12 \
        libsofia-sip-ua0 \
    ;\
    apt-get install -y --no-install-recommends \
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
    git clone --branch $LIBWEBSOCKETS_VERSION https://libwebsockets.org/repo/libwebsockets /build/libwebsockets; \
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
    cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" ..; \
    make; \
    make install; \
    \
    cd /build/janus-gateway; \
    sh autogen.sh; \
    ./configure --prefix=/opt/janus; \
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
        libsofia-sip-ua-dev \
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

VOLUME [ "/opt/janus" ]

CMD ["/opt/janus/bin/janus"]
