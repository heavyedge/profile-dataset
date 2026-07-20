#!/bin/sh

set -eu

if ! uv pip install --system -r requirements.txt; then
  exit 1
fi

if ! ./download.sh; then
  exit 2
fi
