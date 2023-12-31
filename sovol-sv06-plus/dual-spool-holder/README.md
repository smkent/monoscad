# Sovol SV06 (Plus) forward-facing dual spool holder V2

[![Available on Printables][printables-badge]][printables-model]
[![CC-BY-SA-4.0 license][license-badge]][license]

Sovol SV06 (Plus) forward-facing dual spool holder

![Photo of model installed with spools](images/readme/photo-spools-front.jpg)
![Photo of model without spools](images/readme/photo1.jpg)
![Model render](images/readme/render-part.png)
![Installed model preview render](images/readme/render-model-preview.png)

# Description

Use this double spool holder to place two forward facing filament spools on your
Sovol SV06 or SV06 Plus! Using
[the original Sovol SV06 filament barrel nut][original-part-link-sv06],
I created a longer double-ended nut combined with a new base to create this dual
spool holder. (Credit to
[braga3dprint's model][braga3dprint-double-spool-holder] for the double-ended
nut idea!)

Also included is a slightly tweaked stock spool holder model that chamfers the
spool holder threads for printing without supports. While this could result in a
looser fit, the modified filament barrels I printed fit snugly into my dual
spool holder.

These models were created using [OpenSCAD][openscad]. The source code and models
are included.

This is a new version of [my similar V1 model][v1], which was created using
TinkerCAD.

## Prerequisites

The SV06 Plus includes a filament runout sensor that mounts on the stock spool
holder assembly. This model doesn't include a mounting point for the runout
sensor, so it should be relocated. I relocated mine to the extruder using
[my filament runout sensor extruder mount][sv06-plus-extruder-runout-mount].

## Recommended pairing

For best results, pair this model with
[rogerquin's terrific SV06 (Plus) spool holder add-on][rogerquin-spool-holder-for-sovol-sv06]
or [my resized spool holder remix with an easier grip][sv06-spool-holder-remix],
which allow the filament spools to rotate smoothly!

![Animation of spool holder rotation with add-on model](../spool-holder-remix/images/readme/spin-video.gif)

## Printing

The dual spool holder body prints on its side with no supports.

![Slicer screenshot of dual spool holder](images/readme/slicer-screenshot-dual-spool-holder.png)

The filament barrel(s) print upright, with no supports if printing the included
chamfered version. You can reuse the stock spool holder for one of the two
sides, or print two new ones.

For vanity reasons, I used concentric top and bottom fill patterns for the
filament barrels.

![Slicer screenshot of filament barrel with chamfer](images/readme/slicer-screenshot-filament-barrel-chamfered.png)
![Slicer screenshot of filament barrel with chamfer, underside](images/readme/slicer-screenshot-filament-barrel-chamfered-2.png)

## Installation

Remove the original spool holder from the gantry, and reuse the original M5
bolts to attach the new spool holder body. Then, insert both filament spool
barrels into each sides of the integrated nut.

## Variation

The dual spool holder OpenSCAD model has a few configurable options. Most
notably, the tilt angle is configurable if you want your spools to sit further
forward or backward than the default 9.5° tilt.

![Animated render of various dual spool holder tilt angles](images/readme/demo-dual-spool-holder-tilt-angle.gif)

## Previous version

I created an [earlier dual spool holder model version][v1]
in TinkerCAD. That model is a combined remix of the double-ended nut from
[braga3dprint's model][braga3dprint-double-spool-holder] and
[Andrew Gipson's model][andrew-gipson-sv06-spool-holder].

## Attribution and License

This model uses the original [Sovol SV06 barrel nut][original-part-link-sv06].

This model is licensed under
[Creative Commons (4.0 International License) Attribution-ShareAlike][license].


[andrew-gipson-sv06-spool-holder]: https://www.printables.com/model/501529-sv06-spool-holder-with-filament-guide-v1
[braga3dprint-double-spool-holder]: https://www.printables.com/model/458130-sovol-sv06sv06-plus-double-filamentspool-holder
[license-badge]: /_static/license-badge-cc-by-sa-4.0.svg
[license]: http://creativecommons.org/licenses/by-sa/4.0/
[openscad]: https://openscad.org
[original-part-link-sv06]: https://github.com/Sovol3d/SV06-Fully-Open-Source/blob/main/Molded%20Parts%20STL/JXHSV06-07003-d%20Barrel%20nut.STL
[printables-badge]: /_static/printables-badge.png
[printables-model]: https://www.printables.com/model/669121
[rogerquin-spool-holder-for-sovol-sv06]: https://www.printables.com/model/409684-spool-holder-for-sovol-sv06-3d-printer
[sovol-sv06]: https://github.com/Sovol3d/SV06-Fully-Open-Source
[sv06-plus-extruder-runout-mount]: /sovol-sv06-plus/extruder-runout-mount
[sv06-spool-holder-remix]: /sovol-sv06-plus/spool-holder-remix
[v1]: https://www.printables.com/model/584632-sovol-sv06-plus-90-degree-dual-spool-holder
