import argparse
import pathlib

import matplotlib.pyplot as plt
import pandas as pd


def plot_viscosity(viscosity_files):
    fig, ax = plt.subplots()

    for path in viscosity_files:
        df = pd.read_csv(path)
        ax.loglog(
            df["shear_rate"].values,
            df["viscosity"].values,
            label=path.stem,
        )
    return fig


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot viscosity data.")
    parser.add_argument("viscosity", type=pathlib.Path, nargs="*", help="csv files")
    parser.add_argument("-o", "--out", type=pathlib.Path, help="Output image file")
    args = parser.parse_args()
    fig = plot_viscosity(args.viscosity)
    if args.out:
        fig.savefig(args.out)
