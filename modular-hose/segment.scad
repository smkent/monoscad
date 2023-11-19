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
Extra_Segment_Length = 0; // [0:1:200]

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

module rotate_at(rotation, rotate_offset) {
    translate(-rotate_offset)
    rotate(rotation)
    translate(rotate_offset)
    children();
}

module segment_bend() {
    rotate([90, 0, 0])
    translate([$fhs_rotate_edge_offset, 0])
    difference() {
        rotate_extrude(angle=-$fhs_bend_angle)
        translate([-$fhs_rotate_edge_offset, 0])
        difference() {
            circle(d=$fh_origin_inner_diameter + $fh_thickness * 2);
            circle(d=$fh_origin_inner_diameter);
            if ($fh_render_mode == RENDER_MODE_HALF) {
                translate([-$fh_origin_inner_diameter * 2, 0])
                square($fh_origin_inner_diameter * 4);
            }
        }
    }
}

module add_segment_bend() {
    if ($fh_render_mode == RENDER_MODE_2D_PROFILE) {
        arc_radius = $fh_origin_inner_radius * 2 + $fhs_bend_radius;
        rotate_at(
            $fhs_bend_angle,
            [0, -(arc_radius + $fh_origin_inner_radius + $fh_thickness)]
        )
        children();
        color("lightslategray", 0.8)
        translate([0, arc_radius + $fh_origin_inner_radius + $fh_thickness])
        difference() {
            arc_cut_size = ($fh_origin_inner_diameter + $fhs_bend_radius) * 4;
            circle(r=arc_radius + $fh_thickness);
            circle(r=arc_radius);
            rotate($fhs_bend_angle)
            translate([0, -arc_cut_size / 2])
            square(arc_cut_size);
            mirror([1, 0])
            translate([0, -arc_cut_size / 2])
            square(arc_cut_size);
        }
    } else {
        color("lightslategray", 0.8)
        segment_bend();
        rotate_at([0, $fhs_bend_angle, 0], [-$fhs_rotate_edge_offset, 0, 0])
        children();
    }
}

module add_extra_segment_length() {
    segment_offset = $fhs_extra_segment_length / 2;
    segment_position = (
        $fh_render_mode == RENDER_MODE_2D_PROFILE
            ? [segment_offset, 0, 0] : [0, 0, segment_offset]
    );
    translate(segment_position)
    children();
    color("slategray", 0.8)
    if ($fhs_extra_segment_length) {
        if ($fh_render_mode == RENDER_MODE_2D_PROFILE) {
            rotate(-90)
            translate([-$fh_origin_inner_radius, 0])
            mirror([1, 0])
            square([$fh_thickness, $fhs_extra_segment_length / 2]);
        } else {
            translate([0, 0, 0 * -$fhs_extra_segment_length / 2])
            rotate_extrude(angle=($fh_render_mode == RENDER_MODE_NORMAL ? 360 : 180))
            translate([$fh_origin_inner_radius, 0])
            square([$fh_thickness, $fhs_extra_segment_length / 2]);
        }
    }
}

module modular_hose_segment(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    connector_type=CONNECTOR_MALE,
    extra_segment_length=0,
    bend_angle=0,
    bend_radius=0,
    render_mode=RENDER_MODE_NORMAL
) {
    $fhs_bend_angle = bend_angle;
    $fhs_bend_radius = bend_radius;
    $fhs_extra_segment_length = extra_segment_length;
    modular_hose(inner_diameter, thickness, size_tolerance, render_mode) {
        $fhs_rotate_edge_offset = (
            $fh_origin_inner_radius + $fh_thickness + $fhs_bend_radius
        );
        add_segment_bend()
        add_extra_segment_length()
        if (connector_type == CONNECTOR_BOTH || connector_type == CONNECTOR_MALE) {
            modular_hose_connector_male();
        }
        mirror(render_mode == RENDER_MODE_2D_PROFILE ? [1, 0, 0] : [0, 0, 1])
        add_extra_segment_length()
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
    Extra_Segment_Length,
    Bend_Angle,
    Bend_Radius,
    Render_Mode
);
