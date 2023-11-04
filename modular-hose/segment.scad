/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Hose segment model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;

/* [Model Options] */

// Render a full segment or just one of the connector ends
Connector_Type = 0; // [0: Both, 1: Male, 2: Female]

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

// Optional extra hose length to add between the segment connectors
Extra_Segment_Length = 0; // [0:1:200]

/* [Advanced Size Adjustment] */
// All units in millimeters

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

/* [Development Options] */
Render_Mode = 0; // [0: Normal, 1: Half, 2: 2D shape]

module __end_customizer_options__() { }

// Modules

module modular_hose_segment(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    connector_type=0,
    extra_segment_length=0,
    render_mode=0
) {
    modular_hose(inner_diameter, thickness, size_tolerance, render_mode) {
        if (connector_type == 0 || connector_type == 1) {
            translate([connector_type == 0 ? extra_segment_length / 2 : 0, 0, 0])
            modular_hose_connector(female=false);
        }
        if (connector_type == 0 || connector_type == 2) {
            mirror(render_mode == 2 ? [1, 0, 0] : [0, 0, 1])
            translate([connector_type == 0 ? extra_segment_length / 2 : 0, 0, 0])
            modular_hose_connector(female=true);
        }
        color("slategray", 0.8)
        if (extra_segment_length) {
            mirror([(connector_type == 2 ? 1 : 0), 0, 0])
            translate([0, 0, -extra_segment_length / (connector_type == 0 ? 2 : 1)])
            linear_extrude(height=extra_segment_length)
            difference() {
                circle(inner_diameter / 2 + thickness);
                circle(inner_diameter / 2);
            }
        }
    }
}

modular_hose_segment(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Connector_Type,
    Extra_Segment_Length,
    Render_Mode
);
