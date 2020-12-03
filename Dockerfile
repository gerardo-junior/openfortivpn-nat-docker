FROM alpine:3.11 as builder

ARG OPENFORTIVPN_VERSION=v1.13.2

RUN apk add --no-cache \
    autoconf automake build-base ca-certificates curl git openssl-dev ppp && \
    update-ca-certificates && \
    # build openfortivpn
    mkdir -p /usr/src/openfortivpn && \
    curl -sL https://github.com/adrienverge/openfortivpn/archive/${OPENFORTIVPN_VERSION}.tar.gz \
      | tar xz -C /usr/src/openfortivpn --strip-components=1 && \
    cd /usr/src/openfortivpn && \
    ./autogen.sh && \
    ./configure --prefix=/usr --sysconfdir=/etc && \
    make -j$(nproc) && \
    make install

FROM alpine:3.11

RUN apk add --no-cache ca-certificates openssl ppp iptables

COPY --from=builder /usr/bin/openfortivpn /usr/bin/
COPY ./tools /opt/tools

ENTRYPOINT ["/opt/tools/entrypoint.sh"]
