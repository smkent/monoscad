/*
 * Bicycle taillight clip
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Style = "double"; // [single: Single, double: Double]
Holes = "horizontal"; // [horizontal: Horizontal 50mm apart, vertical: Vertical 20mm apart, all: All of the above]

/* [Size] */
Round_Radius = 0.6; // [0:0.1:2]
Screw_Fit = 0.8; // [0:0.1:2]
Extra_Clip_Spacing = 5; // [0:1:7]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

clip_top_offset = 30.5; // top to bottom of clip
clip_length = 3;
clip_height = 1.3;
clip_width = 4;
clip_tab_h = 10;
clip_tab_width = 7;
clip_tab_d = 13;
clip_tab_thickness = 2.25;
grip_height = 22;
grip_back_depth = 2.5 + 2;
grip_opening_width = 15.4;
grip_opening_thickness = 3;
grip_inner_width = 20.4;
grip_overhang_thickness = 2.3;
grip_outer_width = 25.4;
grip_outer_depth = (
    grip_back_depth + grip_overhang_thickness + grip_opening_thickness
);

screw_spacing = 50;
screw_spacing_vertical = 20;
screw_d = 5;
screw_head_d_hex = 9;
screw_head_height = 3;
screw_hole_d = screw_d + Screw_Fit;

clip_spacing = Style == "double" ? (screw_spacing + Extra_Clip_Spacing) : 0;

rr = Round_Radius;
slop = 0.001;

// Functions //

function hole_positions_proportion() = (
    (Holes == "horizontal")
        ? [[-0.5, 0], [0.5, 0]]
        : (Holes == "vertical")
            ? [[0, -0.125], [0, 0.875]]
            : (Holes == "all")
                ? [[-0.5, 0], [0, -0.125], [0, 0.875], [0.5, 0]]
                : []
);

function hole_positions() = [
    for (prop = hole_positions_proportion())
    [prop[0] * screw_spacing, prop[1] * screw_spacing_vertical, 0]
];

// Modules //

module at_bracket_screws() {
    for (tt = hole_positions())
    translate(tt)
    children();
}

module at_taillights() {
    for (tx = [-0.5, 0.5])
    translate([tx * clip_spacing, 0, 0])
    children();
}

module round_2d(radius = rr) {
    offset(r=radius)
    offset(r=-radius)
    children();
}

module round_3d(radius = rr) {
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

module tail_light_grip_cut() {
    translate([0, 0, -slop])
    linear_extrude(height=grip_height + slop * 2) {
        translate([-grip_opening_width / 2, grip_back_depth])
        square([grip_opening_width, grip_outer_depth]);
        translate([-grip_inner_width / 2, grip_back_depth])
        square([grip_inner_width, grip_opening_thickness]);
    }
}

module tail_light_grip_tab_shape() {
    ww = clip_tab_d - rr * 2;
    translate([-ww / 2, 0]) {
        round_2d(radius=rr * 2)
        square([ww, clip_tab_d / 2 - rr]);
        square([ww, clip_tab_d / 4 - rr]);
    }
    circle(d=clip_tab_d - rr * 2);
}

module tail_light_grip_tab_lines() {
    size = 0.8;

    translate([0, 0, grip_height + clip_tab_h])
    rotate([-90, 0, 0])
    translate([0, 0, clip_tab_thickness])
    intersection() {
        linear_extrude(height=clip_tab_thickness)
        offset(r=-rr)
        tail_light_grip_tab_shape();

        mirror([0, 1, 0])
        for (oy = [size * 2:size * 2:clip_tab_d / 2])
        rotate([0, 90, 0])
        translate([0, oy, 0])
        linear_extrude(height=clip_tab_d, center=true)
        circle(d=size);
    }
}

module tail_light_grip_tab() {
    thick = clip_tab_thickness;

    // Support
    linear_extrude(height=grip_height + clip_tab_h - rr * 2)
    round_2d()
    translate([-clip_tab_width / 2, 0])
    square([clip_tab_width, thick]);

    // Circle finger grip
    round_3d()
    translate([0, 0, grip_height + clip_tab_h])
    rotate([-90, 0, 0])
    translate([0, 0, rr])
    linear_extrude(height=thick - rr * 2)
    tail_light_grip_tab_shape();

    // Retaining tab
    snip = 0.4;
    translate([0, thick, clip_top_offset - clip_length])
    rotate([90, 0, 90])
    linear_extrude(height=clip_width, center=true)
    intersection() {
        polygon([
            [0, 0],
            [0, clip_length],
            [clip_height, clip_length]
        ]);
        square([clip_height - snip, clip_length]);
    }

    tail_light_grip_tab_lines();
}

module tail_light_grip_poly() {
    round_3d()
    translate([0, 0, rr])
    linear_extrude(height=grip_height - rr * 2)
    round_2d()
    offset(r=-rr)
    translate([-grip_outer_width / 2, 0])
    square([grip_outer_width, grip_outer_depth]);
}

module bracket_body() {
    ww = screw_spacing + screw_head_d_hex * 2;
    translate([0, 0, rr])
    round_3d() {
        difference() {
            linear_extrude(height=grip_height - rr * 2)
            translate([-ww / 2, 0])
            round_2d()
            offset(r=-rr)
            square([ww, grip_back_depth]);

            if (Style == "double")
            rotate([90, 0, 180])
            linear_extrude(height=grip_back_depth * 4, center=true)
            round_2d(radius=grip_height / 5)
            translate([-clip_spacing / 4, grip_height / 4 - rr])
            square([clip_spacing / 2, grip_height / 2]);
        }
    }
}

module tail_light_grips() {
    difference() {
        union() {
            at_taillights()
            tail_light_grip_poly();

            translate([0, grip_back_depth - clip_tab_thickness, 0])
            at_taillights()
            tail_light_grip_tab();
        }

        at_taillights()
        tail_light_grip_cut();
    }
}

module bracket_screw_hole() {
    linear_extrude(height=grip_back_depth)
    circle(d=screw_hole_d);

    linear_extrude(height=screw_head_height)
    rotate(90)
    circle(d=screw_head_d_hex + 0.4, $fn=6);
}

module bracket_screw_holes() {
    render()
    difference() {
        children();
        translate([0, grip_back_depth, 0])
        rotate([90, 0, 0])
        at_bracket_screws()
        translate([0, screw_d * 2])
        bracket_screw_hole();
    }
}

module bracket() {
    rotate([90, 0, 0])
    bracket_screw_holes() {
        bracket_body();
        tail_light_grips();
    }
}

module main() {
    color("mintcream", 0.9)
    bracket();
}

main();
