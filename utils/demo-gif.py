#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

MODEL_CONFIG_FILE_NAME = "config.json"
MODEL_CONFIG_GIF_OBJECT = "gif"
MODEL_IMAGES_DIR_NAME = "images"


class DemoGIFGenerator:
    def __init__(self):
        ap = argparse.ArgumentParser(description="Model demo GIF generator")
        ap.add_argument(
            "model_dir",
            type=self._dir_path,
            metavar="directory",
            help="Model subdirectory",
        )
        ap.add_argument(
            "-c",
            "--colorscheme",
            dest="color_scheme",
            default="DeepOcean",
            metavar="color-scheme",
            help="OpenSCAD color scheme name (default: %(default)s)",
        )
        ap.add_argument(
            "-d",
            "--delay",
            dest="delay",
            type=int,
            default=75,
            metavar="delay",
            help="Delay, if not configured in model (default: %(default)s)",
        )
        ap.add_argument(
            "-s",
            "--size",
            dest="size",
            default="1200x900",
            metavar="dimensions",
            help="Size for published model (default: %(default)s)",
        )
        ap.add_argument(
            "-rs",
            "--readme-size",
            dest="readme_size",
            default="400x300",
            metavar="dimensions",
            help="Size for README (default: %(default)s)",
        )
        ap.add_argument(
            "-o",
            "--output",
            dest="output",
            default="demo.gif",
            metavar="filename.gif",
            help=(
                "Output file name within model's images/ subdirectory"
                " (default: %(default)s)"
            ),
        )

        self.args = ap.parse_args()
        try:
            self.config = json.loads(
                (self.args.model_dir / MODEL_CONFIG_FILE_NAME).read_text()
            )[MODEL_CONFIG_GIF_OBJECT]
        except KeyError as e:
            raise Exception(
                f'No "{MODEL_CONFIG_GIF_OBJECT}" section'
                " in model configuration"
            ) from e

    def main(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            self._render_frames(tdp)
            self._render_gif(tdp)

    def _render_frames(self, tdp: Path) -> None:
        required_config_keys = ["model", "camera", "vars", "values"]
        for required_config_key in required_config_keys:
            if required_config_key not in self.config:
                raise Exception(
                    "Missing one or more required properties within"
                    f" gif config object: {', '.join(required_config_keys)}"
                )
        for i, value_set in enumerate(self.config["values"]):
            render_args = []
            for var_name, var_value in zip(self.config["vars"], value_set):
                render_args += ["-D", f"{var_name}={var_value}"]
            imgsize = self.args.size.replace("x", ",")
            cmd = [
                "openscad",
                self.args.model_dir / self.config["model"],
                f"--colorscheme={self.args.color_scheme}",
                f"--camera={self.config['camera']}",
                f"--imgsize={imgsize}",
                "-o",
                tdp / f"image_{i:05d}.png",
            ] + render_args
            self._run(cmd, check=True)

    def _render_gif(self, tdp: Path) -> None:
        images_dir = self.args.model_dir / MODEL_IMAGES_DIR_NAME
        images_dir.mkdir(exist_ok=True)
        for size, subdir in (
            (self.args.readme_size, "readme"),
            (self.args.size, "publish"),
        ):
            subdir_path = images_dir / subdir
            subdir_path.mkdir(exist_ok=True)
            cmd = (
                [
                    "convert",
                    "-delay",
                    str(self.config.get("delay", self.args.delay)),
                    "-loop",
                    "0",
                    "-resize",
                    size,
                ]
                + sorted(list(tdp.glob("*.png")))
                + [subdir_path / self.args.output]
            )
            self._run(cmd, check=True)

    @staticmethod
    def _run(cmd: list, *args: Any, **kwargs: Any) -> Any:
        print("+", " ".join([str(c) for c in cmd]), file=sys.stderr)
        subprocess.run(cmd, *args, **kwargs)

    @staticmethod
    def _dir_path(path: str) -> Path:
        ppath = Path(path)
        if not ppath.is_dir():
            raise argparse.ArgumentTypeError(f"{path} is not a directory")
        if not (ppath / MODEL_CONFIG_FILE_NAME).is_file():
            raise argparse.ArgumentTypeError(
                f"{path} does not contain {MODEL_CONFIG_FILE_NAME}"
            )
        return ppath


if __name__ == "__main__":
    DemoGIFGenerator().main()
