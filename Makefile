.ONESHELL:
.SECONDEXPANSION:
.SECONDARY:
.PHONY: all datasets examples tests clean .FORCE
# Dummy target to ensure that prerequisite files are built.
.FORCE:

all: datasets examples tests

datasets: dataset-v1

examples: examples-v1

tests: tests-v1

clean:
	shopt -s globstar nullglob
	rm -rf _temp examples/**/*.h5 examples/**/*.csv
	for dataset_dir in datasets/v*; do
		[ -d "$$dataset_dir" ] || continue
		find "$$dataset_dir" -mindepth 1 -maxdepth 1 ! -name datapackage.json -exec rm -rf -- {} +
	done

include make/v1.mk
