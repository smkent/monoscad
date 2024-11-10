/*
 * ESPHome 40x40mm PCB mount
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Preview_PCB = true;
// Print_Orientation = true;

/* [PCB] */
// 40mm units
PCB_X = 1; // [1:1:3]

// 40mm units
PCB_Y = 1; // [1:1:3]

/* [Size] */
Height = 6; // [5:0.5:20]
Thickness = 2.0; // [1:0.1:5]
Edge_Radius = 0.5; // [0:0.5:1]
Screw_Insert_Diameter = 4.5; // [3:0.1:6]

/* [Features] */
Mounting_Screw_Holes_X = false;
Mounting_Screw_Holes_Y = false;
Mounting_Screw_Hole_Chamfer = false;
Mounting_Screw_Diameter = 4.5;
PCB_Support_Chamfer = 1.5; // [0:0.1:3]

/* [Advanced Options] */
Inner_Holes = true;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

pcb_grid = 40;
pcb_grid_sep = 2;
corner_radius = 3;
hole_inset = 3;
pcb_hole_d = 3.2;
pcb_thick = 1.6;

hole_d = Screw_Insert_Diameter;
edge_outset = 2;
hole_to_edge = edge_outset + hole_inset;
pcb_hole_clearance = 2.495 + 0.5;
edge_radius = Edge_Radius;

slop = 0.001;

// Functions //

pcb_x = PCB_X * pcb_grid + (PCB_X - 1) * pcb_grid_sep;
pcb_y = PCB_Y * pcb_grid + (PCB_Y - 1) * pcb_grid_sep;

// Modules //

module hull_pair(height) {
    slop = 0.001;
    hull() {
        for (child_obj = [
            // Child index, height offset
            [0, 0],
            [1, height - slop]
        ]) {
            translate([0, 0, child_obj[1]])
            linear_extrude(height=slop)
            children(child_obj[0]);
        }
    }
}

module round_3d(radius = edge_radius) {
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

module at_pcb_grid() {
    translate([
        -(PCB_X - 1) / 2 * (pcb_grid_sep + pcb_grid),
        -(PCB_Y - 1) / 2 * (pcb_grid_sep + pcb_grid),
    ])
    for (px = [0:1:PCB_X - 1], py = [0:1:PCB_Y - 1])
    translate([px * (pcb_grid + pcb_grid_sep), py * (pcb_grid + pcb_grid_sep)])
    union() {
        $grid_x = px;
        $grid_y = py;
        children();
    }
}

module at_pcb_holes() {
    at_pcb_grid()
    union() {
        px = $grid_x;
        py = $grid_y;
        for (hx = [0, 1], hy = [0, 1]) {
            edge_x0 = (px == 0 && hx == 0);
            edge_x1 = (px == (PCB_X - 1) && hx == 1);
            edge_y0 = (py == 0 && hy == 0);
            edge_y1 = (py == (PCB_Y - 1) && hy == 1);
            inner_x = !(edge_x0 || edge_x1);
            inner_y = !(edge_y0 || edge_y1);
            inner = (inner_x && inner_y);
            if (!inner || (Inner_Holes && inner))
            mirror([1 - hx, 0])
            mirror([0, 1 - hy])
            translate([pcb_grid / 2 - hole_inset, pcb_grid / 2 - hole_inset])
            children();
        }
    }
}

module at_pcb_grid_corners() {
    translate([
        -PCB_X / 2 * (pcb_grid + pcb_grid_sep),
        -PCB_Y / 2 * (pcb_grid + pcb_grid_sep)
    ])
    for (px = [0:1:PCB_X], py = [0:1:PCB_Y]) {
        inner = (px > 0 && px < PCB_X) && (py > 0 && py < PCB_Y);
        if (!inner || (Inner_Holes && inner))
        translate([
            px * (pcb_grid + pcb_grid_sep),
            py * (pcb_grid + pcb_grid_sep)
        ])
        children();
    }
}

module at_base_mount_screws(enable_x=true, enable_y=true) {
    screw_offset = Mounting_Screw_Diameter + (pcb_grid + pcb_grid_sep) / 2;
    at_pcb_grid() {
        if (enable_x && Mounting_Screw_Holes_X) {
            if ($grid_x == 0)
            translate([-screw_offset, 0])
            children();
            if ($grid_x == PCB_X - 1)
            translate([screw_offset, 0])
            children();
        }
        if (enable_y && Mounting_Screw_Holes_Y) {
            if ($grid_y == 0)
            translate([0, -screw_offset])
            children();
            if ($grid_y == PCB_Y - 1)
            translate([0, screw_offset])
            children();
        }
    }
}

module pcb() {
    color("darkseagreen", 0.5)
    linear_extrude(height=pcb_thick)
    difference() {
        $fs = $preview ? ($fs / 4) : $fs;
        offset(r=corner_radius)
        offset(r=-corner_radius)
        square([pcb_x, pcb_y], center=true);
        at_pcb_holes()
        circle(d=pcb_hole_d);
    }
}

module base_shape() {
    offset(r=-edge_radius)
    offset(r=hole_to_edge)
    offset(r=-hole_to_edge)
    square([pcb_x + edge_outset * 2, pcb_y + edge_outset * 2], center=true);
}

module base_cutouts() {
    at_pcb_grid()
    offset(r=-edge_radius)
    offset(r=hole_to_edge * 1.25)
    offset(r=-hole_to_edge * 1.25)
    square(pcb_grid - (hole_to_edge * 2), center=true);
}

module base_support_quad_shape() {
    offset(r=3)
    offset(r=-3)
    square((hole_inset + pcb_hole_clearance) * 2 + pcb_grid_sep, center=true);
}

module base_supports() {
    intersection() {
        linear_extrude(height=Height * 2)
        base_shape();
        translate([0, 0, edge_radius])
        // linear_extrude(height=Height - edge_radius * 2)
        at_pcb_grid_corners()
        hull_pair(Height - edge_radius * 2) {
            offset(r=PCB_Support_Chamfer)
            base_support_quad_shape();
            base_support_quad_shape();
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

    translate([0, 0, edge_radius])
    linear_extrude(height=Thickness - edge_radius * 2)
    difference() {
        union() {
            base_shape();
            base_mount_edges();
        }
        base_cutouts();
    }
}

module base_holes() {
    at_pcb_holes() {
        translate([0, 0, -slop])
        cylinder(d=hole_d, h=Height + slop * 2);
        translate([0, 0, Height - edge_radius])
        cylinder(d1=hole_d, d2=hole_d + 2 * edge_radius, h=edge_radius + slop);
        translate([0, 0, -slop])
        cylinder(d1=hole_d + 2 * edge_radius, d2=hole_d, h=edge_radius + slop);
    }
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
        round_3d()
        base_body();
        base_holes();
    }
}

module main() {
    base();
    if ($preview && Preview_PCB)
    translate([0, 0, Height + slop])
    pcb();
}

main();
