#!/bin/sh

set -eu

if ! uv pip install --system -r requirements.txt; then
  exit 1
fi

if ! ./download.sh; then
  exit 2
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
      exit 3
    fi
    if [ -z "${HUGGINGFACE_TOKEN:-}" ]; then
      echo "::error::Missing Hugging Face token for dataset download." >&2
      exit 3
    fi
    if ! hf download "${DATASET_REPO_ID}" \
        --repo-type dataset \
        --revision "${DATASET_REVISION}" \
        --token "${HUGGINGFACE_TOKEN}" \
        --local-dir datasets; then
      exit 3
    fi
    ;;
  *)
    echo "::error::Unsupported dataset mode: ${DATASET_MODE}" >&2
    exit 3
    ;;
esac

if ! make -j ${CPU_REQUEST} ${make_targets}; then
  exit 4
fi
