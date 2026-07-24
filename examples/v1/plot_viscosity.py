import argparse
import pathlib
from itertools import cycle

import matplotlib.pyplot as plt
import pandas as pd

MARKERS = dict(
    G50="o",
    G45="v",
    G40="^",
    G40IPA="s",
)


def plot_viscosity(viscosity_files, pv_files):
    pvs = [pd.read_csv(pv_file) for pv_file in pv_files]
    process_shear_rates = pd.concat([pv["shear_rate"].dropna() for pv in pvs])
    shear_rate_min = process_shear_rates.min()
    shear_rate_max = process_shear_rates.max()

    fig, ax = plt.subplots()
    colors = cycle(plt.rcParams["axes.prop_cycle"].by_key()["color"])

    for path, color in zip(viscosity_files, colors):
        df = pd.read_csv(path)
        descending = df["sweep_direction"] == "descending"
        in_process_range = df["shear_rate"].between(
            shear_rate_min, shear_rate_max, inclusive="both"
        )

        # Draw the complete curve faintly first, then redraw the measurements
        # covered by actual process conditions at full opacity.
        ax.loglog(
            df["shear_rate"][descending].values,
            df["viscosity"][descending].values,
            marker=MARKERS[path.stem],
            color=color,
            alpha=0.25,
        )
        ax.loglog(
            df["shear_rate"][descending & in_process_range].values,
            df["viscosity"][descending & in_process_range].values,
            marker=MARKERS[path.stem],
            color=color,
            label=path.stem,
        )
    ax.set_xlabel("Shear Rate (1/s)")
    ax.set_ylabel("Viscosity (Pa·s)")
    ax.legend()
    return fig


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Plot viscosity data.")
    parser.add_argument("viscosity", type=pathlib.Path, nargs="*", help="csv files")
    parser.add_argument(
        "--pv", type=pathlib.Path, nargs="+", help="Process variable csv files"
    )
    parser.add_argument("-o", "--out", type=pathlib.Path, help="Output image file")
    args = parser.parse_args()
    fig = plot_viscosity(args.viscosity, args.pv)
    if args.out:
        fig.savefig(args.out)
