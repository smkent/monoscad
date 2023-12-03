import functools
import tempfile
from dataclasses import dataclass, field
from itertools import cycle
from math import ceil
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence

from SCons.Node.FS import File as SConsFile
from SCons.Script.SConscript import SConsEnvironment

from utils import openscad_var_args, run

IMAGE_RENDER_SIZE = "1200x900"


@dataclass
class ImageBuilder:
    image_targets: Optional[Dict[str, str]] = None
    stl_vals_list: Optional[Sequence[Dict[str, Any]]] = None
    delay: int = 75
    camera: Optional[str] = None
    view_options: Optional[str] = None
    tile: str = ""
    zoom: float = 1

    frames: List[str] = field(repr=False, init=False, default_factory=list)

    def __call__(
        self,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
    ) -> None:
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            self.render_frames(tdp, source, env)
            if len(self.frames) > 1 and target[0].suffix != ".gif":
                self.render_montage(tdp, target[0].suffix)
            for tt in target:
                self.finish_image(tt)

    @functools.cached_property
    def target_size(self) -> str:
        return [int(d) for d in IMAGE_RENDER_SIZE.split("x")]

    @functools.cached_property
    def render_size(self) -> str:
        return [int(d * self.zoom) for d in self.target_size]

    @functools.cached_property
    def crop_values(self) -> str:
        offset = [
            int((self.render_size[0] - self.target_size[0]) / 2),
            int((self.render_size[1] - self.target_size[1]) / 2),
        ]
        return "+".join(
            ["x".join(map(str, self.target_size)), "+".join(map(str, offset))]
        )

    def finish_image(self, target: SConsFile) -> None:
        size_arg = "x" + self.image_targets[target.abspath].split("x")[1]
        cmd = ["convert", "-resize", size_arg]
        if target.suffix == ".gif":
            cmd += ["-loop", "0", "-delay", str(self.delay)]
        run(cmd + self.frames + [target.path])

    def render_montage(self, tdp: Path, suffix: str) -> str:
        if not self.tile:
            row_len = ceil(len(self.frames) / 2)
            self.tile = f"x{row_len}"
        montage_fn = str(tdp / "montage") + suffix
        montage_cmd = [
            "montage",
            "-background",
            "#333",
            "-border",
            0,
            "-geometry",
            "+0+0",
            "-tile",
            self.tile,
        ]
        run(montage_cmd + self.frames + [montage_fn])
        self.frames = [montage_fn]

    def render_frames(
        self, tdp: Path, source: Sequence[SConsFile], env: SConsEnvironment
    ) -> None:
        for i, (frame_stl_vals, frame_model_file) in enumerate(
            zip(self.stl_vals_list, cycle(source))
        ):
            fn = tdp / f"image_{i:05d}.png"
            self.render_frame(
                env, fn, frame_model_file.path, frame_stl_vals or {}
            )
            self.frames.append(fn)

    def render_frame(
        self,
        env: SConsEnvironment,
        image_target: Path,
        model_file: str,
        stl_vals: Dict[str, Any],
    ) -> None:
        size = ",".join(map(str, self.render_size))
        render_args = openscad_var_args(stl_vals, for_subprocess=True)
        if self.camera:
            render_args += [f"--camera={self.camera}"]
        if self.view_options:
            render_args += [f"--view={self.view_options}"]
        run(
            [
                env["OPENSCAD"],
                model_file,
                f"--colorscheme={'DeepOcean'}",
                f"--imgsize={size}",
                "-o",
                str(image_target),
            ]
            + env["OPENSCAD_FEATURES"]
            + render_args
        )
        if self.render_size != self.target_size:
            self.crop_frame(image_target)

    def crop_frame(self, image_target: Path) -> None:
        source_fn = (
            Path(image_target).parent
            / f"{image_target.stem}_source{image_target.suffix}"
        )
        image_target.rename(source_fn)
        run(
            [
                "convert",
                source_fn,
                "-crop",
                self.crop_values,
                "+repage",
                image_target,
            ]
        )


@dataclass
class InsetImageBuilder:
    image_size: str
    resize: str
    gravity: str

    def __call__(
        self,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
    ) -> None:
        background_image, foreground_image = source
        cmd = [
            "convert",
            "(",
            background_image.path,
            "-resize",
            self.image_size,
            ")",
            "null:",
            "(",
            foreground_image.path,
            "-coalesce",
            "-resize",
            self.resize,
            "+repage",
            "-bordercolor",
            "#ccc",
            "-border",
            "2x2",
            ")",
            "-gravity",
            self.gravity,
            "-geometry",
            "+0+0",
            "-layers",
            "composite",
            "-layers",
            "optimizeplus",
            target[0].path,
        ]
        run(cmd)
