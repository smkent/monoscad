/*
 * Monitor arm tray mount
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

use <Chamfers-for-OpenSCAD/Chamfer.scad>;
use <honeycomb-openscad/honeycomb.scad>;

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
// All units in millimeters

tray_grip_depth = 120;
tray_grip_width = 200;
tray_grip_height = 3;
tray_support_width = 15;
grip_thickness = 10;
grip_height = 42;
grip_depth = grip_thickness * 2;
chamfer = 3.0;
screw_diameter = 5;
screw_inset = 30;

/* [Advanced Options] */
Honeycomb = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

pole_diam = 35;
pole_lip_diam = 39.5 + 1;
outer_diam = 50;
base_len = 100;
pole_sep = 11;

width = 100;
depth = outer_diam + grip_depth;


// Modules //

module cut_shape_for_base() {
    scale([base_len, outer_diam / 2])
    circle(1);
}

module cut_shape_for_poles() {
    for(x = [-1:1:1]) {
        translate([(pole_diam + pole_sep) * x, 0])
        union() {
            circle(pole_diam / 2);
            translate([-pole_diam/2, 0])
            square([pole_diam, outer_diam]);
        }
    }
}

module tray_support() {
    extra_ht = max(0, grip_thickness - tray_grip_height);
    scale([1, (tray_grip_depth - chamfer * 2) / (grip_height + extra_ht), 1])
    chamferCylinder(tray_support_width, grip_height + extra_ht, a=90);
}

module hc(x, y, z) {
    difference() {
        cube([x, y, z]);
        linear_extrude(z)
        honeycomb(x, y, 12, 3);
    }
}

module screw_hole() {
    rad = screw_diameter / 2;
    linear_extrude(height=tray_grip_height)
    circle(rad);
}

module tray_top() {
    inset = screw_inset;
    difference() {
        chamferCube([tray_grip_width, chamfer + tray_grip_depth, tray_grip_height], ch=chamfer);
        translate([tray_grip_width - inset, inset, 0]) screw_hole();
        translate([inset, inset, 0]) screw_hole();
        translate([tray_grip_width - inset, tray_grip_depth - inset, 0]) screw_hole();
        translate([inset, tray_grip_depth - inset, 0]) screw_hole();
    }
}

module tray_body() {
    cubeht = grip_thickness + grip_height;
    slop = 3;
    difference() {
        translate([-width / 2, -depth / 2, 0])
        chamferCube([width, depth, cubeht], ch=chamfer);

        if (Honeycomb) {
            translate([-width/2 + tray_support_width + chamfer + slop, -depth / 2 + 10, grip_thickness])
            rotate([90, 0, 0])
            hc(width - 2 * (tray_support_width + chamfer + slop), grip_height - grip_thickness, 10);
        }
    }

    translate([-tray_grip_width/2, 1.5 - tray_grip_depth - outer_diam/2, cubeht - tray_grip_height])
    tray_top();

    ww = min(width, tray_grip_width) - tray_support_width;
    difference() {
        for(i = [-1:2:1]) {
            translate([tray_support_width / 2 + i * (ww / 2 - chamfer), -outer_diam/2, cubeht - tray_grip_height + chamfer])
            rotate([90, 90, -90])
            tray_support();
        }
        // Remove any support overhang past the tray top
        translate([-(ww + chamfer / 2), -outer_diam / 2 - tray_grip_depth, cubeht])
        cube([ww * 2 + chamfer, tray_grip_depth, cubeht]);
    }
}

module tray_mount() {
    difference() {
        tray_body();
        linear_extrude(height=grip_height)
        cut_shape_for_base();
        linear_extrude(height=grip_height + grip_thickness)
        cut_shape_for_poles();
        translate([0, 0, grip_height])
        linear_extrude(height=2)
        circle(pole_lip_diam / 2);
    }
}

module orient_main() {
    if (Print_Orientation) {
        translate([0, 0, grip_thickness + grip_height])
        rotate([0, 180, 0])
        children();
    } else {
        children();
    }
}

module main() {
    color("darkseagreen", 0.8)
    orient_main()
    tray_mount();
}

main();
