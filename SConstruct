import os
from pathlib import Path


def add_deps_target(target, source, env):
    target.append("${TARGET.name}.deps")
    return target, source


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
        )
    },
)

for sc in Glob("*/SConscript", strings=True):
    SConscript(
        sc,
        src_dir=Path(sc).parent,
        variant_dir=Path(sc).parent / "build",
        duplicate=False,
        exports="env",
    )
