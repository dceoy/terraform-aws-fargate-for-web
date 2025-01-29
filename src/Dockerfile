# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.13
FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean \
      && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
        > /etc/apt/apt.conf.d/keep-cache

RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -y update \
      && apt-get -y upgrade

RUN \
      --mount=type=cache,target=/root/.cache/pip \
      --mount=type=bind,source=.,target=/mnt/host \
      /usr/local/bin/python -m pip install -U awslambdaric pip poetry poetry-plugin-export \
      && /usr/local/bin/python -m poetry --directory=/mnt/host export \
        --format=requirements.txt --output=/tmp/requirements.txt \
      && /usr/local/bin/python -m pip uninstall -y poetry poetry-plugin-export \
      && /usr/local/bin/python -m pip install -U -r /tmp/requirements.txt


FROM public.ecr.aws/docker/library/python:${PYTHON_VERSION}-slim AS app

ARG USER_UID=1001
ARG USER_GID=1001
ARG USER_NAME=fargate

COPY --from=builder /usr/local /usr/local
COPY --from=builder /etc/apt/apt.conf.d/keep-cache /etc/apt/apt.conf.d/keep-cache

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      groupadd --gid "${USER_GID}" "${USER_NAME}" \
      && useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USER_NAME}"

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean

RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -y update \
      && apt-get -y upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates

RUN \
      /sbin/groupadd --gid "${USER_GID}" "${USER_NAME}" \
      && /sbin/useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USER_NAME}"

RUN \
      --mount=type=bind,source=.,target=/mnt/host \
      mkdir -p /opt/streamlit \
      && chown -R "${USER_NAME}:${USER_NAME}" /opt/streamlit

EXPOSE 8501

USER "${USER_NAME}"

RUN \
      --mount=type=bind,source=.,target=/mnt/host \
      cp /mnt/host/app.py /opt/streamlit/

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
      CMD curl --fail http://localhost:8501/ || exit 1

ENTRYPOINT ["/usr/local/bin/python", "-m", "streamlit"]
CMD [ "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
