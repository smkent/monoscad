/*
 * Electronics project box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Part = "all"; // [all: All, box: Box, lid: Lid]

/* [Size] */
Width = 50;
Length = 40;
Height = 30;
Thickness = 2.4;
Screw_Diameter = 3.5;
Insert_Diameter = 4.5;
Insert_Depth = 10;

/* [Advanced Options] */
Screw_Inset = 4;
Corner_Radius = 3; // [0:0.1:5]
Edge_Radius = 1.5; // [0:0.1:4]
Screw_Count = 4; // [2: 2, 4: 4]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

edge_radius = Edge_Radius;
screw_ht = Insert_Depth;
slop = 0.001;

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

module at_screws() {
    if (Screw_Count == 2) {
        for (m = [0, 1])
        mirror([m, 0])
        mirror([0, m])
        translate([Width / 2 - Screw_Inset, Length / 2 - Screw_Inset])
        children();
    } else {
        for (mx = [0, 1], my = [0, 1])
        mirror([mx, 0])
        mirror([0, my])
        translate([Width / 2 - Screw_Inset, Length / 2 - Screw_Inset])
        children();
    }
}

module box_shape(radius=Corner_Radius) {
    offset(r=radius)
    offset(r=-radius)
    square([Width, Length], center=true);
}

module box_interior() {
    translate([0, 0, Edge_Radius]) {
        screw_corner = Insert_Diameter + Screw_Inset;
        translate([0, 0, (Height - screw_ht - screw_corner) - Edge_Radius + Thickness]) {
            translate([0, 0, Edge_Radius])
            hull_pair(screw_corner) {
                box_shape();
                offset(r=-screw_corner)
                box_shape();
            }
            translate([0, 0, 0])
            linear_extrude(height=Edge_Radius)
            box_shape();
        }

        translate([0, 0, Thickness])
        translate([0, 0, Edge_Radius])
        round_3d()
        union() {
            linear_extrude(height=(Height - screw_ht - screw_corner) - Edge_Radius * 2)
            difference() {
                offset(r=-Edge_Radius)
                box_shape();
            }
            interior_corner_radius = max(0.5, (Corner_Radius - Thickness));
            linear_extrude(height=Height + Thickness * 2 - Edge_Radius * 2)
            offset(r=interior_corner_radius)
            offset(r=-interior_corner_radius)
            difference() {
                offset(r=-Edge_Radius)
                box_shape();
                at_screws()
                union() {
                    r = Insert_Diameter + Edge_Radius;
                    circle(r=r);
                    for (tr = [[0, -r], [-r, 0]])
                    translate(tr)
                    square([r, r]);
                }
            }
        }
    }
}

module box_body() {
    translate([0, 0, Edge_Radius])
    round_3d()
    linear_extrude(height=Height + Thickness * 2 - Edge_Radius * 2)
    offset(r=Thickness)
    offset(r=-Edge_Radius)
    box_shape();
}

module box() {
    difference() {
        intersection() {
            box_body();
            linear_extrude(height=Height + Thickness)
            offset(r=Thickness)
            box_shape(radius=0);
        }
        box_interior();
        at_screws()
        translate([0, 0, Height - screw_ht + Thickness])
        cylinder(d=Insert_Diameter, h=screw_ht + Thickness);
        all_cutouts();
    }
}

module lid() {
    difference() {
        intersection() {
            box_body();
            translate([0, 0, Height + Thickness])
            linear_extrude(height=Thickness)
            offset(r=Thickness)
            box_shape(radius=0);
        }
        at_screws()
        translate([0, 0, Height - screw_ht + Thickness])
        cylinder(d=Screw_Diameter, h=screw_ht + Thickness);
        all_cutouts();
    }
}

module all_cutouts() {
    // Add custom cutouts here
}

module main() {
    if (Part == "all" || Part == "box") {
        color("lightsteelblue", 0.8)
        render()
        box();
    }
    if (Part == "all" || Part == "lid") {
        color("lightgreen", 0.5)
        translate([0, 0, (Part == "lid" ? -(Height + Thickness) : 0)])
        render()
        lid();
    }
}

main();
