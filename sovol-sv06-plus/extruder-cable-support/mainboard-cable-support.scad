/*
 * Sovol SV06 Plus extruder cable support
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */

Render_Mode = "print"; // [print: Print Orientation, normal: Installed orientation, model_preview: Preview of model installed on mainboard box]

/* [Mainboard support options] */

Minimum_Thickness = 1.2; // [0.4:0.1:3]

/* [Development Toggles] */

Preview_Mainboard_Box_Open = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

zoff = -12.814 + ((2.2 - 1.5) / 2);
min_thickness = Minimum_Thickness;

hinge_pos = [5, 6.5];

// Functions //

function convert_z(mainboard_z) = (mainboard_z - 154.63 - zoff);

// Modules //

module original_mainboard_box(open=false) {
    color("#ccc", 0.6) {
        import("sovol-sv06-plus-motherboard-box-back.stl", convexity=4);
        translate(hinge_pos)
        rotate(open ? -90 : 0)
        translate(-hinge_pos)
        import("sovol-sv06-plus-motherboard-box-front.stl", convexity=4);
    }
}

module original_model() {
    import("itsrouteburn-Sovol SV06 Plus Print Head Cable Support.stl", convexity=4);
}

// 165.33, 166.83

module modified_model() {
    difference() {
        original_model();
        zb = (165.33 - 154.63 + 1*zoff);
        for (zrange = [
            [10.614, 12.814],
            [convert_z(165.33) - 0.2, convert_z(166.83) + 0.2],
        ])
        translate([-(30) / 2 + 4, 0, zrange[0]])
        linear_extrude(height=abs(zrange[1] - zrange[0]))
        square([30, (3 - min_thickness) * 2], center=true);
    }
}

module mainboard_cable_support() {
    color("chartreuse", 0.9) {
        modified_model();
    }
}

module preview_placement() {
    translate([(32.259 - 30) / 2, 0, 0])
    translate([0, 0, zoff])
    translate([0, 21 - 16, 0]) // 5
    translate([22, 0, 0])
    translate([73.931, 16, 154.63])
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
