/*
 * ESPHome 40x40mm PCB mount
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <esp-pcb-40mm-library.scad>;

/* [Rendering Options] */
Preview_PCB = true;

/* [PCB] */
// 40(+2)mm units
PCB_Units = [1, 1]; // [1:1:3]

/* [PCB Support] */
Height = 6; // [5:0.5:20]
Screw_Insert_Diameter = 4.5; // [3:0.1:6]
PCB_Support_Chamfer = 1.5; // [0:0.1:3]

/* [Base] */
Thickness = 2.0; // [1:0.1:5]
Edge_Radius = 0.5; // [0:0.5:1]

/* [Features] */
Mounting_Screw_Holes_X = false;
Mounting_Screw_Holes_Y = false;
Mounting_Screw_Hole_Chamfer = false;
Mounting_Screw_Diameter = 4.5;

/* [Advanced Options] */
Inner_Holes = true;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module at_base_mount_screws(enable_x=true, enable_y=true) {
    screw_offset = Mounting_Screw_Diameter + (pcb_grid + pcb_grid_sep) / 2;
    _at_pcb40_grid() {
        if (enable_x && Mounting_Screw_Holes_X) {
            if ($p_grid_x == 0)
            translate([-screw_offset, 0])
            children();
            if ($p_grid_x == PCB_Units[0] - 1)
            translate([screw_offset, 0])
            children();
        }
        if (enable_y && Mounting_Screw_Holes_Y) {
            if ($p_grid_y == 0)
            translate([0, -screw_offset])
            children();
            if ($p_grid_y == PCB_Units[1] - 1)
            translate([0, screw_offset])
            children();
        }
    }
}

module base_shape() {
    pcb40_perimeter_shape();
}

module base_cutouts() {
    _at_pcb40_grid()
    offset(r=-Edge_Radius)
    offset(r=hole_to_edge * 1.25)
    offset(r=-hole_to_edge * 1.25)
    square(pcb_grid - (hole_to_edge * 2), center=true);
}

module base_supports() {
    intersection() {
        linear_extrude(height=Height * 2)
        base_shape();
        translate([0, 0, Edge_Radius])
        // linear_extrude(height=Height - Edge_Radius * 2)
        _at_pcb40_grid_corners()
        _pcb40_hull_pair(Height - Edge_Radius * 2) {
            offset(r=PCB_Support_Chamfer)
            _pcb40_support_quad_shape();
            _pcb40_support_quad_shape();
        }
    }
}

module base_mount_edges() {
    offset(r=-hole_to_edge)
    offset(r=hole_to_edge)
    union() {
        base_shape();
        for (enable_x = [0, 1])
        hull() {
            offset(r=(-hole_to_edge - hole_inset))
            base_shape();
            at_base_mount_screws(enable_x=enable_x, enable_y=!enable_x)
            circle(d=Mounting_Screw_Diameter * (Mounting_Screw_Hole_Chamfer ? 3 : 2.25));
        }
    }
}

module base_body() {
    base_supports();

    translate([0, 0, Edge_Radius])
    linear_extrude(height=Thickness - Edge_Radius * 2)
    difference() {
        union() {
            base_shape();
            base_mount_edges();
        }
        base_cutouts();
    }
}

module base_holes() {
    at_base_mount_screws() {
        // translate([0, 0, -slop])
        translate([0, 0, Thickness])
        mirror([0, 0, 1]) {
            cylinder(d=Mounting_Screw_Diameter, h=Height + Mounting_Screw_Diameter + slop * 2);
            if (Mounting_Screw_Hole_Chamfer)
            cylinder(d1=Mounting_Screw_Diameter*2, d2=Mounting_Screw_Diameter, h=Mounting_Screw_Diameter / 2);
        }
    }
}

module base() {
    color("mintcream", 0.9)
    render()
    difference() {
        pcb40_round_3d()
        base_body();
        pcb40_screw_holes();
        base_holes();
    }
}

module main() {
    base();
    if ($preview && Preview_PCB)
    translate([0, 0, Height + slop])
    pcb40_pcb();
}

pcb40(
    x=PCB_Units[0],
    y=PCB_Units[1],
    height=Height,
    edge_radius=Edge_Radius,
    screw_insert_diameter=Screw_Insert_Diameter,
    pcb_support_chamfer=PCB_Support_Chamfer,
    inner_holes=Inner_Holes
)
main();
