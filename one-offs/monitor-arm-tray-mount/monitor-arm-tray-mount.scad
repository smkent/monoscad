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
tray_support_width = 5;
grip_thickness = 8;
grip_height = 42;
grip_depth = 20;
grip_screw_catch_height = 10;
chamfer = 3.0;
tray_screw_diameter = 5;
tray_screw_inset = 30;
grip_screw_diameter = 3;
pole_base_height = 17;

round_radius = 5;

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

pole_base_diam = 41;


// Modules //

module cut_shape_for_base() {
    scale([base_len, outer_diam / 2])
    circle(r=1, $fn=100);
}

module cut_shape_for_poles(single=false) {
    for(x = (single ? [0] : [-1:1:1])) {
        translate([(pole_diam + pole_sep) * x, 0])
        union() {
            circle(d=pole_diam);
            translate([-pole_diam/2, 0])
            square([pole_diam, outer_diam]);
        }
    }
}

module tray_support() {
    extra_ht = max(0, grip_thickness - tray_grip_height);
    denominator = grip_height + extra_ht + grip_screw_catch_height + chamfer * 0.75;
    scale([1, (tray_grip_depth - chamfer * 2) / denominator, 1])
    chamferCylinder(tray_support_width, denominator, a=90);
}

module hc(x, y, z) {
    difference() {
        cube([x, y, z]);
        linear_extrude(z)
        honeycomb(x, y, 12, 3);
    }
}

module screw_hole() {
    linear_extrude(height=tray_grip_height * 4, center=true)
    circle(d=tray_screw_diameter);
}

module at_each_screw_hole() {
    inset = tray_screw_inset;
    for (x = [inset, tray_grip_width - inset])
    for (y = [inset, tray_grip_depth - inset])
    translate([x, y, 0])
    children();
}

module tray_top() {
    center_offset = [-tray_grip_width/2, 1.5 - tray_grip_depth - outer_diam/2, 0];
    translate(center_offset)
    translate([0, 0, grip_thickness + grip_height - tray_grip_height])
    difference() {
        chamferCube([tray_grip_width, chamfer + tray_grip_depth, tray_grip_height], ch=chamfer);
        at_each_screw_hole()
        screw_hole();

        if (Honeycomb)
        difference() {
            slop = 20;
            hcdims = [for (i = [tray_grip_width, chamfer + tray_grip_depth]) i - slop];
            translate([slop / 2, slop / 2])
            hc(hcdims[0], hcdims[1], tray_grip_height);
            // Ensure screw holes are attached
            at_each_screw_hole()
            cylinder(d=tray_screw_diameter * 4.2, h=tray_grip_height * 2, center=true);
            // Remove pattern around supports
            translate(-center_offset)
            at_each_tray_support()
            translate([0, -tray_grip_depth / 2 + chamfer, 0])
            cube([tray_support_width * 2.9, tray_grip_depth, tray_grip_height * 2], center=true);
        }
    }
}

module at_each_tray_support() {
    ww = min(width, tray_grip_width) - tray_support_width;
    for (i = [-1:2:1]) {
        translate([(i * ww) / 2, -outer_diam/2, 0])
        children();
    }
}

module tray_supports() {
    cubeht = grip_thickness + grip_height;
    ww = min(width, tray_grip_width) - tray_support_width;
    render()
    difference() {
        at_each_tray_support()
        translate([tray_support_width / 2, 0, cubeht - tray_grip_height + chamfer])
        rotate([90, 90, -90])
        tray_support();
        // Remove any support overhang past the tray top
        translate([0, -outer_diam / 2 - tray_grip_depth / 2, cubeht])
        linear_extrude(height=cubeht)
        square([ww * 2, tray_grip_depth] * 2, center=true);
    }
}

module tray_grip_screw_holes() {
    // grip_screw_diameter;
    translate([0, 0, -grip_screw_catch_height / 2])
    for (mx = [0, 1])
    mirror([mx, 0, 0])
    translate([(pole_diam + pole_sep) / 2, 0, 0])
    rotate([90, 0, 0])
    union() {
        screw_len = 60; // pole_diam + grip_depth * 2;
        mirror([0, 0, 1])
        cylinder(d=grip_screw_diameter - 0.1, h=screw_len);
        cylinder(d=grip_screw_diameter + 0.2, h=screw_len);
        translate([0, 0, screw_len / 2])
        cylinder(d=grip_screw_diameter * 2, h=screw_len);
    }
}

module tray_grip_body() {
    rr = chamfer;
    extrudeht = grip_thickness + grip_height + grip_screw_catch_height - rr;
    minkowski() {
        union() {
            translate([0, 0, -grip_screw_catch_height + rr / 2])
            linear_extrude(height=extrudeht)
            offset(r=-rr / 2)
            offset(r=round_radius)
            offset(r=-round_radius)
            difference() {
                square([width, depth], center=true);
                cut_shape_for_poles();
            }
        }
        if (rr > 0)
        union() {
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(d1=rr, d2=0, h=rr / 2);
            // sphere(r=rr);
        }
    }
}

module tray_grip() {
    slop = 3;
    render()
    difference() {
        tray_grip_body();
        tray_grip_screw_holes();
        if (Honeycomb) {
            translate([-width/2 + tray_support_width + chamfer + slop, -depth / 2 + 10, grip_thickness - grip_screw_catch_height / 2])
            rotate([90, 0, 0])
            translate([0, 0, -grip_depth])
            hc(width - 2 * (tray_support_width + chamfer + slop), grip_height - grip_thickness + grip_screw_catch_height / 2, grip_depth * 2);
        }
    }
}

module tray_body() {
    tray_grip();
    tray_top();
    tray_supports();
}

module tray_mount() {
    render()
    difference() {
        tray_body();
        linear_extrude(height=grip_height * 2, center=true)
        cut_shape_for_base();
        translate([0, 0, grip_height])
        linear_extrude(height=2)
        circle(d=pole_lip_diam);
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
