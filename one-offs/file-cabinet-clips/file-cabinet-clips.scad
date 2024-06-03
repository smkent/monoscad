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

screw_d = 3.5; // [3:0.1:6]

/* [Advanced Options] */
screw_hole = true;

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

b_len = inset * 2 + r_thick;
back_add = min(r_outset, 2);
rr = thick * 0.48;
slop = 0.1;

// Modules //

module clip_cut() {
    translate([0, 0, -slop])
    linear_extrude(height=r_height + slop)
    round_shape(r=min(thick, r_thick) * 0.48)
    union() {
        translate([-b_len, thick])
        square([b_len * 2, b_thick]);

        translate([-r_thick / 2, b_thick + thick])
        square([r_thick, (r_outset + thick) * 2]);
    }
}

module clip_body_shape() {
    translate([-b_len / 2, -back_add])
    square([b_len, b_thick + thick * 2 + back_add]);

    translate([-(r_thick + thick * 2) / 2, b_thick + thick])
    square([r_thick + thick * 2, r_outset + thick]);
}

module round_shape(r=rr) {
    offset(r=-r)
    offset(r=r * 2)
    offset(r=-r)
    children();
}

module clip_body_poly() {
    translate([0, 0, rr])
    linear_extrude(height=r_height + thick - rr * 2)
    offset(delta=-rr)
    round_shape()
    hull()
    clip_body_shape();
}

module clip_body_wing() {
    w_thick = thick + back_add;
    translate([0, 0, -(r_height + thick)])
    difference() {
        round_poly()
        translate([0, 0, rr])
        linear_extrude((r_height + thick) * 2 - rr * 2)
        offset(delta=-rr)
        translate([-b_len / 2, -thick / 2])
        square([b_len, w_thick * 2]);

        linear_extrude((r_height + thick) * 2 * 2, center=true)
        translate([-b_len, -thick / 2 + w_thick])
        square([b_len * 2, w_thick]);
    }
}

module round_poly() {
    minkowski() {
        children();
        union() {
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=rr, r2=0, h=rr);
        }
    }
}

module clip_body() {
    render() {
        round_poly()
        clip_body_poly();
        clip_body_wing();
    }
}

module screw_hole() {
    // translate([0, b_thick / 2 + thick, r_height + thick / 2])
    translate([0, 0, -(r_height + thick) / 2])
    rotate([90, 0, 0])
    union() {
        linear_extrude(height = thick * 4, center=true)
        circle(d=screw_d);

        translate([0, 0, -screw_d + back_add])
        cylinder(d1=screw_d, d2=screw_d * 2, h=screw_d + slop);
    }
}

module screw_holes() {
    for (mx = [0, 1])
    mirror([mx, 0])
    translate([screw_d * 1.25, 0])
    screw_hole();
}

module clip() {
    rotate([0, 0, 180])
    render()
    difference() {
        clip_body();
        clip_cut();
        if (screw_hole)
        screw_holes();
    }
}

module orient_model() {
    if (Print_Orientation) {
        rotate([0, 180, 0])
        children();
    } else {
        children();
    }
}

module main() {
    orient_model()
    color("mintcream", 0.8)
    clip();
}

main();
