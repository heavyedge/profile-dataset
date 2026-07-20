.ONESHELL:

DATASETS_v1 := $(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename)
PROFILES_v1 = $(shell ls _data/v1/profiles/$(1)/*.tar.gz | xargs -n 1 basename -s .tar.gz)

.PHONY: all dataset-v1 test clean

all: dataset-v1

dataset-v1: \
$(foreach dataset,$(DATASETS_v1),$(foreach profile,$(call PROFILES_v1,$(dataset)),datasets/v1/profiles/$(dataset)/$(profile).h5)) \
$(foreach dataset,$(DATASETS_v1),$(foreach profile,$(call PROFILES_v1,$(dataset)),datasets/v1/profiles/$(dataset)/$(profile)-Mean.h5))

test: datasets/v1/profiles/dataset1/001-Mean.h5 _temp/v1/ContactAngles.yml

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

_temp/v1/ContactAngles.yml: scripts/v1/write-ca.py  _data/v1/ca/G50 _data/v1/ca/G45 _data/v1/ca/G40 _data/v1/ca/G40IPA
	mkdir -p $(@D)
	python3 $^ --slurries HighViscosity Standard LowViscosity LowSurfaceTension -o $@

.SECONDARY:
