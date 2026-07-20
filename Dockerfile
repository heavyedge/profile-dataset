# syntax=docker/dockerfile:1.19
FROM ghcr.io/astral-sh/uv:latest AS uv


FROM python:slim AS dev
COPY --from=uv /uv /uvx /usr/local/bin/

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates curl git jq openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

