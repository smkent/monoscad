import functools
import os
import subprocess
from pathlib import Path
from typing import Sequence, Set

from SCons.Builder import Builder
from SCons.Defaults import DefaultEnvironment
from SCons.Script import ARGUMENTS
from SCons.Script.SConscript import SConsEnvironment


class MainBuilder:
    def __init__(self):
        # Build in parallel by default
        self._default_env.SetOption("num_jobs", os.cpu_count())

    @functools.cached_property
    def _default_env(self) -> SConsEnvironment:
        return DefaultEnvironment()

    def build(self) -> None:
        env = self._build_env  # noqa: F841
        for sc in {md / "SConscript" for md in self._model_dirs}:
            self._default_env.SConscript(
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
                for i in self._default_env.Glob(str(md / "images") + "/*")
            ],
        )
        for alias in {"printables", "zip"}:
            env.Alias(alias, [".", "images"])

    @functools.cached_property
    def _build_env(self) -> SConsEnvironment:
        env = self._default_env.Environment(
            PREV_REF=ARGUMENTS.get("ref", None)
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
                "$OPENSCAD"
                " $OPENSCAD_FEATURES"
                " -m make"
                " -o $TARGET"
                " -d ${TARGET}.deps"
                " $SOURCE"
                " $OPENSCAD_ARGS"
            ),
            emitter=_add_deps_target,
        )

    @functools.cached_property
    def _model_dirs(self) -> Set[Path]:
        start_dir = Path(
            "."
            if self._default_env.Dir("#").path
            == self._default_env.GetLaunchDir()
            else self._default_env.Dir(self._default_env.GetLaunchDir()).path
        )
        return {
            Path(self._default_env.Dir(x.parent).path)
            for x in start_dir.glob("**/SConscript")
            if not str(x).startswith("_")
        }
