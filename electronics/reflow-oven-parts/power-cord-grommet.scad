/*
 * Controleo3 reflow oven add-ons
 * Power cord grommet
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Size] */
// All units in millimeters

Dimensions = [15, 10.2]; // [5:0.1:20]
Radius = 3.5; // [0:0.1:5]
Thickness = 3; // [1.5:0.1:10]
Cord_Diameter = 9.5; // [5:0.05:20]

Screw_Hole_Diameter = 3; // [2:0.1:5]
Screw_Hole_Offset = 5;
Grommet_Thickness = 3; // [0.8:0.1:5]
Grommet_Depth = 6; // [0.4:0.1:5]

/* [Advanced Options] */
Vertical_Overlap = 8; // [0:0.1:10]
Screw_Hole_Fit = 0.2; // [0:0.05:1]
Screw_Hole_Style = "inset"; // [flat: Flat, countersink: Countersink, inset: Inset]
Edge_Radius = 0.4; // [0:0.1:3]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 4 : 0.4;

shd = Screw_Hole_Diameter + Screw_Hole_Fit;
soff = shd * 2 + Grommet_Thickness;

slop = 0.001;

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module _round_3d(radius = Edge_Radius) {
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

module _screw_hole(d, h, fit=0, style="flat", print_upside_down=false) {
    inset_bare_min_h = 1.4;
    inset_min_h = (style == "inset") ? max((h - d), inset_bare_min_h) - (h - d) : 0;
    translate([0, 0, -slop])
    cylinder(d=(d + fit), h=h + slop * 2);
    if (style == "countersink" || style == "inset") {
        translate([0, 0, h + inset_min_h + slop * 2])
        mirror([0, 0, 1])
        cylinder(d1=d * 2, d2=d * (style == "inset" ? 2 : 1), h=d);
    }
    if (style == "inset" && print_upside_down) {
        layer_height = 0.2;
        translate([0, 0, (h + inset_min_h) - d - layer_height])
        linear_extrude(height=layer_height + slop * 2)
        intersection() {
            square([d * 2, d + fit], center=true);
            circle(d=d*2);
        }
    }
}

module _round_hole(r=Radius) {
    offset(r=r)
    offset(r=-r)
    children();
}


module at_power_cord_grommet_screw_holes() {
    for (mx = [0, 1])
    mirror([mx, 0])
    translate([Dimensions[0] / 2 + Screw_Hole_Offset / 2, 0])
    children();
}

module power_cord_grommet_hole() {
    dd = Cord_Diameter;
    translate([0, 0, slop])
    linear_extrude(height=Thickness + Grommet_Depth + slop * 2)
    circle(d=dd);
    translate([0, 0, -slop])
    cylinder(d2=dd, d1=dd + Edge_Radius * 2, h=Edge_Radius);
    translate([0, 0, Thickness + Grommet_Depth - Edge_Radius + slop])
    cylinder(d1=dd, d2=dd + Edge_Radius * 2, h=Edge_Radius);
}

module power_cord_grommet_screw_holes() {
    translate([0, 0, Thickness])
    mirror([0, 0, 1])
    at_power_cord_grommet_screw_holes()
    _screw_hole(
        d=Screw_Hole_Diameter,
        h=Thickness,
        fit=Screw_Hole_Fit,
        style=Screw_Hole_Style,
        print_upside_down=true
    );
}

module power_cord_grommet_body() {
    difference() {
        translate([0, 0, Edge_Radius])
        union() {
            _round_3d()
            linear_extrude(height=Thickness + Grommet_Depth - Edge_Radius * 2)
            _round_hole(Radius - Edge_Radius)
            square(vec_add(Dimensions, -Edge_Radius * 2), center=true);

            _round_3d()
            linear_extrude(height=Thickness - Edge_Radius * 2) {
                cd = max(3, shd / 2);
                hull() {
                    _round_hole(Radius - Edge_Radius)
                    square(
                        vec_add(Dimensions, -Edge_Radius * 2)
                        + [
                            Screw_Hole_Offset + Screw_Hole_Diameter * 2,
                            Vertical_Overlap
                        ],
                        center=true
                    );
                    at_power_cord_grommet_screw_holes()
                    translate([Screw_Hole_Diameter, 0])
                    circle(d=cd);
                }
            }
        }
        power_cord_grommet_hole();
        power_cord_grommet_screw_holes();
    }
}

module power_cord_grommet() {
    render()
    power_cord_grommet_body();
}

module main() {
    color("lightsteelblue", 0.8)
    power_cord_grommet();
}

main();
