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

// Functions

function circle_radius_at_offset_from_center(circle_radius, offset_from_center) = (
    sqrt(circle_radius^2 - offset_from_center^2)
);

function circle_radius_from_offset_prop_from_center(offset_radius, offset_prop_from_center) = (
    sqrt(offset_radius^2 + (offset_radius * offset_prop_from_center)^2)
);

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

function circle_segment_radius_at_center_fn(female=false) = (
    let (circle_segment_base_radius_at_center = circle_radius_from_offset_prop_from_center(
        $fh_origin_inner_radius,
        sphere_truncate_proportion + sphere_attach_truncate_proportion
    ))
    circle_segment_base_radius_at_center + (female ? $fh_thickness + $fh_size_tolerance : 0)
);

function circle_segment_offset_from_origin_fn(female=false) = (
    let (base_circle_segment_offset_from_origin = $fh_origin_inner_radius * (sphere_attach_truncate_proportion / 2))
    base_circle_segment_offset_from_origin + (female ? $fh_thickness * 2 : 0) + ($fh_origin_inner_diameter * (female ? 0.12 : 0.08) * separation_adjustment_proportion)
);

function circle_segment_origin_connection_truncate_offset_fn() = (
    $fh_origin_inner_radius * (sphere_truncate_proportion + sphere_attach_truncate_proportion / 2)
);

function circle_segment_x_max_fn(female) = (
    let (circle_segment_radius_at_center = circle_segment_radius_at_center_fn(female))
    (
        female
            ? $fh_origin_inner_radius * female_connector_sphere_offset_max_proportion
            : circle_segment_radius_at_center * sphere_truncate_proportion
    )
);

// Modules

module modular_hose_init(inner_diameter, thickness, size_tolerance, render_mode=0) {
    $fh_origin_inner_diameter = inner_diameter;
    $fh_origin_inner_radius = inner_diameter / 2;
    $fh_thickness = thickness;
    $fh_size_tolerance = size_tolerance;
    $fh_render_mode = render_mode;
    children();
}

module connector(female=false) {
    color(female ? "darkseagreen" : "lightsteelblue", 0.8)
    _connector_extrude()
    _connector_shape(female=female);
}

// Private Modules

module _connector_circle_segment(circle_segment_radius_at_center, x_min=0, x_max=0, grip=false) {
    grip_radius = circle_segment_radius_at_center / 15;
    outer_radius_at_center = circle_segment_radius_at_center + $fh_thickness;
    difference() {
        union() {
            circle(outer_radius_at_center);
            if (grip) {
                grip_x = x_max - grip_radius * 0.6;
                outer_radius_at_grip = circle_radius_at_offset_from_center(circle_segment_radius_at_center, grip_x);
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
    circle_segment_origin_connection_truncate_prop = sphere_truncate_proportion + sphere_attach_truncate_proportion / 2;
    circle_segment_attach_radius_inner = circle_radius_at_offset_from_center(
            circle_segment_radius_at_center,
            $fh_origin_inner_radius * circle_segment_origin_connection_truncate_prop
        );
    circle_segment_attach_radius_outer = circle_radius_at_offset_from_center(
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
            reverse(bezier_polyline(outer_bezier, N=3)),
        ));
}

module _connector_shape(female=false) {
    circle_segment_radius_at_center = circle_segment_radius_at_center_fn(female);
    circle_segment_offset_from_origin = circle_segment_offset_from_origin_fn(female);
    circle_segment_origin_connection_truncate_offset = circle_segment_origin_connection_truncate_offset_fn();

    translate([circle_segment_origin_connection_truncate_offset + circle_segment_offset_from_origin, 0])
    _connector_circle_segment(
        circle_segment_radius_at_center=circle_segment_radius_at_center,
        x_min=circle_segment_origin_connection_truncate_offset,
        x_max=circle_segment_x_max_fn(female),
        grip=female
    );
    _connector_origin_segment(circle_segment_radius_at_center, circle_segment_offset_from_origin);
}

module _connector_extrude() {
    if ($fh_render_mode == 0 || $fh_render_mode == 1) {
        rotate($fh_render_mode == 1 ? [-90, 0, 90] : [0, -90, 0])
        rotate_extrude(angle=($fh_render_mode == 0 ? 360 : 180))
        rotate([0, 0, -90])
        children();
    } else if ($fh_render_mode == 2) {
        children();
    }
}
