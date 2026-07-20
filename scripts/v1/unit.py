"""Parse process variable."""

import csv
from datetime import datetime

import pandas as pd
import pint
import yaml

__all__ = [
    "UREG",
    "HEIGHT_UNIT",
    "SHEAR_RATE_UNIT",
    "VISCOSITY_UNIT",
    "GRAVITY_UNIT",
    "load_pv",
    "load_viscosity",
    "load_property",
]


UREG = pint.UnitRegistry()
HEIGHT_UNIT = UREG.millimeter
SHEAR_RATE_UNIT = UREG.second**-1
VISCOSITY_UNIT = UREG.pascal * UREG.second
GRAVITY_UNIT = UREG.standard_gravity


PV_CONVERTERS = dict(
    Name=str,
    Date=lambda x: datetime.strptime(x, "%Y-%m-%d"),
    Slurry=str,
)


def load_pv(path):
    converters = {}
    converters.update(PV_CONVERTERS)

    with open(path) as csvfile:
        for field in next(csv.reader(csvfile)):
            if field not in converters:
                converters[field] = UREG
    return pd.read_csv(path, converters=converters)


def load_viscosity(path):
    converters = {
        "shear rate": lambda x: (float(x) * SHEAR_RATE_UNIT),
        "viscosity": lambda x: (float(x) * VISCOSITY_UNIT),
    }
    df = pd.read_csv(path, converters=converters)
    return df


def load_property(path):
    with open(path) as f:
        d = {k: UREG(v) for k, v in yaml.full_load(f).items()}
    return d
