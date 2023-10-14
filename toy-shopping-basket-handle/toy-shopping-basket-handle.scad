/*
 * Toy Shopping Basket Handle
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <BOSL/constants.scad>;
use <BOSL/beziers.scad>;
use <BOSL/math.scad>;
use <BOSL/paths.scad>;

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
// All units in millimeters

handle_height = 80;
handle_top_width = 152.5;
handle_thickness = 5.3;
handle_grip_thickness = 7;
handle_grip_width = 88;
handle_curve_radius = 18;

handle_clip_thin_length = 5;
handle_clip_thin_thickness = 4.3;
handle_clip_end_length = 3.5; // or 3.75
handle_clip_end_thickness = 5;

handle_clip_outer_width = handle_clip_thin_length + handle_clip_end_length;

basket_width_inner = 158;
basket_width_outer = 166;

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

function handle_path_points() = (
    let (xbase = handle_thickness / 2)
    let (ybase = handle_thickness / 2)
    let (height = handle_height - ybase)
    let (top_width = handle_top_width - xbase * 2)
    let (bottom_width = basket_width_inner - xbase * 2)
    let (tb_width_diff_half = (bottom_width - top_width) / 2)
    translate_points(
        [
            [-xbase, ybase],
            [0, ybase],
            [tb_width_diff_half, height],
            [tb_width_diff_half + top_width, height],
            [tb_width_diff_half * 2 + top_width, ybase],
            [tb_width_diff_half * 2 + top_width + xbase, ybase],
        ],
        [xbase, -ybase]
    )
);

function handle_path() = bezier_polyline(fillet_path(handle_path_points(), handle_curve_radius));

module handle_body() {
    bez = handle_path();
    // trace_polyline(bez, showpts=true, size=0.5, color="green");
    extrude_2d_shapes_along_3dpath(path3d(bez))
    circle(r=handle_thickness / 2);
}

module handle_grip() {
    length = handle_grip_width;
    translate([(basket_width_inner - length) / 2, handle_height - handle_thickness, 0])
    rotate([0, 90, 0]) {
        linear_extrude(height=length)
        circle(handle_grip_thickness / 2);
        translate([0, 0, handle_grip_width / 2])
        for (mx = [0:1:1]) {
            mirror([0, 0, mx])
            translate([0, 0, -handle_grip_width / 2 - handle_grip_thickness])
            cylinder(handle_grip_thickness, 0, handle_grip_thickness / 2);
        }
    }
}

module handle_clip() {
    rotate([0, 90, 0]) {
        // Thin bit
        linear_extrude(height=handle_clip_thin_length)
        circle(handle_clip_thin_thickness / 2);
        // End bit
        translate([0, 0, handle_clip_thin_length])
        difference() {
            linear_extrude(height=handle_clip_end_length)
            circle(handle_clip_end_thickness / 2);
            translate([-handle_clip_end_thickness / 2, 0, handle_clip_end_thickness / 2])
            rotate([0, 90, 0])
            linear_extrude(height=handle_clip_end_thickness)
            polygon(points=[
                [handle_clip_end_thickness / 2, 0],
                [-handle_clip_end_thickness / 2, -handle_clip_end_thickness / 8],
                [-handle_clip_end_thickness / 2, handle_clip_end_thickness / 8],
            ]);
        }
    }
}

module handle_clips() {
    translate([basket_width_inner / 2, 0, 0])
    for (mx = [0:1:1]) {
        mirror([mx, 0, 0])
        translate([-basket_width_inner / 2, 0, 0])
        mirror([1, 0, 0])
        handle_clip();
    }
}

module flatten_handle_bottom() {
    flatten_amount = (handle_thickness / 2) / 4;
    difference() {
        children();
        translate([-handle_clip_outer_width, 0, -handle_grip_thickness - handle_thickness / 2 + flatten_amount])
        cube([basket_width_inner + handle_clip_outer_width * 4, handle_height + handle_thickness * 2, handle_grip_thickness]);
    }
}

module handle() {
    flatten_handle_bottom() {
        translate([handle_clip_outer_width, handle_thickness / 2, 0]) {
            handle_body();
            handle_grip();
            handle_clips();
        }
    }
}

module main() {
    color("lightblue", 1.0) {
        handle();
    }
}

main();
