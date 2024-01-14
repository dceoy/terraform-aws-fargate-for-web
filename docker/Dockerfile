FROM public.ecr.aws/docker/library/ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

RUN set -e \
      && ln -sf /bin/bash /bin/sh

RUN set -e \
      && apt-get -y update \
      && apt-get -y dist-upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        apt-transport-https apt-utils ca-certificates locales \
      && apt-get -y autoremove \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash", "-lc"]
