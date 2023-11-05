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
    $fh_origin_inner_diameter = inner_diameter;
    $fh_thickness = thickness;
    $fh_size_tolerance = size_tolerance;
    $fh_render_mode = render_mode;
    // Set computed values
    $fh_origin_inner_radius = inner_diameter / 2;
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
    $fh_connector_type_is_female = (connector_type == CONNECTOR_FEMALE);
    color(
        $fh_connector_type_is_female ? "darkseagreen" : "lightsteelblue",
        0.8
    )
    _connector_extrude()
    _connector_shape();
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

function _circle_radius_at_offset_from_center(circle_radius, offset_from_center) = (
    sqrt(circle_radius^2 - offset_from_center^2)
);

module _connector_circle_segment(circle_segment_radius_at_center, x_min=0, x_max=0, grip=false) {
    grip_radius = circle_segment_radius_at_center / 15;
    outer_radius_at_center = circle_segment_radius_at_center + $fh_thickness;
    difference() {
        union() {
            circle(outer_radius_at_center);
            if (grip) {
                grip_x = x_max - grip_radius * 0.6;
                outer_radius_at_grip = _circle_radius_at_offset_from_center(circle_segment_radius_at_center, grip_x);
                translate([
                    grip_x,
                    outer_radius_at_grip + $fh_thickness - grip_radius / 4
                ])
                circle(grip_radius);
            }
        }
        // Hollow circle
        circle(circle_segment_radius_at_center);
        // Half circle
        translate([-circle_segment_radius_at_center, -circle_segment_radius_at_center * 2])
        square([circle_segment_radius_at_center * 2, circle_segment_radius_at_center * 2]);
        // truncate circle
        for(mx = [0:1:1]) {
            mirror([mx, 0, 0])
            translate([mx ? x_min : x_max, -circle_segment_radius_at_center * 2])
            square([circle_segment_radius_at_center * 2, circle_segment_radius_at_center * 4]);
        }
    }
}

module _connector_origin_segment(circle_segment_radius_at_center, circle_segment_offset_from_origin) {
    function bezier_curve_from_origin_to_circle_segment(out_radius, in_radius, length) = (
        let (curve_control_point_offset_proportion = 0.35)
        let (curve_control_point_additional_offset_proportion = 0.35)
        let (control_prop =
                curve_control_point_additional_offset_proportion
                * (1 - min(1, ($fh_thickness / $fh_origin_inner_diameter) / 0.05))
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

    circle_segment_origin_connection_truncate_prop = sphere_truncate_proportion + sphere_attach_truncate_proportion / 2;
    circle_segment_attach_radius_inner = _circle_radius_at_offset_from_center(
            circle_segment_radius_at_center,
            $fh_origin_inner_radius * circle_segment_origin_connection_truncate_prop
        );
    circle_segment_attach_radius_outer = _circle_radius_at_offset_from_center(
            circle_segment_radius_at_center + $fh_thickness,
            $fh_origin_inner_radius * circle_segment_origin_connection_truncate_prop
        );
    inner_bezier = bezier_curve_from_origin_to_circle_segment(
            circle_segment_attach_radius_inner,
            $fh_origin_inner_radius,
            circle_segment_offset_from_origin
        );
    outer_bezier = bezier_curve_from_origin_to_circle_segment(
            circle_segment_attach_radius_outer,
            $fh_origin_inner_radius + $fh_thickness,
            circle_segment_offset_from_origin
        );
    polygon(points=concat(
            bezier_polyline(inner_bezier, N=3),
            reverse(bezier_polyline(outer_bezier, N=3))
        ));
}

module _connector_shape() {
    function circle_radius_from_offset_prop_from_center(offset_radius, offset_prop_from_center) = (
        sqrt(offset_radius^2 + (offset_radius * offset_prop_from_center)^2)
    );

    function circle_segment_radius_at_center_fn() = (
        let (circle_segment_base_radius_at_center = circle_radius_from_offset_prop_from_center(
            $fh_origin_inner_radius,
            sphere_truncate_proportion + sphere_attach_truncate_proportion
        ))
        circle_segment_base_radius_at_center + (
            $fh_connector_type_is_female
                ? $fh_thickness + $fh_size_tolerance
                : 0
        )
    );

    function circle_segment_offset_from_origin_fn() = (
        let (base_circle_segment_offset_from_origin =
            $fh_origin_inner_radius * (sphere_attach_truncate_proportion / 2)
        )
        base_circle_segment_offset_from_origin + (
            ($fh_connector_type_is_female ? $fh_thickness * 2 : 0)
            + (
                $fh_origin_inner_diameter
                * ($fh_connector_type_is_female ? 0.12 : 0.08)
                * separation_adjustment_proportion)
            )
    );

    function circle_segment_origin_connection_truncate_offset_fn() = (
        $fh_origin_inner_radius * (sphere_truncate_proportion + sphere_attach_truncate_proportion / 2)
    );

    function circle_segment_x_max_fn() = (
        let (circle_segment_radius_at_center = circle_segment_radius_at_center_fn())
        (
            $fh_connector_type_is_female
                ? $fh_origin_inner_radius * female_connector_sphere_offset_max_proportion
                : circle_segment_radius_at_center * sphere_truncate_proportion
        )
    );

    circle_segment_radius_at_center = circle_segment_radius_at_center_fn();
    circle_segment_offset_from_origin = circle_segment_offset_from_origin_fn();
    circle_segment_origin_connection_truncate_offset = circle_segment_origin_connection_truncate_offset_fn();

    translate([circle_segment_origin_connection_truncate_offset + circle_segment_offset_from_origin, 0])
    _connector_circle_segment(
        circle_segment_radius_at_center=circle_segment_radius_at_center,
        x_min=circle_segment_origin_connection_truncate_offset,
        x_max=circle_segment_x_max_fn(),
        grip=$fh_connector_type_is_female
    );
    _connector_origin_segment(circle_segment_radius_at_center, circle_segment_offset_from_origin);
}

module _connector_extrude() {
    if (
        $fh_render_mode == RENDER_MODE_NORMAL
        || $fh_render_mode == RENDER_MODE_HALF
    ) {
        rotate([180, 0, 0])
        rotate_extrude(angle=(
            $fh_render_mode == RENDER_MODE_NORMAL ? 360 : -180
        ))
        rotate([0, 0, -90])
        children();
    } else if ($fh_render_mode == RENDER_MODE_2D_PROFILE) {
        children();
    }
}
