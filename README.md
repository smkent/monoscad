# My OpenSCAD Models

[![bulbasaur0 on Printables][printables-profile-badge]][printables-profile]

A monorepository for my [OpenSCAD][openscad] models and remixes.

## Setup

Models in this repository depend on various
[third-party libraries][openscad-libraries], which are provided as
[git submodules][git-submodules] using
[smkent/openscad-libraries][smkent-openscad-libraries].

After cloning this repository, install all third-party libraries by running in
the repository directory:

```console
git submodule update --init --recursive
```

## Model samples

[![Rugged Storage Box](/rugged-box/images/readme/demo-dimensions.gif)](rugged-box/)
[![Segmented Modular Hose](/modular-hose/images/readme/demo.png)](modular-hose/)
[![Gridfinity Material Swatches Holder V2](/gridfinity-bins-material-swatches/images/readme/demo.gif)](gridfinity-bins-material-swatches/)
[![Bathtub Drain Hair Catcher](/bathtub-drain-hair-catcher/images/readme/demo-winged-round.png)](bathtub-drain-hair-catcher/)
[![Material Swatches rebuilt in OpenSCAD (remix)](/material-swatches/images/readme/demo.gif)](material-swatches/)
[![3D Printer Enclosure Filament Grommet](/filament-grommet/images/readme/top.png)](filament-grommet/)

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


[git-submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[license-cc-by-4.0]: http://creativecommons.org/licenses/by/4.0/
[openscad-libraries]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries
[openscad]: https://openscad.org
[printables-profile-badge]: /_static/printables-profile-badge.svg
[printables-profile]: https://www.printables.com/@bulbasaur0_1139994/models
[smkent-openscad-libraries]: https://github.com/smkent/openscad-libraries
