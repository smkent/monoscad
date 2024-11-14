import subprocess
import sys
from typing import Any, Dict, Sequence


def openscad_var_args(
    vals: Dict[str, any] = None, for_subprocess: bool = False
) -> Sequence[str]:
    def _val_args(k, v):
        if isinstance(v, str):
            v = f'"{v}"' if for_subprocess else f"'\"{v}\"'"
        if isinstance(v, (tuple, list)):
            v = f"[{','.join(str(i) for i in v)}]"
        return ["-D", f"{k}={v}"]

    return [arg for k, v in (vals or {}).items() for arg in _val_args(k, v)]


def run(
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
