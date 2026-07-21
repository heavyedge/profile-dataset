import argparse
import pathlib

import pandas as pd
import yaml

parser = argparse.ArgumentParser(description="Write contact angle data.")
parser.add_argument("ca", type=pathlib.Path, nargs="+", help="csv files")
parser.add_argument("--slurries", nargs="+", help="Slurry names")
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output yaml file")
args = parser.parse_args()

data = dict()
for path, slurry in zip(args.ca, args.slurries):
    ca = pd.read_csv(path)
    ca["file"] = ca["name"].str.rsplit("/", n=1).str[0]
    first_rows = ca.groupby("file", sort=False).first()
    data[str(slurry)] = float(first_rows["contact_angle"].mean())

with open(args.out, "w") as f:
    yaml.dump(data, f)
