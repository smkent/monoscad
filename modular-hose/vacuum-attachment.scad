/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Vacuum attachment model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;

/* [Modular Hose base options -- use consistent values to make compatible parts] */

// Inner diameter at the center in millimeters (connector attachment point)
Inner_Diameter = 100;

// Wall thickness in millimeters, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this many millimeters to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

/* [Vacuum attachment options] */
Connector_Type = "female"; // [male: Male, female: Female]

// Optional extra hose length to add between the attachment and connector
Extra_Length = 0; // [0:1:200]

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
    connector_type=CONNECTOR_FEMALE,
    extra_length=0,
) {
    modular_hose(inner_diameter, thickness, size_tolerance) {
        mirror([0, 0, 1])
        modular_hose_configure_connector(extra_length=extra_length)
        modular_hose_connector(connector_type);

        color("thistle", 0.8)
        utility_nozzle();
    }
}

modular_hose_vacuum_attachment(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Connector_Type,
    Extra_Length
);
