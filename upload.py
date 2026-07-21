import argparse
import json
import os
import sys

from huggingface_hub import HfApi
from packaging.version import InvalidVersion, Version

parser = argparse.ArgumentParser(description="Upload model to Hugging Face Hub")
parser.add_argument("tag", help="Model version tag (e.g., v1.0.0)")
parser.add_argument(
    "--metadata-file",
    help="Write uploaded model metadata as JSON after a successful upload",
)
args = parser.parse_args()

version_text = args.tag.removeprefix("v")

try:
    version = Version(version_text)
except InvalidVersion:
    print(f"Invalid model version tag: {args.tag}", file=sys.stderr)
    sys.exit(1)

if version.dev is not None:
    print(f"Skipping Hugging Face upload for dev release tag: {args.tag}")
    sys.exit(1)

api = HfApi(token=os.getenv("HUGGINGFACE_TOKEN"))

DATASET_VERSION = args.tag
REPO = "jeesoo9595/heavyedge-profiles"

api.create_repo(
    repo_id=REPO,
    repo_type="dataset",
    private=True,
    exist_ok=True,
)
api.upload_folder(
    folder_path="datasets",
    path_in_repo=".",
    repo_id=REPO,
    repo_type="dataset",
    commit_message=f"Upload dataset version {DATASET_VERSION}",
)
api.create_tag(
    repo_id=REPO,
    repo_type="dataset",
    tag=DATASET_VERSION,
)

if args.metadata_file:
    metadata = {
        "dataset_repo": f"{REPO}",
        "dataset_revision": DATASET_VERSION,
    }
    with open(args.metadata_file, "w", encoding="utf-8") as file:
        json.dump(metadata, file, sort_keys=True)
        file.write("\n")
