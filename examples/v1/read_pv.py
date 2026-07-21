import json

import pandas as pd
import pint


def read_pv(pv_csv_path, datapackage_json_path):
    """Return process variables, attaching Data Package units as Pint quantities.

    Columns without a declared unit (for example ``name``, ``slurry``, and
    ``date``) are left unchanged.  Units are read from the ``pv`` resource in
    the supplied Data Package descriptor so that the CSV and its schema remain
    the single source of truth.
    """
    with open(datapackage_json_path) as file:
        datapackage = json.load(file)

    resource = next(
        (item for item in datapackage["resources"] if item["name"] == "pv"),
        None,
    )
    if resource is None:
        raise ValueError(f"No pv resource found in {datapackage_json_path}")

    field_units = {
        field["name"]: field["unit"]
        for field in resource["schema"]["fields"]
        if "unit" in field
    }

    df = pd.read_csv(pv_csv_path)
    ureg = pint.UnitRegistry()
    for field, unit_name in field_units.items():
        if field not in df.columns:
            raise ValueError(f"PV CSV is missing unit-bearing field: {field}")
        unit = ureg.Unit(unit_name)
        df[field] = df[field].map(lambda value: value * unit)

    return df
