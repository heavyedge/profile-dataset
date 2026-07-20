import argparse
import pathlib

import numpy as np
import pandas as pd
import yaml
from unit import (
    GRAVITY_UNIT,
    HEIGHT_UNIT,
    SHEAR_RATE_UNIT,
    VISCOSITY_UNIT,
    load_property,
    load_pv,
    load_viscosity,
)

parser = argparse.ArgumentParser(description="Write dimensionless process variables.")
parser.add_argument("index", type=pathlib.Path, help="Experiment index CSV file")
parser.add_argument(
    "viscosities",
    type=pathlib.Path,
    help="Directory of viscosity xlsx files",
)
parser.add_argument(
    "properties",
    type=pathlib.Path,
    help="Directory of physical property yaml files",
)
parser.add_argument("ca", type=pathlib.Path, help="Contact angle yaml file")
parser.add_argument("--dataset", help="Dataset name")
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output csv file")
args = parser.parse_args()

# LOAD DATA

pv = load_pv(args.index)
if args.dataset is not None:
    pv["Name"] = pv["Name"].apply(lambda x: f"{args.dataset}/{x}")

VISCOSITY_NAMES = dict(
    high_viscosity="HighViscosity",
    standard_viscosity="Standard",
    low_viscosity="LowViscosity",
    low_surface_tension="LowSurfaceTension",
)
viscosities = {
    VISCOSITY_NAMES[path.stem]: load_viscosity(path)
    for path in args.viscosities.glob("*.csv")
}

properties = {path.stem: load_property(path) for path in args.properties.glob("*.yml")}

# GET DIMENSIONAL VARIABLES

# density
density = np.array([properties[s]["Density"] for s in pv["Slurry"]], dtype=object)

# viscosity
shear_rate = (pv["Speed"] / pv["Gap"]).apply(lambda x: x.to(SHEAR_RATE_UNIT).magnitude)
viscosity = np.array(
    [
        np.interp(
            sr,
            list(reversed(viscosities[s]["shear rate"].apply(lambda x: x.magnitude))),
            list(reversed(viscosities[s]["viscosity"].apply(lambda x: x.magnitude))),
        )
        * VISCOSITY_UNIT
        for sr, s in zip(shear_rate, pv["Slurry"])
    ],
    dtype=object,
)

# surface tension
st = np.array([properties[s]["SurfaceTension"] for s in pv["Slurry"]], dtype=object)

# CONSTRUCT DIMENSIONLESS VARIABLES

Rgt = pv["Speed"] * pv["Gap"] / pv["FlowRatePerWidth"]
Ca = viscosity * pv["Speed"] / st
Re = density * pv["Speed"] * pv["Gap"] / viscosity
R_F = pv["Shim"] / pv["Gap"]
R_Ld = pv["Ld"] / pv["Gap"]
R_Lu = pv["Lu"] / pv["Gap"]

# Construct characteristic lengths

h_w = (pv["FlowRatePerWidth"] / pv["Speed"]).apply(
    lambda x: x.to(HEIGHT_UNIT).magnitude
)
g = np.array([1 * GRAVITY_UNIT] * len(pv), dtype=object)
l_c = [(x.to(HEIGHT_UNIT).magnitude) for x in ((st / (density * g)) ** 0.5)]


def to_dimless(series):
    return series.apply(lambda x: x.to_base_units().magnitude)


fields = {
    "Gap_to_thickness_ratio": to_dimless(Rgt),
    "Capillary_number": to_dimless(Ca),
    "Surface_tension": [x.magnitude for x in st],
    "Reynolds_number": to_dimless(Re),
    "Feed_slot_height_ratio": to_dimless(R_F),
    "Downstream_lip_length_ratio": to_dimless(R_Ld),
    "Upstream_lip_length_ratio": to_dimless(R_Lu),
    "Wet_thickness": h_w,
    "Capillary_length": l_c,
}


SLURRY_DICT = dict(
    Standard="G45",
    HighViscosity="G50",
    LowViscosity="G40",
    LowSurfaceTension="G40+IPA",
)
data = dict(Name=pv["Name"], Slurry=pv["Slurry"].apply(lambda x: SLURRY_DICT[x]))
data.update(fields)

with open(args.ca, "r") as f:
    ca_data = yaml.safe_load(f)
contact_angles = [ca_data.get(s, float("nan")) for s in pv["Slurry"]]
data["Contact_angle"] = contact_angles

df = pd.DataFrame(data)
df.to_csv(args.out, index=False)
