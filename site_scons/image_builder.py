import tempfile
from itertools import cycle
from math import ceil
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence

from SCons.Node.FS import File as SConsFile
from SCons.Script.SConscript import SConsEnvironment

from utils import openscad_var_args, run

IMAGE_RENDER_SIZE = "1200x900"


class ImageBuilder:
    @classmethod
    def render_image(
        cls,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
        image_targets: Optional[Dict[str, str]] = None,
        stl_vals_list: Optional[Sequence[Dict[str, Any]]] = None,
        delay: int = 75,
        camera: Optional[str] = None,
        view_options: Optional[str] = None,
        tile: str = "",
    ) -> None:
        def _render_single_image(
            image_target: str,
            model_file: str,
            stl_vals: Dict[str, Any],
            size=None,
        ) -> None:
            render_args = openscad_var_args(stl_vals, for_subprocess=True)
            if camera:
                render_args += [f"--camera={camera}"]
            if view_options:
                render_args += [f"--view={view_options}"]
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

        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            # Render frames
            frames: List[str] = []
            for i, (frame_stl_vals, frame_model_file) in enumerate(
                zip(stl_vals_list, cycle(source))
            ):
                fn = tdp / f"image_{i:05d}.png"
                frames.append(fn)
                _render_single_image(
                    fn,
                    frame_model_file.path,
                    frame_stl_vals or {},
                    IMAGE_RENDER_SIZE.replace("x", ","),
                )
            if len(frames) > 1 and target[0].suffix != ".gif":
                if not tile:
                    row_len = ceil(len(frames) / 2)
                    tile = f"x{row_len}"
                montage_fn = str(tdp / "montage") + target[0].suffix
                montage_cmd = [
                    "montage",
                    "-background",
                    "#333",
                    "-border",
                    0,
                    "-geometry",
                    "+0+0",
                    "-tile",
                    tile,
                ]
                run(montage_cmd + frames + [montage_fn])
                frames = [montage_fn]
            for tt in target:
                size_arg = "x" + image_targets[tt.abspath].split("x")[1]
                cmd = ["convert", "-resize", size_arg]
                if target[0].suffix == ".gif":
                    cmd += ["-loop", "0", "-delay", str(delay)]
                run(cmd + frames + [tt.path])

    @classmethod
    def render_inset_image(
        cls,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
        image_size: str,
        resize: str,
        gravity: str,
    ) -> None:
        background_image, foreground_image = source
        cmd = [
            "convert",
            "(",
            background_image.path,
            "-resize",
            image_size,
            ")",
            "null:",
            "(",
            foreground_image.path,
            "-coalesce",
            "-resize",
            resize,
            "+repage",
            "-bordercolor",
            "#ccc",
            "-border",
            "2x2",
            ")",
            "-gravity",
            gravity,
            "-geometry",
            "+0+0",
            "-layers",
            "composite",
            "-layers",
            "optimizeplus",
            target[0].path,
        ]
        run(cmd)
