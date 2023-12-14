/*
 * Sovol SV06 (Plus) MP1584 buck converter mount for mainboard fan
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

use <mp1584-case.scad>;

/* [Rendering Options] */
Render_Mode = "print"; // [print: Print orientation, top: MP1584 case top, preview: Installed model preview]

/* [Options] */
Potentiometer_Hole = "top"; // [top: MP1584 facing upright, bottom: MP1584 facing mainboard box cover]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

fit = 0.2;
slop = 0.001;

fan_center = [45, 83.5];
fan_screws_pos = vec_add([
    [61, 99.5],
    [29, 99.5],
    [29, 67.5],
    [61, 67.5],
], -fan_center);

board_size = vec_add([22.2, 16.9, 4], fit);
potentiometer_hole = Potentiometer_Hole;
mp1584_case_pos = (59 / 2 + 10.5);

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module original_mainboard_box_front() {
    color("#ccc", 0.6)
    import("sovol-sv06-plus-motherboard-box-front.stl", convexity=4);
}

module box_front() {
    intersection() {
        linear_extrude(height=100)
        square(500, center=true);

        rotate([-90, 180, 0])
        translate([0, -1.5, 0])
        original_mainboard_box_front();
    }
}

module screw_posts_cut() {
    difference() {
        children();
        for (pos = fan_screws_pos)
        translate(pos)
        cylinder(d=5.5 + fit, h=20, center=true);
    }
}

module rounded_square(dimensions, r, center=false) {
    offset(r=r)
    offset(r=-r)
    square(dimensions, center=center);
}

module fan_bracket() {
    fan_sz = 40;
    hh = 1.2;
    htop = 2.1;
    dd = 10;
    od = fan_sz + 16;
    linear_extrude(height=hh)
    offset(r=-dd / 2)
    offset(r=dd / 2)
    union() {
        intersection() {
            rounded_square(od, center=true, dd);
            for (rot = [0:90:360 - slop])
            rotate(rot)
            translate(fan_screws_pos[1]) {
                circle(d=dd);
                offset(r=dd / 2)
                offset(r=-dd / 2)
                translate([-dd / 2, dd / 2])
                square(dd * 2, center=true);
            }
        }
        difference() {
            rounded_square(od, center=true, dd);
            rounded_square(40, center=true, dd / 2);
        }
    }
    linear_extrude(height=htop)
    difference() {
        rounded_square(od, center=true, dd);
        rounded_square(42, center=true, dd / 2);
    }
}

module bracket() {
    color("lightsteelblue", 0.8)
    render(convexity=2)
    union() {
        translate([fan_center[0], -fan_center[1]])
        mirror([1, 0, 0])
        translate(fan_center)
        screw_posts_cut()
        fan_bracket();

        translate([0, -mp1584_case_pos, 0])
        mp1584_case(part="bottom", potentiometer_hole=potentiometer_hole);
    }
}

module main() {
    if (Render_Mode == "print" || Render_Mode == "preview") {
        bracket();
        if ($preview)
        if (Render_Mode == "preview") {
            translate([0, -mp1584_case_pos, 6.30 + 2])
            rotate([180, 0, 0])
            mp1584_case(part="top", potentiometer_hole=potentiometer_hole);
            translate([fan_center[0], -fan_center[1], -5])
            box_front();
        }
    } else if (Render_Mode == "top") {
        mp1584_case(part="top", potentiometer_hole=potentiometer_hole);
    }
}

main();
