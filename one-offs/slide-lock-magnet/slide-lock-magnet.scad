/*
 * Slide lock magnet holder
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;
Show_Slide = true;
Part = "both"; // ["both": Base and lid, "base": Base, "lid": Lid]

/* [Size] */
Screw_Diameter = 2.5; // [2:0.5:4]
Screw_Hole_Diameter = 3; // [2:0.1:10]

Base_Thickness = 1; // [1:0.1:4]
Lid_Thickness = 1; // [1:0.1:4]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

slide_size = [12, 24, 4];

slide_hole_d = 9.5;
slide_hole_inset = 10.5;

holder_base_thick = Base_Thickness;
holder_lid_thick = Lid_Thickness;
holder_thick = 2;
holder_size = [20, 24, 2];
holder_screw_d = Screw_Diameter;
holder_screw_hole_d = Screw_Hole_Diameter;
holder_screw_base_d = holder_screw_d * 2.5;

rr = 0.6;

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module slide_body_shape() {
    intersection() {
        difference() {
            translate([0, -slide_size.y / 2])
            square([slide_size.x, slide_size.y]);
            translate([slide_size.x - slide_hole_inset, 0])
            circle(d=slide_hole_d);
        }
        scale([1, (slide_size.y * 1.5) / (slide_size.x * 2)])
        circle(d=slide_size.x * 2);
    }
}

module slide_body() {
    linear_extrude(height=slide_size.z)
    slide_body_shape();
}

module round_shape() {
    offset(r=-rr)
    offset(r=rr*2)
    offset(r=-rr)
    children();
}

module at_holder_screws() {
    for (ox = [
        slide_size.x + holder_size.x + holder_screw_base_d / 2 - holder_thick / 2,
        holder_screw_base_d / 2
    ])
    translate([ox, 0])
    children();
}

module holder_screw_holes() {
    render()
    difference() {
        children();
        linear_extrude(height = (holder_base_thick + slide_size.z) * 10, center=true)
        at_holder_screws()
        circle(d=holder_screw_hole_d);
    }
}

module holder_base_shape() {
    translate([0, -slide_size.y / 2])
    round_shape()
    square([slide_size.x + holder_size.x + holder_screw_base_d, holder_size.y]);
}

module holder() {
    // Back
    translate([0, 0, -holder_base_thick])
    linear_extrude(height=holder_base_thick)
    holder_base_shape();

    // Body
    linear_extrude(height=slide_size.z)
    difference() {
        round_shape()
        difference() {
            translate([0, -holder_size.y / 2])
            square([slide_size.x + holder_size.x + holder_screw_base_d, holder_size.y]);
            slide_body_shape();
        }
        translate([slide_size.x, -holder_size.y / 2])
        translate([holder_thick, holder_thick])
        round_shape()
        square(vec_add([holder_size.x, holder_size.y], -holder_thick * 2));
    }
}

module holder_lid() {
    translate([0, 0, slide_size.z])
    linear_extrude(height=holder_lid_thick)
    holder_base_shape();
}

module main() {
    if (Part == "both" || Part == "base") {
        if (Show_Slide && $preview)
        color("lightsteelblue", 0.9)
        slide_body();
        color("darkseagreen", 0.9)
        holder_screw_holes()
        holder();
    }
    if (Part == "both" || Part == "lid") {
        color("lemonchiffon", 0.5)
        holder_screw_holes()
        holder_lid();
    }
}

main();
