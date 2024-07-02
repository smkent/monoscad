/*
 * Bicycle bottle cage mount riser
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
Screw_Fit = 0.2; // [0:0.1:2]
Round_Radius = 1;

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Constants //

screw_spacing = 64;
screw_d = 5;
thick = 5;
rr = Round_Radius;
slop = 0.001;

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module at_screws() {
    translate([-screw_spacing / 2, 0, 0])
    for (ox = [0, screw_spacing])
    translate([ox, 0, 0])
    children();
}

module screw_holes() {
    shr = rr / 2;
    render()
    difference() {
        children();
        at_screws() {
            translate([0, 0, -slop])
            linear_extrude(height=thick * 2 + slop * 2)
            circle(d=screw_d + Screw_Fit);
            translate([0, 0, thick])
            for (mz = [0, 1])
            mirror([0, 0, mz])
            translate([0, 0, -(slop) - thick])
            cylinder(
                d1=screw_d + Screw_Fit + shr,
                d2=screw_d + Screw_Fit,
                h=shr
            );
        }
    }
}

module screw_risers() {
    at_screws()
    translate([0, 0, rr])
    linear_extrude(height=thick * 2 - rr * 2)
    circle(d=screw_d * 3 - rr * 2);
}

module round_3d() {
    if (Round_Radius == 0) {
        children();
    } else {
        render()
        minkowski() {
            children();
            // sphere(r=rr);
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=rr, r2=0, h=rr);
        }
    }
}

module riser() {
    screw_holes()
    round_3d()
    render() {
        translate([0, 0, rr])
        linear_extrude(height=thick - rr * 2)
        // offset(r=screw_d)
        // offset(r=-screw_d)
        // square(vec_add([screw_spacing + screw_d, screw_d], screw_d * 2 - rr * 2), center=true);
        hull() {
            at_screws()
            circle(d=screw_d * 3 - rr * 2);
        }
        screw_risers();
    }
}

module main() {
    color("lightsteelblue", 0.8)
    riser();
}

main();
