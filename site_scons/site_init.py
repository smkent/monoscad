import functools
import os
import subprocess
from pathlib import Path
from typing import Sequence, Set

from SCons.Script.SConscript import SConsEnvironment

# Exports for use in SConscript
from model_builder import ModelBuilder  # noqa: F401
from options import GenerateOptions  # noqa: F401


class MainBuilder:
    def __init__(self):
        # Build in parallel by default
        SetOption("num_jobs", os.cpu_count())

    def build(self) -> None:
        for sc in {md / "SConscript" for md in self._model_dirs}:
            env = self._env  # noqa: F841
            SConscript(
                str(sc),
                src_dir=sc.parent,
                variant_dir=sc.parent / "build",
                duplicate=False,
                exports="env",
            )
        env.Alias(
            "images",
            [
                i
                for md in self._model_dirs
                for i in Glob(str(md / "images") + "/*")
            ],
        )
        for alias in {"printables", "zip"}:
            env.Alias(alias, [".", "images"])

    @functools.cached_property
    def _env(self) -> SConsEnvironment:
        env = Environment(
            PREV_REF=ARGUMENTS.get("ref", None),
        )
        self._add_openscad_builder(env)
        return env

    def _openscad_cmd(self, env: SConsEnvironment) -> Sequence[str]:
        executable = ARGUMENTS.get(
            "openscad", os.environ.get("OPENSCAD", "openscad")
        )

        def _openscad_has_features() -> bool:
            help_text = subprocess.run(
                [executable, "--help"],
                check=True,
                capture_output=True,
                text=True,
                env=env["ENV"],
            ).stderr
            return "--enable" in help_text

        cmd = [executable]
        if _openscad_has_features():
            cmd += ["--enable", "fast-csg", "--enable", "manifold"]
        return cmd

    def _add_openscad_builder(self, env: SConsEnvironment) -> None:
        def _add_deps_target(target, source, env):
            target.append("${TARGET.name}.deps")
            return target, source

        cmd = self._openscad_cmd(env)
        env["OPENSCAD"] = cmd[0]
        env["OPENSCAD_FEATURES"] = cmd[1:]
        env["BUILDERS"]["openscad"] = Builder(
            action=(
                "$OPENSCAD $OPENSCAD_FEATURES -m make -o $TARGET -d ${TARGET}.deps"
                + " $SOURCE $OPENSCAD_ARGS"
            ),
            emitter=_add_deps_target,
        )

    @functools.cached_property
    def _model_dirs(self) -> Set[Path]:
        start_dir = Path(
            "."
            if Dir("#").path == GetLaunchDir()
            else Dir(GetLaunchDir()).path
        )
        return {
            Path(Dir(x.parent).path)
            for x in start_dir.glob("**/SConscript")
            if not str(x).startswith("_")
        }
