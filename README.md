# Preprocess HeavyEdge dataset

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

```
pip install huggingface_hub
python3 upload.py
```
