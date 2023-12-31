import functools
import os
import subprocess
import tempfile
from contextlib import ExitStack
from pathlib import Path
from typing import (Any, Callable, Dict, Iterable, List, Optional, Sequence,
                    Set, Union)
from zipfile import ZipFile

from SCons.Node.FS import File as SConsFile
from SCons.Script import BUILD_TARGETS
from SCons.Script.SConscript import SConsEnvironment

from image_builder import IMAGE_RENDER_SIZE, ImageBuilder, InsetImageBuilder
from utils import openscad_var_args, run

PRINTABLES_TARGETS = {"printables", "zip"}
IMAGES_TARGETS = {"images"} | PRINTABLES_TARGETS
DIST_PRINTABLES_ZIP = "dist-printables.zip"
LIBRARIES_ZIP = "libraries.zip"
IMAGE_TARGETS = {
    "images/readme": "400x300",
    "images/publish": IMAGE_RENDER_SIZE,
}


class ModelBuilder:
    def __init__(self, env: SConsEnvironment):
        self.env = env
        self.build_dir = self.env.Dir(".")
        self.src_dir = self.env.Dir(".").srcdir
        self.src_dir_path = self.src_dir.path
        self.model_dir = self.src_dir_path
        self.publish_images: Set[str] = set()
        self.publish_assets: Set[str] = set()
        self.zip_dirs: Dict[str, str] = {}

    def ref_filter(fn: Callable[..., Any]) -> Callable[..., Any]:
        def _wrapper(self, *args: Any, **kwargs: Any) -> Any:
            if not self._allowed_by_ref_filter:
                return
            fn(self, *args, **kwargs)

        return _wrapper

    def target_filter(
        required_targets: Union[str, Iterable[str]]
    ) -> Callable[..., Any]:
        if isinstance(required_targets, str):
            required_targets = [required_targets]

        def _inner(fn: Callable[..., Any]) -> Callable[..., Any]:
            def _wrapper(self, *args: Any, **kwargs: Any) -> Any:
                if not (
                    self.env.GetOption("clean")
                    or any(t in BUILD_TARGETS for t in required_targets)
                ):
                    return
                fn(self, *args, **kwargs)

            return _wrapper

        return _inner

    @ref_filter
    def add_default_targets(self) -> None:
        self.add_repository_tracked_images()
        self.add_printables_zip_targets()

    def add_repository_tracked_images(self) -> None:
        self.publish_images |= {
            f"{self.src_dir}/{line}"
            for line in run(
                ["git", "ls-files", "--", "images/publish"],
                quiet=True,
                capture_output=True,
                text=True,
                cwd=self.src_dir.get_abspath(),
            ).stdout.splitlines()
        }

    def _source_glob(self, *files: str) -> None:
        return {
            f
            for fn in files
            for f in (
                self.src_dir.glob(fn, strings=True) if "*" in fn else [fn]
            )
        }

    def Source(self, *files: str) -> None:
        return self.Asset(*files, zip_dir="source")

    def Asset(self, *files: str, zip_dir: str) -> None:
        for f in self._source_glob(*files):
            self.publish_assets.add(f)
            self.zip_dirs[f] = zip_dir

    @ref_filter
    def STL(
        self,
        stl_file: str,
        model_file: str,
        stl_vals: Optional[Dict[str, Any]] = None,
        model_dependencies: Optional[Sequence[str]] = None,
        zip_dir: Optional[str] = None,
    ) -> None:
        self.env.openscad(
            target=stl_file,
            source=[model_file] + (model_dependencies or []),
            OPENSCAD_ARGS=" ".join(openscad_var_args(stl_vals)),
        )
        if zip_dir:
            self.zip_dirs[stl_file] = zip_dir

    def make_doc(
        self,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
    ) -> None:
        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            md_file = tdp / "input.md"
            md_text = Path(source[0].path).read_text()
            for rpath, rep_path in [
                ("/_static/", Path(self.env.Dir("#").path) / "_static"),
                (
                    ("../images/readme", "images/readme"),
                    Path(self.src_dir.path) / "images" / "publish",
                ),
            ]:
                rpath_abs = str(rep_path.absolute()) + "/"
                for rp in [rpath] if isinstance(rpath, str) else rpath:
                    md_text = md_text.replace(rp, rpath_abs)
            with open(md_file, "w") as f:
                f.write(md_text)
            cmd = [
                "pandoc",
                "-f",
                "commonmark",
                md_file,
                "-o",
                target[0].path,
                "--table-of-contents",
                "--toc-depth=4",
                "--number-sections",
                "--pdf-engine=xelatex",
            ]
            for pandoc_var in [
                "fontsize=12pt",
                "colorlinks=true",
                "linestretch=1.0",
                (
                    " geometry:"
                    '"top=1.5cm, bottom=2.5cm, left=1.5cm, right=1.5cm"'
                ),
                "papersize=letter",
            ]:
                cmd += ["--variable", pandoc_var]
            run(cmd)

    @ref_filter
    def Document(
        self,
        target: str,
        source: str,
        image_dependencies: Optional[Sequence[str]] = None,
    ) -> None:
        self.env.Command(
            target, [source] + [image_dependencies or []], self.make_doc
        )

    @target_filter(IMAGES_TARGETS)
    def Image(
        self,
        target: str,
        model_file: Union[str, Sequence[str]],
        stl_vals: Optional[Union[List[Dict[str, Any]], Dict[str, Any]]] = None,
        camera: Optional[str] = None,
        view_options: Optional[str] = None,
        delay: int = 75,
        tile: str = "",
        zoom: float = 1,
    ) -> None:
        image_targets = {
            f"{self.src_dir}/{image_path}/{target}": size
            for image_path, size in IMAGE_TARGETS.items()
        }
        self.env.NoClean(
            self.env.Command(
                image_targets.keys(),
                model_file,
                ImageBuilder(
                    stl_vals_list=(
                        [stl_vals]
                        if isinstance(stl_vals, dict)
                        else (stl_vals or [[]])
                    ),
                    image_targets=image_targets,
                    camera=camera,
                    view_options=view_options,
                    delay=delay,
                    tile=tile,
                    zoom=zoom,
                ),
            )
        )
        self.publish_images.add(f"{self.src_dir}/images/publish/{target}")

    @target_filter(IMAGES_TARGETS)
    def InsetImage(
        self,
        target: str,
        background_image: str,
        foreground_image: str,
        gravity: str = "southwest",
        resize: str = "33%",
    ) -> None:
        for image_path, image_size in IMAGE_TARGETS.items():
            target_path = f"{self.src_dir}/{image_path}/{target}"
            self.env.NoClean(
                self.env.Command(
                    target_path,
                    [
                        f"{self.src_dir}/{image_path}/{background_image}",
                        f"{self.src_dir}/{image_path}/{foreground_image}",
                    ],
                    InsetImageBuilder(image_size, resize, gravity),
                )
            )
            self.publish_images.add(target_path)

    @functools.cached_property
    def library_files(self) -> Sequence[SConsFile]:
        def _is_dir_symlink(f: str) -> bool:
            p = Path(str(f))
            if not p.is_symlink():
                return False
            if p.absolute().is_dir():
                return True
            return False

        return [
            lib_file
            for lib_glob in [
                fn.glob("*.scad")
                for fn in self.src_dir.glob("*")
                if _is_dir_symlink(fn)
            ]
            for lib_file in lib_glob
        ]

    @target_filter(PRINTABLES_TARGETS)
    def add_printables_zip_targets(self) -> None:
        sources = [
            self.env.File(f)
            for f in (
                set(self.src_dir.glob("*.scad", strings=True))
                | set(self.build_dir.glob("*.pdf", ondisk=False, strings=True))
                | set(self.build_dir.glob("*.stl", ondisk=False, strings=True))
                | self.publish_images
                | self.publish_assets
            )
        ] + self.library_files
        zip_name = self.model_dir.replace(os.sep, "__")
        fn = f"{self.build_dir}/printables-{zip_name}.zip"
        self.env.Command(fn, sorted(list(sources)), self.make_zip)

    def zip_file_dest(self, source: Union[str, Path]) -> str:
        dest_stripped = self._remove_prefix(
            str(source),
            [str(self.build_dir) + "/", str(self.src_dir) + "/"],
        )
        dest_path = Path(dest_stripped).name
        zip_dir = self.zip_dirs.get(dest_stripped)
        if zip_dir:
            return f"{zip_dir}/" + dest_path
        if dest_stripped.startswith("images"):
            if "readme" in dest_stripped:
                return None
            return "images/" + dest_path
        elif dest_stripped.endswith(".stl"):
            return "stl/" + dest_path
        elif dest_stripped.endswith(".pdf"):
            return "doc/" + dest_path
        return str(dest_stripped)

    def make_zip(
        self,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
    ) -> None:
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
                            self._remove_prefix(
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

    @functools.cached_property
    def _allowed_by_ref_filter(self) -> bool:
        prev_ref = self.env.get("PREV_REF")
        if not prev_ref:
            return True
        try:
            dirs = {
                str(Path(fn).parent)
                for fn in run(
                    ["git", "diff", f"{prev_ref}...@", "--name-only", "--"],
                    quiet=True,
                    capture_output=True,
                    text=True,
                ).stdout.splitlines()
                if fn.endswith(".scad") or fn.endswith("/SConscript")
            }
            if self.model_dir not in dirs:
                return False
            print(
                f"Including model directory {self.model_dir}"
                f" changed since {prev_ref}"
            )
        except subprocess.CalledProcessError as e:
            print(f"Ignoring git diff error: {e}")
            pass
        return True

    @staticmethod
    def _remove_prefix(value: str, prefixes: Union[str, Sequence[str]]) -> str:
        for prefix in [prefixes] if isinstance(prefixes, str) else prefixes:
            if value.startswith(prefix):
                return value[len(prefix) :]  # noqa: E203
        return value
