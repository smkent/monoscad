import functools
import os
import subprocess
import sys
import tempfile
from contextlib import ExitStack
from math import ceil
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Sequence, Set, Union
from zipfile import ZipFile

from SCons.Node.FS import File as SConsFile
from SCons.Script.SConscript import SConsEnvironment

PRINTABLES_TARGET = "printables"
DIST_PRINTABLES_ZIP = "dist-printables.zip"
LIBRARIES_ZIP = "libraries.zip"
IMAGE_RENDER_SIZE = "1200x900"
IMAGE_TARGETS = {
    "images/readme": "400x300",
    "images/publish": IMAGE_RENDER_SIZE,
}


def openscad_cmd(env: SConsEnvironment) -> Sequence[str]:
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


class MainBuilder:
    def __init__(self):
        # Build in parallel by default
        SetOption("num_jobs", os.cpu_count())

    def build(self) -> None:
        build_dir = Path(".") / "build"
        build_dir.mkdir(exist_ok=True)
        for sc in {str(md / "SConscript") for md in self._model_dirs}:
            env = self._env  # noqa: F841
            SConscript(
                sc,
                src_dir=Path(sc).parent,
                variant_dir=build_dir / Path(sc).parent,
                duplicate=False,
                exports="env",
            )
        env.Default("build/")
        env.Alias(
            "images",
            [
                i
                for md in self._model_dirs
                for i in Glob(str(md / "images") + "/*")
            ],
        )
        env.Alias("printables", ["build/", "images"])

    @functools.cached_property
    def _env(self) -> SConsEnvironment:
        env = Environment(
            PREV_REF=ARGUMENTS.get("ref", None),
        )
        self._add_openscad_builder(env)
        return env

    def _add_openscad_builder(self, env: SConsEnvironment) -> None:
        def _add_deps_target(target, source, env):
            target.append("${TARGET.name}.deps")
            return target, source

        cmd = openscad_cmd(env)
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
        return {
            x.parent
            for x in Path(".").glob("**/SConscript")
            if not str(x).startswith("_")
        }


