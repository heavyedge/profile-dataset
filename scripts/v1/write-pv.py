import argparse
import pathlib

import numpy as np
import pandas as pd
import yaml
from unit import (
    SHEAR_RATE_UNIT,
    UREG,
    VISCOSITY_UNIT,
    load_property,
    load_pv,
    load_viscosity,
)

parser = argparse.ArgumentParser(description="Write process variables.")
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
shear_rate = (pv["Speed"] / pv["Gap"]).apply(lambda x: x.to(SHEAR_RATE_UNIT))
viscosity = np.array(
    [
        np.interp(
            sr.magnitude,
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


def format_quantity(quantity):
    """Return a Pint-readable quantity string for CSV output."""
    return str(quantity)


SLURRY_DICT = dict(
    Standard="G45",
    HighViscosity="G50",
    LowViscosity="G40",
    LowSurfaceTension="G40+IPA",
)

with open(args.ca, "r") as f:
    ca_data = yaml.safe_load(f)
contact_angles = [ca_data.get(s, float("nan")) for s in pv["Slurry"]]
contact_angles = [angle * UREG.degree for angle in contact_angles]

data = {
    # Material identifiers and measured slurry properties.
    "name": pv["Name"],
    "slurry": pv["Slurry"].apply(lambda x: SLURRY_DICT[x]),
    "contact_angle": [format_quantity(angle) for angle in contact_angles],
    "viscosity": [format_quantity(value) for value in viscosity],
    "density": [format_quantity(value) for value in density],
    "shear_rate": [format_quantity(value) for value in shear_rate],
    "surface_tension": [format_quantity(value) for value in st],
    # Process conditions from the experiment index.
    "flow_rate_per_width": [format_quantity(value) for value in pv["FlowRatePerWidth"]],
    "speed": [format_quantity(value) for value in pv["Speed"]],
    "width": [format_quantity(value) for value in pv["Width"]],
    "gap": [format_quantity(value) for value in pv["Gap"]],
    "downstream_lip_length": [format_quantity(value) for value in pv["Ld"]],
    "upstream_lip_length": [format_quantity(value) for value in pv["Lu"]],
    "shim": [format_quantity(value) for value in pv["Shim"]],
    "date": pv["Date"].dt.strftime("%Y-%m-%d"),
}

df = pd.DataFrame(data)
df.to_csv(args.out, index=False)
