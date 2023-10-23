/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * 120mm fan flange and grommet model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modules.scad>;

/* [Model Options] */
Model_Type = 0; // [-1: Plate only, 0: Connector, 1: Grommet]
Connector_Type = 1; // [1: Male, 2: Female]

/* [Size Adjustment] */

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

// Base plate thickness
Plate_Thickness = 1.6; // [0.8:0.2:6.4]

// Screw hole diameter
Screw_Diameter = 4; // [3:1:8]

// Outer diameter of grommet ring
Grommet_Diameter = 115;

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
plate_screw_hole_inset = 7.5;
plate_screw_hole_diameter = Screw_Diameter * 1.2;
plate_size = fan_size + 0;

// Modules

module plate_120mm_fan(connector_diameter) {
    color("mintcream", 0.8)
    mirror([0, 0, 1])
    linear_extrude(height=Plate_Thickness)
    difference() {
        offset(plate_screw_hole_inset)
        offset(-plate_screw_hole_inset)
        square([plate_size, plate_size], center=true);
        circle(connector_diameter / 2);
        translate([
            -(fan_size - 2 * plate_screw_hole_inset) / 2,
            -(fan_size - 2 * plate_screw_hole_inset) / 2,
            ])
        for (mx = [0:1:1]) for (my = [0:1:1]) {
            translate([
                mx * (fan_size - 2 * plate_screw_hole_inset),
                my * (fan_size - 2 * plate_screw_hole_inset),
            ])
            circle(plate_screw_hole_diameter / 2);
        }
    }
}

module grommet_120mm_fan(connector_diameter) {
    difference() {
        union() {
            plate_120mm_fan(Inner_Diameter);
            color("lightskyblue", 0.8)
            linear_extrude(height=Grommet_Depth)
            circle(Grommet_Diameter / 2);
        }
        color("lightskyblue", 0.8)
        translate([0, 0, -Plate_Thickness])
        cylinder(Grommet_Depth + Plate_Thickness * 1.001, Inner_Diameter / 2, Grommet_Diameter / 2 - Thickness);
    }
}

module main() {
    modular_hose_init(Inner_Diameter, Thickness, Size_Tolerance) {
        if (Model_Type == -1) {
            plate_120mm_fan(Inner_Diameter);
        } else if (Model_Type == 0) {
            plate_120mm_fan(Inner_Diameter);
            rotate([0, -90, 0])
            connector(female=(Connector_Type == 2));
        } else if (Model_Type == 1) {
            grommet_120mm_fan(Inner_Diameter);
        }
    }
}

main();
