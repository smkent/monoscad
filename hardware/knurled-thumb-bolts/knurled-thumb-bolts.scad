/*
 * Knurled Thumb Bolts
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <BOSL/constants.scad>
use <BOSL/metric_screws.scad>
use <knurled-openscad/knurled.scad>

/* [Rendering Options] */

Part = "both"; // [both: Both, head: Thumb bolt head, plug: Bolt plug insert]

/* [Size] */
// All units in millimeters

Bolt_Diameter = 6; // [1:0.01:10]
Bolt_Shaft_Overlap = 4; // [2:0.1:30]

Height = 29.4; // [5:0.1:50]
Diameter = 18.6; // [5:0.1:50]

Inset_Depth = 10.0; // [0:0.1:50]
Inset_Diameter = 30; // [0:0.01:30]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

outer_height = Inset_Depth + Height;

bolt_d = Bolt_Diameter;
bolt_head_z = Bolt_Shaft_Overlap;
bolt_tolerance = 0.2;

head_d = get_metric_bolt_head_size(bolt_d);
head_depth = get_metric_bolt_head_height(bolt_d);

knurl_depth = 1.5;

fit = 0.1;
slop = 0.01;

plug_face_thick = 2;
plug_thick = 0.8;
plug_base_thick = 0.8;
plug_base_height = head_depth + fit + 2 * plug_face_thick;

layer_height = 0.2;

// Modules //

module kcyl(h, d) {
    knurled_cylinder(
        h,
        d - knurl_depth * 0.5,
        knurl_width=7,
        knurl_height=5,
        knurl_depth=knurl_depth,
        bevel=min(5, h / 3),
        smooth=50
    );
}

module rounded_cylinder(h, d, r=1, round_top=true, round_bottom=true) {
    rotate_extrude(angle=360)
    union () {
        offset(r=r)
        offset(r=-r)
        square([d / 2, h]);
        square([d / 2 / 2, h]);
        if (!round_bottom) {
            square([d / 2, h / 2]);
        }
        if (!round_top) {
            translate([0, h / 2])
            square([d / 2, h / 2]);
        }
    }
}

module bolt_head_shape() {
    projection(cut=true)
    metric_bolt(headtype="hex", size=bolt_d, l=0, details=false);
}

module bolt_head() {
    color("lemonchiffon", 0.8)
    linear_extrude(height=head_depth + fit)
    offset(delta=fit)
    bolt_head_shape();
}

module bolt_plug_body_base_shape() {
    offset(delta=plug_thick + plug_base_thick)
    circle(d=head_d / cos(30), $fn=6);
}

module bolt_plug_body() {
    linear_extrude(height=plug_base_height)
    bolt_plug_body_base_shape();
}

module bolt_plug() {
    color("lightgreen", 0.8)
    render(convexity=2)
    difference() {
        bolt_plug_body();
        bolt_head();
        translate([0, 0, 0.2])
        intersection() {
            bolt_head();
            linear_extrude(height=Height)
            square([Diameter, bolt_d], center=true);
        }
        translate([0, 0, -slop])
        linear_extrude(height=plug_base_height + slop * 2)
        circle(d=bolt_d + fit);
    }
}

module thumb_bolt() {
    color("plum", 0.8)
    render(convexity=2)
    union() {
        translate([0, 0, Inset_Depth])
        difference() {
            rounded_cylinder(h=Height, d=Diameter, round_bottom=false);
            translate([0, 0, Height])
            mirror([0, 0, 1])
            linear_extrude(height=plug_base_height)
            offset(delta=fit * 2)
            bolt_plug_body_base_shape();
        }
        kcyl(h=Inset_Depth, d=Inset_Diameter);
    }
}

module main() {
    if (Part == "both") {
        translate([-Diameter * 2, 0, 0])
        bolt_plug();
        thumb_bolt();
    } else if (Part == "head") {
        thumb_bolt();
    } else if (Part == "plug") {
        bolt_plug();
    }
}

main();
