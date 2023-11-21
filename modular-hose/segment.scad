/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Hose segment model with bend
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modular-hose-library.scad>;

/* [Size Adjustment] */
// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

/* [Segment Options] */
// Render a full segment or just one of the connector ends
Connector_Type = "both"; // ["both": Both, "male": Male, "female": Female]

// Optional extra straight length to add between the segment connectors
Extra_Length = 0; // [0:1:200]

// Optional bend angle to add between the segment connectors
Bend_Angle = 0; // [0:1:180]

// Radius of optional bend angle to add between the segment connectors
Bend_Radius = 0; // [0:1:200]

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
    connector_type=CONNECTOR_BOTH,
    extra_length=0,
    bend_angle=0,
    bend_radius=0,
    render_mode=RENDER_MODE_NORMAL
) {
    modular_hose(inner_diameter, thickness, size_tolerance, render_mode)
    modular_hose_modify_connector(extra_length=extra_length / 2)
    union() {
        modular_hose_modify_connector(
            bend_angle=bend_angle,
            bend_radius=bend_radius
        )
        if (connector_type == CONNECTOR_BOTH || connector_type == CONNECTOR_MALE) {
            modular_hose_connector_male();
        }
        mirror(render_mode == RENDER_MODE_2D_PROFILE ? [1, 0, 0] : [0, 0, 1])
        if (connector_type == CONNECTOR_BOTH || connector_type == CONNECTOR_FEMALE) {
            modular_hose_connector_female();
        }
    }
}

modular_hose_segment(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Connector_Type,
    Extra_Length,
    Bend_Angle,
    Bend_Radius,
    Render_Mode
);
