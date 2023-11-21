/*
 * Flexible Segmented Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <BOSL/constants.scad>;
use <BOSL/beziers.scad>;
use <BOSL/paths.scad>;
use <BOSL/math.scad>;

module __end_customizer_options__() { }

// Defaults

default_inner_diameter = 100;
default_thickness = 0.8;
default_size_tolerance = 0;

// Constants

CONNECTOR_BOTH = "both";
CONNECTOR_MALE = "male";
CONNECTOR_FEMALE = "female";

RENDER_MODE_NORMAL = "normal";
RENDER_MODE_HALF = "half";
RENDER_MODE_2D_PROFILE = "2d-profile";

// Public modules

/*
 * Setup module
 *
 * Use this module to configure hose sizing before rendering a part
 *
 * Arguments:
 *  - inner_diameter: Interior diameter at the center of the hose (the
 *    narrowest diameter at the center of a connector segment)
 *  - thickness: Connector wall thickness, 2x or another multiple of nozzle
 *    size is recommended
 *  - size_tolerance: Increase the female connector diameter this much to
 *    adjust fit
 *  - render_mode: (For development) Render the connectors, half of the
 *    connectors, or the 2-dimensional connector curve shape only
 *
 * Example:
 *
 *      modular_hose(inner_diameter=100, thickness=0.8, size_tolerance=0) {
 *          // Render male connector on top
 *          modular_hose_connector_male();
 *
 *          // Render male connector on bottom, flipped along the Z axis
 *          mirror([0, 0, 1])
 *          modular_hose_connector_female();
 *      }
 */
module modular_hose(
    inner_diameter=default_inner_diameter,
    thickness=default_thickness,
    size_tolerance=default_size_tolerance,
    render_mode=RENDER_MODE_NORMAL
) {
    $mh_origin_inner_diameter = inner_diameter;
    $mh_thickness = thickness;
    $mh_size_tolerance = size_tolerance;
    $mh_render_mode = render_mode;
    // Set computed values
    $mh_origin_inner_radius = inner_diameter / 2;
    $mh_connector_rotate_edge_offset = 0;
    // Set defaults
    $mh_connector_extra_length = 0;
    $mh_connector_bend_angle = 0;
    $mh_connector_bend_radius = 0;
    $mh_connector_join_rotation = 0;
    $mh_connector_bottom = false;
    children();
}

/*
 * Connector modules
 *
 * Use one of these modules to create the corresponding connector.
 *
 * - modular_hose_connector_male() creates a male connector.
 * - modular_hose_connector_female() creates a female connector.
 * - modular_hose_connector() creates a male or female connector depending on
 *   the argument value ("male" or "female").
 *
 * Connectors are created at the origin facing upwards. A full part can be
 * created by placing a connector on one end (such as the upward-facing
 * default), and placing the other half of the part on the bottom below the
 * Z-axis (such as with mirror([0, 0, 1]) applied to the remaining part half).
 *
 * A simple example is a modular hose segment itself, which consists of one
 * connector on top and the opposite connector mirrored along the Z-axis to
 * face downwards.
 *
 * Example:
 *
 *      modular_hose(inner_diameter=100, thickness=0.8, size_tolerance=0) {
 *          // Render male connector on top
 *          modular_hose_connector_male();
 *
 *          // Render male connector on bottom, flipped along the Z axis
 *          mirror([0, 0, 1])
 *          modular_hose_connector_female();
 *      }
 */
module modular_hose_connector_male() { modular_hose_connector(CONNECTOR_MALE); }
module modular_hose_connector_female() { modular_hose_connector(CONNECTOR_FEMALE); }
module modular_hose_connector(connector_type=CONNECTOR_FEMALE) {
    $mh_connector_type_is_female = (connector_type == CONNECTOR_FEMALE);
    _connector();
}

module modular_hose_configure_connector(
    extra_length=$mh_connector_extra_length,
    bend_angle=$mh_connector_bend_angle,
    bend_radius=$mh_connector_bend_radius,
    join_rotation=$mh_connector_join_rotation,
    bottom=$mh_connector_bottom
) {
    $mh_connector_extra_length = extra_length;
    $mh_connector_bend_angle = bend_angle;
    $mh_connector_bend_radius = bend_radius;
    $mh_connector_join_rotation = join_rotation;
    $mh_connector_bottom = bottom;
    // Set constants
    $mh_connector_rotate_edge_offset = (
        $mh_origin_inner_radius + $mh_thickness + $mh_connector_bend_radius
    );
    children();
}

// Constants

$fa = $preview ? 6 : 2;
$fs = $preview ? 0.6 : 0.2;

// Connector sphere truncate proportion at the outer end
sphere_truncate_proportion = 0.40; // [0.05:0.01:0.95]
// Connector sphere truncate proportion at the inner (attachment) end
sphere_attach_truncate_proportion = 0.20; // [0.05:0.01:0.50]
// Female connector sphere truncate proportion at the outer grip end
female_connector_sphere_offset_max_proportion = 0.21; // [0.1:0.01:0.5]
// Connector distance from center adjustment proportion
separation_adjustment_proportion = 1.0; // [0.5:0.01:1.5]

