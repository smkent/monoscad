import os
from pathlib import Path

# Build in parallel by default
SetOption("num_jobs", os.cpu_count())

openscad_path = ARGUMENTS.get(
    "openscad", os.environ.get("OPENSCAD", "openscad")
)

env = Environment(
    OPENSCAD=openscad_path,
    BUILDERS={"openscad": openscad_builder(openscad_path)},
    PREV_REF=ARGUMENTS.get("ref", None),
)

for sc in Glob("*/SConscript", strings=True):
    SConscript(
        sc,
        src_dir=Path(sc).parent,
        variant_dir="build" / Path(sc).parent,
        duplicate=False,
        exports="env",
    )

env.Default("build/")
env.Alias("images", Glob("*/images"))
env.Alias("printables", ["build/", "images"])

# vim: ft=python
