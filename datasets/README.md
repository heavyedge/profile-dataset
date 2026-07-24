---
license: cc-by-4.0
language: en
---

# Edge profile dataset

[![HuggingFace](https://img.shields.io/badge/HuggingFace-Dataset-orange?logo=huggingface)](https://huggingface.co/datasets/jeesoo9595/heavyedge-profiles)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/profile-dataset)

Profile data can be loaded using [heavyedge](https://pypi.org/project/heavyedge/) Python package.
Refer to the examples in the [source release](https://github.com/heavyedge/profile-dataset/releases).

## v1

Slot-die coating dataset collected by Yoon and Min (2026).

Profiles are stored as `dataset*.tar.gz` archives.
To unpack all profiles, run:

```sh
for directory in v1/profiles v1/mean_profiles; do
    for archive in "$directory"/*.tar.gz; do
        [ -e "$archive" ] || continue
        dataset=${archive##*/}
        dataset=${dataset%.tar.gz}
        mkdir -p "$directory/$dataset"
        tar -xzf "$archive" -C "$directory/$dataset"
    done
done
```