class ModelBuilder:
    def __init__(self, env: SConsEnvironment):
        self.env = env
        self.build_dir = Dir(".")
        self.common_build_dir = Dir("#/build")
        self.src_dir = Dir(".").srcdir
        self.src_dir_path = self.src_dir.path
        self.model_dir = self.src_dir_path
        self.publish_images: Set[str] = set()
        self.publish_assets: Set[str] = set()
        self.zip_dirs: Dict[str, str] = {}

    def ref_filter(fn: Callable[..., Any]) -> Callable[..., Any]:
        def _wrapper(self, *args: Any, **kwargs: Any) -> Any:
            if not self._allowed_by_filter:
                return
            fn(self, *args, **kwargs)

        return _wrapper

    @ref_filter
    def add_default_targets(self) -> None:
        if PRINTABLES_TARGET in BUILD_TARGETS:
            self.add_printables_zip_targets()

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
            OPENSCAD_ARGS=" ".join(self._openscad_var_args(stl_vals)),
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
                ("/_static/", Path(Dir("#").path) / "_static"),
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
            self._run(cmd)

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

    def Image(
        self,
        target: str,
        model_file: str,
        stl_vals: Optional[Union[List[Dict[str, Any]], Dict[str, Any]]] = None,
        camera: Optional[str] = None,
        view_options: Optional[str] = None,
        delay=75,
    ) -> None:
        image_targets = {
            f"{self.src_dir}/{image_path}/{target}": size
            for image_path, size in IMAGE_TARGETS.items()
        }
        func = functools.partial(
            self.render_image,
            stl_vals_list=(
                [stl_vals]
                if isinstance(stl_vals, dict)
                else (stl_vals or [[]])
            ),
            image_targets=image_targets,
            camera=camera,
            view_options=view_options,
            delay=delay,
        )
        func.__name__ = self.render_image.__name__
        self.env.NoClean(
            self.env.Command(image_targets.keys(), model_file, func)
        )
        self.publish_images.add(f"{self.src_dir}/images/publish/{target}")

    def InsetImage(
        self,
        target: str,
        background_image: str,
        foreground_image: str,
        gravity: str = "southwest",
        resize: str = "33%",
    ) -> None:
        for image_path in IMAGE_TARGETS.keys():
            target_path = f"{self.src_dir}/{image_path}/{target}"
            self.env.NoClean(
                self.env.Command(
                    target_path,
                    [
                        f"{self.src_dir}/{image_path}/{background_image}",
                        f"{self.src_dir}/{image_path}/{foreground_image}",
                    ],
                    functools.partial(
                        self.render_inset_image,
                        resize=resize,
                        gravity=gravity,
                    ),
                )
            )
            self.publish_images.add(target_path)

    @functools.cached_property
    def library_files(self) -> Sequence[SConsFile]:
        return [
            lib_file
            for lib_glob in [
                fn.glob("*.scad")
                for fn in self.src_dir.glob("*")
                if Path(str(fn)).is_symlink()
            ]
            for lib_file in lib_glob
        ]

    def render_image(
        self,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
        image_targets: Optional[Dict[str, str]] = None,
        stl_vals_list: Optional[Sequence[Dict[str, Any]]] = None,
        delay: int = 75,
        camera: Optional[str] = None,
        view_options: Optional[str] = None,
    ) -> None:
        def _render_single_image(
            image_target: str, stl_vals: Dict[str, Any], size=None
        ) -> None:
            render_args = self._openscad_var_args(
                stl_vals, for_subprocess=True
            )
            if camera:
                render_args += [f"--camera={camera}"]
            if view_options:
                render_args += [f"--view={view_options}"]
            self._run(
                [
                    self.env["OPENSCAD"],
                    source[0].path,
                    f"--colorscheme={'DeepOcean'}",
                    f"--imgsize={size}",
                    "-o",
                    str(image_target),
                ]
                + self.env["OPENSCAD_FEATURES"]
                + render_args
            )

        with tempfile.TemporaryDirectory() as td:
            tdp = Path(td)
            # Render frames
            frames: List[str] = []
            for i, frame_stl_vals in enumerate(stl_vals_list):
                fn = tdp / f"image_{i:05d}.png"
                frames.append(fn)
                _render_single_image(
                    fn, frame_stl_vals, IMAGE_RENDER_SIZE.replace("x", ",")
                )
            if len(frames) > 1 and target[0].suffix != ".gif":
                row_len = str(ceil(len(frames) / 2))
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
                    f"{row_len}x{row_len}",
                ]
                self._run(montage_cmd + frames + [montage_fn])
                frames = [montage_fn]
            for tt in target:
                cmd = ["convert", "-resize", image_targets[tt.abspath]]
                if target[0].suffix == ".gif":
                    cmd += ["-loop", "0", "-delay", str(delay)]
                self._run(cmd + frames + [tt.path])

    def render_inset_image(
        self,
        target: Sequence[SConsFile],
        source: Sequence[SConsFile],
        env: SConsEnvironment,
        resize: str,
        gravity: str,
    ) -> None:
        background_image, foreground_image = source
        cmd = [
            "convert",
            background_image.path,
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
        self._run(cmd)

    def add_printables_zip_targets(self) -> None:
        sources = [
            File(f)
            for f in (
                set(self.src_dir.glob("*.scad", strings=True))
                | set(self.build_dir.glob("*.pdf", ondisk=False, strings=True))
                | set(self.build_dir.glob("*.stl", ondisk=False, strings=True))
                | self.publish_images
                | self.publish_assets
            )
        ] + self.library_files
        zip_name = self.model_dir.replace(os.sep, "__")
        self.env.Command(
            f"{self.common_build_dir}/printables-{zip_name}.zip",
            sorted(list(sources)),
            self.make_zip,
        )

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
    def _allowed_by_filter(self) -> bool:
        prev_ref = self.env.get("PREV_REF")
        if not prev_ref:
            return True
        try:
            dirs = {
                str(Path(fn).parent)
                for fn in self._run(
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
    def _run(
        cmd: list,
        *args: Any,
        quiet: bool = False,
        check: bool = True,
        **kwargs: Any,
    ) -> subprocess.CompletedProcess:
        cmds = [str(c) for c in cmd]
        if not quiet:
            print("+", " ".join(cmds), file=sys.stderr)
        return subprocess.run(cmds, *args, check=check, **kwargs)

    @staticmethod
    def _remove_prefix(value: str, prefixes: Union[str, Sequence[str]]) -> str:
        for prefix in [prefixes] if isinstance(prefixes, str) else prefixes:
            if value.startswith(prefix):
                return value[len(prefix) :]
        return value

    @staticmethod
    def _openscad_var_args(
        vals: Dict[str, any] = None, for_subprocess: bool = False
    ) -> Sequence[str]:
        def _val_args(k, v):
            if isinstance(v, str):
                v = f'"{v}"' if for_subprocess else f"'\"{v}\"'"
            return ["-D", f"{k}={v}"]

        return [
            arg for k, v in (vals or {}).items() for arg in _val_args(k, v)
        ]
