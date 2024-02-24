/*
 * Tongs clip
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Size] */

// Interior width in millimeters
Width = 22;

// Interior length in millimeters
Length = 20;

// Height in millimeters
Height = 10;

// Wall thickness in millimeters
Thickness = 4;

// Screw head clearance width
Cutout_Width = 7;
Cutout_Depth = 2.5;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module box_extrude(width, length, radius) {
    corners_data = [
        // Rotate angle, X direction, Y direction
        [0, -1, -1],
        [90, 1, -1],
        [180, 1, 1],
        [270, -1, 1],
    ];
    // Corners
    for (i = [0:1:len(corners_data) - 1]) {
        translate([
            corners_data[i][1] * (width - radius * 2) / 2,
            corners_data[i][2] * (length - radius * 2) / 2,
            0
        ])
        rotate([0, 0, 180 + corners_data[i][0]])
        union() {
            rotate_extrude(angle=90)
            children();
        }
    }
    // Sides
    for (i = [0:1:len(corners_data) - 1]) {
        extrude_length = (
            (corners_data[i][0] % 180 == 0 ? width : length) - radius * 2
        );
        translate([
            corners_data[i][1] * (width - radius * 2) / 2,
            corners_data[i][2] * (length - radius * 2) / 2,
            0
        ])
        rotate([0, 0, corners_data[i][0]])
        translate([extrude_length, 0, 0])
        rotate([90, 0, -90])
        linear_extrude(height=extrude_length)
        children();
    }
}

module tongs_clip() {
    edge_radius = Thickness / 2;
    retaining_lip_radius = edge_radius / 2;
    render()
    difference() {
        box_extrude(Width, Length, edge_radius)
        translate([edge_radius, 0])
        union() {
            translate([0, Height / 2])
            circle(retaining_lip_radius);
            offset(edge_radius / 2)
            offset(-edge_radius / 2)
            square([Thickness, Height]);
        }
        hull()
        for (my = [0, (Length - retaining_lip_radius) / 2])
        translate([0, my, 0])
        scale([1, retaining_lip_radius / Cutout_Width, 1])
        cylinder(d=Cutout_Width, h=Height);
    }
}

module main() {
    color("coral", 0.8)
    tongs_clip();
}

main();
