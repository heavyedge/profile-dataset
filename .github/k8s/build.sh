#!/bin/sh

set -eu

if ! hf auth login --token "${HUGGINGFACE_TOKEN}"; then
  exit 1
fi

if ! uv pip install --system -r requirements.txt; then
  exit 2
fi

if ! ./download.sh; then
  exit 3
fi

make_targets="test"
case "${DATASET_MODE}" in
  test) ;;
  release)
    make_targets="all"
    ;;
  reuse) ;;
  *)
    echo "::error::Unsupported dataset mode: ${DATASET_MODE}" >&2
    exit 4
    ;;
esac

if ! make -j "${CPU_REQUEST}" ${make_targets}; then
  exit 4
fi
