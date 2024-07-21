/*
 * Cable clips
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
// All units in millimeters

Thickness = 2.4;
Clip_Diameter = 5;
Screw_Diameter = 4.5; // [1:0.1:10]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

width = Screw_Diameter * 2.5;
clip_od = Clip_Diameter + Thickness * 2;
slop = 0.001;

// Modules //

module round_circle(od, extend=0) {
    hull() {
        circle(d=od);
        translate([-od / 2, -od / 2 - extend])
        square([od, od / 2]);
    }
}

module clip_hook() {
    translate([width / 2 + Thickness + Clip_Diameter / 2, 0])
    intersection() {
        translate([0, Clip_Diameter / 2])
        difference() {
            round_circle(clip_od);
            round_circle(Clip_Diameter, extend=Thickness * 2);
        }
        translate([-clip_od * 5, 0])
        square([clip_od * 10, clip_od * 10]);
    }
}

module clip_foot() {
    translate([-width / 2, 0])
    square([width + Thickness, Thickness]);
}

module screw_hole() {
    rotate([270, 0, 0])
    translate([0, 0, -Screw_Diameter / 2 + Thickness])
    union() {
        translate([0, 0, -slop])
        cylinder(d1=Screw_Diameter, d2=Screw_Diameter * 2, h=Screw_Diameter / 2 + slop * 2);
        translate([0, 0, Screw_Diameter / 2])
        cylinder(h=(Thickness + Clip_Diameter) * 2, d=Screw_Diameter * 2);
        translate([0, 0, Thickness * 2])
        scale([1, 1.05])
        mirror([0, 0, 1])
        cylinder(h=(Thickness + Clip_Diameter) * 2, d=Screw_Diameter);
    }
}

module add_screw_hole() {
    difference() {
        children();
        screw_hole();
    }
}

module clip() {
    rr = Thickness * 0.48;
    add_screw_hole()
    linear_extrude(height=width, center=true)
    offset(r=-rr)
    offset(r=rr * 2)
    offset(r=-rr)
    union() {
        clip_hook();
        clip_foot();
    }
}

module orient_model() {
    if (Print_Orientation) {
        children();
    } else {
        rotate([90, 0, 0])
        children();
    }
}

module main() {
    orient_model()
    color("lemonchiffon", 0.9)
    render()
    clip();
}

main();
