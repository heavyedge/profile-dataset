# Edge Profile Dataset
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Dataset-orange?logo=huggingface)](https://huggingface.co/datasets/jeesoo9595/heavyedge-profiles)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/profile-dataset)

Preprocessed edge profile dataset.

## Setup

```sh
export PROFILES_V1_GDRIVE="..."
export CA_V1_GDRIVE="..."
./setup.sh
```

## Building the dataset

```
make
```

Each `datasets/v*` directory stores preprocessed profiles from the corresponding major version of raw profile dataset.

## Building the notebooks

```sh
make examples
```

## Contributing

### Configuring git

Configure the local git filter (run once after cloning):

```sh
nbstripout --install --attributes .gitattributes
git config filter.nbstripout.clean "nbstripout"
git config filter.nbstripout.smudge cat
git config filter.nbstripout.required true
```

### Versioning policy

This repository follows semantic versioning with [Python version specifiers](https://packaging.python.org/en/latest/specifications/version-specifiers/):

```
N.N.N[{a|b|rc}N][.postN][.devN]
```

- Final release and pre-release (`N.N.N[{a|b|rc}N]`):
  - Dataset is re-built and deployed to HuggingFace.
  - Examples are re-built using the new dataset and uploaded as release artifacts.
- Post-release (`*.postN`):
  - Dataset is deployed to HuggingFace without re-building.
    This means that only the metadata will change.
  - Examples are re-built using the previous dataset and uploaded as release artifacts.
- Developmental release (`*.devN`):
  - Dataset is not built and not deployed to HuggingFace.
  - Examples are not built and not uploaded as release artifacts.

> **NOTE** : Major version is raised only when the dataset is changed in backwards incompatible way.
> When new data is added, minor version is raised with new `datasets/v*` directory.
