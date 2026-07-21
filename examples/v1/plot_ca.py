import argparse
import pathlib

import matplotlib.pyplot as plt


def plot_ca():
    fig, ax = plt.subplots()
    ax.plot([1, 2, 3], [4, 5, 6])

    return fig


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Write contact angle data.")
    parser.add_argument("-o", "--out", type=pathlib.Path, help="Output image file")
    args = parser.parse_args()
    fig = plot_ca()
    if args.out:
        fig.savefig(args.out)
