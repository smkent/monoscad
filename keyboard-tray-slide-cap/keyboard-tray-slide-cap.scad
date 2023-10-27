/*
 * Keyboard tray slide end cap
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Options] */
Cap_Style = 0; // [0:Rounded, 1: Flat]

/* [Size] */
// All units in millimeters

width = 11;
height = 37;
horizontal_radius = 5;
vertical_radius = 3;
plug_outer_thickness = 4;
plug_outer_thickness_radius = 1.6;
pylon_vertical_diameter_tip = 6.5;
pylon_vertical_diameter_base = 7;
pylon_width = 8;
pylon_inner_spacing = 25;
pylon_height = 9;

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module cap_shape(half=true) {
    difference() {
        hull()
        for (my = [0:1:1]) {
            mirror([0, my, 0])
            translate([0, height / 2 - vertical_radius])
            scale([horizontal_radius / vertical_radius, 1])
            circle(vertical_radius);
        }
        if (half) {
            translate([-width / 2, -height / 2])
            square([width / 2, height]);
        }
    }
}

module cap_outer_round() {
    rotate([270, 0, 0])
    scale([1, plug_outer_thickness / horizontal_radius, 1])
    difference() {
        rotate_extrude(angle=180)
        cap_shape(half=true);
        translate([0, height / 2 + width / 2 - 1, 0])
        cube(height, center=true);
    }
}

module cap_outer_flat() {
    hull()
    mirror([0, 0, 1]) {
        linear_extrude(height=plug_outer_thickness - plug_outer_thickness_radius)
        cap_shape(half=false);
        translate([0, 0, plug_outer_thickness - plug_outer_thickness_radius])
        scale([0.9, 0.9, 1.0])
        linear_extrude(height=plug_outer_thickness_radius)
        cap_shape(half=false);
    }
}

module cap_pylon_polygon() {
    scale([pylon_width / pylon_vertical_diameter_base, 1, 1])
    cylinder(pylon_height, pylon_vertical_diameter_base / 2, pylon_vertical_diameter_tip / 2);
}

module cap_pylon() {
    difference() {
        cap_pylon_polygon();
        translate([pylon_width / 8, -pylon_width / 4, 0])
        scale([1, 1, 1.01])
        cap_pylon_polygon();

        translate([0, 0, pylon_height])
        rotate([45, 0, 0])
        translate([0, 0, pylon_width / 2])
        cube(pylon_width * 1.2, center=true);
    }
}

module cap_pylons() {
    for (my = [0:1:1]) {
        mirror([0, my, 0])
        translate([0, pylon_inner_spacing / 2, 0])
        cap_pylon();
    }
}

module cap() {
    if (Cap_Style == 0) {
        cap_outer_round();
    } else if (Cap_Style == 1) {
        cap_outer_flat();
    }
    cap_pylons();
}

module main() {
    color("#bef", 0.8) {
        cap();
    }
}

main();
