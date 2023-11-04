/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Models demo
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;
use <segment.scad>;
use <magnetic-parts.scad>;
use <vacuum-attachment.scad>;

Inner_Diameter = 100; // [20:1:100]

module __end_customizer_options__() { }

// Constants

spacing = 100 * 1.5;

// Modules

module place_part(x, y) {
    translate([spacing * x, spacing * y, 0])
    children();
}

module center_demo(max_x, max_y) {
    translate([-spacing * max_x / 2, -spacing * max_y / 2, 0])
    children();
}

module stack_parts() {
    for (i = [0:1:1]) {
        mirror([0, 0, i])
        translate([0, 0, Inner_Diameter / 4])
        children(i);
    }
}

module modular_hose_demo(id) {
    place_part(0, 0)
    modular_hose_segment(id);

    place_part(-1, 0)
    translate([0, 0, -id * 0.6])
    modular_hose(id)
    modular_hose_connector(female=true);

    place_part(-0.5, 1)
    modular_hose_vacuum_attachment(id, connector_type=2);

    place_part(1, 0)
    stack_parts() {
        modular_hose_magnetic_part(id, model_type=1, plate_type=1, grommet_diameter=101.6, magnet_holes=true, screw_holes=true);
        modular_hose_magnetic_part(id, model_type=0, connector_type=1, plate_type=1, grommet_diameter=101.6, magnet_holes=true, screw_holes=false);
    }

    place_part(1, 1)
    stack_parts() {
        modular_hose_magnetic_part(id, model_type=1, plate_type=0, grommet_diameter=101.6, magnet_holes=true, screw_holes=true);
        modular_hose_magnetic_part(id, model_type=0, connector_type=2, plate_type=0, grommet_diameter=101.6, magnet_holes=true, screw_holes=false);
    }
}

mirror([1, 0, 0])
center_demo(1, 1)
modular_hose_demo(Inner_Diameter);
