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

// Functions

function plate_full_thickness() = (
    $fhp_plate_base_thickness + max(
        $fhp_magnet_holes ? $fhp_magnet_thickness : 0,
        $fhp_screw_holes ? $fhp_screw_hole_thickness : 0
    )
);

function max_hole_diameter() = (
    max(
        $fhp_magnet_holes ? $fhp_magnet_diameter : 0,
        $fhp_screw_holes ? $fhp_screw_diameter * 2 : 0
    )
);

function plate_hole_size_buffer() = (
    1.5 * max(max_hole_diameter(), 5)
);

// Modules

module circle_spread(count, stagger=false) {
    for (rot = [0:360/count:360]) {
        rotate([0, 0, rot + (stagger ? 360 / count / 2 : 0)])
        translate([($fh_origin_inner_diameter + $fhp_magnet_diameter + plate_hole_size_buffer()) / 2, 0])
        children();
    }
}

module flange_plate_shape() {
    mhd = max_hole_diameter();
    phsb = plate_hole_size_buffer();
    difference() {
        offset(-phsb * 2.0)
        offset(phsb * 2.0)
        union() {
            circle($fh_origin_inner_radius + phsb);
            if ($fhp_magnet_holes) {
                circle_spread($fhp_hole_count)
                translate([-mhd * 1 + phsb, 0])
                circle(mhd * 1);
            }
            if ($fhp_screw_holes) {
                circle_spread($fhp_hole_count, stagger=true)
                translate([-mhd * 1 + phsb, 0])
                circle(mhd * 1);
            }
        }
        circle($fh_origin_inner_radius);
        if ($fhp_screw_holes) {
            circle_spread($fhp_hole_count, stagger=true)
            circle($fhp_screw_diameter / 2);
        }
    }
}

module flange_plate() {
    pft = plate_full_thickness();
    difference() {
        linear_extrude(height=pft)
        flange_plate_shape();
        if ($fhp_magnet_holes) {
            translate([0, 0, pft - $fhp_magnet_thickness])
            circle_spread($fhp_hole_count)
            linear_extrude(height=$fhp_magnet_thickness)
            circle($fhp_magnet_diameter / 2);
        }
        if ($fhp_screw_holes) {
            translate([0, 0, pft - $fhp_screw_hole_thickness])
            circle_spread($fhp_hole_count, stagger=true)
            cylinder($fhp_screw_hole_thickness + 0.001, $fhp_screw_diameter / 2, $fhp_screw_diameter);
        }
    }
}

module flange() {
    color("khaki", 0.8)
    mirror([0, 0, 1])
    flange_plate();
}

module grommet() {
    color("lightskyblue", 0.8)
    linear_extrude(height=$fhp_grommet_depth)
    difference() {
        circle($fh_origin_inner_radius + $fh_thickness);
        circle($fh_origin_inner_radius);
    }
}

module modular_hose_flange_part(
    plate_base_thickness,
    hole_count,
    magnet_holes,
    magnet_diameter,
    magnet_thickness,
    screw_holes,
    screw_diameter,
    grommet_depth,
) {
    $fhp_plate_base_thickness = plate_base_thickness;
    $fhp_hole_count = hole_count;
    $fhp_magnet_holes = magnet_holes;
    $fhp_magnet_diameter = magnet_diameter;
    $fhp_magnet_thickness = magnet_thickness;
    $fhp_screw_holes = screw_holes;
    $fhp_screw_diameter = screw_diameter * 1.1;
    $fhp_screw_hole_thickness = screw_diameter * 1.1;
    $fhp_grommet_depth = grommet_depth;
    children();
}

module modular_hose_flange(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    model_type=0,
    connector_type=1,
    plate_base_thickness=1.6,
    hole_count=8,
    magnet_holes=1,
    magnet_diameter=8,
    magnet_thickness=3,
    screw_holes=0,
    screw_diameter=4,
    grommet_depth=19,
) {
    modular_hose_part(inner_diameter, thickness, size_tolerance)
    modular_hose_flange_part(
        plate_base_thickness,
        hole_count,
        magnet_holes,
        magnet_diameter,
        magnet_thickness,
        screw_holes,
        screw_diameter,
        grommet_depth
    ) {
        flange();
        if (model_type == 0) {
            rotate([0, -90, 0])
            modular_hose_connector(female=(connector_type == 2));
        } else if (model_type == 1) {
            grommet();
        }
    }
}

modular_hose_flange(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Model_Type,
    Connector_Type,
    Plate_Base_Thickness,
    Hole_Count,
    Magnet_Holes,
    Magnet_Diameter,
    Magnet_Thickness,
    Screw_Holes,
    Screw_Diameter,
    Grommet_Depth
);