// Private Modules

function _connector_color() = (
    let (colors = [
        // Connector, extra length, bend
        ["darkseagreen", "#729672", "#557055"],
        ["lightsteelblue", "#95a6bc", "#8190a3"]
    ])
    colors[$mh_connector_type_is_female ? 0 : 1]
);

function _circle_radius_at_offset_from_center(
    circle_radius, offset_from_center
) = (sqrt(circle_radius^2 - offset_from_center^2));

module _connector_circle_segment(
    circle_segment_radius_at_center, x_min=0, x_max=0, grip=false
) {
    grip_radius = circle_segment_radius_at_center / 15;
    outer_radius_at_center = circle_segment_radius_at_center + $mh_thickness;
    difference() {
        union() {
            circle(outer_radius_at_center);
            if (grip) {
                grip_x = x_max - grip_radius * 0.6;
                outer_radius_at_grip = _circle_radius_at_offset_from_center(
                    circle_segment_radius_at_center, grip_x
                );
                translate([
                    grip_x,
                    outer_radius_at_grip + $mh_thickness - grip_radius / 4
                ])
                circle(grip_radius);
            }
        }
        // Hollow circle
        circle(circle_segment_radius_at_center);
        // Half circle
        translate([
            -circle_segment_radius_at_center,
            -circle_segment_radius_at_center * 2
        ])
        square(circle_segment_radius_at_center * 2);
        // truncate circle
        for(mx = [0:1:1]) {
            mirror([mx, 0, 0])
            translate([mx ? x_min : x_max, -circle_segment_radius_at_center * 2])
            square([
                circle_segment_radius_at_center * 2,
                circle_segment_radius_at_center * 4
            ]);
        }
    }
}

module _connector_origin_segment(
    circle_segment_radius_at_center, circle_segment_offset_from_origin
) {

    function bezier_curve_from_origin_to_circle_segment(
        out_radius, in_radius, length
    ) = (
        let (curve_control_point_offset_proportion = 0.35)
        let (curve_control_point_additional_offset_proportion = 0.35)
        let (control_prop =
                curve_control_point_additional_offset_proportion
                * (1 - min(1, ($mh_thickness / $mh_origin_inner_diameter) / 0.05))
        )
        [
            [0, in_radius],
            [length * curve_control_point_offset_proportion, in_radius],
            [
                length * (curve_control_point_offset_proportion + control_prop),
                in_radius + (out_radius - in_radius) * 0.2
            ],
            [length, out_radius],
        ]
    );

    circle_segment_origin_connection_truncate_prop = (
        sphere_truncate_proportion + sphere_attach_truncate_proportion / 2
    );
    circle_segment_attach_radius_inner = _circle_radius_at_offset_from_center(
            circle_segment_radius_at_center,
            $mh_origin_inner_radius * circle_segment_origin_connection_truncate_prop
        );
    circle_segment_attach_radius_outer = _circle_radius_at_offset_from_center(
            circle_segment_radius_at_center + $mh_thickness,
            $mh_origin_inner_radius * circle_segment_origin_connection_truncate_prop
        );
    inner_bezier = bezier_curve_from_origin_to_circle_segment(
            circle_segment_attach_radius_inner,
            $mh_origin_inner_radius,
            circle_segment_offset_from_origin
        );
    outer_bezier = bezier_curve_from_origin_to_circle_segment(
            circle_segment_attach_radius_outer,
            $mh_origin_inner_radius + $mh_thickness,
            circle_segment_offset_from_origin
        );
    polygon(points=concat(
            bezier_polyline(inner_bezier, N=3),
            reverse(bezier_polyline(outer_bezier, N=3))
        ));
}

module _connector_placement() {
    if ($mh_connector_bottom) {
        mirror(
            $mh_render_mode == RENDER_MODE_2D_PROFILE
                ? [1, 0, 0]
                : [0, 0, 1]
        )
        children();
    } else {
        children();
    }
}

module _connector_rotation() {
    rotate(
        $mh_render_mode == RENDER_MODE_2D_PROFILE
            ? 0
            : $mh_connector_join_rotation
    )
    children();
}

module _connector() {
    // Connector bend
    _connector_placement()
    _connector_rotation()
    _connector_bend() {
        // Connector body
        color(_connector_color()[0], 0.8)
        _connector_extrude()
        translate([$mh_connector_extra_length, 0])
        _connector_shape();
        // Extra length
        color(_connector_color()[1], 0.8)
        if ($mh_connector_extra_length > 0) {
            _connector_extrude()
            translate([0, $mh_origin_inner_radius])
            square([$mh_connector_extra_length, $mh_thickness]);
        }
    }
}

module rotate_at(rotation, rotate_offset) {
    translate(-rotate_offset)
    rotate(rotation)
    translate(rotate_offset)
    children();
}

