/*
 * Hanging file cabinet rail clips
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
b_thick = 12;
r_thick = 2.75;
r_height = 12;
inset = 8.7;

thick = 4;
r_outset = 4;

/* [Advanced Options] */
/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

b_len = inset * 2 + r_thick;
rr = thick * 0.48;
slop = 0.1;

// Modules //

module clip_cut() {
    translate([0, 0, -slop])
    linear_extrude(height=r_height + slop) {
        translate([-b_len, thick])
        square([b_len * 2, b_thick]);

        translate([-r_thick / 2, b_thick + thick])
        square([r_thick, r_outset + thick]);
    }
}

module clip_body_shape() {
    translate([-b_len / 2, 0])
    square([b_len, b_thick + thick * 2]);

    translate([-(r_thick + thick * 2) / 2, b_thick + thick])
    square([r_thick + thick * 2, r_outset + thick]);
}

module round_shape() {
    offset(r=-rr)
    offset(r=rr * 2)
    offset(r=-rr)
    children();
}

module clip_body() {
    minkowski() {
        union() {
            translate([0, 0, rr])
            linear_extrude(height=r_height + thick - rr * 2)
            offset(delta=-rr)
            round_shape()
            hull()
            clip_body_shape();
        }
        union() {
            // sphere(r=rr);
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=rr, r2=0, h=rr);
        }
    }
}

module clip() {
    difference() {
        clip_body();
        clip_cut();
    }
}

module main() {
    color("plum", 0.8)
    rotate([0, 180, 0])
    clip();
}

main();
