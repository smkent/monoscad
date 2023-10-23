/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * 120mm fan flange and grommet model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;

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
plate_size = fan_size + 0;

// Modules

module plate_120mm_fan() {
    color("mintcream", 0.8)
    mirror([0, 0, 1])
    linear_extrude(height=$fhp_plate_thickness)
    difference() {
        offset(plate_screw_hole_inset)
        offset(-plate_screw_hole_inset)
        square([plate_size, plate_size], center=true);
        circle($fh_origin_inner_diameter / 2);
        translate([
            -(fan_size - 2 * plate_screw_hole_inset) / 2,
            -(fan_size - 2 * plate_screw_hole_inset) / 2,
            ])
        for (mx = [0:1:1]) for (my = [0:1:1]) {
            translate([
                mx * (fan_size - 2 * plate_screw_hole_inset),
                my * (fan_size - 2 * plate_screw_hole_inset),
            ])
            circle(($fhp_screw_diameter * 1.2) / 2);
        }
    }
}

module grommet_120mm_fan() {
    difference() {
        union() {
            plate_120mm_fan();
            color("lightskyblue", 0.8)
            linear_extrude(height=$fhp_grommet_depth)
            circle($fhp_grommet_diameter / 2);
        }
        color("lightskyblue", 0.8)
        translate([0, 0, -$fhp_plate_thickness])
        cylinder($fhp_grommet_depth + $fhp_plate_thickness * 1.001, $fh_origin_inner_diameter / 2, $fhp_grommet_diameter / 2 - Thickness);
    }
}

module modular_hose_120mm_fan_part(
    plate_thickness,
    screw_diameter,
    grommet_depth,
    grommet_diameter
) {
    $fhp_plate_thickness = plate_thickness;
    $fhp_screw_diameter = screw_diameter;
    $fhp_grommet_depth = grommet_depth;
    $fhp_grommet_diameter = grommet_diameter;
    children();
}

module modular_hose_120mm_fan(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    model_type=0,
    connector_type=1,
    plate_thickness=1.6,
    screw_diameter=4,
    grommet_depth=19,
    grommet_diameter=115
) {
    modular_hose_part(inner_diameter, thickness, size_tolerance)
    modular_hose_120mm_fan_part(plate_thickness, screw_diameter, grommet_depth, grommet_diameter) {
        if (model_type == -1) {
            plate_120mm_fan();
        } else if (model_type == 0) {
            plate_120mm_fan();
            modular_hose_connector(female=(connector_type == 2));
        } else if (model_type == 1) {
            grommet_120mm_fan();
        }
    }
}

modular_hose_120mm_fan(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Model_Type,
    Connector_Type,
    Plate_Thickness,
    Screw_Diameter,
    Grommet_Depth,
    Grommet_Diameter
);
