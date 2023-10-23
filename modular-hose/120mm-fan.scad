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
Model_Type = 0; // [0: Connector, 1: Grommet]
Connector_Type = 1; // [1: Male, 2: Female]

/* [Size Adjustment] */

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

// Fan size (e.g. 120mm)
Fan_Size = 120; // [40:1:200]

// Fan screw hole corner inset (e.g. 120mm fans have a 7.5mm inset)
Plate_Screw_Hole_Inset = 7.5; // [1:0.1:20]

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

// Modules

module modular_hose_120mm_fan(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    model_type=0,
    connector_type=1,
    fan_size=120,
    plate_screw_hole_inset=7.5,
    plate_thickness=1.6,
    screw_diameter=4,
    grommet_depth=19,
    grommet_diameter=115
) {
    $fhp_fan_size = fan_size;
    $fhp_plate_screw_hole_inset = plate_screw_hole_inset;
    $fhp_plate_thickness = plate_thickness;
    $fhp_screw_diameter = screw_diameter;
    modular_hose_part(inner_diameter, thickness, size_tolerance) {
        if (model_type == 0) {
            plate_120mm_fan();
            modular_hose_connector(female=(connector_type == 2));
        } else if (model_type == 1) {
            grommet_120mm_fan(grommet_diameter, grommet_depth, plate_thickness);
        }
    }
}

module plate_120mm_fan() {
    mirror([0, 0, 1])
    modular_hose_fan_plate(
        $fhp_fan_size,
        $fhp_fan_size + 0,
        $fhp_plate_thickness,
        $fhp_plate_screw_hole_inset,
        $fhp_screw_diameter
    );
}

module grommet_120mm_fan(grommet_diameter, grommet_depth, plate_thickness) {
    difference() {
        union() {
            plate_120mm_fan();
            color("lightskyblue", 0.8)
            linear_extrude(height=grommet_depth)
            circle(grommet_diameter / 2);
        }
        color("lightskyblue", 0.8)
        translate([0, 0, -plate_thickness])
        cylinder(
            grommet_depth + plate_thickness * 1.001,
            $fh_origin_inner_radius,
            grommet_diameter / 2 - Thickness
        );
    }
}

modular_hose_120mm_fan(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Model_Type,
    Connector_Type,
    Fan_Size,
    Plate_Screw_Hole_Inset,
    Plate_Thickness,
    Screw_Diameter,
    Grommet_Depth,
    Grommet_Diameter
);
