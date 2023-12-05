/*
 * MP1584 buck converter case
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Part = "both"; // [both: Top and bottom, both_assembled: Assembled model preview, top: top, bottom: Bottom]

Body_Style = "chamfer"; // [chamfer: Chamfer, rounded: Rounded]

/* [Size] */
// All units in millimeters

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 2 : 2 / 4;
$fs = $preview ? $fs / 4 : 0.4 / 4;

edge_radius = 1;
fit = 0.1;

board_size = vec_add([22.2, 17.2, 4], fit);
inductor_pos = [-board_size[0] / 2 + 7, -board_size[1] / 2 + 7, 0];
potentiometer_pos = [-board_size[0] / 2 + 6.8, board_size[1] / 2 - 2.5];

grip_radius = 0.5;
grip_length = board_size[0] / 3;

thick = 2;
font_size = 4;

slop = 0.01;

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module round_cube(dimensions, edge_radius=1) {
    hull()
    for (mx = [0:1:1], my = [0:1:1], mz = [0:1:1]) {
        mirror([0, 0, mz])
        mirror([0, my, 0])
        mirror([mx, 0, 0])
        translate([for (d = dimensions) d / 2 - edge_radius])
        sphere(r=edge_radius);
    }
}

module round_square(dimensions, edge_radius=1, center=false) {
    offset(r=edge_radius)
    offset(r=-edge_radius)
    square([dimensions[0], dimensions[1]], center=center);
}

module chamfer_cube(dimensions, edge_radius=1) {
    union() {
        for (mz = [0:1:1])
        mirror([0, 0, mz])
        hull_in_order() {
            translate([0, 0, dimensions[2] / 2 - slop])
            linear_extrude(height=slop)
            offset(r=edge_radius)
            offset(r=-edge_radius * 1.5)
            square([dimensions[0], dimensions[1]], center=true);

            translate([0, 0, dimensions[2] / 2 - edge_radius])
            linear_extrude(height=slop)
            round_square(dimensions, edge_radius=edge_radius, center=true);

            linear_extrude(height=slop)
            round_square(dimensions, edge_radius=edge_radius, center=true);
        }
    }
}

module base_cube(dimensions, edge_radius=1) {
    if (Body_Style == "rounded") {
        round_cube(dimensions, edge_radius=edge_radius);
    } else if (Body_Style == "chamfer") {
        chamfer_cube(dimensions, edge_radius=edge_radius);
    }
}

module hull_in_order() {
    for (ch = [1:1:$children - 1]) {
        hull() {
            children(ch - 1);
            children(ch);
        }
    }
}

module cut_z(flip=false, raise=0) {
    difference() {
        children();
        mirror([0, 0, flip ? 1 : 0])
        translate([0, 0, raise])
        linear_extrude(height=max(board_size) * 2)
        square(max(board_size) * 2, center=true);
    }
}

module cut_wire_holes(single=false) {
    difference() {
        children();
        for (my = single ? [0] : [0, 1])
        mirror([0, my, 0])
        rotate([0, -90, 0])
        linear_extrude(height=board_size[0] * 2, center=true)
        translate([board_size[2] / 2, single ? 0 : board_size[1] / 3])
        offset(r=edge_radius)
        offset(r=-edge_radius)
        square([board_size[2] * 2, board_size[1] / (single ? 1 : 3) - edge_radius], center=true);
    }
}

module grips(inset=false) {
    iadd = inset ? fit : 0;
    for (my = [0:1:1])
    mirror([0, my, 0])
    translate([0, (board_size[1] + thick) / 2, 0])
    rotate([0, -90, 0])
    rotate_extrude(angle=360)
    translate([0, -grip_length / 2 - iadd]) {
        offset(r=grip_radius * 0.49)
        offset(r=-grip_radius * 0.49)
        square([grip_radius + iadd, grip_length + iadd * 2]);
        square([grip_radius / 2, grip_length + iadd * 2]);
    }
}

