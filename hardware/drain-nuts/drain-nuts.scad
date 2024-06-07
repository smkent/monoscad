/*
 * Drain nuts
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <BOSL/constants.scad>
use <BOSL/threading.scad>

/* [Nut Selection] */
Nut_Type = "G1-1/4"; // [Stopper-Nut, G5/8, G1-1/4, G1-1/2]

Shape = "circular"; // [circular: Circular, hexagonal: Hexagonal]

/* [Features] */

Wing_Grips = true;

// Not recommended for hexagonal nuts
Mini_Grips = true;

Ball_Cut = false;

Chamfer_Inner_Ring = true;

/* [Size] */
// All units in millimeters

Height = 15; // [5:1:50]
Thickness = 5; // [2:1:20]

Thread_Slop = 0.2; // [0:0.05:2]

/* [Advanced Options] */
Grip_Thickness = 4; // [3:0.5:10]
Grip_Length = 10; // [5:1:30]

Lip_Height = 4; // [2:0.5:10]
Thread_Setback_Height = 1; // [0:1:50]
Thread_End_Offset = 0; // [0:1:50]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

nut_lip_h = Lip_Height;
nut_start_h = min(Thread_Setback_Height, Height - nut_lip_h);
nut_end_h = min(Thread_End_Offset, Height - nut_lip_h);

slop = 0.01;

// Functions //

nut_table = [
    ["Stopper-Nut", [23.6, 1.3, 23.6 - 22.9, 14.2, 18.4 + 2]],
    // https://www.ring-plug-thread-gages.com/PDChart/G-series-Fine-thread-data.html
    ["G5/8", [22.911, 1.814, 1.162, 14.2, 18.3]],
    ["G1-1/4", [41.910, 2.309, 1.479, 32.6, -1]],
    ["G1-1/2", [47.803, 2.309, 1.479, 39, -1]]
];

nut_spec = vsearch(nut_table, Nut_Type);
major_d = nut_spec[0];
pitch = nut_spec[1];
thread_depth = nut_spec[2];
nut_small_d = nut_spec[3];
ball_d = nut_spec[4];
thread_h = Height - nut_lip_h - nut_start_h - nut_end_h;

nut_d = major_d + Thickness * 2;
lip_thick = (nut_d - nut_small_d) / 2;

function vsearch(vec, term) = (
    let (r = [for (i = vec) if (i[0] == term) i])
    len(r) == 1 ? r[0][1] : undef
);

// Modules //

module body_shape() {
    if (Shape == "circular") {
        circle(d=nut_d);
    } else if (Shape == "hexagonal") {
        circle(d=nut_d + Thickness, $fn=6);
    }
}

module body() {
    body_h = Height - nut_lip_h;
    difference() {
        translate([0, 0, nut_lip_h])
        union() {
            linear_extrude(height=body_h)
            body_shape();
            if (Shape == "circular") {
                circular_lip();
            } else if (Shape == "hexagonal") {
                hexagonal_lip();
            }
        }
        cylinder(d=nut_small_d, h=Height * 2, center=true);
        if (Chamfer_Inner_Ring) {
            translate([0, 0, -slop])
            cylinder(
                d1=nut_small_d + nut_lip_h / 2,
                d2=nut_small_d,
                h=nut_lip_h / 2 + slop
            );
        }
    }
}

module threads() {
    if (thread_h > 0)
    trapezoidal_threaded_rod(
        d=major_d,
        thread_depth=thread_depth,
        thread_angle=27.5,
        l=thread_h,
        pitch=pitch,
        slop=Thread_Slop,
        internal=true,
        align=V_TOP
    );
}

module circular_lip() {
    rotate_extrude() {
        mirror([0, 1])
        square([nut_small_d / 2 + lip_thick / 2, nut_lip_h]);
        translate([nut_small_d / 2 + lip_thick / 2, 0])
        intersection() {
            hull()
            for (ox = [0, (lip_thick - nut_lip_h * 2) / 2])
            translate([ox, 0])
            scale([lip_thick / 2 / nut_lip_h, 1])
            circle(r=nut_lip_h);
            mirror([0, 1])
            square([lip_thick / 2, lip_thick]);
        }
    }
}

module hexagonal_lip() {
    hull() {
        linear_extrude(height=slop)
        body_shape();
        translate([0, 0, -nut_lip_h])
        linear_extrude(height=slop)
        circle(d=nut_small_d + lip_thick);
    }
}

module grip() {
    squash = 1;
    short = 1;
    hull()
    union() {
        for (ox = [-Thickness, $grip_outset + Thickness / 2 * 0])
        translate([nut_d / 2 + ox, 0, Height - short])
        linear_extrude(height=short)
        circle(d=$grip_thick);

        difference() {
            translate([0, 0, -squash]) {
                translate([nut_d / 2 - Thickness - short, 0, $grip_thick / 2])
                rotate([0, 90, 0])
                linear_extrude(height=short)
                circle(d=$grip_thick);

                translate([nut_d / 2 - $grip_thick / 2 + $grip_outset, 0, $grip_thick])
                rotate([90, 90, 0])
                rotate_extrude(angle=90)
                translate([$grip_thick / 2, 0])
                circle(d=$grip_thick);
            }
            mirror([0, 0, 1])
            linear_extrude(height=$grip_thick)
            translate([nut_d / 2, 0])
            square([($grip_thick + $grip_outset + Thickness) * 4, $grip_thick], center=true);
        }
    }
}

module mini_grips() {
    $grip_thick = Grip_Thickness;
    $grip_outset = 0.5;
    for (a = [0:360/8:360 - 0.1])
    if (a != 0 && a != 180)
    rotate([0, 0, a])
    grip();
}

module wing_grips() {
    $grip_thick = Grip_Thickness;
    $grip_outset = Grip_Length;
    for (a = [0, 180])
    rotate([0, 0, a])
    grip();
}

module grips() {
    if (Wing_Grips) {
        wing_grips();
    }
    if (Mini_Grips) {
        mini_grips();
    }
}

module ball_cut() {
    if (Ball_Cut && ball_d > 0) {
        #hull()
        for (oz = [0, Height])
        translate([0, 0, nut_lip_h + ball_d * 3/16 + oz])
        sphere(d=ball_d);
    }
}

module nut() {
    render()
    difference() {
        union() {
            body();
            grips();
        }

        if(nut_start_h > 0)
        translate([0, 0, nut_lip_h])
        translate([0, 0, Height - nut_lip_h - nut_start_h])
        linear_extrude(height=nut_start_h + slop)
        circle(d=major_d + Thread_Slop * 3);

        if(nut_end_h > 0)
        translate([0, 0, nut_lip_h])
        linear_extrude(height=nut_end_h + slop)
        circle(d=major_d + Thread_Slop * 3);

        translate([0, 0, nut_lip_h + nut_end_h])
        threads();

        ball_cut();
    }
}

module main() {
    color("mintcream", 0.8)
    nut();
}

main();
