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
clip_tab_thickness = 2.6;
grip_height = 22;
grip_back_depth = 2.5 + 3;
grip_opening_width = 15.4;
grip_opening_thickness = 3.2;
grip_inner_width = 20.4;
grip_overhang_thickness = 2.3;
grip_outer_width = 25.4;
grip_outer_depth = (
    grip_back_depth + grip_overhang_thickness + grip_opening_thickness
);

bracket_base_height = 15;

screw_spacing = 50;
screw_spacing_vertical = 20;
screw_d = 5;
screw_head_d_hex = 9;
screw_head_height = 4;
screw_hole_d = screw_d + Screw_Fit;

clip_spacing = screw_spacing + Extra_Clip_Spacing;

rr = Round_Radius;
slop = 0.001;

// Functions //

function hole_positions_proportion() = (
    (Holes == "horizontal")
        ? [[-0.5, 0], [0.5, 0]]
        : (Holes == "vertical")
            ? [[0, 0], [0, 1]]
            : (Holes == "all")
                ? [[-0.5, 0], [0, 0], [0, 1], [0.5, 0]]
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
    if (Style == "double") {
        for (tx = [-0.5, 0.5])
        translate([tx * clip_spacing, 0, 0])
        children();
    } else {
        children();
    }
}

module round_2d(radius=rr, inner=false) {
    if (inner) {
        offset(r=-radius)
        offset(r=radius)
        children();
    } else {
        offset(r=radius)
        offset(r=-radius)
        children();
    }
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
    difference() {
        children();
        translate([0, 0, -slop])
        linear_extrude(height=grip_height * 4 + slop * 2, center=true) {
            translate([-grip_opening_width / 2, grip_back_depth])
            square([grip_opening_width, grip_outer_depth]);
            translate([-grip_inner_width / 2, grip_back_depth])
            square([grip_inner_width, grip_opening_thickness]);
        }
    }
}

module tail_light_grip_body_cut() {
    difference() {
        children();
        rotate([-90, 0, 0])
        translate([0, -grip_height / 2, -slop])
        linear_extrude(height=grip_back_depth * 4, center=true)
        translate([-grip_inner_width / 2, -grip_height / 2])
        round_2d(radius=rr*4)
        offset(r=-5)
        square([grip_inner_width, grip_height]);

        translate([0, 0, -(5 - rr * 2)])
        linear_extrude(height=grip_height)
        translate([-grip_opening_width / 2, grip_back_depth - rr * 0.9])
        square([grip_opening_width, grip_outer_depth]);
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
    size = 1.0;

    translate([0, 0, grip_height + clip_tab_h])
    rotate([-90, 0, 0])
    translate([0, 0, clip_tab_thickness])
    intersection() {
        linear_extrude(height=clip_tab_thickness)
        offset(r=-rr)
        tail_light_grip_tab_shape();

        mirror([0, 1, 0])
        for (oy = [size / 2:size * 2:clip_tab_d / 2])
        rotate([0, 90, 0])
        translate([0, oy, 0])
        linear_extrude(height=clip_tab_d, center=true)
        circle(d=size);
    }
}

module tail_light_grip_tab() {
    thick = clip_tab_thickness;

    rotate([-90, 0, 0])
    round_3d()
    union() {
        translate([0, -(grip_height - rr * 2), 0])
        translate([0, 0, rr])
        linear_extrude(height = thick - rr * 2)
        offset(r=-rr)
        translate([0, -clip_tab_h / 2])
        square([clip_tab_width, clip_tab_h + rr * 2], center=true);

        // Circle finger grip
        translate([0, -(grip_height + clip_tab_h), 0])
        translate([0, 0, rr])
        linear_extrude(height=thick - rr * 2)
        tail_light_grip_tab_shape();
    }

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

module tail_light_grip_back_poly(
    radius=rr,
    thickness=grip_outer_depth,
    height=grip_height
) {
    translate([0, 0, radius])
    linear_extrude(height=height - radius * 2)
    offset(r=-radius)
    translate([-grip_outer_width / 2, 0])
    square([grip_outer_width, thickness]);
}

module tail_light_grip_poly() {
    adj = 2;
    tail_light_grip_back_poly(radius=rr);
    translate([0, 0, rr])
    translate([0, -grip_back_depth, -adj])
    linear_extrude(height=adj * 2)
    offset(r=-rr)
    translate([-grip_outer_width / 2, grip_back_depth])
    square([grip_outer_width, grip_outer_depth - grip_back_depth]);
}

module bracket_body() {
    overlap = 1 + rr * 4;
    translate([0, 0, bracket_base_height / 2])
    rotate([-90, 0, 0])
    round_3d()
    bracket_body_cut()
    translate([0, 0, rr])
    linear_extrude(height=grip_back_depth - rr * 2)
    offset(r=-rr)
    round_2d(radius=bracket_base_height / 4, inner=true) {
        hull()
        for (mx = [0, 1])
        mirror([mx, 0, 0])
        translate([clip_spacing / 2, 0, 0])
        translate([(grip_outer_width - bracket_base_height) / 2, 0, 0]) {
            circle(d=bracket_base_height);
            if (Style == "double") {
                translate([-bracket_base_height / 2, -bracket_base_height / 2])
                square([bracket_base_height, bracket_base_height / 2]);
            }
        }
        at_taillights()
        translate([-grip_outer_width / 2, -(overlap + bracket_base_height / 2)])
        square([grip_outer_width, overlap]);
    }
}

module bracket_body_cut() {
    difference() {
        children();

        linear_extrude(height=grip_back_depth * 4, center=true)
        hull()
        for (mx = [0, 1])
        mirror([mx, 0, 0])
        translate([clip_spacing / 4, 0])
        circle(d=bracket_base_height * 0.4);
    }
}

module tail_light_grip() {
    tail_light_grip_cut()
    round_3d()
    tail_light_grip_body_cut()
    tail_light_grip_poly();
    translate([0, grip_back_depth - clip_tab_thickness, 0])
    tail_light_grip_tab();
}

module bracket_screw_hole() {
    linear_extrude(height=grip_back_depth * 4, center=true)
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
        translate([0, bracket_base_height / 2])
        bracket_screw_hole();
    }
}

module bracket() {
    rotate([90, 0, 0])
    bracket_screw_holes() {
        bracket_body();
        translate([0, 0, bracket_base_height])
        at_taillights()
        tail_light_grip();
    }
}

module main() {
    color("mintcream", 0.9)
    bracket();
}

main();
