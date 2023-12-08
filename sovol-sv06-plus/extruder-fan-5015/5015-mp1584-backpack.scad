/*
 * MP1584 buck converter case
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */

Render_Mode = "print"; // [print: Print orientation, preview: Installed preview]

/* [Options] */

Increase_Body_Thickness = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 2 : 2 / 4;
$fs = $preview ? $fs / 4 : 0.4 / 4;

fit = 0.2;
slop = 0.01;
edge_radius = 2;

board_size = vec_add([22.2, 17.2, 4], fit);

thick = 2;
backpack_thick = 0.8;
backpack_center_d = 50 - 5;
backpack_center_offset = [-1, -2];
board_thick = 1.2 + 0.8;
board_lip_overlap = 0.8;
holder_offset = [-7, 0, 0];

fan_hole_offset = 2;
fan_holes_pos = [[18, 20.5], [-20, -23.5]];

// Functions //

function add_thick(dimensions, add, thick_factor=1) = [
    dimensions[0] + add * 2, dimensions[1] + add * 2, dimensions[2] + add * thick_factor
];

function vec_add(vector, add) = [for (v = vector) v + add];

// Modules //

module fan_model_5015() {
    color("#ccc", 0.6)
    rotate([90, 0, 90])
    import("FarmerKGBOfficer-5015-blower-fan.stl", convexity=4);
}

module fan_5015_holes_shape() {
    for (p = fan_holes_pos)
    translate(p)
    circle(d=4.3);
}

module backpack_body() {
    difference() {
        hull() {
            linear_extrude(height=backpack_thick + board_thick + thick)
            translate(holder_offset)
            offset(r=edge_radius)
            backpack_base_shape();
            linear_extrude(height=backpack_thick)
            translate(backpack_center_offset)
            circle(d=backpack_center_d);
        }
        translate(holder_offset + [0, 0, backpack_thick])
        linear_extrude(height=board_thick + thick + slop)
        offset(r=-edge_radius / 1)
        scale([1, 3])
        backpack_base_shape();
    }
}

module backpack_base() {
    linear_extrude(height=backpack_thick)
    difference() {
        offset(r=-edge_radius)
        offset(r=edge_radius * 2)
        offset(r=-edge_radius)
        union() {
            translate(holder_offset)
            offset(r=edge_radius)
            backpack_base_shape();
            translate(backpack_center_offset)
            circle(d=backpack_center_d);
            offset(r=fan_hole_offset)
            hull()
            fan_5015_holes_shape();
        }
        fan_5015_holes_shape();
    }
    if (Increase_Body_Thickness) {
        backpack_body();
    }
}

module holder_shape() {
    for (mx = [0:1:1])
    mirror([mx, 0])
    translate([-board_size[1] / 2 - thick, 0])
    offset(r=min(backpack_thick * 0.9, 0.8))
    offset(r=-min(backpack_thick * 0.9, 0.8))
    polygon(points=[
        [0, -backpack_thick],
        [thick, -backpack_thick],
        [thick, board_thick],
        [thick + board_lip_overlap, board_thick + thick / 2],
        [thick + board_lip_overlap, board_thick + thick],
        [0, board_thick + thick],
    ]);
}

module backpack_base_shape() {
    rotate(90)
    translate([thick / 2, 0])
    square(vec_add([board_size[0] + thick, board_size[1]], thick * 2), center=true);
}

module mp1584_holder() {
    render(convexity=4)
    translate([0, 0, backpack_thick])
    rotate([90, 0, 90])
    translate([0, 0, thick / 2])
    linear_extrude(height=board_size[0] + thick * 2 + thick, center=true)
    holder_shape();
    // Retaining lip
    translate([0, 0, backpack_thick])
    hull() {
        linear_extrude(height=slop)
        translate([(board_size[0] + thick * 2) / 2 + thick / 2 + thick / 4, 0])
        square([thick * 1.5, board_size[1] / 3], center=true);
        translate([(board_size[0] + thick * 2) / 2 + thick / 2, 0, board_thick + thick / 2])
        rotate([90, 0, 0])
        cylinder(h=board_size[1] / 3, d=thick, center=true);
    }
    rotate(90)
    linear_extrude(height=backpack_thick)
    backpack_base_shape();
}

module mp1584_5015_backpack() {
    rotate([180, 0, 0]) {
        color("lightgreen", 0.6) {
            render(convexity=4)
            mirror([0, 0, 1]) {
                backpack_base();
                translate(holder_offset)
                rotate(90)
                mp1584_holder();
            }
        }
        if (Render_Mode == "preview")
        if ($preview)
        fan_model_5015();
    }
}

mp1584_5015_backpack();
