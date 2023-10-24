/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Magnetic plate, grommet, connector models
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;
use <knurled-openscad/knurled.scad>;

/* [Model Options] */
Model_Type = 0; // [-1: Plate only, 0: Connector, 1: Grommet]
Connector_Type = 1; // [1: Male, 2: Female]
Plate_Type = 0; // [0: Round, 1: Fan]

/* [Size Adjustment] */
// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100; // [10:0.1:200]

/* [Plate] */
// Fan size (e.g. 120mm)
Fan_Size = 120; // [40:1:200]

// Fan screw hole corner inset (e.g. 120mm fans have a 7.5mm inset)
Plate_Screw_Hole_Inset = 7.5; // [1:0.1:20]

// Total plate thickness. Must be greater than Magnet Thickness if magnets are enabled.
Plate_Thickness = 4.0; // [0.8:0.2:10]

// Enable plate edge knurling
Plate_Knurled = true;

/* [Grommet] */
// Depth of grommet ring
Grommet_Depth = 19; // [1:0.1:50.8]

// Outer diameter of grommet ring
Grommet_Diameter = 115; // [10:0.1:200]

// Advanced diameter adjustment
Grommet_Diameter_Adjustment = 0; // [0: No Adjustment, 1: Add Connector Thickness]

/* [Magnets] */
Magnet_Holes = true;
Magnet_Diameter = 8; // [2:1:15]
Magnet_Thickness = 3; // [1:0.1:5]

/* [Screws] */
Screw_Holes = true;
Screw_Diameter = 4; // [3:1:8]
Screw_Hole_Chamfer = true;

/* [Advanced Size Adjustment] */

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

module __end_customizer_options__() { }

// Modules

module fan_screw_placement() {
    translate([
        -($fhp_fan_size - 2 * $fhp_plate_screw_hole_inset) / 2,
        -($fhp_fan_size - 2 * $fhp_plate_screw_hole_inset) / 2,
        ])
    for (mx = [0:1:1]) for (my = [0:1:1]) {
        translate([
            mx * ($fhp_fan_size - 2 * $fhp_plate_screw_hole_inset),
            my * ($fhp_fan_size - 2 * $fhp_plate_screw_hole_inset),
        ])
        children();
    }
}

module circle_even_placement(count, stagger=false) {
    mdiff = $fhp_fan_size - $fhp_grommet_diameter;
    for (rot = [0:360/count:360]) {
        rotate([0, 0, rot + (stagger ? 360 / count / 2 : 0)])
        translate([1 + ($fh_origin_inner_diameter + $fhp_magnet_diameter + 3) / 2, 0, 0])
        children();
    }
}

module fan_screw_placement_selection() {
    if ($fhp_plate_type == 1) {
        fan_screw_placement()
        children();
    } else {
        circle_even_placement(4, stagger=true)
        translate([
            max(0,
                ($fhp_grommet_diameter - $fh_origin_inner_diameter) / 2
            ) - $fhp_screw_diameter / 2,
            0,
            0
        ])
        children();
    }
}

