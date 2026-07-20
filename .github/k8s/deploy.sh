#!/bin/sh

set -eu

dataset_status=0
if [ "${DATASET_MODE}" = "release" ]; then
  if [ -z "${GITHUB_REF_NAME:-}" ]; then
    echo "::error::Missing GITHUB_REF_NAME for dataset upload." >&2
    dataset_status=1
  fi
  if [ "$dataset_status" -eq 0 ] && ! uv pip install --system huggingface_hub; then
    dataset_status=1
  fi
  dataset_metadata_file="${DATASET_UPLOAD_METADATA_FILE:-/tmp/dataset-upload-metadata.json}"
  if [ "$dataset_status" -eq 0 ]; then
    rm -f "$dataset_metadata_file"
    if ! python upload.py "${GITHUB_REF_NAME}" --metadata-file "$dataset_metadata_file"; then
      dataset_status=1
    fi
  fi
fi

exit "$dataset_status"
