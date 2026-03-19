.ONESHELL:

DATASETS := $(shell ls -d _data/dataset* | sed -E 's|^[^/]*/||')

.PHONY: all

all: dataset/heavyedge-dataset.h5

_temp/%-Prep.h5: _data/%.tar.gz config-preprocess.yml
	@mkdir -p $(@D)
	rawdata=$$(mktemp -d)
	trap 'rm -rf $$rawdata' EXIT INT TERM
	tar -xzf $(word 1, $^) -C $$rawdata
	subdir=$$(ls $$rawdata)
	heavyedge prep --type=csvs --name=$* $$rawdata/$$subdir/HEAD_A --config $(lastword $^) -o $@
	echo 'Created $@'

_temp/%-Mean.h5: _temp/%-Prep.h5
	@filled=$$(mktemp)
	trap 'rm -rf $$filled' EXIT INT TERM
	heavyedge fill $< --fill-value=0 -o $$filled
	heavyedge mean $$filled --wnum=1000 -o $@
	echo 'Created $@'

define dataset-mean
_temp/MeanProfiles-$(1).h5: $(foreach expt, $(shell ls _data/$(1)/*.tar.gz | sed -E 's|^[^/]*/||; s/\.tar\.gz//'), _temp/$(expt)-Mean.h5)
	mkdir -p $$(@D)
	heavyedge merge $$^ -o $$@
endef

$(foreach dataset,$(DATASETS),$(eval $(call dataset-mean,$(dataset))))

dataset/heavyedge-dataset.h5: $(foreach dataset, $(DATASETS), _temp/MeanProfiles-$(dataset).h5)
	mkdir -p $(@D)
	heavyedge merge $^ -o $@
