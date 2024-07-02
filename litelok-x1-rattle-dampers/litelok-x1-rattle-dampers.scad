/*
 * Litelok X1 Rattle Dampers
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Options] */
Notch = true;

/* [Size] */
// All units in millimeters

insert_d = 24;
hill_h = 6;

h = 1.8;

tpu_fit = 0.4; // [0:0.1:2]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

shackle_d = 16.1;
barronium_d = 17.6;
// u_od = vec_add([20.6, 23.5], -0.6);
u_od = 20;

b_overlap = 1;

u_overlap = 2;
thick = 2.2;
r = min(0.3, h / 6);

slop = 0.01;

ring_id = shackle_d;

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module chamfer() {
    minkowski() {
        children();
        for (mz = [0, 1])
        mirror([0, 0, mz])
        cylinder(h=r * 2, r1=r, r2=0);
    }
}

module chamfer_extrude(height=0) {
    translate([0, 0, r * 2])
    chamfer()
    linear_extrude(height=height - r * 4)
    offset(r=-r)
    children();
}

module hill_intersect() {
    hill_w = insert_d * 0.74;
    intersection() {
        children();
        translate([0, 0, h])
        rotate([90, 0, 0])
        linear_extrude(height=insert_d * 2, center=true)
        offset(r=-hill_h / 2)
        offset(r=hill_h / 2)
        union() {
            translate([0, -insert_d / 2])
            square([insert_d * 2, insert_d], center=true);
            scale([1, hill_h / hill_w])
            circle(d=hill_w);
        }
    }
}

module ring() {
    render()
    hill_intersect()
    chamfer_extrude(height=h + hill_h)
    difference() {
        circle(d=insert_d + tpu_fit);
        circle(d=insert_d + tpu_fit - thick * 2);
    }
}

module main() {
    color("#ccc", 0.9)
    ring();
}

main();