module fan_plate(
    solid=false
) {
    plate_size = $fhp_fan_size + 0;
    color("mintcream", 0.8)
    difference() {
        difference() {
            if ($fhp_plate_type == 1) {
                linear_extrude(height=$fhp_plate_thickness)
                offset($fhp_plate_screw_hole_inset)
                offset(-$fhp_plate_screw_hole_inset)
                square([plate_size, plate_size], center=true);
            } else {
                if ($fhp_plate_knurled) {
                    knurl_depth = 1.5;
                    knurled_cylinder(
                        $fhp_plate_thickness,
                        plate_size + $fhp_magnet_diameter * 2 + knurl_depth,
                        knurl_width=7,
                        knurl_height=5,
                        knurl_depth=knurl_depth,
                        bevel=$fhp_plate_thickness / 3,
                        smooth=50
                    );
                } else {
                    linear_extrude(height=$fhp_plate_thickness)
                    circle(plate_size / 2 + $fhp_magnet_diameter);
                }
            }
            translate([0, 0, -0.01])
            linear_extrude(height=$fhp_plate_thickness + 0.02) {
                if (!solid) {
                    circle($fh_origin_inner_diameter / 2);
                }
                if ($fhp_screw_holes) {
                    fan_screw_placement_selection()
                    circle(($fhp_screw_diameter * 1.2) / 2);
                }
            }
        }
        if ($fhp_screw_holes && $fhp_screw_hole_chamfer) {
            translate([0, 0, $fhp_plate_thickness - $fhp_screw_diameter])
            fan_screw_placement_selection()
            cylinder($fhp_screw_diameter + 0.001, $fhp_screw_diameter / 2, $fhp_screw_diameter);
        }
        if ($fhp_magnet_holes) {
            circle_even_placement(8, stagger=true)
            translate([0, 0, $fhp_plate_thickness - $fhp_magnet_thickness])
            linear_extrude(height=$fhp_magnet_thickness + 0.001)
            circle(($fhp_magnet_diameter * 1.05) / 2);
        }
    }
}

module grommet_body() {
    color("lightskyblue", 0.8)
    linear_extrude(height=$fhp_grommet_depth)
    circle($fhp_grommet_diameter / 2 + $fhp_grommet_diameter_adjustment);
}

module grommet_interior() {
    color("lightskyblue", 0.8)
    translate([0, 0, -$fhp_plate_thickness - 0.01])
    cylinder(
        $fhp_grommet_depth + $fhp_plate_thickness + 0.02,
        $fh_origin_inner_radius,
        $fhp_grommet_diameter / 2 - $fh_thickness + $fhp_grommet_diameter_adjustment
    );
}

module modular_hose_magnetic_part(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    model_type=0,
    connector_type=1,
    fan_size=120,
    plate_type=0,
    plate_screw_hole_inset=7.5,
    plate_thickness=4.0,
    plate_knurled=true,
    magnet_holes=true,
    magnet_diameter=8,
    magnet_thickness=3,
    screw_holes=true,
    screw_diameter=4,
    screw_hole_chamfer=true,
    grommet_depth=19,
    grommet_diameter=115,
    grommet_diameter_adjustment=0
) {
    $fhp_model_type = model_type;
    $fhp_fan_size = fan_size;
    $fhp_plate_type = plate_type;
    $fhp_plate_screw_hole_inset = plate_screw_hole_inset;
    $fhp_plate_thickness = plate_thickness;
    $fhp_plate_knurled = plate_knurled;
    $fhp_magnet_holes = magnet_holes;
    $fhp_magnet_diameter = magnet_diameter;
    $fhp_magnet_thickness = magnet_thickness;
    $fhp_screw_holes = screw_holes;
    $fhp_screw_diameter = screw_diameter;
    $fhp_screw_hole_chamfer = screw_hole_chamfer;
    $fhp_grommet_depth = grommet_depth;
    $fhp_grommet_diameter = grommet_diameter;
    $fhp_grommet_diameter_adjustment = grommet_diameter_adjustment ? thickness : 0;
    modular_hose_part(inner_diameter, thickness, size_tolerance) {
        difference() {
            union() {
                mirror([0, 0, 1])
                fan_plate(solid=(model_type == 1));
                if (model_type == 0) {
                    modular_hose_connector(female=(connector_type == 2));
                } else if (model_type == 1) {
                    grommet_body();
                }
            }
            if (model_type == 1) {
                grommet_interior();
            }
        }
    }
}

modular_hose_magnetic_part(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Model_Type,
    Connector_Type,
    Fan_Size,
    Plate_Type,
    Plate_Screw_Hole_Inset,
    Plate_Thickness,
    Plate_Knurled,
    Magnet_Holes,
    Magnet_Diameter,
    Magnet_Thickness,
    Screw_Holes,
    Screw_Diameter,
    Screw_Hole_Chamfer,
    Grommet_Depth,
    Grommet_Diameter,
    Grommet_Diameter_Adjustment
);
