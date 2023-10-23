/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Generic screw/magnetic grommet and flange models
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modules.scad>;

/* [Model Options] */
Model_Type = 0; // [-1: Flange plate only, 0: Connector, 1: Grommet]
Connector_Type = 1; // [1: Male, 2: Female]

Magnet_Holes = true;
Screw_Holes = false;
Hole_Count = 8; // [4:2:16]

/* [Size Adjustment] */

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

// Flange plate base thickness excluding magnet/screw size
Plate_Base_Thickness = 1.6; // [0.8:0.2:6.4]

Screw_Diameter = 4; // [3:1:8]
Magnet_Diameter = 8; // [2:1:15]
Magnet_Thickness = 3; // [1:0.1:5]

// Depth of grommet ring
Grommet_Depth = 19; // [1:0.1:50.8]

/* [Advanced Size Adjustment] */

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

module __end_customizer_options__() { }

// Constants
fan_size = 120;
screw_diameter = Screw_Diameter * 1.1;
screw_hole_thickness = screw_diameter / 2;
plate_full_thickness = Plate_Base_Thickness + max(
        Magnet_Holes ? Magnet_Thickness : 0,
        Screw_Holes ? screw_hole_thickness : 0
    );
plate_screw_hole_inset = 7.5;
max_hole_diameter = max(
    Magnet_Holes ? Magnet_Diameter : 0,
    Screw_Holes ? Screw_Diameter * 2 : 0
    );
plate_hole_size_buffer = 1.5 * max(max_hole_diameter, 5);

// Modules

module circle_spread(count, stagger=false) {
    for (rot = [0:360/count:360]) {
        rotate([0, 0, rot + (stagger ? 360 / count / 2 : 0)])
        translate([(Inner_Diameter + Magnet_Diameter + plate_hole_size_buffer) / 2, 0])
        children();
    }
}

module flange_plate_shape(connector_diameter) {
    difference() {
        offset(-plate_hole_size_buffer * 2.0)
        offset(plate_hole_size_buffer * 2.0)
        union() {
            circle(connector_diameter / 2 + plate_hole_size_buffer);
            if (Magnet_Holes) {
                circle_spread(Hole_Count)
                translate([-max_hole_diameter * 1 + plate_hole_size_buffer, 0])
                circle(max_hole_diameter * 1);
            }
            if (Screw_Holes) {
                circle_spread(Hole_Count, stagger=true)
                translate([-max_hole_diameter * 1 + plate_hole_size_buffer, 0])
                circle(max_hole_diameter * 1);
            }
        }
        circle(connector_diameter / 2);
        if (Screw_Holes) {
            circle_spread(Hole_Count, stagger=true)
            circle(screw_diameter / 2);
        }
    }
}

module flange_plate(connector_diameter) {
    difference() {
        linear_extrude(height=plate_full_thickness)
        flange_plate_shape(connector_diameter);
        if (Magnet_Holes) {
            translate([0, 0, plate_full_thickness - Magnet_Thickness])
            circle_spread(Hole_Count)
            linear_extrude(height=Magnet_Thickness)
            circle(Magnet_Diameter / 2);
        }
        if (Screw_Holes) {
            translate([0, 0, plate_full_thickness - screw_hole_thickness])
            circle_spread(Hole_Count, stagger=true)
            cylinder(screw_hole_thickness + 0.001, screw_diameter / 2, screw_diameter);
        }
    }
}

module flange(connector_diameter) {
    color("khaki", 0.8)
    mirror([0, 0, 1])
    flange_plate(connector_diameter);
}

module grommet(connector_diameter) {
    color("lightskyblue", 0.8)
    linear_extrude(height=Grommet_Depth)
    difference() {
        circle(connector_diameter / 2 + Thickness);
        circle(connector_diameter / 2);
    }
}

module main() {
    modular_hose_init(Inner_Diameter, Thickness, Size_Tolerance) {
        flange(Inner_Diameter);
        if (Model_Type == 0) {
            rotate([0, -90, 0])
            connector(female=(Connector_Type == 2));
        } else if (Model_Type == 1) {
            grommet(Inner_Diameter);
        }
    }
}

main();
