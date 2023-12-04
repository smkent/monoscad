/*
 * Ferris wheel base
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 4 : 0.4;

base_outer = [10 * 2 + 34.5, 55];
base_inner = [34.5, 55 - 6 * 2];
base_height = 10;
base_lip_height = 8;
base_lip_width = 4;
base_notch_dimensions = [5, 5];
base_notch_gap = 3;
base_notch_size_tolerance = 1;

supports_size = [20, 6, 61 + 10];
supports_tilt = 0.81;
supports_placement = 10;

axle_height = 10 + 61;
axle_diameter = 10;

slop = 0.001;

// Modules //

module ferris_wheel_base_notch() {
    square(base_notch_dimensions);
}

module ferris_wheel_base() {
    render(convexity=4)
    difference() {
        linear_extrude(height=base_height)
        difference() {
            square(base_outer, center=true);
            square(base_inner, center=true);
        }
        translate([0, 0, -slop])
        linear_extrude(height=base_lip_height + slop)
        union() {
            // Base interior
            offset(delta=-base_lip_width)
            square(base_outer, center=true);
            // Notch
            translate([
                -base_outer[0] / 2 + base_notch_gap,
                -base_notch_dimensions[1] / 2
            ])
            offset(delta=base_notch_size_tolerance)
            square(base_notch_dimensions);
        }
    }
}

module ferris_wheel_supports() {
    for (mirror_y = [0, 1])
    mirror([0, mirror_y])
    translate([-supports_size[0] / 2, -base_outer[1] / 2, supports_placement])
    rotate([-supports_tilt, 0, 0])
    cube(supports_size);
}

module ferris_wheel_axle() {
    difference() {
        children();
        translate([0, 0, axle_height])
        rotate([90, 0, 0])
        cylinder(h=base_outer[1] * 2, d=axle_diameter, center=true);
    }
}

module ferris_wheel_stand() {
    ferris_wheel_base();
    ferris_wheel_axle() {
        ferris_wheel_supports();
    }
}

module main() {
    color("gold", 0.9)
    ferris_wheel_stand();
}

main();
