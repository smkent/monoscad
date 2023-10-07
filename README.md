# My OpenSCAD Models

A monorepository for my [OpenSCAD][openscad] models and remixes.

## Setup

Models in this repository depend on various
[third-party libraries][openscad-libraries].

Libraries can be initialized by one of:

1. Initializing the included `libraries` submodule, by running:
   `git submodule update --init --recursive`
2. Cloning [smkent/openscad-libraries][smkent-openscad-libraries] to the
   OpenSCAD default library path directly. The default library path is OS
   dependent:

| OS | Path |
|--- |--- |
| Linux | `$HOME/.local/share/OpenSCAD/libraries` |
| Mac OS X | `$HOME/Documents/OpenSCAD/libraries` |
| Windows | `My Documents\OpenSCAD\libraries` |

## License

### Models

Each model in this repository is licensed individually, especially for remixes
which must maintain compatible licensing with their original model(s).

See `README.md` and/or any `LICENSE` files within a model's subdirectory for
that model's license.

### Third party libraries

Third party libraries have their own licenses.

### Monorepository

All remaining contents of this repository (i.e. not models or third party
libraries) are licensed under [Creative Commons (4.0 International License)
Attribution][license-cc-by-4.0].


[license-cc-by-4.0]: http://creativecommons.org/licenses/by/4.0/
[openscad]: https://openscad.org
[openscad-libraries]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
[smkent-openscad-libraries]: https://github.com/smkent/openscad-libraries
