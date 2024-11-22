from contextlib import suppress
from itertools import product
from types import SimpleNamespace
from typing import Iterator, Sequence, Union


class GenerateOptions:
    def __init__(
        self,
        **kwargs: Sequence[Union[Sequence[Union[str, int]], Union[str, int]]],
    ):
        self.options = kwargs

    def _value(
        self, value: Union[Union[str, int], Sequence[Union[str, int]]]
    ) -> Union[str, int]:
        if isinstance(value, (list, tuple)) and len(value) == 2:
            return value[0]
        return value

    def _file_name_value(
        self, value: Union[Union[str, int], Sequence[Union[str, int]]]
    ) -> Union[str, int]:
        if isinstance(value, (list, tuple)) and len(value) == 2:
            with suppress(IndexError):
                return value[1]
        return ""

    def __iter__(self) -> Iterator[SimpleNamespace]:
        opt_keys = sorted(self.options.keys())
        args = [self.options[key] for key in opt_keys]
        for p in product(*args):
            yield SimpleNamespace(
                **{
                    **{k: self._value(v) for k, v in zip(opt_keys, p)},
                    **{
                        f"{k}_fn": self._file_name_value(v)
                        for k, v in zip(opt_keys, p)
                    },
                }
            )
