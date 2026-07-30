#!/bin/sh

set -eu

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT INT TERM

if ! ./setup.sh; then
  exit 1
fi
if ! curl -LsSf https://hf.co/cli/install.sh | bash; then
  exit 1
fi

make_targets="dataset-v1"
set -- -j "${MAKE_JOBS}"
case "${BUILD_MODE:-test}" in
  build)
    if ! HEAVYEDGE_TEST_MODE=0 make -j ${MAKE_JOBS} ${make_targets}; then
      exit 2
    fi
    ;;
  pull)
    overlay_dir="${work_dir}/dataset-overlay"
    mkdir -p "$overlay_dir"
    cp -a datasets/. "$overlay_dir/"
    if ! "$HOME/.local/bin/hf" download "${UPSTREAM_REPO_ID}" \
        --repo-type dataset \
        --revision "${UPSTREAM_REVISION}" \
        --token "${HUGGINGFACE_TOKEN}" \
        --local-dir datasets; then
      exit 2
    fi
    cp -a "$overlay_dir/." datasets/
    rm -rf datasets/.cache/huggingface
    dataset_list="${work_dir}/datasets.list"
    find datasets -type f -print > "${dataset_list}"
    while IFS= read -r dataset_file; do
      set -- "$@" "--assume-old=${dataset_file}"
    done < "${dataset_list}"
    ;;
  test)
    if ! HEAVYEDGE_TEST_MODE=1 make -j ${MAKE_JOBS} ${make_targets}; then
      exit 2
    fi
    ;;
  *)
    echo "::error::Unsupported build mode: ${BUILD_MODE}" >&2
    exit 2
    ;;
esac

make_targets="examples-v1"
case "${DOC_BUILD_MODE:-test}" in
  build)
    if ! HEAVYEDGE_TEST_MODE=0 make -j "${MAKE_JOBS}" "$@" ${make_targets}; then
      exit 3
    fi
    ;;
  pull)
    if ! HEAVYEDGE_TEST_MODE=0 make -j "${MAKE_JOBS}" "$@" ${make_targets}; then
      exit 3
    fi
    ;;
  test)
    if ! HEAVYEDGE_TEST_MODE=1 make -j "${MAKE_JOBS}" "$@" ${make_targets}; then
      exit 3
    fi
    ;;
  *)
    echo "::error::Unsupported doc build mode: ${DOC_BUILD_MODE}" >&2
    exit 3
    ;;
esac
