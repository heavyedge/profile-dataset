# Edge Profile Dataset
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Dataset-orange?logo=huggingface)](https://huggingface.co/datasets/jeesoo9595/heavyedge-profiles)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/profile-dataset)

Preprocessed edge profile dataset.

## Setup

```sh
export PROFILES_V1_GDRIVE="..."
./setup.sh
```

## Building the dataset

```
make
```

Each `datasets/v*` directory stores preprocessed profiles from the corresponding major version of raw profile dataset.

## Building the notebooks

```sh
pip install -r notebooks/requirements.txt
```

## Contributing

### Configuring git

Configure the local git filter (run once after cloning):

```sh
git config filter.nbstripout.clean "nbstripout"
git config filter.nbstripout.smudge cat
git config filter.nbstripout.required true
```

### Versioning policy

This repository follows semantic versioning with [Python version specifiers](https://packaging.python.org/en/latest/specifications/version-specifiers/):

```
N.N.N[{a|b|rc}N][.postN][.devN]
```

Datasets are uploaded to HuggingFace repository only when the final relase or the pre-release are made.

> **NOTE** : Major version is raised only when the dataset is changed in backwards incompatible way.
> When a new version of dataset is added, minor version is raised with new `dataset/v*` directory.
