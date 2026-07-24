.ONESHELL:
.SECONDEXPANSION:
.SECONDARY:
.PHONY: all datasets examples dataset-v1 examples-v1 clean .FORCE
# Dummy target to ensure that prerequisite files are built.
.FORCE:

DATASETS_v1 := $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),dataset1,$(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename))
PROFILES_v1 = $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),001,$(shell ls _data/v1/profiles/$(1)/*.tar.gz | xargs -n 1 basename -s .tar.gz))
SLURRIES_v1 := G50 G45 G40 G40IPA

all: datasets examples

datasets: dataset-v1

examples: examples-v1

dataset-v1: \
$(foreach dataset,$(DATASETS_v1),datasets/v1/process_variables/$(dataset).csv) \
$(foreach slurry,$(SLURRIES_v1),datasets/v1/contact_angles/$(slurry).csv) \
$(foreach slurry,$(SLURRIES_v1),datasets/v1/viscosities/$(slurry).csv) \
$(foreach dataset,$(DATASETS_v1),datasets/v1/profiles/$(dataset).tar.gz) \
$(foreach dataset,$(DATASETS_v1),datasets/v1/mean_profiles/$(dataset).tar.gz)

examples-v1: $(wildcard examples/v1/*.ipynb)

clean:
	rm -rf _temp
	for dataset_dir in datasets/v*; do
		[ -d "$$dataset_dir" ] || continue
		find "$$dataset_dir" -mindepth 1 -maxdepth 1 ! -name datapackage.json -exec rm -rf -- {} +
	done

# Dataset

_temp/v1/profiles/%.h5: _data/v1/profiles/%.tar.gz config/v1/prep.yml
	@mkdir -p $(@D)
	rawdata=$$(mktemp -d)
	trap 'rm -rf $$rawdata' EXIT INT TERM
	tar -xzf $(word 1, $^) -C $$rawdata
	subdir=$$(ls $$rawdata)
	heavyedge prep --type=csvs --name=$* $$rawdata/$$subdir/HEAD_A --config $(lastword $^) -o $@
	echo 'Created $@'

define PROFILES_TARGZ_v1
datasets/v1/profiles/$(1).tar.gz: $(foreach profile,$(call PROFILES_v1,$(1)),_temp/v1/profiles/$(1)/$(profile).h5)
	mkdir -p $$(@D)
	tar -czf $$@ -C _temp/v1/profiles/$(1) $$(notdir $$^)
endef
$(foreach dataset,$(DATASETS_v1),$(eval $(call PROFILES_TARGZ_v1,$(dataset))))

_temp/v1/mean_profiles/%.h5: _temp/v1/profiles/%.h5 config/v1/mean.yml
	@mkdir -p $(@D)
	@filled=$$(mktemp)
	trap 'rm -rf $$filled' EXIT INT TERM
	heavyedge fill $< --config $(lastword $^) -o $$filled
	heavyedge mean $$filled --config $(lastword $^) -o $@
	echo 'Created $@'

define MEANPROFILES_TARGZ_v1
datasets/v1/mean_profiles/$(1).tar.gz: $(foreach profile,$(call PROFILES_v1,$(1)),_temp/v1/mean_profiles/$(1)/$(profile).h5)
	@mkdir -p $$(@D)
	tar -czf $$@ -C _temp/v1/mean_profiles/$(1) $$(notdir $$^)
endef
$(foreach dataset,$(DATASETS_v1),$(eval $(call MEANPROFILES_TARGZ_v1,$(dataset))))

datasets/v1/process_variables/%.csv: scripts/v1/write-pv.py _data/v1/profiles/%/index.csv _temp/v1/Viscosities.csv _data/v1/SlurryProperties _temp/v1/ContactAngles.yml datasets/v1/datapackage.json
	mkdir -p $(@D)
	python3 $^ --dataset=$* -o $@

datasets/v1/viscosities/G50.csv: scripts/v1/write-viscosity.py _data/v1/SlurryViscosities/Ascending/high_viscosity.csv _data/v1/SlurryViscosities/Descending/high_viscosity.csv
	mkdir -p $(@D)
	python3 $^ -o $@

datasets/v1/viscosities/G45.csv: scripts/v1/write-viscosity.py _data/v1/SlurryViscosities/Ascending/standard_viscosity.csv _data/v1/SlurryViscosities/Descending/standard_viscosity.csv
	mkdir -p $(@D)
	python3 $^ -o $@

datasets/v1/viscosities/G40.csv: scripts/v1/write-viscosity.py _data/v1/SlurryViscosities/Ascending/low_viscosity.csv _data/v1/SlurryViscosities/Descending/low_viscosity.csv
	mkdir -p $(@D)
	python3 $^ -o $@

datasets/v1/viscosities/G40IPA.csv: scripts/v1/write-viscosity.py _data/v1/SlurryViscosities/Ascending/low_surface_tension.csv _data/v1/SlurryViscosities/Descending/low_surface_tension.csv
	mkdir -p $(@D)
	python3 $^ -o $@

datasets/v1/contact_angles/%.csv: scripts/v1/read-ca.py _data/v1/ca/%
	mkdir -p $(@D)
	python3 $^ -o $@

_temp/v1/Viscosities.csv: datasets/v1/viscosities/G50.csv datasets/v1/viscosities/G45.csv datasets/v1/viscosities/G40.csv datasets/v1/viscosities/G40IPA.csv
	mkdir -p $(@D)
	python3 -c "from pathlib import Path; import pandas as pd; paths = '$^'.split(' '); slurries = [Path(path).stem for path in paths]; dfs = [pd.read_csv(path).assign(slurry=slurry) for path, slurry in zip(paths, slurries)]; pd.concat(dfs, keys=slurries, names=['slurry']).to_csv('$@', index=False)"

_temp/v1/ContactAngles.yml: scripts/v1/write-ca.py datasets/v1/contact_angles/G50.csv datasets/v1/contact_angles/G45.csv datasets/v1/contact_angles/G40.csv datasets/v1/contact_angles/G40IPA.csv
	mkdir -p $(@D)
	python3 $^ --slurries HighViscosity Standard LowViscosity LowSurfaceTension -o $@

# Examples

datasets/v1/profiles/dataset1/001.h5: datasets/v1/profiles/dataset1.tar.gz
	@mkdir -p $(@D)
	@tar -xzf $< -C $(@D) $(notdir $@)

datasets/v1/mean_profiles/dataset1/001.h5: datasets/v1/mean_profiles/dataset1.tar.gz
	@mkdir -p $(@D)
	@tar -xzf $< -C $(@D) $(notdir $@)

examples/v1/profile.ipynb: datasets/v1/profiles/dataset1/001.h5 datasets/v1/mean_profiles/dataset1/001.h5 .FORCE
	jupyter nbconvert --to notebook --execute --inplace $@

examples/v1/contact_angle.ipynb: datasets/v1/contact_angles/G50.csv datasets/v1/contact_angles/G45.csv datasets/v1/contact_angles/G40.csv datasets/v1/contact_angles/G40IPA.csv .FORCE
	jupyter nbconvert --to notebook --execute --inplace $@

examples/v1/viscosity.ipynb: $(foreach slurry,$(SLURRIES_v1),datasets/v1/viscosities/$(slurry).csv) $(foreach dataset,$(DATASETS_v1),datasets/v1/process_variables/$(dataset).csv) .FORCE
	jupyter nbconvert --to notebook --execute --inplace $@

examples/v1/dimless.ipynb: datasets/v1/process_variables/dataset1.csv datasets/v1/datapackage.json .FORCE
	jupyter nbconvert --to notebook --execute --inplace $@
