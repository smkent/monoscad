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
Connector_Type = "both"; // ["both": Both, "male": Male, "female": Female]

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
Render_Mode = "normal"; // [normal: Normal, half: Half, 2d-profile: 2D profile shape]

module __end_customizer_options__() { }

// Modules

module modular_hose_segment(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    connector_type=CONNECTOR_MALE,
    extra_segment_length=0,
    render_mode=RENDER_MODE_NORMAL
) {
    modular_hose(inner_diameter, thickness, size_tolerance, render_mode) {
        segment_offset = extra_segment_length / 2;
        if (connector_type == CONNECTOR_BOTH || connector_type == CONNECTOR_MALE) {
            translate([0, 0, segment_offset])
            modular_hose_connector_male();
        }
        if (connector_type == CONNECTOR_BOTH || connector_type == CONNECTOR_FEMALE) {
            mirror(render_mode == RENDER_MODE_2D_PROFILE ? [1, 0, 0] : [0, 0, 1])
            translate([0, 0, segment_offset])
            modular_hose_connector_female();
        }
        color("slategray", 0.8)
        if (extra_segment_length && render_mode != RENDER_MODE_2D_PROFILE) {
            translate([0, 0, -extra_segment_length / 2])
            rotate_extrude(angle=(render_mode == RENDER_MODE_NORMAL ? 360 : 180))
            translate([inner_diameter / 2, 0])
            square([thickness, extra_segment_length]);
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
