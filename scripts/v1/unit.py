"""Parse process variable."""

import csv
from datetime import datetime

import pandas as pd
import pint
import yaml

__all__ = [
    "UREG",
    "SHEAR_RATE_UNIT",
    "VISCOSITY_UNIT",
    "load_pv",
    "load_viscosity",
    "load_property",
]


UREG = pint.UnitRegistry()
SHEAR_RATE_UNIT = UREG.second**-1
VISCOSITY_UNIT = UREG.pascal * UREG.second


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
    df = pd.read_csv(path)
    shear_rate_column = next(
        (column for column in ("shear_rate", "shear rate") if column in df.columns),
        None,
    )
    if shear_rate_column is None:
        raise ValueError(f"No shear-rate column found in {path}")
    if "viscosity" not in df.columns:
        raise ValueError(f"No viscosity column found in {path}")

    converters = {
        shear_rate_column: lambda x: (float(x) * SHEAR_RATE_UNIT),
        "viscosity": lambda x: (float(x) * VISCOSITY_UNIT),
    }
    return pd.read_csv(path, converters=converters)


def load_property(path):
    with open(path) as f:
        d = {k: UREG(v) for k, v in yaml.full_load(f).items()}
    return d
