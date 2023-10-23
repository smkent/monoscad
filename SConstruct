import os
from pathlib import Path


def add_deps_target(target, source, env):
    target.append("${TARGET.name}.deps")
    return target, source


env = Environment(
    CI=os.environ.get("CI", False),
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
        )
    },
)

env.Alias("printables", ".")

for sc in Glob("*/SConscript", strings=True):
    SConscript(
        sc,
        src_dir=Path(sc).parent,
        variant_dir="build" / Path(sc).parent,
        duplicate=False,
        exports="env",
    )
