FROM ghcr.io/astral-sh/uv:latest AS uv


FROM python:slim AS dev
COPY --from=uv /uv /uvx /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates curl git jq openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

ARG IMAGE_CREATED
ARG IMAGE_VERSION
ARG IMAGE_REVISION
LABEL org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.authors="Jisoo Song <jeesoo9595@snu.ac.kr>" \
      org.opencontainers.image.source="https://github.com/heavyedge/profile-dataset" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="HeavyEdge Profile Dataset (dev)" \
      org.opencontainers.image.description="Development environment for heavyedge/profile-dataset."


FROM python:slim AS data
COPY --from=uv /uv /uvx /usr/local/bin/

WORKDIR /app
COPY datasets ./datasets
COPY README.md LICENSE ./

ARG IMAGE_CREATED
ARG IMAGE_VERSION
ARG IMAGE_REVISION
LABEL org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.authors="Jisoo Song <jeesoo9595@snu.ac.kr>" \
      org.opencontainers.image.source="https://github.com/heavyedge/profile-dataset" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="HeavyEdge Profile Dataset (data)" \
      org.opencontainers.image.description="Built data from heavyedge/profile-dataset."
