/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Hose segment model with bend
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

/* [Segment options] */
Connector_Type = "male"; // ["male": Male, "female": Female]

// Extra straight length to add between the two connectors
Extra_Length = 0; // [0:1:200]

// Bend angle to add between the two connectors
Bend_Angle = 0; // [0:1:180]

// Radius in millimeters of bend angle to add between the two connectors
Bend_Radius = 0; // [0:1:200]

/* [Development options] */
Render_Mode = "normal"; // [normal: Normal, half: Half, 2d-profile: 2D profile shape]

module __end_customizer_options__() { }

// Modules

module modular_hose_segment(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    connector_type=CONNECTOR_MALE,
    extra_length=0,
    bend_angle=0,
    bend_radius=0,
    render_mode=RENDER_MODE_NORMAL
) {
    modular_hose(inner_diameter, thickness, size_tolerance, render_mode) {
        modular_hose_configure_connector(
            extra_length=extra_length / 2,
            bend_angle=bend_angle,
            bend_radius=bend_radius,
        )
        modular_hose_connector_male();
        modular_hose_configure_connector(
            extra_length = extra_length / 2,
            bottom=true
        )
        modular_hose_connector_female();
    }
}

module modular_hose_segment_detail() {
    children();
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
