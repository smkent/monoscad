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
Model_Type = "connector"; // [plate_only: Plate only, connector: Connector, grommet: Grommet]
Connector_Type = "male"; // [male: Male, female: Female]
Plate_Type = "round"; // [round: Round, fan: Fan]

/* [Size Adjustment] */
// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100; // [10:0.1:200]

/* [Plate] */
// Fan size (e.g. 120mm)
Fan_Size = 120; // [40:1:200]

// Fan screw hole corner inset (e.g. 120mm fans have a 7.5mm inset)
Plate_Screw_Hole_Inset = 7.5; // [1:0.1:20]

// Total plate thickness. Must be greater than Magnet Thickness if magnets are enabled.
Plate_Thickness = 6.0; // [0.8:0.2:10]

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
Magnet_Diameter = 8; // [2:0.1:15]
Magnet_Thickness = 3; // [1:0.1:5]

/* [Screws] */
Screw_Holes = true;
Screw_Diameter = 4; // [3:0.1:8]
Screw_Hole_Top = "inset"; // [none: None, chamfer: Chamfer, inset: Inset]

/* [Advanced Size Adjustment] */

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

module __end_customizer_options__() { }

// Constants

knurl_depth = 1.5;

// Functions

function round_plate_diameter() = (
    $mhp_fan_size + $mhp_magnet_diameter * 2
    + ($mhp_plate_knurled ? knurl_depth : 0)
);

// Modules

module fan_screw_placement() {
    translate([
        -($mhp_fan_size - 2 * $mhp_plate_screw_hole_inset) / 2,
        -($mhp_fan_size - 2 * $mhp_plate_screw_hole_inset) / 2,
        ])
    for (mx = [0:1:1]) for (my = [0:1:1]) {
        translate([
            mx * ($mhp_fan_size - 2 * $mhp_plate_screw_hole_inset),
            my * ($mhp_fan_size - 2 * $mhp_plate_screw_hole_inset),
        ])
        children();
    }
}

module circle_even_placement(count, stagger=false) {
    mdiff = $mhp_fan_size - $mhp_grommet_diameter;
    for (rot = [0:360/count:360]) {
        rotate([0, 0, rot + (stagger ? 360 / count / 2 : 0)])
        children();
    }
}

module fan_screw_placement_selection() {
    if ($mhp_plate_type == "fan") {
        fan_screw_placement()
        children();
    } else {
        x_offset = (round_plate_diameter() + $mhp_grommet_diameter) / 4;
        circle_even_placement(4, stagger=true)
        translate([x_offset, 0, 0])
        children();
    }
}

module plate_body(solid=false) {
    difference() {
        difference() {
            if ($mhp_plate_type == "fan") {
                plate_size = $mhp_fan_size;
                linear_extrude(height=$mhp_plate_thickness)
                offset($mhp_plate_screw_hole_inset)
                offset(-$mhp_plate_screw_hole_inset)
                square([plate_size, plate_size], center=true);
            } else {
                plate_size = round_plate_diameter();
                if ($mhp_plate_knurled) {
                    knurled_cylinder(
                        $mhp_plate_thickness,
                        plate_size,
                        knurl_width=7,
                        knurl_height=5,
                        knurl_depth=knurl_depth,
                        bevel=$mhp_plate_thickness / 3,
                        smooth=50
                    );
                } else {
                    linear_extrude(height=$mhp_plate_thickness)
                    circle(d=plate_size);
                }
            }
            translate([0, 0, -0.01])
            linear_extrude(height=$mhp_plate_thickness + 0.02) {
                if (!solid) {
                    circle($mh_origin_inner_diameter / 2);
                }
                if ($mhp_screw_holes) {
                    fan_screw_placement_selection()
                    circle(($mhp_screw_diameter * 1.2) / 2);
                }
            }
        }
        if ($mhp_screw_holes) {
            fan_screw_placement_selection()
            if ($mhp_screw_hole_top == "chamfer") {
                translate([0, 0, $mhp_plate_thickness - $mhp_screw_diameter])
                cylinder($mhp_screw_diameter + 0.001, $mhp_screw_diameter / 2, $mhp_screw_diameter);
            } else if ($mhp_screw_hole_top == "inset") {
                translate([0, 0, $mhp_plate_thickness - $mhp_screw_diameter])
                difference() {
                    linear_extrude(height=$mhp_screw_diameter + 0.001)
                    circle($mhp_screw_diameter);
                    linear_extrude(height=0.2)
                    for (mx = [0:1:1]) {
                        mirror([mx, 0])
                        translate([$mhp_screw_diameter*1.1, 0])
                        square([$mhp_screw_diameter, $mhp_screw_diameter*2], center=true);
                    }
                }
            }
        }
        if ($mhp_magnet_holes) {
            x_offset = (round_plate_diameter() +  $mh_origin_inner_diameter) / 4;
            circle_even_placement(8, stagger=true)
            translate([x_offset, 0, $mhp_plate_thickness - $mhp_magnet_thickness])
            linear_extrude(height=$mhp_magnet_thickness + 0.001)
            circle(($mhp_magnet_diameter * 1.05) / 2);
        }
    }
}

