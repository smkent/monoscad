# Segmented Modular Hose, Parametric and Customizable

[![Available on Printables][printables-badge]][printables-model]
[![CC-BY-SA-4.0 license][license-badge]][license]

A flexible and segmented modular hose to use as an air duct or with a vacuum.
Customize your own segments and attachments!

![Model renders](images/readme/demo.png)
![Segment model renders](images/readme/part-segment-options.gif)

![Photo of hose installed on 3D printer enclosure](images/readme/photo-3dprinter-hose.jpg)
![Photo of hose with several segments](images/readme/photo-extended-hose-1.jpg)
![Photo of magnetic grommets with no hose](images/readme/photo-magnetic-grommets.jpg)
![Photo of magnetic grommets with hose](images/readme/photo-magnetic-grommets-and-hose-1.jpg)

# Description

A flexible segmented hose makes a great air duct for the exhaust fan on my 3D
printer enclosure.

Inspired by several other
[terrific][flexible-segmented-hose-100mm-by-marius-hornberger]
[segmented][flexible-segmented-vacuum-hose-for-drill-press-by-martins-musings]
[hose][flexible-segmented-vacuum-hose-40mm-for-shopvac-by-teslapunk]
[models][parametric-momdular-hose-library-by-axford], I built my own segmented
modular hose model and library! I chose [OpenSCAD][openscad] so the software and
model would be fully open source.

## Features

This model was built with configurable sizing based on the smallest interior
diameter, such as where the two halves of a segment join at the center:

![Measurement demo](images/readme/demo-measurement.png)

This diameter, wall thickness, and connector size tolerance are configurable for
all parts. Selecting the same values for each part will create compatible parts.
The default thickness (0.8mm) and size tolerance (0mm) worked well on my printer
with a 0.4mm nozzle.

The model code is also organized as a library, so you can make your own custom
parts!

## Setup and rendering

### Setup

This model uses third-party libraries, such as [BOSL][bosl] for connector curve
math. See [the top-level README.md](/README.md) for libraries installation.

### Model files and rendering

Ensure all of the model's `*.scad` files are placed in the same directory. Open
a part model file (such as `mh-segment.scad`) in OpenSCAD. Select your desired
sizing and options in the OpenSCAD Customizer before rendering each part.

![OpenSCAD customizer screenshot](images/readme/customizer-screenshot-compatibility.png)

## Printing

I recommend printing with PETG for the additional flexibility it provides
compared to PLA. The hose segments bend slightly when fitting together.

Hose segments and connectors are sized to be two perimeters thick with the
default wall thickness of 0.8mm printed using a 0.4mm nozzle. Hose segments and
connectors should not generate any printed infill material (except for the
female connector end raised lip, if the hose diameter is large enough).

![Slicer screenshot](images/readme/slicer-screenshot-segment.png)

## Available parts

| Render | Part Info |
| ------ | --------- |
| ![Segment part render](images/readme/part-segment.png) | **Flexible segment** (`mh-segment.scad`): Print as many of these as you need for your desired hose length |
| ![Segment with advanced options part render](images/readme/part-segment-advanced.png) | **Flexible segment (advanced options)** (`mh-segment-advanced.scad`): Segment with more advanced bend/length options than `mh-segment.scad` |
| ![Magnetic round connector](images/readme/part-magnetic-connector-round.png) | **Round connector** (`mh-magnetic-parts.scad`): A round base connector with base holes for magnets/screws (configurable size). Use with another connector or a grommet. |
| ![Magnetic round grommet](images/readme/part-magnetic-grommet-round.png) | **Round grommet** (`mh-magnetic-parts.scad`): A round base grommet with base holes for magnets/screws (configurable size). Use with a connector. |
| ![Magnetic 120mm fan connector](images/readme/part-magnetic-connector-fan.png) | **120mm fan connector** (`mh-magnetic-parts.scad`): A 120mm fan base connector with base holes for magnets/screws (configurable size). Use with another connector or a grommet. |
| ![Magnetic 120mm fan grommet](images/readme/part-magnetic-grommet-fan.png) | **120mm fan grommet** (`mh-magnetic-parts.scad`): A 120mm fan base grommet with base holes for magnets/screws (configurable size). Use with a connector. |
| ![Vacuum attachment render](images/readme/part-vacuum-attachment.png) | **Vacuum attachment** (`mh-vacuum-attachment.scad`): A sample vacuum attachment that can connect to the end of a hose |

## Design your own custom parts and attachments!

Design your own custom parts using `mh-library.scad`!

Here's an example of how to create a hose part with a connector on top of
another shape:

```openscad

// Create this new .scad file in the same directory as mh-library.scad

include <mh-library.scad>;

// Initialize a modular hose part with an inner diameter of 50mm
mh(inner_diameter=50) {

    // Create a male connector.
    // For a female connector, use mh_connector_female().
    mh_connector_male();

    // Since connectors render centered at the origin,
    // attach our new part by facing it downwards instead
    // of upwards. Mirroring along the Z-axis flips
    // the parts to face down.
    mirror([0, 0, 1]) {

        // Let's create a 100x100mm square attachment base
        // with a hole matching the hose diameter (50mm).
        // We can do this by creating a square with a
        // circle removed from the center,
        // then extruding that to a 3D shape.
        color("lemonchiffon", 0.8)
        // Make the attachment part 10mm thick
        linear_extrude(height=10)
        difference() {
            // Create the 100x100mm square
            square(100, center=true);
            // Subtract a circle matching the hose diameter
            circle(50 / 2);
        }

    }
}

```

The above code produces this part:

![Customization example render](images/readme/customization-example-render.png)


## Attribution and License

This model is licensed under [Creative Commons (4.0 International License) Attribution-ShareAlike][license].

This model depends on:

* [The Belfry OpenSCAD Library][bosl]
* [Knurled Surface Library for OpenSCAD][knurled-openscad], based on [aubenc's
  library][knurled-openscad-upstream]

Third party components have their own licenses.


[bosl]: https://github.com/revarbat/BOSL
[flexible-segmented-hose-100mm-by-marius-hornberger]: https://www.printables.com/model/22487-flexible-segmented-hose-100mm
[flexible-segmented-vacuum-hose-40mm-for-shopvac-by-teslapunk]: https://www.printables.com/model/107125-flexible-segmented-vacuum-hose-40mm-fits-dn40-pipe
[flexible-segmented-vacuum-hose-for-drill-press-by-martins-musings]: https://www.printables.com/model/528307-flexible-segmented-vacuum-hose-for-drill-press-wit
[knurled-openscad-upstream]: https://www.thingiverse.com/thing:32122
[knurled-openscad]: https://github.com/smkent/knurled-openscad
[license-badge]: /_static/license-badge-cc-by-sa-4.0.svg
[license]: http://creativecommons.org/licenses/by-sa/4.0/
[openscad]: https://openscad.org
[parametric-momdular-hose-library-by-axford]: https://www.thingiverse.com/thing:9457
[printables-badge]: /_static/printables-badge.png
[printables-model]: https://www.printables.com/model/657275
