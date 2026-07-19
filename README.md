# Edge Profile Dataset
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Dataset-orange?logo=huggingface)](https://huggingface.co/datasets/jeesoo9595/heavyedge-profiles-v1)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/profile-dataset)

Preprocessed edge profile dataset.

## Setup

```sh
export GDRIVE_LINK="..."
pip install uv
uv pip install --system -r requirements.txt
./download.sh
```

## Preprocessing

```
make
```

## Upload to HuggingFace

Make sure that the dataset version in `upload.py` is updated.

```
pip install huggingface_hub
python3 upload.py
```

## Versioning policy

The HeavyEdge dataset follows semantic versioning.

**Major version**

- Matches the raw dataset version.
- Each major version has dedicated repository, e.g., `heavyedge-profiles-v1`, `heavyedge-profiles-v2`, and so on.

**Minor version**

- Preprocessing algorithm or configuration is changed.

**Patch version**

- Bug fix.
- Metadata change.
