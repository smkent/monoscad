/*
 * Display rod grommet
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <BOSL/constants.scad>;
use <BOSL/threading.scad>;

/* [Rendering Options] */

Part = "both"; // [both: Grommet and insert, grommet: Grommet, insert: Insert]

/* [Common Options] */
Lip_Thickness = 5; // [0.2:0.1:10]
Lip_Radius = 4; // [0:0.1:50]
Lip_Sides = 8; // [4:1:30]

/* [Insert Options] */
Insert_Diameter = 5.1; // [1:0.1:50]

/* [Grommet Options] */
Hole_Diameter = 19.1; // [5:0.1:100]
Hole_Depth = 12.2; // [5:0.1:100]
Grommet_Thickness = 2; // [1:0.1:10]

/* [Advanced Size Options] */

Thread_Pitch = 3; // [2:0.5:10]
Thread_Slop_Factor = 2; // [0.1:0.1:3]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

insert_d = Insert_Diameter;
hole_d = Hole_Diameter;
hole_depth = Hole_Depth;
grommet_thick = Grommet_Thickness;
lip_thick = Lip_Thickness;
lip_d = Hole_Diameter + Lip_Radius * 2;
lip_sides = Lip_Sides;
thread_pitch = Thread_Pitch;
thread_slop_fac = Thread_Slop_Factor;

outset = insert_d > (hole_d - grommet_thick * 2 - thread_pitch * 2);
outset_d = outset ? insert_d + grommet_thick * 4 : 0;
outset_depth = outset_d;

inset_cut_d = min(insert_d, hole_d - grommet_thick * 2 - thread_pitch * 2);

slop = 0.01;

// Modules //

module add_lip() {
    translate([0, 0, lip_thick])
    children();
    linear_extrude(height=lip_thick)
    circle(d=lip_d, $fn=lip_sides);
}

module add_outset() {
    mirror([0, 0, 1])
    difference() {
        union() {
            linear_extrude(height=outset_depth)
            circle(d=outset_d, $fn=lip_sides);
            difference() {
                translate([0, 0, lip_d > outset_d ? lip_thick : 0])
                hull() {
                    translate([0, 0, -lip_thick])
                    linear_extrude(height=slop)
                    circle(d=lip_d, $fn=lip_sides);
                    linear_extrude(height=slop)
                    circle(d=outset_d, $fn=lip_sides);
                }
                mirror([0, 0, 1])
                cylinder(h=hole_depth + lip_thick + slop * 2, d=hole_d - grommet_thick * 2 - thread_pitch * 2);
            }
            mirror([0, 0, 1])
            children();
        }
        translate([0, 0, -slop])
        linear_extrude(height=outset_depth + slop * 2)
        circle(d=insert_d);
        mirror([0, 0, 1])
        cylinder(h=lip_thick, d1=insert_d, d2=inset_cut_d);
    }
}

module grommet() {
    color("plum", 0.8)
    difference() {
        add_lip()
        cylinder(h=hole_depth, d=hole_d);
        translate([0, 0, -slop])
        threaded_rod(
            d=hole_d - grommet_thick * 2,
            l=hole_depth + lip_thick + slop * 2,
            pitch=thread_pitch,
            internal=true,
            slop=PRINTER_SLOP * thread_slop_fac,
            align=V_ABOVE
        );
    }
}

module insert_body() {
    difference() {
        add_lip()
        threaded_rod(
            d=hole_d - grommet_thick * 2,
            l=hole_depth + lip_thick,
            bevel2=true,
            pitch=thread_pitch,
            internal=false,
            align=V_ABOVE
        );
        translate([0, 0, -slop])
        cylinder(h=hole_depth + lip_thick * 2 + slop * 2, d=inset_cut_d);
    }
}

module grommet_insert() {
    color("lightsteelblue", 0.8)
    translate([0, 0, outset_depth])
    add_outset()
    insert_body();
}

module main() {
    if (Part == "both") {
        translate([Hole_Diameter, 0, 0])
        grommet();
        translate([-Hole_Diameter, 0, 0])
        grommet_insert();
    } else if (Part == "grommet") {
        grommet();
    } else if (Part == "insert") {
        grommet_insert();
    }
}

main();
