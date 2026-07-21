.ONESHELL:

DATASETS_v1 := $(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename)
PROFILES_v1 = $(shell ls _data/v1/profiles/$(1)/*.tar.gz | xargs -n 1 basename -s .tar.gz)
SLURRIES_v1 := G50 G45 G40 G40IPA

.PHONY: all dataset-v1 examples test clean

all: dataset-v1 examples

dataset-v1: \
datasets/v1/pv.csv \
$(foreach slurry,$(SLURRIES_v1),datasets/v1/contact_angles/$(slurry).csv) \
datasets/v1/datapackage.json \
$(foreach dataset,$(DATASETS_v1),$(foreach profile,$(call PROFILES_v1,$(dataset)),datasets/v1/profiles/$(dataset)/$(profile).h5)) \
$(foreach dataset,$(DATASETS_v1),$(foreach profile,$(call PROFILES_v1,$(dataset)),datasets/v1/profiles/$(dataset)/$(profile)-Mean.h5))

examples: $(wildcard examples/v1/*.ipynb)

test: datasets/v1/profiles/dataset1/001-Mean.h5 _temp/v1/pv/dataset1.csv

clean:
	rm -rf _temp datasets/v*

datasets/v1/profiles/%.h5: _data/v1/profiles/%.tar.gz config/v1/prep.yml
	@mkdir -p $(@D)
	rawdata=$$(mktemp -d)
	trap 'rm -rf $$rawdata' EXIT INT TERM
	tar -xzf $(word 1, $^) -C $$rawdata
	subdir=$$(ls $$rawdata)
	heavyedge prep --type=csvs --name=$* $$rawdata/$$subdir/HEAD_A --config $(lastword $^) -o $@
	echo 'Created $@'

datasets/v1/profiles/%-Mean.h5: datasets/v1/profiles/%.h5 config/v1/mean.yml
	@filled=$$(mktemp)
	trap 'rm -rf $$filled' EXIT INT TERM
	heavyedge fill $< --config $(lastword $^) -o $$filled
	heavyedge mean $$filled --config $(lastword $^) -o $@
	echo 'Created $@'

datasets/v1/datapackage.json: config/v1/datapackage.json
	mkdir -p $(@D)
	cp $< $@

datasets/v1/contact_angles/%.csv: scripts/v1/read-ca.py _data/v1/ca/%
	mkdir -p $(@D)
	python3 $^ -o $@

_temp/v1/ContactAngles.yml: scripts/v1/write-ca.py datasets/v1/contact_angles/G50.csv datasets/v1/contact_angles/G45.csv datasets/v1/contact_angles/G40.csv datasets/v1/contact_angles/G40IPA.csv
	mkdir -p $(@D)
	python3 $^ --slurries HighViscosity Standard LowViscosity LowSurfaceTension -o $@

_temp/v1/pv/%.csv: scripts/v1/write-pv.py _data/v1/profiles/%/index.csv _data/v1/SlurryViscosities/Descending _data/v1/SlurryProperties _temp/v1/ContactAngles.yml datasets/v1/datapackage.json
	mkdir -p $(@D)
	python3 $^ --dataset=$* -o $@

datasets/v1/pv.csv: $(foreach dataset, $(DATASETS_v1), _temp/v1/pv/$(dataset).csv)
	mkdir -p $(@D)
	python3 -c "import pandas as pd; pd.concat([pd.read_csv(path) for path in '$^'.split(' ')]).to_csv('$@', index=False)"

examples/v1/profile.ipynb: datasets/v1/profiles/dataset1/001.h5 datasets/v1/profiles/dataset1/001-Mean.h5
	jupyter nbconvert --to notebook --execute --inplace $@

examples/v1/contact_angle.ipynb: datasets/v1/contact_angles/G50.csv datasets/v1/contact_angles/G45.csv datasets/v1/contact_angles/G40.csv datasets/v1/contact_angles/G40IPA.csv
	jupyter nbconvert --to notebook --execute --inplace $@

.SECONDARY:
