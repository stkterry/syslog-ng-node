FROM mhart/alpine-node:15.2.1

LABEL maintainer="Steven Terry <https://github.com/stkterry>"

ARG SYSLOG_VERSION="3.30.1"
ARG BUILD_CORES=4

# Build-time metadata from http://label-schema.org
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="syslog-ng-node" \
    org.label-schema.description="Minimal Syslog-ng build on Node Alpine" \
    org.label-schema.url="https://hub.docker.com/repository/docker/stevenktdev/syslog-ng-node" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/microscaling/microscaling" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0" \
    org.label-schema.docker.cmd="docker run -d -p 514:514/udp -v /var/log/syslog-ng:/var/log/syslog-ng --name syslog-ng syslog-ng-node"

RUN apk add --no-cache \
    glib \
    pcre \
    eventlog \
    openssl \
    multitail \
    && apk add --no-cache --virtual .build-deps \
    curl \
    alpine-sdk \
    glib-dev \
    pcre-dev \
    eventlog-dev \
    openssl-dev \
    json-c-dev \
    && set -ex \
    && cd /tmp \
    && curl -sSL "https://github.com/balabit/syslog-ng/releases/download/syslog-ng-${SYSLOG_VERSION}/syslog-ng-${SYSLOG_VERSION}.tar.gz" \
        | tar xz \
    && cd "syslog-ng-${SYSLOG_VERSION}" \
    && ./configure -q --prefix=/ \
    && make -j $BUILD_CORES \
    && make install \
    && rm -rf /tmp/* \
    && apk del --no-cache .build-deps \
    && mkdir -p /var/run/syslog-ng /var/log/syslog-ng /syslog-ng/config

COPY /config/startup.sh /config/init /app/
# Copy conf to default directory
COPY /config/syslog-ng.conf /etc/syslog-ng.conf

RUN chmod +x /app/startup.sh

VOLUME ["/var/log/syslog-ng", "/var/run/syslog-ng", "/syslog-ng/config"]

EXPOSE 514/udp 602/tcp 6514/tcp

ENTRYPOINT [ "/bin/sh", "/app/init" ]

CMD [ "/app/startup.sh" ]