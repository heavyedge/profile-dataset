# HeavyEdge Profile Dataset
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Dataset-orange?logo=huggingface)](https://huggingface.co/jeesoo9595/heavyedge-profiles-v1)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/profile-dataset)

Repository to preprocess raw dataset for [HeavyEdge](https://pypi.org/project/heavyedge/) package.

## Setup

```
pip install gdown
gdown --fuzzy [google drive link] -O raw-dataset.tar
```

## Preprocessing

```
pip install -r requirements.txt
mkdir -p _data
tar -xf raw-dataset.tar -C _data
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
- Each major version has dedicated repository, e.g., `heavyedge-dataset-v1`, `heavyedge-dataset-v2`, and so on.

**Minor version**

- Preprocessing algorithm or configuration is changed.

**Patch version**

- Bug fix.
- Metadata change.
