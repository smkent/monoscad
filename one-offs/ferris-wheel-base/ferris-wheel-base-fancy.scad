/*
 * Ferris wheel base
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <honeycomb-openscad/honeycomb.scad>;

/* [Options] */

Honeycomb = true;
Round_All_Edges = true;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 4 : 0.4;

base_outer = [10 * 2 + 34.5, 55];
base_inner = [34.5, 55 - 6 * 2];
base_height = 10;

supports_size = [20, 6, 61 + 10 + 10];
supports_tilt = 0.81;
supports_placement = 10;

axle_height = 10 + 61;
axle_diameter = 10;

base_outer_radius = 4;
supports_outer_radius = 8;
edge_radius = Round_All_Edges ? 1 : 0;

honeycomb_size = 7;
honeycomb_separation = 2.5;

// Modules //

module honeycomb_grid(x, y, hex_size, separation, double=true) {
    translate([-x / 2, -y / 2])
    render(convexity=2)
    intersection() {
        translate([double ? separation / 2 : 0, 0])
        difference() {
            difference() {
                square([double ? x * 2 : x, y]);
                honeycomb(double ? x * 2 : x, y, hex_size, separation, whole_only=true);
            }
            if (double)
            translate([2 * (hex_size * cos(30) + separation) - separation, 0])
            difference() {
                square([x * 2, y]);
                honeycomb(x * 2, y, hex_size, separation, whole_only=true);
            }
        }
        square([x, y]);
    }
}

module ferris_wheel_base() {
    translate([0, 0, edge_radius])
    linear_extrude(height=base_height - edge_radius * 2)
    difference() {
        offset(delta=-edge_radius)
        offset(r=base_outer_radius)
        offset(r=-base_outer_radius)
        square(base_outer, center=true);
        offset(delta=edge_radius)
        offset(r=base_outer_radius / 4)
        offset(r=-base_outer_radius / 4)
        square(base_inner, center=true);
    }
}

module ferris_wheel_supports() {
    base_square_length = base_outer[1] - base_outer_radius * 2;
    for (mirror_y = [0, 1])
    mirror([0, mirror_y])
    translate([-supports_size[0] / 2, base_outer[1] / 2, 0])
    render(convexity=2)
    difference() {
        translate([0, 0, supports_placement])
        rotate([supports_tilt, 0, 0])
        rotate([90, 0, 0])
        translate([0, 0, edge_radius])
        linear_extrude(height=supports_size[1] - edge_radius * 2)
        offset(delta=-edge_radius)
        translate([0, -supports_placement])
        offset(r=-supports_outer_radius)
        offset(r=supports_outer_radius)
        union() {
            square([supports_size[0], supports_size[2] - axle_diameter]);
            translate([supports_size[0] / 2, supports_size[2] - supports_size[0] / 2])
            circle(d=supports_size[0]);
            translate([-(base_square_length - supports_size[0]) / 2, 0])
            square([base_square_length, supports_placement]);

        }
        // Honeycomb pattern
        if (Honeycomb) {
            rotate([90, 0, 0])
            linear_extrude(height=supports_size[1] * 4, center=true)
            offset(delta=edge_radius)
            translate([supports_size[0] / 2, supports_size[2] / 2 - supports_placement / 2, 0])
            honeycomb_grid(supports_size[0], supports_size[2] - supports_placement - axle_diameter * 2, honeycomb_size, honeycomb_separation);
        }
        // Remove tilted base overhang
        translate([-(base_square_length - supports_size[0]) / 2, -edge_radius, 0])
        cube([base_square_length, supports_size[1], supports_size[2]]);
    }
}

module ferris_wheel_axle() {
    difference() {
        children();
        translate([0, 0, axle_height])
        rotate([90, 0, 0])
        cylinder(h=base_outer[1] * 2, d=axle_diameter + (2 * edge_radius), center=true);
    }
}

module ferris_wheel_stand() {
    ferris_wheel_base();
    ferris_wheel_axle() {
        ferris_wheel_supports();
    }
}

module round_all_edges() {
    if (Round_All_Edges) {
        minkowski() {
            children();
            sphere(r=edge_radius);
        }
    } else {
        children();
    }
}

module main() {
    color("gold", 0.9)
    round_all_edges()
    render(convexity=2)
    ferris_wheel_stand();
}

main();
