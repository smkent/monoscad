/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Part model template -- use as a starting point for new part models
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <mh-library.scad>;

/* [Modular Hose base options -- use consistent values to make compatible parts] */

// Inner diameter at the center in millimeters (connector attachment point)
Inner_Diameter = 100;

// Wall thickness in millimeters, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this many millimeters to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

module __end_customizer_options__() { }

// Modules

module mh_template_part() {
    // Example module, replace this with your new part
    color("lemonchiffon", 0.8)
    linear_extrude(height=10)
    difference() {
        square(Inner_Diameter * 1.2, center=true);
        circle(d=Inner_Diameter);
    }
}

module mh_template(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
) {
    mh(inner_diameter, thickness, size_tolerance) {
        // Example part assembly, replace this with your part

        mh_connector_male();
        mirror([0, 0, 1])
        mh_template_part();
    }

}

mh_template(
    Inner_Diameter,
    Thickness,
    Size_Tolerance
);
