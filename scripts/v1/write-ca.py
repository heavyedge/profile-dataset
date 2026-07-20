import argparse
import pathlib

import pandas as pd
import yaml
from ca import ContactAngleXLS

parser = argparse.ArgumentParser(description="Write contact angle data.")
parser.add_argument("ca", type=pathlib.Path, nargs="+", help="CA directory")
parser.add_argument("--slurries", nargs="+", help="Slurry names")
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output yaml file")
args = parser.parse_args()

data = dict()
for path, slurry in zip(args.ca, args.slurries):
    xls_files = sorted(path.glob("*.xls"))
    dataframes = []
    for xls_file in xls_files:
        ca_xls = ContactAngleXLS(xls_file)
        df = pd.concat([pd.Series(data) for data in ca_xls], axis=1).transpose()
        dataframes.append(df)
    df_combined = pd.concat(
        dataframes,
        keys=[f.stem for f in xls_files],
        names=["file", "row"],
    )
    first_rows = df_combined.groupby("file", sort=False).first()
    ca = first_rows["Contact Angle(Average)[degree]"].astype(float).mean()
    data[str(slurry)] = float(ca)

with open(args.out, "w") as f:
    yaml.dump(data, f)
