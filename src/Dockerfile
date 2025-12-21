# syntax=docker/dockerfile:1
ARG DEBIAN_VERSION=12
FROM public.ecr.aws/docker/library/debian:${DEBIAN_VERSION}-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV UV_SYSTEM_PYTHON=1
ENV UV_PROJECT_ENVIRONMENT=/opt/uv
ENV PATH="/root/.local/bin:${PATH}"

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean \
      && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
        > /etc/apt/apt.conf.d/keep-cache

RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -y update \
      && apt-get -y upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates curl

RUN \
      --mount=type=cache,target=/root/.cache/uv \
      --mount=type=bind,source=.,target=/mnt/host \
      curl -LsSf https://astral.sh/uv/install.sh | sh \
      && uv sync --directory /mnt/host --no-dev --frozen --no-install-project


FROM public.ecr.aws/docker/library/debian:${DEBIAN_VERSION}-slim AS app

ARG USER_UID=1001
ARG USER_GID=1001
ARG USER_NAME=fargate

COPY --from=builder /etc/apt/apt.conf.d/keep-cache /etc/apt/apt.conf.d/keep-cache
COPY --from=builder /usr/local /usr/local

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONIOENCODING=UTF-8
ENV PIP_NO_CACHE_DIR=off
ENV PIP_DISABLE_PIP_VERSION_CHECK=on
ENV STREAMLIT_SERVER_HEADLESS=true
ENV STREAMLIT_SERVER_PORT=8501
ENV STREAMLIT_SERVER_ADDRESS=0.0.0.0

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN \
      rm -f /etc/apt/apt.conf.d/docker-clean

RUN \
      --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
      apt-get -y update \
      && apt-get -y upgrade \
      && apt-get -y install --no-install-recommends --no-install-suggests \
        ca-certificates curl

RUN \
      groupadd --gid "${USER_GID}" "${USER_NAME}" \
      && useradd --uid "${USER_UID}" --gid "${USER_GID}" --shell /bin/bash --create-home "${USER_NAME}"

RUN \
      mkdir -p /opt/streamlit \
      && chown -R "${USER_NAME}:${USER_NAME}" /opt/streamlit

EXPOSE ${STREAMLIT_SERVER_PORT}

USER "${USER_NAME}"

RUN \
      --mount=type=bind,source=.,target=/mnt/host \
      cp /mnt/host/src/app.py /opt/streamlit/

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
      CMD curl --fail http://localhost:${STREAMLIT_SERVER_PORT}/healthz || exit 1

ENTRYPOINT ["/opt/uv/bin/python", "-m", "streamlit"]
CMD ["run", "/opt/streamlit/app.py"]
