# Gridfinity Rugged Storage Box, Parametric and Customizable

![This model is a work in progress][work-in-progress-badge]
[![CC-BY-SA-4.0 license][license-badge]][license]

A Gridfinity compatible parametric and customizable rugged storage box or
toolbox for OpenSCAD. Make and customize your own boxes!

![Renders animation showing various box sizes](images/readme/demo-dimensions.gif)

# Description

My [Rugged Storage Box][rugged-box-base-model], now for [Gridfinity][gridfinity]
bins!

## Features

Gridfinity:

* Configurable sizing in Gridfinity grid units
* Optional exterior stacking grid on top/bottom of box

Box options:

* Choice of latch style (clip or draw)
* Side stacking latches
* Optional handle
* Top opening grip and hinge end stops
* Lip seal, integrated or for 1.75mm filament
* Reinforced (thicker) corners

## Hardware

The hinges and latches are attached using M3 screws. Depending on whether a
handle or stacking latches are desired, a box may take between 6 and 18 screws
to assemble.

The screw length is dependent on the `Latch Width` (default 22mm) and
`Rib Width` (default 4mm) options. If you change these values, the length of
screws your box will need is `Latch Width` + 2x`Rib Width`.

If a handle is desired, two of the screws need to be an *extra* `Rib Width`
(default 4mm) plus the handle thickness (10mm) long. For example, if the base
screw length used is the default M3 x 30mm with the default 4mm Rib Width, then
the two handle screws need to be M3 x 44mm (~M3x45).

## Rendering

Ensure both `rugged-box-gridfinity.scad` and `rugged-box-library.scad` are
placed in the same directory. Open `rugged-box-gridfinity.scad` in OpenSCAD.

Select your desired dimensions and options in the OpenSCAD Customizer. Then, one
at a time, select each part (top, bottom, and latch) in the Part drop-down. For
each part, perform a render (F6) and export to STL (F7).

## Printing

Print the box top and bottom parts on their outer faces. Latches print on their
side.

Recommended print settings:

* 3 perimeters (instead of the usual default of 2)
* 30% infill
* For the latches, a brim may be helpful for bed adhesion

## Differences of the remix compared to the original

This uses [Gridfinity Rebuilt in OpenSCAD][gridfinity-rebuilt-openscad] to add
[Gridfinity][gridfinity]-compatible baseplates and stacking covers to my
[Rugged Storage Box][rugged-box-base-model].

## Attribution and License

This model is licensed under [Creative Commons (4.0 International License) Attribution-ShareAlike][license].

This is a remix of
[**Gridfinity Rebuilt in OpenSCAD** by **kennetek**][gridfinity-rebuilt-openscad].

Gridfinity and [Gridfinity Rebuilt in OpenSCAD][gridfinity-rebuilt-openscad]
use the [MIT License][gridfinity-license].

[customizable-penguin-case-by-ctag]: https://www.thingiverse.com/thing:4852352
[gridfinity-license]: LICENSE.gridfinity
[gridfinity-rebuilt-openscad]: https://github.com/kennetek/gridfinity-rebuilt-openscad
[gridfinity]: https://www.youtube.com/watch?v=ra_9zU-mnl8
[license-badge]: /_static/license-badge-cc-by-sa-4.0.svg
[openscad]: https://openscad.org
[printables-badge]: /_static/printables-badge.png
[printables-model]: https://www.printables.com/model/637028
[rugged-box-base-model]: ../../rugged-box/
[work-in-progress-badge]: /_static/work-in-progress-badge.svg
