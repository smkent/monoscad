/*
 * 100mm Vesa mount to 35mm pole / pipe
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
// All units in millimeters
VESA_Size = 75;

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module original_model() {
    color("mintcream", 0.8)
    render()
    difference() {
        translate([-150, -150, -.398])
        import("original-model-vesa-to-35mm.stl");
        mirror([0, 0, 1])
        linear_extrude(height=400)
        square([400, 400], center=true);
    }
}

module each_screw() {
    for (x = [-1, 1])
    for (y = [-1, 1])
    translate([VESA_Size / 2 * x, VESA_Size / 2 * y])
    children();
}

module main() {
    difference() {
        rotate(45)
        original_model();
        #each_screw() {
            cylinder(d=4.5, h=20);
            translate([0, 0, 4])
            cylinder(d=8, h=20);
        }
    }
}

main();
