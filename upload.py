import os
import sys

from huggingface_hub import HfApi
from packaging.version import InvalidVersion, Version

REPO = "jeesoo9595/heavyedge-profiles"
DATASET_VERSION = "v1.0.0a0"

try:
    version = Version(DATASET_VERSION.removeprefix("v"))
except InvalidVersion:
    print(f"Invalid model version tag: {DATASET_VERSION}", file=sys.stderr)
    sys.exit(1)

if version.post is not None:
    print(f"Skipping Hugging Face upload for post release tag: {DATASET_VERSION}")
    sys.exit(1)
if version.dev is not None:
    print(f"Skipping Hugging Face upload for dev release tag: {DATASET_VERSION}")
    sys.exit(1)

api = HfApi(token=os.getenv("HUGGINGFACE_TOKEN"))

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
