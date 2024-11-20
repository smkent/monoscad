/*
 * ESPHome 40x40mm PCB mount
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <esp-pcb-40mm-library.scad>;
include <project-box-library.scad>;

/* [Rendering Options] */
Print_Orientation = true;
Part = "all"; // [preview: Assembled preview, all: Side-by-side, box: Box, lid: Lid]
PCB_Preview = true;

/* [40mm PCB Size] */
// 40(+2)mm units
PCB_Units = [1, 1]; // [1:1:3]
PCB_Mount_Height = 6;
Extend_PCB_Mount = false;

/* [Box Size] */
Box_Fit = [20, 20];
Height = 30;
Thickness = 2.4;
// For a smooth look, set Lid Height to (Thickness + Edge Radius).
Lid_Height = 3.9;

Screw_Diameter = 3.0;
Screw_Style = "flat"; // [flat: Flat, countersink: Countersink, inset: Inset]
Insert_Diameter = 4.5;
Insert_Depth = 10;

/* [Mounting Screws] */
Mounting_Screws_X = true;
Mounting_Screws_Y = false;
Mounting_Screw_Diameter = 4.0;
Mounting_Screw_Style = "flat"; // [flat: Flat, countersink: Countersink, inset: Inset]

/* [Hexagon Pattern] */
Pattern_Bottom = false;
Pattern_Lid = false;
// 1 = pattern, 0 = no pattern
Pattern_Walls = [0, 0, 0, 0]; // [0:1:1]

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

// Internal Modules //

module ebox_interior() {
    pcb40_round_3d()
    pcb40_supports(cut=!Extend_PCB_Mount);
    pcb40_box_interior();
}

module ebox_cutouts() {
    $p_height = $p_height - Thickness;
    translate([0, 0, Thickness])
    pcb40_screw_holes(chamfer_bottom=false);
}

module ebox_extras() {
    if ($preview && PCB_Preview)
    translate([0, 0, Thickness + PCB_Mount_Height + slop])
    pcb40_pcb();
}

pcb40(
    x=PCB_Units[0],
    y=PCB_Units[1],
    height=PCB_Mount_Height + Thickness
)
ebox(
    dimensions=concat(pcb40_dimensions() + Box_Fit, Height),
    thickness=Thickness,
    lid_height=Lid_Height,
    screw_diameter=Screw_Diameter,
    insert_diameter=Insert_Diameter,
    insert_depth=Insert_Depth,
    screw_style=Screw_Style,
    mounting_screws_x=Mounting_Screws_X,
    mounting_screws_y=Mounting_Screws_Y,
    mounting_screw_diameter=Mounting_Screw_Diameter,
    mounting_screw_style=Mounting_Screw_Style,
    pattern_lid=Pattern_Lid,
    pattern_bottom=Pattern_Bottom,
    pattern_walls=Pattern_Walls
)
ebox_adjustments(
    print_orientation=Print_Orientation,
    screw_inset=Screw_Inset,
    corner_radius=Corner_Radius,
    edge_radius=Edge_Radius,
    screw_count=Screw_Count,
    screw_fit=Screw_Fit
) {
    ebox_part(Part);
}

// User Modules //

module pcb40_box_interior() {
    // Add custom cutouts here
}
