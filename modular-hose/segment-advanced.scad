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

/* [Top connector] */
Top_Connector_Type = "male"; // ["male": Male, "female": Female]

// Extra straight length to add after the top connector
Top_Extra_Length = 0; // [0:1:200]

// Bend angle to add after the top connector
Top_Bend_Angle = 0; // [0:1:180]

// Radius in millimeters of bend angle to add after the top connector
Top_Bend_Radius = 0; // [0:1:200]

/* [Bottom connector] */
Bottom_Connector_Type = "female"; // ["male": Male, "female": Female]

// Extra straight length to add after the bottom connector
Bottom_Extra_Length = 0; // [0:1:200]

// Bend angle to add after the bottom connector
Bottom_Bend_Angle = 0; // [0:1:180]

// Radius in millimeters of bend angle to add after the bottom connector
Bottom_Bend_Radius = 0; // [0:1:200]

/* [Segment options] */

// Extra straight length to add between the segment connectors
Middle_Extra_Length = 0; // [0:1:200]

// Rotation offset of segment halves
Join_Rotation = 0; // [0:1:360]

/* [Development options] */
Render_Mode = "normal"; // [normal: Normal, half: Half, 2d-profile: 2D profile shape]

module __end_customizer_options__() { }

// Modules

module segment_placement(render_mode, bottom_bend_angle) {
    rotate(render_mode == RENDER_MODE_2D_PROFILE ? 0 : [0, bottom_bend_angle, 0])
    children();
}

module modular_hose_middle(length=0) {
    for (ch = [0, 1]) {
        tr = length / 2 * (ch == 0 ? 1 : -1);
        translate($fh_render_mode == RENDER_MODE_2D_PROFILE ? [tr, 0] : [0, 0, tr])
        children(ch);
    }
    color("lightslategray", 0.8)
    if ($fh_render_mode == RENDER_MODE_2D_PROFILE) {
        translate([-length / 2, $fh_origin_inner_radius])
        square([length, $fh_thickness]);
    } else {
        translate([0, 0, -length / 2])
        rotate_extrude(angle=$fh_render_mode == RENDER_MODE_NORMAL ? 360 : 180)
        translate([$fh_origin_inner_radius, 0])
        square([$fh_thickness, length]);
    }
}

module modular_hose_segment(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    top_connector_type=CONNECTOR_MALE,
    top_extra_length=0,
    top_bend_angle=0,
    top_bend_radius=0,
    bottom_connector_type=CONNECTOR_FEMALE,
    bottom_extra_length=0,
    bottom_bend_angle=0,
    bottom_bend_radius=0,
    middle_extra_length=0,
    join_rotation=0,
    render_mode=RENDER_MODE_NORMAL
) {
    modular_hose(inner_diameter, thickness, size_tolerance, render_mode)
    segment_placement(render_mode, bottom_bend_angle)
    modular_hose_middle(length=middle_extra_length) {
        modular_hose_configure_connector(
            extra_length=top_extra_length,
            bend_angle=top_bend_angle,
            bend_radius=top_bend_radius,
            join_rotation=join_rotation
        )
        modular_hose_connector(top_connector_type);
        modular_hose_configure_connector(
            extra_length=bottom_extra_length,
            bend_angle=bottom_bend_angle,
            bend_radius=bottom_bend_radius,
            bottom=true
        )
        modular_hose_connector(bottom_connector_type);
    }
}

module modular_hose_segment_detail() {
    children();
}

modular_hose_segment(
    Inner_Diameter,
    Thickness,
    Size_Tolerance,
    Top_Connector_Type,
    Top_Extra_Length,
    Top_Bend_Angle,
    Top_Bend_Radius,
    Bottom_Connector_Type,
    Bottom_Extra_Length,
    Bottom_Bend_Angle,
    Bottom_Bend_Radius,
    Middle_Extra_Length,
    Join_Rotation,
    Render_Mode
);
