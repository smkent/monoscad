# Parametric and Customizable Rugged Storage Box

[![CC-BY-SA-4.0 license][license-badge]][license]

A parametric and customizable rugged storage box for OpenSCAD

![Renders animation showing various box sizes](images/readme/demo-dimensions.gif)
![Renders animation showing various box radii and chamfers](images/readme/demo-edges.gif)
![Photo of two small printed rugged boxes](images/readme/photo.jpg)

# Description

Inspired by
[several][rugged-box-parametric-by-whity]
[other][sbox-by-michael-fanta]
[terrific][frog-box-2.0-by-nibb31]
[rugged][waterproof-box-v2-by-zx82net]
[box][parametrizable-rugged-box-openscad-by-dochni]
[models][customizable-penguin-case-by-ctag],
I decided to build one to share! I
chose [OpenSCAD][openscad] to ensure the model would use an open source format.
This model can both create parametric boxes and be used as a library to make
customized boxes!

## Features

* Configurable sizing, including basic dimensions (width, length, height),
  corner radius, and top/bottom edge chamfer
* Optional lip seal, integrated or for 1.75mm filament
* Optional reinforced (thicker) corners
* All parts print without supports
* Model code organized as an include library -- make your own custom boxes!
* No [`minkowski`][openscad-minkowski] usages!

## Hardware

The hinges and latches are attached using M3 screws, M3x30 by default. Each
hinge needs 1 screw and each latch needs 2. A box with one latch needs 3 screws
total, while a box with two latches needs 6 screws total.

The screw length is dependent on the `Latch Width` (default 22mm) and
`Rib Width` (default 4mm) options. If you change these values, the length of
screws your box will need is `Latch Width` + 2x`Rib Width`.

## Rendering

Ensure both `rugged-box.scad` and `rugged-box-library.scad` are placed in the
same directory. Open `rugged-box.scad` in OpenSCAD.

Select your desired dimensions and options in the OpenSCAD Customizer. Then, one
at a time, select each part (top, bottom, and latch) in the Part drop-down. For
each part, perform a render (F6) and export to STL (F7).

![Customizer screenshot](images/readme/customizer-screenshot.png)
![Customizer part selection screenshot](images/readme/customizer-screenshot-part-select.png)

## Printing

Print the box top and bottom parts on their outer faces. Latches print on their
side. No supports are needed.

![Slicer screenshot](images/readme/slicer-screenshot.png)

## Make your own custom boxes

Make your own custom boxes using `rugged-box-library.scad`!

| [Tutorial: **Rugged box with dividers**](tutorials/box-with-dividers.md) | [Tutorial: **Rugged box with cutouts**](tutorials/box-with-cutouts.md) |
| --- | --- |
| [![Rugged box with dividers tutorial render](images/readme/tutorial-box-with-dividers-step-7.png)](tutorials/box-with-dividers.md) | [![Rugged box with cutouts tutorial render](images/readme/tutorial-box-with-cutouts-step-5.png)](tutorials/box-with-cutouts.md) |

## License

This model is licensed under [Creative Commons (4.0 International License) Attribution-ShareAlike][license].


[customizable-penguin-case-by-ctag]: https://www.thingiverse.com/thing:4852352
[frog-box-2.0-by-nibb31]: https://www.thingiverse.com/thing:4094861
[license-badge]: /_static/license-badge-cc-by-sa-4.0.svg
[license]: http://creativecommons.org/licenses/by-sa/4.0/
[openscad-minkowski]: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#minkowski
[openscad]: https://openscad.org
[parametrizable-rugged-box-openscad-by-dochni]: https://www.printables.com/model/168664-parametrizable-rugged-box-openscad
[rugged-box-parametric-by-whity]: https://www.printables.com/model/258431-rugged-box-parametric
[sbox-by-michael-fanta]: https://www.printables.com/model/262716-sbox-for-mk234-stackable-toolbox-system
[waterproof-box-v2-by-zx82net]: https://www.thingiverse.com/thing:4838803
