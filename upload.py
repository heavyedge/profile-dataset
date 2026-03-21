import os

from huggingface_hub import HfApi

api = HfApi(token=os.getenv("HUGGINGFACE_TOKEN"))

REPO = "jeesoo9595/heavyedge-profiles-v1"
DATASET_VERSION = "v1.0.0"

api.create_repo(
    repo_id=REPO,
    repo_type="dataset",
    private=True,
    exist_ok=True,
)
api.upload_file(
    path_or_fileobj="dataset.tar.gz",
    path_in_repo="dataset.tar.gz",
    repo_id=REPO,
    repo_type="dataset",
    commit_message=f"Upload dataset version {DATASET_VERSION}",
)
api.create_tag(
    repo_id=REPO,
    repo_type="dataset",
    tag=DATASET_VERSION,
)
