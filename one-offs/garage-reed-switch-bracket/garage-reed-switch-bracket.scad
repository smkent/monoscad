/*
 * Garage Door Reed Switch Bracket
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Part = "both"; // ["both": Front and back, "front": Front, "back": Back]

/* [Size] */
Thickness = 3; // [0.4:0.1:10]

Bracket_Screw_Diameter = 6; // [2:0.5:10]

Round_Radius = 10; // [1:0.1:10]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

sensor_size = [48, 105];
screws_pos = [[9, 90], [38, 37]];
screw_d = 4;

bracket_size = [88, sensor_size.y];
bracket_screw_d = Bracket_Screw_Diameter + 0.2;
bracket_back_size = [bracket_size.x - 44, sensor_size.y - 49];

square_size = [9, 25];
squares_pos = vec_add(
    [[0, 0], [19, 0], [0, 32], [19, 32]],
    ([52, 49] + square_size / 2)
);

// Functions //
function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module round_shape(r=Round_Radius) {
    offset(r=-r)
    offset(r=r * 2)
    offset(r=-r)
    children();
}

module at_squares() {
    for (pos = squares_pos)
    translate(pos)
    children();
}

module bracket_screw_holes_shape() {
    at_squares()
    circle(d=bracket_screw_d);
}

module at_reed_switch_screw_holes() {
    for (rot = [0, 180])
    translate(rot ? [sensor_size.x, sensor_size.y] : [0, 0])
    rotate(rot)
    for (screw_pos = screws_pos)
    translate(screw_pos)
    children();
}

module reed_switch_screw_holes_shape() {
    at_reed_switch_screw_holes()
    circle(d=screw_d);
}

module reed_switch_bracket_cutouts_shape() {
    round_shape(r=min(sensor_size) / 10)
    difference() {
        offs = 10;
        for (oy = [offs / 2, sensor_size.y / 2 - offs / 2])
        translate([0, oy])
        offset(r=-offs)
        square([sensor_size.x, sensor_size.y / 2]);
        at_reed_switch_screw_holes()
        circle(d=screw_d * 4);
    }
}

module squares_bracket_cutouts_shape() {
    round_shape(r=min(sensor_size) / 20)
    difference() {
        offs = 5;
        offset(r=offs)
        hull()
        at_squares()
        circle(d=1);
        at_squares()
        circle(d=bracket_screw_d * 3);
    }
}

module bracket_front() {
    linear_extrude(height=Thickness)
    difference() {
        union() {
            round_shape()
            union() {
                square(sensor_size);
                bracket_back_shape();
            }
            round_shape(r=2)
            square(sensor_size);
        }
        reed_switch_screw_holes_shape();
        reed_switch_bracket_cutouts_shape();
        bracket_screw_holes_shape();
        squares_bracket_cutouts_shape();
    }
}

module bracket_back_shape() {
    translate(bracket_size - bracket_back_size)
    square(bracket_back_size);
}

module bracket_back() {
    translate([-(bracket_size.x + 10), 0])
    linear_extrude(height=Thickness)
    difference() {
        round_shape()
        bracket_back_shape();
        squares_bracket_cutouts_shape();
        bracket_screw_holes_shape();
    }
}

module main() {
    if (Part == "both" || Part == "front") {
        color("mintcream", 0.9)
        bracket_front();
    }
    if (Part == "both" || Part == "back") {
        color("lemonchiffon", 0.9)
        bracket_back();
    }
}

main();
