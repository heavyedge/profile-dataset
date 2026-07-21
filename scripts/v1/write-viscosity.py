"""Combine rheometer shear-sweep CSV files into a viscosity dataset."""

import argparse
import csv
import pathlib

parser = argparse.ArgumentParser(description="Write rheometer shear-sweep data.")
parser.add_argument(
    "viscosities",
    type=pathlib.Path,
    nargs="+",
    help="Shear-sweep CSV files, stored below ascending/ or descending/.",
)
parser.add_argument(
    "-o", "--out", type=pathlib.Path, required=True, help="Output CSV file"
)
args = parser.parse_args()


SOURCE_COLUMNS = {"shear rate": "shear_rate", "viscosity": "viscosity"}


def sweep_direction(path):
    """Return the sweep direction encoded by a source file's parent directory."""
    direction = path.parent.name.lower()
    if direction not in {"ascending", "descending"}:
        raise ValueError(
            f"Cannot determine sweep direction for {path}; "
            "its parent directory must be ascending or descending."
        )
    return direction


def load_sweep(path):
    """Load one sweep and attach its direction while preserving source row order."""
    # utf-8-sig removes the BOM written by the rheometer export software.
    with open(path, encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source)
        missing = set(SOURCE_COLUMNS).difference(reader.fieldnames or [])
        if missing:
            raise ValueError(
                f"{path} is missing required column(s): {', '.join(sorted(missing))}"
            )

        rows = []
        for row_number, row in enumerate(reader, start=2):
            output_row = {
                output_column: row[source_column]
                for source_column, output_column in SOURCE_COLUMNS.items()
            }
            for column, value in output_row.items():
                try:
                    float(value)
                except (TypeError, ValueError) as error:
                    raise ValueError(
                        f"{row_number} has a non-numeric {column!r} value: {value!r}"
                    ) from error
            output_row["sweep_direction"] = sweep_direction(path)
            rows.append(output_row)
    return rows


rows = [row for path in args.viscosities for row in load_sweep(path)]
fieldnames = [*SOURCE_COLUMNS.values(), "sweep_direction"]
with open(args.out, "w", encoding="utf-8", newline="") as output:
    writer = csv.DictWriter(output, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
