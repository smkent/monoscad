/*
 * Sovol SV06 Plus Heat Bed Cable Support Bundle for tight spaces
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Frame support model file -- only used for README image rendering
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

/* [Channel Bend] */

Angle = 60; // [0:0.1:90]
Radius = 27.5; // [0:0.1:50]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 2 : 2;
$fs = $preview ? $fs / 3 : 0.4;

indent_z = 35.4;
tip_z = 44.386;
channel_origin_offset = 5.859;

slop = 0.01;

// Modules //

module original_model() {
    color("mintcream", 0.8)
    import("rogerquin-SV06 heatbed cable support V2.stl", convexity=4);
}

module body() {
    render(convexity=2)
    intersection() {
        original_model();
        cube((indent_z + slop) * 2, center=true);
    }
}

module channel_shape() {
    render(convexity=2)
    projection(cut=true)
    translate([0, 0, -(indent_z + (tip_z - indent_z) / 2)])
    original_model();
}

module channel_bend() {
    translate([0, -channel_origin_offset - $f_radius, indent_z])
    rotate([90, 180, 90])
    rotate_extrude(angle=$f_angle)
    translate([-$f_radius, 0])
    rotate(90)
    translate([0, channel_origin_offset])
    channel_shape();
}

module tip() {
    translate([0, 0, indent_z])
    render(convexity=2)
    translate([0, -channel_origin_offset - $f_radius])
    rotate([$f_angle, 0, 0])
    translate([0, channel_origin_offset + $f_radius])
    intersection() {
        translate([0, 0, -tip_z])
        original_model();
        linear_extrude(height=tip_z)
        square(tip_z, center=true);
    }
}

module frame_cable_support(angle=60, radius=27.5) {
    $f_angle = angle;
    $f_radius = radius;
    body();
    channel_bend();
    tip();
}

module main() {
    color("#94c5db", 0.8)
    frame_cable_support(angle=Angle, radius=Radius);
}

main();
