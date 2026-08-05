import argparse
import pathlib

import pandas as pd
from heavyedge import ProfileData

parser = argparse.ArgumentParser(description="Write process variables.")
parser.add_argument("pv", type=pathlib.Path, help="Process variables CSV file")
parser.add_argument(
    "profiles",
    type=pathlib.Path,
    help="Directory of profile HDF5 files",
)
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output csv file")
args = parser.parse_args()


def count_profiles(profiles_dir):
    paths = sorted(profiles_dir.glob("*.h5"))
    num_profiles = []
    names = []
    for path in paths:
        with ProfileData(path) as profiles:
            num_profiles.append(profiles.shape()[0])
        names.append(path.stem)
    return num_profiles, pd.Series(names, name="name")


pv = pd.read_csv(args.pv, dtype=str)
num_profiles, each_names = count_profiles(args.profiles)
names = each_names.repeat(num_profiles).reset_index(drop=True)

expanded_pv = pv.set_index("name").reindex(names).reset_index()
expanded_pv.to_csv(args.out, index=False)
