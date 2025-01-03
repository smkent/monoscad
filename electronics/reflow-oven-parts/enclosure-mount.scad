/*
 * Controleo3 reflow oven add-ons
 * Enclosure mounting spacer
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Size] */
// All units in millimeters

Dimensions = [38, 15];

Thickness = 4; // [1.5:0.1:10]
Diameter = 35;
Hole_Diameter = 16; // [10:0.1:30]
Screw_Hole_Diameter = 3; // [2:0.1:5]
Screw_Hole_Offset = 14;
Screw_Separation = 19;
Grommet_Thickness = 3; // [0.8:0.1:5]
Grommet_Depth = 2; // [0.4:0.1:5]

/* [Advanced Options] */
Screw_Hole_Fit = 0.2; // [0:0.05:1]
Screw_Hole_Style = "inset"; // [flat: Flat, countersink: Countersink, inset: Inset]
Edge_Radius = 0.4; // [0:0.1:3]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 2 : 0.4;

slop = 0.001;

// Modules //

module _round_3d(radius = Edge_Radius) {
    if (radius == 0) {
        children();
    } else {
        render()
        minkowski() {
            children();
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=radius, r2=0, h=radius);
        }
    }
}

module _screw_hole(d, h, fit=0, style="flat", print_upside_down=false) {
    inset_bare_min_h = 1.4;
    inset_min_h = (style == "inset") ? max((h - d), inset_bare_min_h) - (h - d) : 0;
    translate([0, 0, -slop])
    cylinder(d=(d + fit), h=h + slop * 2);
    if (style == "countersink" || style == "inset") {
        translate([0, 0, h + inset_min_h + slop * 2])
        mirror([0, 0, 1])
        cylinder(d1=d * 2, d2=d * (style == "inset" ? 2 : 1), h=d);
    }
    if (style == "inset" && print_upside_down) {
        layer_height = 0.2;
        translate([0, 0, (h + inset_min_h) - d - layer_height])
        linear_extrude(height=layer_height + slop * 2)
        intersection() {
            square([d * 2, d + fit], center=true);
            circle(d=d*2);
        }
    }
}

module at_enclosure_mount_screw_holes() {
    for (mx = [0, 1])
    mirror([mx, 0])
    translate([Screw_Separation / 2, 0])
    children();
}

module enclosure_mount_body() {
    difference() {
        translate([0, 0, Edge_Radius])
        union() {
            rr = 2;
            _round_3d()
            difference() {
                linear_extrude(height=Thickness - Edge_Radius * 2)
                offset(r=rr)
                offset(r=-rr)
                square(Dimensions, center=true);
                translate([0, 0, Dimensions[1] + (Thickness - Edge_Radius * 2) / 2])
                rotate([0, 90, 0])
                cylinder(h=Dimensions[0], d=Dimensions[1] * 2, center=true);
            }
        }
        if(0)
        union() {
            dd = Hole_Diameter - Grommet_Thickness * 2;
            translate([0, 0, slop])
            linear_extrude(height=Thickness + Grommet_Depth + slop * 2)
            circle(d=dd);
            translate([0, 0, -slop])
            cylinder(d2=dd, d1=dd + Edge_Radius * 2, h=Edge_Radius);
            translate([0, 0, Thickness + Grommet_Depth - Edge_Radius + slop])
            cylinder(d1=dd, d2=dd + Edge_Radius * 2, h=Edge_Radius);
        }
    }
}

module enclosure_mount_screw_holes() {
    translate([0, 0, Thickness])
    mirror([0, 0, 1])
    at_enclosure_mount_screw_holes()
    hull() {
        oy = (Dimensions[1] - Screw_Hole_Diameter) / 4;
        for (my = [0, 1])
        mirror([0, my])
        translate([0, oy, 0])
        cylinder(d=Screw_Hole_Diameter + Screw_Hole_Fit, h=Thickness * 2);
    }
}

module panel_grommet() {
    difference() {
        enclosure_mount_body();
        enclosure_mount_screw_holes();
    }
}

module main() {
    color("yellowgreen", 0.8)
    panel_grommet();
}

main();
