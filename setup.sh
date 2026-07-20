#!/bin/sh

pip install uv

uv pip install --system -r requirements.txt

mkdir -p ./_data/v1
uv pip install --system 'gdown<6.0.0'
gdown --fuzzy "$PROFILES_V1_GDRIVE" -O ./_data/v1.tar
tar -xf _data/v1.tar -C _data/v1
