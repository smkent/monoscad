#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any
from zipfile import ZipFile

DIST_FILE_NAME = "dist.zip"
DIST_FILE_NAME_FORMAT = "dist-{model_dir}.zip"
DIST_LIBRARIES_FILE_NAME = "libraries.zip"
MODEL_CONFIG_FILE_NAME = "config.json"
MODEL_CONFIG_DIST_OBJECT = "dist"
MODEL_IMAGES_DIR_NAME = "images"


class DistGenerator:
    def __init__(self):
        ap = argparse.ArgumentParser(description="Dist zip file generator")
        ap.add_argument(
            "model_dir",
            type=self._dir_path,
            metavar="directory",
            help="Model subdirectory",
        )
        self.args = ap.parse_args()
        try:
            self.config = json.loads(
                (self.args.model_dir / MODEL_CONFIG_FILE_NAME).read_text()
            ).get(MODEL_CONFIG_DIST_OBJECT, {})
        except FileNotFoundError:
            self.config = {}

    def main(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            self._render_stl(tdp)
            self._build_zip(tdp)

    def _render_stl(self, tdp: Path) -> None:
        required_config_keys = ["model", "vars", "values"]
        for required_config_key in required_config_keys:
            if required_config_key not in self.config:
                return None
        stl_dir = tdp / "stl"
        stl_dir.mkdir(exist_ok=True)
        for i, value_set in enumerate(self.config["values"]):
            render_args = []
            output_file = value_set.pop(0)
            for var_name, var_value in zip(self.config["vars"], value_set):
                render_args += ["-D", f"{var_name}={var_value}"]
            cmd = [
                "openscad",
                self.args.model_dir / self.config["model"],
                "-o",
                stl_dir / output_file,
            ] + render_args
            self._run(cmd, check=True)

    def _build_zip(self, tdp: Path) -> None:
        # Collect model and library .scad files
        model_files: list[tuple[Path, str]] = []
        library_files: list[Path] = []
        for p in sorted(self.args.model_dir.glob("*")):
            if p.is_file() and p.suffix == ".scad":
                model_files.append((p, p.name))
            elif p.is_symlink():
                for library_file in p.rglob("*.scad"):
                    library_files.append(library_file)
        # Collect images
        for p in sorted(
            (self.args.model_dir / "images" / "publish").glob("*")
        ):
            if p.is_file():
                model_files.append((p, f"images/{p.name}"))
        # Collect rendered STL files
        for p in sorted((tdp / "stl").glob("*")):
            if p.is_file():
                model_files.append((p, f"stl/{p.name}"))
        # Zip library files
        with ZipFile(tdp / DIST_LIBRARIES_FILE_NAME, mode="w") as z:
            for library_file in library_files:
                z.write(
                    library_file,
                    self._remove_prefix(
                        str(library_file), self.args.model_dir.name + "/"
                    ),
                )
        # Zip model files and images
        with ZipFile(tdp / DIST_FILE_NAME, mode="w") as z:
            if (tdp / DIST_LIBRARIES_FILE_NAME).is_file():
                z.write(
                    tdp / DIST_LIBRARIES_FILE_NAME, DIST_LIBRARIES_FILE_NAME
                )
            for model_file, dest_file_name in model_files:
                z.write(model_file, dest_file_name)
        dest_file_name = DIST_FILE_NAME_FORMAT.format(
            model_dir=self.args.model_dir.name
        )
        shutil.move(tdp / DIST_FILE_NAME, dest_file_name)
        print(f"Created {dest_file_name}")

    @staticmethod
    def _run(cmd: list, *args: Any, **kwargs: Any) -> Any:
        print("+", " ".join([str(c) for c in cmd]), file=sys.stderr)
        subprocess.run(cmd, *args, **kwargs)

    @staticmethod
    def _remove_prefix(value: str, prefix: str) -> str:
        if value.startswith(prefix):
            return value[len(prefix) :]
        return value

    @staticmethod
    def _dir_path(path: str) -> Path:
        ppath = Path(path)
        if not ppath.is_dir():
            raise argparse.ArgumentTypeError(f"{path} is not a directory")
        return ppath


if __name__ == "__main__":
    DistGenerator().main()
