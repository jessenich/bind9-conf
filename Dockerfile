FROM ubuntu:focal AS conf-repos

RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg \
    && apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc >>  \
    && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list;

RUN echo "root content: " \
    && ls / \
    && echo "var content" \
    && ls /etc \
    && echo "var/apt contents" \
    && ls /etc/apt

FROM ubuntu:focal

LABEL maintainer="Jesse N. <https://github.com/jessenich> <https://linkedin.com/jessenich> <jesse@keplerdev.com>"

ENV BIND_USER=bind \
    BIND_VERSION=9.11.3 \
    WEBMIN_VERSION=1.941 \
    DATA_DIR=/data \
    WEBMIN_INIT_SSL_ENABLED= \
    TZ=

COPY --from=conf-repos /etc/apt/trusted.gpg /etc/apt/trusted.gpg
COPY --from=conf-repos /etc/apt/sources.list /etc/apt/sources.list

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && apt-get upgrade -y \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      tzdata \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin=${WEBMIN_VERSION}* \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/named"]