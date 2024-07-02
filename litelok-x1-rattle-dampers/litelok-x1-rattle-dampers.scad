/*
 * Litelok X1 Rattle Dampers
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Size] */
// All units in millimeters

x = 16.1;
y = 17.6;
h = 1.6;

tpu_fit = 0.6; // [0:0.1:2]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

shackle_d = 16.1;
barronium_d = 17.6;
u_od = [20.6, 23.5];

u_overlap = 2;
thick = 2.4;
r = min(0.5, h / 6);

slop = 0.01;

ring_id = shackle_d;

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module ring_v1() {

    module shape() {
        scale([1, y/x])
        circle(d=x);
    }

    minkowski() {
        linear_extrude(height=h - r * 4)
        offset(r=-r)
        difference() {
            offset(r=thick)
            shape();
            shape();
        }
        for (mz = [0, 1])
        mirror([0, 0, mz])
        cylinder(h=r * 2, r1=r, r2=0);
    }
}

module chamfer() {
    minkowski() {
        children();
        // for (mz = [0, 1])
        // mirror([0, 0, mz])
        mirror([0, 0, 1])
        cylinder(h=r * 2, r1=r, r2=0);
    }
}

module chamfer_extrude(height=0) {
    translate([0, 0, r * 2])
    chamfer()
    linear_extrude(height=height - r * 2)
    offset(r=-r)
    children();
}

module u_shape() {
    scale([1, u_od[1] / u_od[0]])
    circle(d=u_od[0]);
}

module ring() {
    render()
    difference() {
        intersection() {
            chamfer_extrude(height=h + u_overlap)
            difference() {
                u_shape();
                circle(d=ring_id - tpu_fit);
            }
            linear_extrude(height=h + u_overlap - r * 2)
            circle(d=ring_id * 2);
        }
        translate([0, 0, h])
        hull() {
            translate([0, 0, u_overlap])
            mirror([0, 0, 1])
            linear_extrude(height=slop)
            u_shape();
            linear_extrude(height=slop)
            circle(d=ring_id - tpu_fit);
        }
    }
}

module main() {
    color("#ccc", 0.9)
    ring();
}

main();
