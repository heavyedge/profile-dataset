import argparse
import pathlib

import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from mpl_toolkits.axes_grid1.inset_locator import inset_axes


def plot_ca(ca_files, labels, ca_img=None):
    fig, ax = plt.subplots()

    for path, label in zip(ca_files, labels):
        df = pd.read_csv(path, index_col=[0, 1])

        all_t, all_y = [], []
        for _, subdf in df.groupby("file"):
            t = pd.to_timedelta(subdf["Rec. Time"]).dt.total_seconds()
            t = t - t.iloc[0]
            all_t.append(t.values)
            all_y.append(subdf["Contact Angle(Average)[degree]"].values)

        t_ref = np.unique(np.concatenate(all_t))
        y_interp = np.array(
            [
                np.interp(t_ref, t, y, left=np.nan, right=np.nan)
                for t, y in zip(all_t, all_y)
            ]
        )
        y_mean = np.nanmean(y_interp, axis=0)
        y_std = np.nanstd(y_interp, axis=0)

        ax.errorbar(
            t_ref,
            y_mean,
            yerr=y_std,
            fmt="-",
            label=label,
            capsize=3,
            elinewidth=0.8,
            errorevery=max(1, len(t_ref) // 20),
        )
        ax.text(
            0.99,
            0.01,
            "Error bars: ±1σ",
            transform=ax.transAxes,
            ha="right",
            va="bottom",
            color="gray",
        )
    plt.xlabel("Time (s)")
    plt.ylabel("Contact Angle (degree)")
    plt.legend()

    if ca_img:
        img = mpimg.imread(ca_img)
        axins = inset_axes(ax, width="30%", height="30%", loc="upper right")
        axins.imshow(img)
        axins.axis("off")

    return fig


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Write contact angle data.")
    parser.add_argument("ca", type=pathlib.Path, nargs="*", help="csv files")
    parser.add_argument("--slurries", nargs="*", help="Slurry names")
    parser.add_argument("--img", type=pathlib.Path, help="Example image file")
    parser.add_argument("-o", "--out", type=pathlib.Path, help="Output image file")
    args = parser.parse_args()
    fig = plot_ca(args.ca, args.slurries, args.img)
    if args.out:
        fig.savefig(args.out)