module add_grips(inset=false) {
    difference() {
        children();
        if (inset) {
            grips(inset=inset);
        }
    }
    if (!inset) {
        grips(inset=inset);
    }
}

module polarity_text() {
    for (mx = [0:1:1])
    mirror([mx, 0])
    rotate(90)
    translate([0, (board_size[0] - font_size) / 2])
    text("–       +", font=":style=Bold", size=font_size, halign="center", valign="center");
}

module make_outline() {
    difference() {
        offset(delta=thick)
        children();
        children();
    }
}
module outline_shape_base() {
    rr = 4;
    for (my = [0:1:1])
    mirror([0, my])
    translate([0, rr/cos(30)])
    circle(r=rr, $fn=6);
}

module base_pattern(potentiometer_hole=false) {
    polarity_text();
    difference() {
        offset(r=thick)
        offset(r=-thick)
        difference() {
            square([board_size[0], board_size[1]], center=true);
            for (mx = [0:1:1], my = [0:1:1])
            mirror([0, my])
            mirror([mx, 0])
            translate([board_size[0] / 2, board_size[1] / 2])
            circle(r=font_size + thick / 2);
        }
        if (potentiometer_hole) {
            make_outline() {
                translate([-board_size[0] / 2 + 6.8, board_size[1] / 2 - 2.5])
                circle(d = 3 + thick);
            }
        }
        difference() {
            for (i = [0, 1, 2, 3, 4])
            make_outline()
            translate([board_size[0] / 2, -board_size[1] / 2])
            circle(d=13 + thick * 3.5 * i);
            if (potentiometer_hole) {
                translate([-board_size[0] / 2 + 6.8, board_size[1] / 2 - 2.5])
                offset(delta=0.5)
                circle(d = 3 + thick);
            }
        }
    }
}

module top_pattern() {
    base_pattern(potentiometer_hole=true);
}

module bottom_pattern() {
    base_pattern();
}

module top() {
    color("plum", 0.6)
    render(convexity=2)
    add_grips()
    cut_wire_holes(single=true)
    cut_z(raise = board_size[2] - thick)
    mirror([0, 1])
    difference() {
        base_cube(vec_add(board_size, thick * 2 + fit));
        translate([0, 0, thick])
        base_cube(vec_add([board_size[0], board_size[1], board_size[2] * 2], thick + fit));
        linear_extrude(height=board_size[2] * 4, center=true)
        top_pattern();
    }
}

module bottom() {
    color("greenyellow", 0.6)
    render(convexity=2)
    add_grips(inset=true)
    cut_wire_holes()
    difference() {
        union() {
            cut_z(raise=-(board_size[2] - thick))
            base_cube(vec_add(board_size, thick * 2));
            cut_z(raise=board_size[2] - thick)
            base_cube(vec_add(board_size, thick));
        }
        translate([0, 0, thick])
        base_cube([board_size[0], board_size[1], board_size[2] * 2]);
        linear_extrude(height=board_size[2] * 4, center=true)
        bottom_pattern();
    }
}

module board() {
    if ($preview)
    translate([0, 0, -board_size[2] / 2])
    color("seagreen", 0.4) {
        linear_extrude(height=1.2)
        square([board_size[0], board_size[1]], center=true);
        linear_extrude(height=board_size[2])
        translate(inductor_pos)
        square([6.7, 6.7], center=true);
        linear_extrude(height=board_size[2] / 2 + 1.2)
        translate(potentiometer_pos)
        circle(d=3);
    }
}

module mp1584_case() {
    if (Part == "both") {
        translate([0, -board_size[1], 0])
        top();
        translate([0, board_size[1], 0]) {
            bottom();
            board();
        }
    } else if (Part == "both_assembled") {
        rotate([180, 0, 0])
        top();
        bottom();
        board();
    } else if (Part == "top") {
        top();
    } else if (Part == "bottom") {
        bottom();
    }
}

module main() {
    mp1584_case();
}

main();
