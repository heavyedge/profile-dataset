.ONESHELL:

DATASETS := $(shell ls -d _data/dataset* | sed -E 's|^[^/]*/||')

.PHONY: all

all: dataset.tar.gz

_temp/%.h5: _data/%.tar.gz config-preprocess.yml
	@mkdir -p $(@D)
	rawdata=$$(mktemp -d)
	trap 'rm -rf $$rawdata' EXIT INT TERM
	tar -xzf $(word 1, $^) -C $$rawdata
	subdir=$$(ls $$rawdata)
	heavyedge prep --type=csvs --name=$* $$rawdata/$$subdir/HEAD_A --config $(lastword $^) -o $@
	echo 'Created $@'

dataset/%.h5: _temp/%-Mean.h5
	@mkdir -p $(@D)
	cp $< $@

_temp/%-Mean.h5: _temp/%.h5
	@filled=$$(mktemp)
	trap 'rm -rf $$filled' EXIT INT TERM
	heavyedge fill $< --fill-value=0 -o $$filled
	heavyedge mean $$filled --wnum=1000 -o $@
	echo 'Created $@'

define dataset-mean
dataset/$(1)/MeanProfiles.h5: $(foreach expt, $(shell ls _data/$(1)/*.tar.gz | sed -E 's|^[^/]*/||; s/\.tar\.gz//'), _temp/$(expt)-Mean.h5)
	mkdir -p $$(@D)
	heavyedge merge $$^ -o $$@
endef

$(foreach dataset,$(DATASETS),$(eval $(call dataset-mean,$(dataset))))

dataset.tar.gz: \
$(foreach dataset,$(DATASETS),$(foreach expt, $(shell ls _data/$(dataset)/*.tar.gz | sed -E 's|^[^/]*/||; s/\.tar\.gz//'), dataset/$(expt).h5)) \
$(foreach dataset,$(DATASETS),dataset/$(dataset)/MeanProfiles.h5)
	tar -czf $@ -C dataset .

.SECONDARY:
