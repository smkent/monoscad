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

/* [Clip Options] */
Countersink_Screw = true;

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

width = Screw_Diameter * 2.5;
clip_od = Clip_Diameter + Thickness * 2;
slop = 0.001;
foot_height = max(Clip_Diameter, Thickness);

// Modules //

module at_clip_hook() {
    translate([width / 2 + Thickness + Clip_Diameter / 2, 0])
    children();
}

module round_circle(od, extend=0) {
    hull() {
        circle(d=od);
        translate([-od / 2, -od / 2 - extend])
        square([od, od / 2]);
    }
}

module clip_hook_cut() {
    difference() {
        children();
        at_clip_hook()
        translate([0, Clip_Diameter / 2])
        round_circle(Clip_Diameter, extend=Thickness * 2);
    }
}

module clip_hook() {
    at_clip_hook()
    intersection() {
        translate([0, Clip_Diameter / 2])
        round_circle(clip_od);
        translate([-clip_od * 5, 0])
        square([clip_od * 10, clip_od * 10]);
    }
}

module clip_foot() {
    translate([-(width + Thickness) / 2, 0])
    square([width + Thickness * 2, foot_height]);
}

module screw_hole() {
    rotate([270, 0, 0])
    translate([0, 0, -Screw_Diameter / 2 + foot_height])
    union() {
        if (Countersink_Screw) {
            translate([0, 0, -slop])
            cylinder(d1=Screw_Diameter, d2=Screw_Diameter * 2, h=Screw_Diameter / 2 + slop * 2);
            translate([0, 0, Screw_Diameter / 2])
            cylinder(h=(Thickness + Clip_Diameter) * 2, d=Screw_Diameter * 2);
        }
        translate([0, 0, foot_height * 2])
        scale([1, 1.05])
        mirror([0, 0, 1])
        cylinder(h=(foot_height + Clip_Diameter) * 2, d=Screw_Diameter);
    }
}

module add_screw_hole() {
    difference() {
        children();
        screw_hole();
    }
}

module clip_edges() {
    intersection() {
        children();
        hull() {
            rotate([90, 0, 0])
            cylinder(d=width + Thickness, h=foot_height * 10, center=true);
            translate([(Clip_Diameter + Thickness) * 2, 0, 0])
            cube([width, foot_height * 10, width + Thickness], center=true);
        }
    }
}

module clip() {
    rr = min(Thickness, Clip_Diameter) * 0.25;
    clip_edges()
    add_screw_hole()
    linear_extrude(height=width, center=true)
    offset(r=-rr)
    offset(r=rr * 2)
    offset(r=-rr)
    clip_hook_cut()
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
