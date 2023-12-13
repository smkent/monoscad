/*
 * Sovol SV06 Plus extruder cable support
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */

Render_Mode = "print"; // [print: Print Orientation, normal: Installed orientation, model_preview: Preview of model installed on mainboard box]

/* [Mainboard support options] */

Minimum_Thickness = 2.0; // [0.4:0.1:3]

/* [Development Toggles] */

Preview_Mainboard_Box_Open = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

zoff = -12.814 + ((2.2 - 1.5) / 2);
min_thickness = Minimum_Thickness;

hinge_pos = [5, 6.5];

fit = 0.25;
slop = 0.01;

bottom_cut = 6;

// Functions //

function convert_z(mainboard_z) = (mainboard_z - 154.63 - zoff);

// Modules //

module original_mainboard_box_back() {
    color("#ccc", 0.6)
    import("sovol-sv06-plus-motherboard-box-back.stl", convexity=4);
}

module original_mainboard_box(open=false) {
    original_mainboard_box_back();
    color("#ccc", 0.6)
    translate(hinge_pos)
    rotate(open ? -90 : 0)
    translate(-hinge_pos)
    import("sovol-sv06-plus-motherboard-box-front.stl", convexity=4);
}

module original_model() {
    import("itsrouteburn-Sovol SV06 Plus Print Head Cable Support.stl", convexity=4);
}

module mainboard_box_groove_shape() {
    offset(r=0.90)
    offset(r=-1)
    offset(r=1)
    projection(cut=true)
    intersection() {
        rotate([90, 0, 0])
        translate([0, -(21 - 15.5) - slop, 0])
        translate([-68.446, -15.5, -153.518])
        original_mainboard_box_back();
        linear_extrude(height=1)
        mirror([0, 1])
        square([103.56 - 68.446, 167 - 153.518]);
    }
}

module modified_model() {
    translate([0, 0, -bottom_cut])
    render(convexity=4)
    difference() {
        original_model();
        rotate([-90, 0, 0])
        translate([0, -10.614, min_thickness])
        mirror([0, 0, 1])
        linear_extrude(height=3)
        mirror([1, 0])
        intersection() {
            overlap = 1;
            translate([-((103.56 - 68.446) - 22) / 2, 0])
            mainboard_box_groove_shape();
            translate([-overlap, 0])
            mirror([0, 1])
            square(22 + (overlap * 2));
        }
        translate([0, 0, -slop])
        linear_extrude(height=bottom_cut + slop)
        square(100, center=true);
    }
}

module mainboard_cable_support() {
    color("greenyellow", 0.9)
    modified_model();
}

module preview_placement() {
    translate([(32.259 - 30) / 2, 0, 0])
    translate([0, 0, zoff])
    translate([0, 21 - 16, 0]) // 5
    translate([22, 0, 0])
    translate([73.931, 16, 154.63])
    translate([0, 0, bottom_cut])
    children();
}

module main() {
    if (Render_Mode == "print") {
        rotate([90, 0, 0])
        mainboard_cable_support();
    } else if (Render_Mode == "normal") {
        rotate(180)
        mainboard_cable_support();
    } else if (Render_Mode == "model_preview") {
        preview_placement()
        mainboard_cable_support();
        if (Render_Mode == "model_preview" && $preview) {
            original_mainboard_box(open=Preview_Mainboard_Box_Open);
        }
    }
}

main();
