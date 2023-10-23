import functools
import json
import subprocess
import sys
import tempfile
from contextlib import ExitStack
from pathlib import Path
from typing import Any, Sequence, Union
from zipfile import ZipFile

PRINTABLES_TARGET = "printables"
DIST_PRINTABLES_ZIP = "dist-printables.zip"
LIBRARIES_ZIP = "libraries.zip"
GIF_TARGETS = {
    "images/readme/demo.gif": "400x300",
    "images/publish/demo.gif": "1200x900",
}


def run(cmd: list, *args: Any, check: bool = True, **kwargs: Any) -> Any:
    print("+", " ".join([str(c) for c in cmd]), file=sys.stderr)
    subprocess.run(cmd, *args, check=check, **kwargs)


def remove_prefix(value: str, prefixes: Union[str, Sequence[str]]) -> str:
    for prefix in [prefixes] if isinstance(prefixes, str) else prefixes:
        if value.startswith(prefix):
            return value[len(prefix) :]
    return value


class ModelBuilder:
    def __init__(self, env):
        self.env = env
        self.build_dir = Dir(".")
        self.common_build_dir = Dir("..")
        self.src_dir = Dir(".").srcdir
        self.src_dir_path = Path(str(self.src_dir))
        self.model_dir = self.src_dir_path.name

    def make_all(self):
        self.add_gif_targets()
        self.add_stl_targets()
        if PRINTABLES_TARGET in BUILD_TARGETS:
            self.add_dist_zip()

    @functools.cached_property
    def config(self):
        try:
            with open(self.src_dir_path / "config.json") as f:
                return json.load(f)
        except FileNotFoundError:
            return {}

    @functools.cached_property
    def model_files(self):
        return list(self.stl_data.keys()) or self.src_dir.glob("*.scad")

    @functools.cached_property
    def stl_data(self):
        stl_data = {}
        for model_file, model_opts in self.config.get("dist", {}).items():
            stl_data[model_file] = {}
            for stl_file, stl_vals_raw in model_opts.get("stl", {}).items():
                stl_vals = {
                    k: v for k, v in zip(model_opts["vars"], stl_vals_raw)
                }
                stl_args = " ".join(
                    [f"-D {k}={v}" for k, v in stl_vals.items()]
                )
                stl_data[model_file][stl_file] = stl_args
        return stl_data

    @functools.cached_property
    def gif_data(self):
        gif_config = self.config.get("gif", {})
        if not gif_config:
            return {}
        gif_data = {
            "args": [],
            "camera": gif_config["camera"],
            "colorscheme": gif_config.get("colorscheme", "DeepOcean"),
            "delay": gif_config.get("delay", 75),
            "imgsize": gif_config.get("imgsize", "1200,900"),
            "model": gif_config["model"],
        }
        for stl_raw in gif_config["values"]:
            stl_vals = {k: v for k, v in zip(gif_config["vars"], stl_raw)}
            thisdata = []
            for k, v in stl_vals.items():
                thisdata.append("-D")
                thisdata.append(f"{k}={v}")
            gif_data["args"].append(thisdata)
        return gif_data

    @functools.cached_property
    def stl_targets(self):
        return [
            stl_file
            for model_stl_files in self.stl_data.values()
            for stl_file in model_stl_files.keys()
        ]

    @functools.cached_property
    def library_files(self):
        return [
            lib_file
            for lib_glob in [
                fn.glob("*.scad")
                for fn in self.src_dir.glob("*")
                if Path(str(fn)).is_symlink()
            ]
            for lib_file in lib_glob
        ]

    @functools.cached_property
    def gif_targets(self):
        if "gif" in self.config:
            return [
                str(self.src_dir_path / gif_path)
                for gif_path in GIF_TARGETS.keys()
            ]
        return None

    @functools.cached_property
    def image_files(self):
        return list(self.src_dir.glob("images/publish/*"))

    def add_stl_targets(self):
        for model_file, model_stl_files in self.stl_data.items():
            for stl_file, stl_args in model_stl_files.items():
                self.env.openscad(
                    target=stl_file, source=model_file, OPENSCAD_ARGS=stl_args
                )

    def add_gif_targets(self):
        if self.gif_targets:
            if self.env["CI"]:
                for target in self.gif_targets:
                    if not Path(target).exists():
                        raise Exception(f"Missing: {target}")
                return
            self.env.NoClean(
                self.env.Command(
                    self.gif_targets, self.model_files, self.make_gif
                )
            )

    def add_dist_zip(self):
        sources = (
            self.model_files
            + self.stl_targets
            + self.image_files
            + self.library_files
        )
        self.env.Command(
            f"{self.common_build_dir}/printables-{self.model_dir}.zip",
            sources,
            self.make_zip,
        )

    def zip_file_dest(self, source):
        dest_stripped = remove_prefix(
            str(source),
            [str(self.build_dir) + "/", str(self.src_dir) + "/"],
        )
        if dest_stripped.startswith("images"):
            if "readme" in dest_stripped:
                return None
            return "images/" + Path(dest_stripped).name
        elif dest_stripped.endswith(".stl"):
            return "stl/" + Path(dest_stripped).name
        return str(dest_stripped)

    def make_zip(self, target, source, env):
        with ExitStack() as stack:
            tdp = None
            libraries_zip = None
            if self.library_files:
                tdp = Path(stack.enter_context(tempfile.TemporaryDirectory()))
                libraries_zip = tdp / LIBRARIES_ZIP
                with ZipFile(str(libraries_zip), mode="w") as z:
                    for lf in self.library_files:
                        z.write(
                            str(lf),
                            remove_prefix(
                                str(lf),
                                [
                                    str(self.build_dir) + "/",
                                    str(self.src_dir) + "/",
                                ],
                            ),
                        )
            with ZipFile(str(target[0]), mode="w") as z:
                if libraries_zip:
                    z.write(libraries_zip, LIBRARIES_ZIP)
                for ss in source:
                    if ss in self.library_files:
                        continue
                    zdest = self.zip_file_dest(ss)
                    if not zdest:
                        continue
                    z.write(str(ss), zdest)

    def make_gif(self, target, source, env):
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            # Render frames
            for i, render_args in enumerate(self.gif_data["args"]):
                run(
                    [
                        self.env["OPENSCAD"],
                        self.src_dir_path / self.gif_data["model"],
                        f"--colorscheme={self.gif_data['colorscheme']}",
                        f"--camera={self.gif_data['camera']}",
                        f"--imgsize={self.gif_data['imgsize']}",
                        "-o",
                        tdp / f"image_{i:05d}.png",
                    ]
                    + render_args,
                )
            for this_target in target:
                # Render gif
                run(
                    (
                        [
                            "convert",
                            "-delay",
                            str(self.gif_data["delay"]),
                            "-loop",
                            "0",
                            "-resize",
                            next(
                                sz
                                for suffix, sz in GIF_TARGETS.items()
                                if str(this_target).endswith(suffix)
                            ),
                        ]
                        + sorted(list(tdp.glob("*.png")))
                        + [str(this_target)]
                    ),
                )
