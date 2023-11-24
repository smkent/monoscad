/*
 * Bosch Custom Case latch
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Options] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

latch_width = 48;
latch_length = 29;
latch_thickness = 2.5;

grip_height = 6.2;
grip_length = 6.7;

grip_separation = 1.5;
grip_separation_setback = 9.75;
grip_segment_width = (latch_width - 2 * grip_separation ) / 3;

hinge_height = 4;
hinge_width = 4.6;
hinge_clip_width = 3.6;
hinge_setback = 22;
hinge_thickness = 1.3;

wing_height = 8.3;
wing_top_diameter = 3;
wing_setback = 12;

stop_height = 4;

wall_thickness = 1.6;

corner_radius = latch_thickness / 3;

// Functions //

// Modules //

module rounded(r=corner_radius) {
    offset(r=-r)
    offset(r=2 * r)
    offset(r=-r)
    children();
}

module latch_base_stop_shape() {
    // Base
    translate([0, latch_length / 2])
    square([latch_thickness, latch_length], center=true);

    // Grip
    // rotate(180)
    // translate([latch_thickness / 2, 0])
    translate([latch_thickness / 2, grip_length])
    mirror([1, 0])
    polygon([[0, 0], [grip_height, 0], [latch_thickness, -grip_length], [0, -grip_length]]);

    // Stop
    translate([latch_thickness / 2 - latch_thickness, latch_length])
    rotate(70)
    square([latch_thickness, stop_height * 1]);

    translate([-latch_thickness / 2, latch_length])
    intersection() {
        circle(r=latch_thickness);
        translate([0, -latch_thickness])
        square(latch_thickness * 2);
    }
}

module latch_stop_middle_shape() {
    translate([latch_thickness / 2 - latch_thickness, latch_length])
    rotate(70)
    square([latch_thickness, stop_height * 2]);
}

module latch_base() {
    rotate([0, 90, 0])
    linear_extrude(height=latch_width, center=true)
    rounded()
    latch_base_stop_shape();

    rotate([0, 90, 0])
    linear_extrude(height=grip_segment_width, center=true)
    rounded()
    latch_stop_middle_shape();
}

module latch_grip_cuts() {
    difference() {
        children();
        linear_extrude(height=latch_length, center=true)
        rounded(grip_separation * 0.4)
        for (mx = [0:1:1])
        mirror([mx, 0])
        translate([grip_segment_width / 2, grip_separation_setback])
        square([grip_separation, latch_length]);
    }
}

module latch_grip() {
    translate([0, grip_length, 0])
    rotate([0, 270, 0])
    linear_extrude(height=latch_width, center=true)
    polygon([[0, 0], [grip_height, 0], [latch_thickness, -grip_length], [0, -grip_length]]);
}

module latch_hinge_shape(base_width_multiple=2) {
    rounded(r=hinge_thickness / 4)
    translate([-(hinge_height + latch_thickness) / 2, hinge_setback])
    translate([-hinge_thickness / 2, 0])
    difference() {
        translate([hinge_thickness / 2, 0]) {
            polygon(points=[
                [-hinge_height / 2 - hinge_thickness, -hinge_width / 2 - hinge_thickness],
                [hinge_height / 2 + hinge_thickness, -hinge_width / 2 - hinge_thickness * base_width_multiple],
                [hinge_height / 2 + hinge_thickness, hinge_width / 2 + hinge_thickness * base_width_multiple],
                [-hinge_height / 2 - hinge_thickness, hinge_width / 2 + hinge_thickness],
            ]);
        }
        translate([hinge_thickness / 2, 0])
        square([hinge_height, hinge_width], center=true);
        translate([-hinge_height + hinge_thickness / 2, 0])
        square([hinge_height * 2, hinge_clip_width], center=true);
    }
}

module latch_hinge() {
    rotate([0, 90, 0])
    for (mz = [0:1:1])
    mirror([0, 0, mz]) {
        translate([0, 0, grip_segment_width / 2 + grip_separation])
        linear_extrude(height=grip_segment_width)
        latch_hinge_shape();

        for (zoff = [0, latch_thickness * 2])
        translate([0, 0, grip_segment_width / 2 + latch_thickness / 2 + grip_separation + zoff])
        linear_extrude(height=latch_thickness)
        latch_hinge_shape(base_width_multiple=3);
    }
}

module latch_wings() {
    translate([0, wing_setback, 0])
    rotate([0, 90, 0])
    for (mz = [0:1:1])
    mirror([0, 0, mz])
    translate([0, 0, latch_width / 2 - latch_thickness * 2])
    linear_extrude(height=latch_thickness)
    translate([-wing_top_diameter / 2, 0])
    hull()
    union() {
        translate([-wing_height + wing_top_diameter / 2, 0])
        circle(d=wing_top_diameter);
        translate([0, -(wing_top_diameter - latch_thickness) / 2])
        circle(d=latch_thickness);
        translate([0, wing_top_diameter * 1.5])
        circle(d=latch_thickness);
    }
}

module custom_case_latch() {
    color("orangered", 0.8) {
        render(convexity=2)
        latch_grip_cuts() {
            latch_base();
            latch_hinge();
            latch_wings();
        }
    }
}

module main() {
    custom_case_latch();
}

main();
