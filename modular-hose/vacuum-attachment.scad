/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Vacuum attachment model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;

/* [Model Options] */

Connector_Type = 2; // [1: Male, 2: Female]

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

// Optional extra hose length to add between the attachment and connector
Extra_Segment_Length = 0; // [0:1:200]

/* [Advanced Size Adjustment] */
// All units in millimeters

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

module __end_customizer_options__() { }

// Modules

module utility_nozzle() {
    module nozzle_shape(reduce=0) {
        rr = $fh_origin_inner_diameter / 2;
        r = rr - reduce;
        hull() {
            translate([0, 0, reduce ? -0.01 : 0])
            linear_extrude(height=0.01)
            difference() {
                circle(r + $fh_thickness);
                circle(r);
            }

            for (mx = [0:1:1], my = [0:1:1]) {
                mirror([mx, 0, 0])
                mirror([0, my, 0])
                translate([rr * 2 - reduce, rr - reduce, rr + (reduce ? 0.01 : 0)])
                difference() {
                    sphere(r / 6);
                    translate([0, 0, r / 6])
                    cube(r / 3, center=true);
                }
            }
        }
    }

    difference() {
        nozzle_shape();
        nozzle_shape(reduce=$fh_thickness);
        cylinder($fh_thickness * 2, $fh_origin_inner_diameter / 2, $fh_origin_inner_diameter / 2);
    }
}

module modular_hose_vacuum_attachment(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    connector_type=0,
    extra_segment_length=0,
) {
    modular_hose(inner_diameter, thickness, size_tolerance) {
        translate([0, 0, -extra_segment_length / 2])
        mirror([0, 0, 1])
        modular_hose_connector(female=(connector_type == 2));

        color("thistle", 0.8)
        translate([0, 0, extra_segment_length / 2])
        utility_nozzle();

        color("slategray", 0.8)
        if (extra_segment_length) {
            translate([0, 0, -extra_segment_length / 2])
            linear_extrude(height=extra_segment_length)
            difference() {
                circle(inner_diameter / 2 + thickness);
                circle(inner_diameter / 2);
            }
        }
    }
}

modular_hose_vacuum_attachment(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Connector_Type,
    Extra_Segment_Length
);
