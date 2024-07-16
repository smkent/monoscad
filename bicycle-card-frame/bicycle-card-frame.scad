/*
 * Bicycle event number card frame
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Style = "number-card"; // [number-card: Number card, bag-tag: Bag tag]

/* [Size] */
// All units in millimeters

Card_Thickness = 1; // [0:0.01:2]
Width = 154; // [20:0.1:200]
Height = 103; // [20:0.1:200]
Border = 5; // [0:1:20]
Rear_Inset = 10; // [0:1:10]
Frame_Thickness = 6; // [0:0.1:10]
Hole_Inset = 10;

Hole_Diameter = 6.4;

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

rr = 5;
slop = 0.01;
fthick = Frame_Thickness;
rthick = (Frame_Thickness - Card_Thickness) / 2;

// Functions //

function holes() = (
    (Style == "number-card")
        ? [
            [Hole_Inset, Height - Hole_Inset],
            [Width - Hole_Inset, Height - Hole_Inset],
            [Width / 2, Hole_Inset],
        ]
        : (Style == "bag-tag")
            ? [[82, 13]]
            : []
);

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module at_holes() {
    translate([-Width / 2, -Height / 2])
    for (pos = holes())
    translate(pos)
    children();
}

module screw_holes() {
    at_holes()
    linear_extrude(height=fthick * 4, center=true)
    circle(d=Hole_Diameter);
}

module eyelets() {
    at_holes()
    circle(d=Hole_Diameter * 2);
}

module top_layer() {
    offset(r=-rr * 2)
    offset(r=rr * 4)
    offset(r=-rr * 2)
    difference() {
        square([Width, Height], center=true);
        for (oy = [-1, 1])
        translate([0, oy * -Height / 2])
        square(Hole_Diameter, center=true);
    }
}

module frame_body() {
    difference() {
        linear_extrude(height=fthick)
        difference() {
            offset(r=rr)
            offset(r=-rr)
            square(vec_add([Width, Height], Border * 2), center=true);
            offset(r=rr)
            offset(r=-rr)
            difference() {
                square(vec_add([Width, Height], -Rear_Inset), center=true);
                eyelets();
            }
        }
        translate([0, 0, rthick])
        linear_extrude(height=Card_Thickness)
        square([Width, Height], center=true);

        rt = Frame_Thickness - (rthick + Card_Thickness);
        translate([0, 0, rthick + Card_Thickness])
        linear_extrude(height=rt + slop)
        top_layer();
    }
}

module frame() {
    difference() {
        frame_body();
        screw_holes();
    }
}

module main() {
    color("lightsteelblue", 0.9)
    frame();
}

main();
