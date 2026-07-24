import argparse
import json
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
    help="Viscosity csv file",
)
parser.add_argument(
    "properties",
    type=pathlib.Path,
    help="Directory of physical property yaml files",
)
parser.add_argument("ca", type=pathlib.Path, help="Contact angle yaml file")
parser.add_argument(
    "datapackage",
    type=pathlib.Path,
    help="Data Package descriptor containing the pv field units",
)
parser.add_argument("--dataset", help="Dataset name")
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output csv file")
args = parser.parse_args()


def load_field_units(path):
    """Load the declared units for the pv resource from a Data Package."""
    with open(path) as f:
        datapackage = json.load(f)

    resource = next(
        (
            resource
            for resource in datapackage["resources"]
            if resource["name"] == "Process variables"
        ),
        None,
    )
    if resource is None:
        raise ValueError(f"No resource found in {path}")

    return {
        field["name"]: field["unit"]
        for field in resource["schema"]["fields"]
        if "unit" in field
    }


field_units = load_field_units(args.datapackage)

# LOAD DATA

pv = load_pv(args.index)
if args.dataset is not None:
    pv["Name"] = pv["Name"]

VISCOSITY_NAMES = dict(
    G50="HighViscosity",
    G45="Standard",
    G40="LowViscosity",
    G40IPA="LowSurfaceTension",
)
viscosity_data = load_viscosity(args.viscosities)
descending_viscosities = viscosity_data.loc[
    viscosity_data["sweep_direction"] == "descending"
]
viscosities = {
    VISCOSITY_NAMES[slurry]: data
    for slurry, data in descending_viscosities.groupby("slurry", sort=False)
    if slurry in VISCOSITY_NAMES
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
            viscosities[s]["shear_rate"].iloc[::-1].apply(lambda x: x.magnitude),
            viscosities[s]["viscosity"].iloc[::-1].apply(lambda x: x.magnitude),
        )
        * VISCOSITY_UNIT
        for sr, s in zip(shear_rate, pv["Slurry"])
    ],
    dtype=object,
)

# surface tension
st = np.array([properties[s]["SurfaceTension"] for s in pv["Slurry"]], dtype=object)


def to_magnitude(quantity, field):
    """Convert a Pint quantity to the numeric value in the field's declared unit."""
    try:
        unit = field_units[field]
    except KeyError as error:
        raise ValueError(f"No unit declared for pv field: {field}") from error
    return quantity.to(unit).magnitude


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
    "contact_angle": [to_magnitude(angle, "contact_angle") for angle in contact_angles],
    "viscosity": [to_magnitude(value, "viscosity") for value in viscosity],
    "density": [to_magnitude(value, "density") for value in density],
    "shear_rate": [to_magnitude(value, "shear_rate") for value in shear_rate],
    "surface_tension": [to_magnitude(value, "surface_tension") for value in st],
    # Process conditions from the experiment index.
    "flow_rate_per_width": [
        to_magnitude(value, "flow_rate_per_width") for value in pv["FlowRatePerWidth"]
    ],
    "coating_speed": [to_magnitude(value, "coating_speed") for value in pv["Speed"]],
    "slot_width": [to_magnitude(value, "slot_width") for value in pv["Width"]],
    "coating_gap": [to_magnitude(value, "coating_gap") for value in pv["Gap"]],
    "downstream_lip_length": [
        to_magnitude(value, "downstream_lip_length") for value in pv["Ld"]
    ],
    "upstream_lip_length": [
        to_magnitude(value, "upstream_lip_length") for value in pv["Lu"]
    ],
    "shim_thickness": [to_magnitude(value, "shim_thickness") for value in pv["Shim"]],
    "date": pv["Date"].dt.strftime("%Y-%m-%d"),
}

df = pd.DataFrame(data)
df.to_csv(args.out, index=False)