module plate_connector_support(height) {
    rotate_extrude(angle=360)
    translate([$mh_origin_inner_radius, 0])
    difference() {
        square([height / 2, height]);
        translate([$mh_thickness, 0])
        translate([height * 2, 0, 0])
        circle(height * 2);
    }
}

module plate_full(solid=false) {
    color("mintcream", 0.8) {
        if ($mhp_model_type == "connector") {
            connector_support_height = $mh_origin_inner_radius / 10;
            plate_connector_support(connector_support_height);
            translate([0, 0, connector_support_height])
            plate_body();
        } else {
            plate_body();
        }
    }
}

module grommet_body() {
    color("lightskyblue", 0.8)
    linear_extrude(height=$mhp_grommet_depth)
    circle($mhp_grommet_diameter / 2 + $mhp_grommet_diameter_adjustment);
}

module grommet_interior() {
    color("lightskyblue", 0.8)
    translate([0, 0, -$mhp_plate_thickness - 0.01])
    cylinder(
        $mhp_grommet_depth + $mhp_plate_thickness + 0.02,
        $mh_origin_inner_radius,
        $mhp_grommet_diameter / 2 - $mh_thickness + $mhp_grommet_diameter_adjustment
    );
}

module mh_magnetic_part(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    model_type="connector",
    connector_type=CONNECTOR_MALE,
    fan_size=120,
    plate_type="round",
    plate_screw_hole_inset=7.5,
    plate_thickness=4.0,
    plate_knurled=true,
    magnet_holes=true,
    magnet_diameter=8,
    magnet_thickness=3,
    screw_holes=true,
    screw_diameter=4,
    screw_hole_top="none",
    grommet_depth=19,
    grommet_diameter=115,
    grommet_diameter_adjustment=0
) {
    $mhp_model_type = model_type;
    $mhp_fan_size = fan_size;
    $mhp_plate_type = plate_type;
    $mhp_plate_screw_hole_inset = plate_screw_hole_inset;
    $mhp_plate_thickness = plate_thickness;
    $mhp_plate_knurled = plate_knurled;
    $mhp_magnet_holes = magnet_holes;
    $mhp_magnet_diameter = magnet_diameter;
    $mhp_magnet_thickness = magnet_thickness;
    $mhp_screw_holes = screw_holes;
    $mhp_screw_diameter = screw_diameter;
    $mhp_screw_hole_top = screw_hole_top;
    $mhp_grommet_depth = grommet_depth;
    $mhp_grommet_diameter = grommet_diameter;
    $mhp_grommet_diameter_adjustment = grommet_diameter_adjustment ? thickness : 0;
    mh(inner_diameter, thickness, size_tolerance) {
        difference() {
            union() {
                mirror([0, 0, 1])
                plate_full(solid=(model_type == "grommet"));
                if (model_type == "connector") {
                    mh_connector(connector_type);
                } else if (model_type == "grommet") {
                    grommet_body();
                }
            }
            if (model_type == "grommet") {
                grommet_interior();
            }
        }
    }
}

mh_magnetic_part(
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
    Screw_Hole_Top,
    Grommet_Depth,
    Grommet_Diameter,
    Grommet_Diameter_Adjustment
);
