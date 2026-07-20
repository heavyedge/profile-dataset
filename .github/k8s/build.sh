#!/bin/sh

set -eu

if ! ./setup.sh; then
  exit 1
fi

make_targets="test"
case "${DATASET_MODE}" in
  test) ;;
  release)
    make_targets="all"
    ;;
  reuse)
    if [ -z "${DATASET_REVISION:-}" ] || [ -z "${DATASET_REPO_ID:-}" ]; then
      echo "::error::Missing Hugging Face dataset revision or repository." >&2
      exit 2
    fi
    if [ -z "${HUGGINGFACE_TOKEN:-}" ]; then
      echo "::error::Missing Hugging Face token for dataset download." >&2
      exit 2
    fi
    if ! hf download "${DATASET_REPO_ID}" \
        --repo-type dataset \
        --revision "${DATASET_REVISION}" \
        --token "${HUGGINGFACE_TOKEN}" \
        --local-dir datasets; then
      exit 2
    fi
    ;;
  *)
    echo "::error::Unsupported dataset mode: ${DATASET_MODE}" >&2
    exit 2
    ;;
esac

if ! make -j ${CPU_REQUEST} ${make_targets}; then
  exit 3
fi
