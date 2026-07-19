.ONESHELL:

DATASETS_v1 := $(shell ls -d _data/v1/dataset* | sed -E 's|^[^/]*/[^/]*/||')
PROFILES_v1 = $(shell ls _data/v1/$(1)/*.tar.gz | xargs -n 1 basename -s .tar.gz)

.PHONY: all dataset-v1 clean

all: dataset-v1

dataset-v1: \
$(foreach dataset,$(DATASETS_v1),$(foreach profile,$(call PROFILES_v1,$(dataset)),datasets/v1/$(dataset)/$(profile).h5)) \
$(foreach dataset,$(DATASETS_v1),$(foreach profile,$(call PROFILES_v1,$(dataset)),datasets/v1/$(dataset)/$(profile)-Mean.h5)) \
$(foreach dataset,$(DATASETS_v1),datasets/v1/$(dataset)/MeanProfiles.h5)

clean:
	rm -rf datasets/v*

datasets/v1/%.h5: _data/v1/%.tar.gz config/v1/prep.yml
	@mkdir -p $(@D)
	rawdata=$$(mktemp -d)
	trap 'rm -rf $$rawdata' EXIT INT TERM
	tar -xzf $(word 1, $^) -C $$rawdata
	subdir=$$(ls $$rawdata)
	heavyedge prep --type=csvs --name=$* $$rawdata/$$subdir/HEAD_A --config $(lastword $^) -o $@
	echo 'Created $@'

datasets/v1/%-Mean.h5: datasets/v1/%.h5 config/v1/mean.yml
	@filled=$$(mktemp)
	trap 'rm -rf $$filled' EXIT INT TERM
	heavyedge fill $< --config $(lastword $^) -o $$filled
	heavyedge mean $$filled --config $(lastword $^) -o $@
	echo 'Created $@'

.SECONDEXPANSION:

datasets/v1/%/MeanProfiles.h5: $$(foreach profile,$$(call PROFILES_v1,$$*),datasets/v1/$$*/$$(profile)-Mean.h5)
	mkdir -p $(@D)
	heavyedge merge $^ -o $@

.SECONDARY:
