import argparse
import pathlib

import pandas as pd
from ca import ContactAngleXLS

parser = argparse.ArgumentParser(description="Read contact angle data.")
parser.add_argument("ca", type=pathlib.Path, help="Directory of xls files")
parser.add_argument("-o", "--out", type=pathlib.Path, help="Output csv file")
args = parser.parse_args()

xls_files = sorted(args.ca.glob("*.xls"))

FIELD_COL, VALUE_COL = 4, 5
NUM_FIELDS = 18
PAD_ROWS = 3
INIT_ROW = 7

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
df_combined.to_csv(args.out)
