/*
 * Controleo3 reflow oven add-ons
 * Door servo catch bracket
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Size] */
// All units in millimeters

Thickness = 4; // [1.5:0.1:10]
Screw_Hole_Diameter = 3; // [2:0.1:5]
Screw_Hole_Offset = 14;
Screw_Separation = 19;

/* [Advanced Options] */
Screw_Hole_Fit = 0.2; // [0:0.05:1]
Screw_Hole_Style = "inset"; // [flat: Flat, countersink: Countersink, inset: Inset]
Edge_Radius = 0.8; // [0:0.1:3]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 2 : 0.4;

catch_width = 12;
catch_height = 61;
grip_angle = 20;
grip_length = 25;
grip_deep = 12;
grip_deep_trig = tan(grip_angle) * grip_deep;
handle_thick = 19;
outer_screw_adjust_x = 1;
grip_support_fill_adjust = 0.5;

slop = 0.001;

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

module _screw_hole(d, h, fit=0, style="flat", print_upside_down=false, part="both") {
    inset_bare_min_h = 1.6;
    inset_min_h = (style == "inset" || style == "nut") ? max((h - d), inset_bare_min_h) - (h - d) : 0;
    if (part == "both" || part == "shaft") {
        translate([0, 0, -slop])
        cylinder(d=(d + fit), h=h + slop * 2);
    }
    if (part == "both" || part == "head") {
        if (style == "countersink" || style == "inset") {
            translate([0, 0, h + inset_min_h + slop * 2])
            mirror([0, 0, 1])
            cylinder(d1=d * 2, d2=d * (style == "inset" ? 2 : 1), h=d);
        }
        if (style == "nut") {
            nut_extra = 1.0;
            translate([0, 0, h + inset_min_h + slop * 2])
            mirror([0, 0, 1])
            cylinder(d=d * 2 + nut_extra, h=d, $fn=6);
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
}

module at_servo_bracket_screw_holes() {
    translate([0, 0, Thickness + handle_thick])
    at_servo_bracket_nut_holes()
    children();
}

module at_servo_bracket_nut_holes() {
    deep = (
        + grip_length / 2
        + tan(grip_angle) * grip_deep / 2
    );
    for (ox = [
        (-grip_length + Thickness) / 2 - Screw_Hole_Diameter * 2.5 - (outer_screw_adjust_x / tan(grip_angle)),
        (grip_length - Thickness) / 2 - Screw_Hole_Diameter * 2.5
    ])
    translate([deep, grip_deep / 2])
    translate([tan(grip_angle) * ox, 0])
    children();
}

module servo_bracket_catch() {
    _round_3d()
    translate([0, 0, Edge_Radius])
    translate([0, 0, Thickness + handle_thick])
    intersection() {
        // Catch shape
        rotate([90, 0, 0])
        mirror([0, 0, 1])
        translate([0, -Edge_Radius, Edge_Radius])
        linear_extrude(height=grip_deep - Edge_Radius * 2)
        translate([grip_length + grip_deep_trig + Thickness - catch_width, 0])
        offset(r=-Edge_Radius)
        union() {
            hull() {
                translate([catch_width / 2, catch_height + Thickness - catch_width / 2])
                circle(d=catch_width);
                square([catch_width, catch_height + Thickness - catch_width]);
            }
            offset(r=-Thickness * 0.75)
            offset(r=Thickness * 0.75)
            union() {
                translate([-Thickness, 0])
                square([catch_width + Thickness, Thickness]);
                square([catch_width, Thickness * 3]);
            }
        }

        // Front-back curve mask
        rotate([0, -90, 0])
        mirror([0, 0, 1])
        linear_extrude(height=grip_length + grip_deep_trig + Thickness)
        difference() {
            translate([0, Edge_Radius])
            square([catch_height + Thickness, grip_deep - Edge_Radius * 2]);
            hull() {
                for (ox = [0, catch_height])
                translate([ox, 0])
                translate([grip_deep - Edge_Radius * 3, grip_deep - Edge_Radius])
                circle(r=grip_deep - Thickness - Edge_Radius);
            }
        }
    }
}

module servo_bracket_body_grip() {
    _round_3d()
    translate([0, 0, Edge_Radius])
    union() {
        // Screw hole grips
        for (oz = [0, Thickness + handle_thick])
        translate([0, 0, oz])
        linear_extrude(height=Thickness - Edge_Radius * 2)
        offset(r=1)
        offset(r=-1)
        offset(r=-Edge_Radius)
        polygon(points=[
            [0, 0],
            [grip_deep_trig, grip_deep],
            [grip_length + grip_deep_trig + Thickness, grip_deep],
            [grip_length + grip_deep_trig + Thickness, 0],
        ]);

        // Vertical support
        linear_extrude(height = Thickness * 2 + handle_thick - Edge_Radius * 2)
        offset(r=-Edge_Radius)
        for (fill_x = [-grip_support_fill_adjust, 0])
        translate([fill_x, 0])
        polygon(points=[
            [grip_length, 0],
            [grip_length + grip_deep_trig + Thickness, 0],
            [grip_length + grip_deep_trig + Thickness, grip_deep],
            [grip_length + grip_deep_trig, grip_deep],
        ]);
    }
}

module servo_bracket_body() {
    servo_bracket_body_grip();
    servo_bracket_catch();
}

module servo_bracket_screw_holes() {
    for (screw_part = ["head", "shaft"]) {
        at_servo_bracket_screw_holes()
        _screw_hole(
            d=Screw_Hole_Diameter,
            h=Thickness,
            fit=Screw_Hole_Fit,
            style=Screw_Hole_Style,
            part=screw_part
        );
        translate([0, 0, Thickness])
        mirror([0, 0, 1])
        at_servo_bracket_nut_holes()
        _screw_hole(
            d=Screw_Hole_Diameter,
            h=Thickness,
            fit=Screw_Hole_Fit,
            style="nut",
            part=screw_part
        );
    }
}

module main() {
    color("lightblue", 0.8)
    render()
    difference() {
        servo_bracket_body();
        servo_bracket_screw_holes();
    }
}

main();