module _connector_bend() {
    arc_radius = $mh_origin_inner_radius * 2 + $mh_connector_bend_radius;

    module _connector_bend_2d() {
        arc_cut_size = ($mh_origin_inner_diameter + $mh_connector_bend_radius) * 4;
        translate([0, arc_radius + $mh_origin_inner_radius + $mh_thickness])
        difference() {
            circle(r=arc_radius + $mh_thickness);
            circle(r=arc_radius);
            rotate($mh_connector_bend_angle)
            translate([0, -arc_cut_size / 2])
            square(arc_cut_size);
            mirror([1, 0])
            translate([0, -arc_cut_size / 2])
            square(arc_cut_size);
        }
    }

    module _connector_bend_3d() {
        rotate([90, 0, 0])
        translate([$mh_connector_rotate_edge_offset, 0])
        rotate_extrude(angle=-$mh_connector_bend_angle)
        translate([-$mh_connector_rotate_edge_offset, 0])
        difference() {
            circle(d=$mh_origin_inner_diameter + $mh_thickness * 2);
            circle(d=$mh_origin_inner_diameter);
            if ($mh_render_mode == RENDER_MODE_HALF) {
                rotate($mh_connector_join_rotation)
                translate([-$mh_origin_inner_diameter * 2, 0])
                square($mh_origin_inner_diameter * 4);
            }
        }
    }

    if ($mh_render_mode == RENDER_MODE_2D_PROFILE) {
        color(_connector_color()[2], 0.8)
        _connector_bend_2d();
        rotate_at(
            $mh_connector_bend_angle,
            [0, -(arc_radius + $mh_origin_inner_radius + $mh_thickness)]
        )
        children();
    } else {
        color(_connector_color()[2], 0.8)
        _connector_bend_3d();
        rotate_at(
            [0, $mh_connector_bend_angle, 0],
            [-$mh_connector_rotate_edge_offset, 0, 0]
        )
        children();
    }
}

module _connector_shape() {
    function circle_radius_from_offset_prop_from_center(
        offset_radius, offset_prop_from_center
    ) = (
        sqrt(offset_radius^2 + (offset_radius * offset_prop_from_center)^2)
    );

    function circle_segment_radius_at_center_fn() = (
        let (circle_segment_base_radius_at_center = circle_radius_from_offset_prop_from_center(
            $mh_origin_inner_radius,
            sphere_truncate_proportion + sphere_attach_truncate_proportion
        ))
        circle_segment_base_radius_at_center + (
            $mh_connector_type_is_female
                ? $mh_thickness + $mh_size_tolerance
                : 0
        )
    );

    function circle_segment_offset_from_origin_fn() = (
        let (base_circle_segment_offset_from_origin =
            $mh_origin_inner_radius * (sphere_attach_truncate_proportion / 2)
        )
        base_circle_segment_offset_from_origin + (
            ($mh_connector_type_is_female ? $mh_thickness * 2 : 0)
            + (
                $mh_origin_inner_diameter
                * ($mh_connector_type_is_female ? 0.12 : 0.08)
                * separation_adjustment_proportion)
            )
    );

    function circle_segment_origin_connection_truncate_offset_fn() = (
        $mh_origin_inner_radius * (
            sphere_truncate_proportion + sphere_attach_truncate_proportion / 2
        )
    );

    function circle_segment_x_max_fn() = (
        let (circle_segment_radius_at_center = circle_segment_radius_at_center_fn())
        (
            $mh_connector_type_is_female
                ? $mh_origin_inner_radius * female_connector_sphere_offset_max_proportion
                : circle_segment_radius_at_center * sphere_truncate_proportion
        )
    );

    circle_segment_radius_at_center = circle_segment_radius_at_center_fn();
    circle_segment_offset_from_origin = circle_segment_offset_from_origin_fn();
    circle_segment_origin_connection_truncate_offset = (
        circle_segment_origin_connection_truncate_offset_fn()
    );

    translate([
        (
            circle_segment_origin_connection_truncate_offset
            + circle_segment_offset_from_origin
        ),
        0
    ])
    _connector_circle_segment(
        circle_segment_radius_at_center=circle_segment_radius_at_center,
        x_min=circle_segment_origin_connection_truncate_offset,
        x_max=circle_segment_x_max_fn(),
        grip=$mh_connector_type_is_female
    );
    _connector_origin_segment(
        circle_segment_radius_at_center,
        circle_segment_offset_from_origin
    );
}

module _connector_extrude() {
    if (
        $mh_render_mode == RENDER_MODE_NORMAL
        || $mh_render_mode == RENDER_MODE_HALF
    ) {
        rotate(-$mh_connector_join_rotation)
        rotate([180, 0, 0])
        rotate_extrude(angle=(
            $mh_render_mode == RENDER_MODE_NORMAL ? 360 : -180
        ))
        rotate([0, 0, -90])
        children();
    } else if ($mh_render_mode == RENDER_MODE_2D_PROFILE) {
        children();
    }
}
