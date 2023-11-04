/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Part model template -- use as a starting point for new part models
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;

/* [Model Options] */

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

/* [Advanced Size Adjustment] */
// All units in millimeters

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

module __end_customizer_options__() { }

// Modules

module modular_hose_template_part() {
    // Example module, replace this with your new part
    color("pink", 0.8)
    linear_extrude(height=10)
    square(Inner_Diameter, center=true);
}

module modular_hose_template(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
) {
    modular_hose(inner_diameter, thickness, size_tolerance) {
        // Example part assembly, replace this with your part

        modular_hose_connector();
        mirror([0, 0, 1])
        modular_hose_template_part();
    }

}

modular_hose_template(
    Inner_Diameter,
    Thickness,
    Size_Tolerance
);
