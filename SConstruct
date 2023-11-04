import os
from pathlib import Path


def add_deps_target(target, source, env):
    target.append("${TARGET.name}.deps")
    return target, source


# Build in parallel by default
SetOption("num_jobs", os.cpu_count())

env = Environment(
    OPENSCAD=ARGUMENTS.get("openscad", os.environ.get("OPENSCAD", "openscad")),
    BUILDERS={
        "openscad": Builder(
            action=(
                "$OPENSCAD -m make"
                " -o $TARGET -d ${TARGET}.deps"
                " $SOURCES"
                " $OPENSCAD_ARGS"
            ),
            emitter=add_deps_target,
        ),
    },
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
