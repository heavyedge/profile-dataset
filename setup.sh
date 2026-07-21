#!/bin/sh

pip install uv

uv pip install --system -r requirements.txt -r examples/requirements.txt
uv pip install --system 'gdown<6.0.0'

mkdir -p ./_data/v1/profiles
gdown --fuzzy "$PROFILES_V1_GDRIVE" -O ./_data/v1/profiles.tar
tar -xf _data/v1/profiles.tar -C _data/v1/profiles
mv _data/v1/profiles/SlurryProperties _data/v1/profiles/SlurryViscosities _data/v1/

mkdir -p ./_data/v1/ca
gdown --fuzzy "$CA_V1_GDRIVE" -O ./_data/v1/ca.tar
tar -xf _data/v1/ca.tar -C _data/v1/ca
