.ONESHELL:
.SECONDEXPANSION:
.SECONDARY:
.PHONY: all datasets examples tests clean .FORCE
# Dummy target to ensure that prerequisite files are built.
.FORCE:

DATASETS_v1 := $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),dataset1,$(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename))
PROFILES_v1 = $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),001,$(shell ls _data/v1/profiles/$(1)/*.tar.gz | xargs -n 1 basename -s .tar.gz))
SLURRIES_v1 := G50 G45 G40 G40IPA

all: datasets examples tests

datasets: dataset-v1

examples: examples-v1

tests: tests-v1

clean:
	rm -rf _temp
	for dataset_dir in datasets/v*; do
		[ -d "$$dataset_dir" ] || continue
		find "$$dataset_dir" -mindepth 1 -maxdepth 1 ! -name datapackage.json -exec rm -rf -- {} +
	done

include make/v1.mk
