import functools
import json
import os
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
IMAGE_TARGETS = {
    "images/readme": "400x300",
    "images/publish": "1200x900",
}


def run(
    cmd: list,
    *args: Any,
    quiet: bool = False,
    check: bool = True,
    **kwargs: Any,
) -> Any:
    if not quiet:
        print("+", " ".join([str(c) for c in cmd]), file=sys.stderr)
    return subprocess.run(cmd, *args, check=check, **kwargs)


def remove_prefix(value: str, prefixes: Union[str, Sequence[str]]) -> str:
    for prefix in [prefixes] if isinstance(prefixes, str) else prefixes:
        if value.startswith(prefix):
            return value[len(prefix) :]
    return value


def openscad_var_args(stl_vars, vals_raw, for_subprocess: bool = False):
    def _val_args(k, v):
        if isinstance(v, str):
            v = f'"{v}"' if for_subprocess else f"'\"{v}\"'"
        return ["-D", f"{k}={v}"]

    vals = {k: v for k, v in zip(stl_vars, vals_raw)}
    return [arg for k, v in vals.items() for arg in _val_args(k, v)]


class ModelBuilder:
    def __init__(self, env):
        self.env = env
        self.build_dir = Dir(".")
        self.common_build_dir = Dir("..")
        self.src_dir = Dir(".").srcdir
        self.src_dir_path = Path(str(self.src_dir))
        self.model_dir = self.src_dir_path.name

    def make_all(self):
        try:
            if not self.filter_by_ref:
                return
        except subprocess.CalledProcessError as e:
            print("EXCEPTION", str(e))
            print("OUT", e.stdout)
            print("ERR", e.stderr)
            raise
        self.add_image_targets()
        self.add_stl_targets()
        if PRINTABLES_TARGET in BUILD_TARGETS:
            self.add_printables_zip_targets()

    @functools.cached_property
    def filter_by_ref(self):
        prev_ref = self.env.get("PREV_REF")
        if not prev_ref:
            return True
        try:
            dirs = {
                fn.split(os.sep)[0]
                for fn in run(
                    ["git", "diff", f"{prev_ref}...@", "--name-only", "--"],
                    quiet=True,
                    capture_output=True,
                    text=True,
                ).stdout.splitlines()
                if fn.endswith(".scad")
            }
            if self.src_dir_path.name not in dirs:
                return False
            print(
                f"Including model directory {self.model_dir}"
                f" changed since {prev_ref}"
            )
        except subprocess.CalledProcessError as e:
            print(f"Ignoring git diff error: {e}")
            pass
        return True

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
                stl_args = " ".join(
                    openscad_var_args(model_opts.get("vars", []), stl_vals_raw)
                )
                stl_data[model_file][stl_file] = stl_args
        return stl_data

    @functools.cached_property
    def images_data(self):
        images_config = self.config.get("images", {})
        data = {}
        for image_name, images_config in images_config.items():
            image_args = []
            for stl_raw in images_config.get("values", [[]]):
                image_args.append(
                    openscad_var_args(
                        images_config.get("vars", []),
                        stl_raw,
                        for_subprocess=True,
                    )
                )
            data[image_name] = {
                "camera": images_config.get("camera"),
                "colorscheme": images_config.get("colorscheme", "DeepOcean"),
                "delay": images_config.get("delay", 75),
                "imgsize": images_config.get("imgsize", "1200,900"),
                "model": images_config["model"],
                "view_options": images_config.get("view_options", ""),
                "args": image_args,
            }
        return data

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
    def image_files(self):
        return list(self.src_dir.glob("images/publish/*"))

    def add_stl_targets(self):
        for model_file, model_stl_files in self.stl_data.items():
            for stl_file, stl_args in model_stl_files.items():
                self.env.openscad(
                    target=stl_file, source=model_file, OPENSCAD_ARGS=stl_args
                )

    def add_image_targets(self):
        if not self.images_data:
            return
        image_targets = [
            {
                f"{self.src_dir}/{image_path}/{image_name}": size
                for image_path, size in IMAGE_TARGETS.items()
            }
            for image_name in self.images_data.keys()
        ]
        for image_targets_set in image_targets:
            self.env.NoClean(
                self.env.Command(
                    image_targets_set.keys(),
                    self.model_files,
                    self.make_image,
                )
            )

    def add_printables_zip_targets(self):
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

    def make_image(self, target, source, env):
        def _enum_targets():
            for t in target:
                yield (
                    t,
                    next(
                        sz
                        for dir_chunk, sz in IMAGE_TARGETS.items()
                        if dir_chunk in str(t)
                    ),
                )

        def _render_png(image_target, image_data, idx, size=None):
            render_args = image_data["args"][idx]
            if image_data.get("camera"):
                render_args = [
                    f"--camera={image_data['camera']}"
                ] + render_args
            if image_data.get("view_options"):
                render_args = [
                    f"--view={image_data['view_options']}"
                ] + render_args
            run(
                [
                    self.env["OPENSCAD"],
                    self.src_dir_path / image_data["model"],
                    f"--colorscheme={image_data['colorscheme']}",
                    f"--imgsize={size or image_data['imgsize']}",
                    "-o",
                    str(image_target),
                ]
                + render_args,
            )

        image_data = self.images_data[target[0].name]
        image_type = target[0].suffix
        if image_type == ".png":
            for image_target, size in _enum_targets():
                _render_png(
                    image_target, image_data, 0, size.replace("x", ",")
                )
        elif image_type == ".gif":
            with tempfile.TemporaryDirectory() as td:
                tdp = Path(td)
                # Render frames
                for i, render_args in enumerate(image_data["args"]):
                    _render_png(tdp / f"image_{i:05d}.png", image_data, i)
                for image_target, size in _enum_targets():
                    # Render gif
                    run(
                        (
                            [
                                "convert",
                                "-delay",
                                str(image_data["delay"]),
                                "-loop",
                                "0",
                                "-resize",
                                size,
                            ]
                            + sorted(list(tdp.glob("*.png")))
                            + [str(image_target)]
                        ),
                    )
