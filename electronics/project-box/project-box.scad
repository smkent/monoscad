/*
 * Electronics project box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <honeycomb-openscad/honeycomb.scad>;
include <project-box-library.scad>;

/* [Rendering Options] */
Print_Orientation = true;
Part = "preview"; // [preview: Assembled preview, all: Side-by-side, box: Box, lid: Lid]
PCB_Preview = true;

/* [Size] */
// Width, Length, Height
Dimensions = [60, 50, 30];
Thickness = 2.4;
// For a smooth look, set Lid Height to (Thickness + Edge Radius).
Lid_Height = 3.9;

Screw_Diameter = 3.0;
Screw_Style = "flat"; // [flat: Flat, countersink: Countersink, inset: Inset]
Insert_Diameter = 4.5;
Insert_Depth = 10;

/* [Mounting Screws] */
Mounting_Screws = true;
Mounting_Screw_Diameter = 4.0;
Mounting_Screw_Style = "flat"; // [flat: Flat, countersink: Countersink, inset: Inset]

/* [Hexagon Fill Pattern] */
Fill_Bottom = false;
Fill_Lid = false;
// 1 = fill, 0 = no fill
Fill_Walls = [0, 0, 0, 0]; // [0:1:1]

/* [PCB] */
PCB_Mount = true;
PCB_Dimensions = [40, 40];
PCB_Screw_Inset = 3;
PCB_Screw_Diameter = 3.0;
PCB_Insert_Diameter = 4.5;
PCB_Mount_Height = 5;

/* [Advanced Options] */
Screw_Inset = 4;
Corner_Radius = 3; // [0:0.1:5]
Edge_Radius = 1.5; // [0:0.1:4]
Screw_Count = 4; // [2: 2, 4: 4]
Screw_Fit = 0.4;

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 4 : 0.4;

pcb_thickness = 1.6;

// Modules //

module at_pcb_screws() {
    for (mx = [0, 1])
    for (my = [0, 1])
    mirror([mx, 0])
    mirror([0, my])
    translate([
        PCB_Dimensions[0] / 2 - PCB_Screw_Inset,
        PCB_Dimensions[1] / 2 - PCB_Screw_Inset
    ])
    children();
}

module pcb_mount() {
    translate([0, 0, $e_thickness])
    at_pcb_screws()
    difference() {
        cylinder(d=PCB_Insert_Diameter * 2, h=PCB_Mount_Height);
        screw_hole(d=PCB_Insert_Diameter, h=PCB_Mount_Height);
    }
}

module pcb() {
    if ($preview)
    color("seagreen", 0.6)
    translate([0, 0, $e_thickness + PCB_Mount_Height + slop])
    linear_extrude(height=pcb_thickness)
    difference() {
        square(PCB_Dimensions, center=true);
        at_pcb_screws()
        circle(d=PCB_Screw_Diameter);
    }
}

module ebox_interior() {
    if (PCB_Mount)
    pcb_mount();
}

module ebox_extras() {
    if (PCB_Mount && PCB_Preview)
    pcb();
}

ebox(
    dimensions=Dimensions,
    thickness=Thickness,
    lid_height=Lid_Height,
    screw_diameter=Screw_Diameter,
    insert_diameter=Insert_Diameter,
    insert_depth=Insert_Depth,
    screw_style=Screw_Style,
    mounting_screws=Mounting_Screws,
    mounting_screw_diameter=Mounting_Screw_Diameter,
    mounting_screw_style=Mounting_Screw_Style,
    fill_lid=Fill_Lid,
    fill_bottom=Fill_Bottom,
    fill_walls=Fill_Walls
)
ebox_adjustments(
    print_orientation=Print_Orientation,
    screw_inset=Screw_Inset,
    corner_radius=Corner_Radius,
    edge_radius=Edge_Radius,
    screw_count=Screw_Count,
    screw_fit=Screw_Fit
)
ebox_part(Part);
