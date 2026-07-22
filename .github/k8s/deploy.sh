#!/bin/sh

set -eu

# upload_release_examples() (
#   if [ -z "${GITHUB_REPOSITORY:-}" ]; then
#     echo "::error::Missing GITHUB_REPOSITORY for release asset upload." >&2
#     exit 1
#   fi
#   if [ -z "${GITHUB_REF_NAME:-}" ]; then
#     echo "::error::Missing GITHUB_REF_NAME for release asset upload." >&2
#     exit 1
#   fi
#   if [ -z "${GITHUB_APP_TOKEN:-}" ]; then
#     echo "::error::Missing GITHUB_APP_TOKEN for release asset upload." >&2
#     exit 1
#   fi
#   if [ ! -d examples ]; then
#     echo "::error::Build output directory examples is missing." >&2
#     exit 1
#   fi

#   archive_file="$(mktemp)"
#   response_file="$(mktemp)"
#   trap 'rm -f "$archive_file" "$response_file"' EXIT

#   if ! tar -czf "$archive_file" examples; then
#     echo "::error::Failed to archive examples for release asset upload." >&2
#     exit 1
#   fi

#   asset_name="examples-${GITHUB_REF_NAME}.tar.gz"
#   release_url="https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/tags/${GITHUB_REF_NAME}"
#   if ! http_status="$(
#     curl -sS \
#       -o "$response_file" \
#       -w '%{http_code}' \
#       -H 'Accept: application/vnd.github+json' \
#       -H "Authorization: Bearer ${GITHUB_APP_TOKEN}" \
#       -H 'X-GitHub-Api-Version: 2022-11-28' \
#       "$release_url"
#   )" || [ "$http_status" -lt 200 ] || [ "$http_status" -ge 300 ]; then
#     echo "::error::Failed to find release ${GITHUB_REF_NAME}; GitHub API returned HTTP ${http_status:-curl-failed}." >&2
#     [ -s "$response_file" ] && sed 's/^/GitHub API response: /' "$response_file" >&2
#     exit 1
#   fi

#   if ! upload_url="$(python -c 'import json, sys; print(json.load(sys.stdin)["upload_url"].split("{")[0])' < "$response_file")"; then
#     echo "::error::Failed to parse release asset upload URL." >&2
#     exit 1
#   fi
#   if ! release_asset_id="$(python -c 'import json, sys; asset_name = sys.argv[1]; release = json.load(sys.stdin); print(next((asset["id"] for asset in release["assets"] if asset["name"] == asset_name), ""))' "$asset_name" < "$response_file")"; then
#     echo "::error::Failed to parse existing release assets." >&2
#     exit 1
#   fi

#   if [ -n "$release_asset_id" ] && ! http_status="$(
#     curl -sS \
#       -o "$response_file" \
#       -w '%{http_code}' \
#       -X DELETE \
#       -H 'Accept: application/vnd.github+json' \
#       -H "Authorization: Bearer ${GITHUB_APP_TOKEN}" \
#       -H 'X-GitHub-Api-Version: 2022-11-28' \
#       "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/assets/${release_asset_id}"
#   )" || [ "$http_status" -lt 200 ] || [ "$http_status" -ge 300 ]; then
#     echo "::error::Failed to replace existing ${asset_name}; GitHub API returned HTTP ${http_status:-curl-failed}." >&2
#     [ -s "$response_file" ] && sed 's/^/GitHub API response: /' "$response_file" >&2
#     exit 1
#   fi

#   if ! http_status="$(
#     curl -sS \
#       -o "$response_file" \
#       -w '%{http_code}' \
#       -X POST \
#       -H 'Accept: application/vnd.github+json' \
#       -H "Authorization: Bearer ${GITHUB_APP_TOKEN}" \
#       -H 'Content-Type: application/gzip' \
#       -H 'X-GitHub-Api-Version: 2022-11-28' \
#       --data-binary "@$archive_file" \
#       "${upload_url}?name=${asset_name}"
#   )" || [ "$http_status" -lt 200 ] || [ "$http_status" -ge 300 ]; then
#     echo "::error::Failed to upload ${asset_name}; GitHub API returned HTTP ${http_status:-curl-failed}." >&2
#     [ -s "$response_file" ] && sed 's/^/GitHub API response: /' "$response_file" >&2
#     exit 1
#   fi

#   echo "Uploaded ${asset_name} to release ${GITHUB_REF_NAME}."
# )

# status=0
# if [ "${DATASET_MODE}" = "release" ] || [ "${DATASET_MODE}" = "post" ]; then
#   if [ -z "${GITHUB_REF_NAME:-}" ]; then
#     echo "::error::Missing GITHUB_REF_NAME for dataset upload." >&2
#     status=1
#   fi
#   if [ "$status" -eq 0 ] && ! uv pip install --system huggingface_hub; then
#     status=1
#   fi
#   dataset_metadata_file="${DATASET_UPLOAD_METADATA_FILE:-/tmp/dataset-upload-metadata.json}"
#   if [ "$status" -eq 0 ]; then
#     rm -f "$dataset_metadata_file"
#     if ! python upload.py "${GITHUB_REF_NAME}" --metadata-file "$dataset_metadata_file"; then
#       status=1
#     fi
#   fi
# fi

# if [ "$status" -eq 0 ] && [ "${GITHUB_EVENT_NAME:-}" = "release" ] && ! upload_release_examples; then
#   status=2
# fi

# exit "$status"
