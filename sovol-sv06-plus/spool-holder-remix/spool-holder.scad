/*
 * Spool Holder remix for Sovol SV06 and SV06 Plus
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

/* [Options] */
Part = "sunlu_combined_barrel"; // [preview: Preview of all model parts, sunlu_combined_barrel: Sunlu-size barrel adapter, sunlu_nut: Sunlu-size nut]

/* [Nut Options] */
Nut_Extra_Length = 10; // [0:0.1:30]

/* [Size] */
// All units in millimeters

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

barrel_cone_r = 39.685 + 0.4;
barrel_in_r = 22.9; // reduce a bit
barrel_base_lip_z = 5.11971;

sunlu_nut_lip_z = 2.41422;

// Modules //

module sunlu_combined_barrel() {
    // Original spool barrel holder
    color("yellow", 0.6)
    import("rogerquin-sv06-spool-holder-barrel.stl", convexity=4);

    // Original Sunlu spool barrel adapter
    color("lightblue", 0.6)
    for (sc = [1, 0.9])
    scale([sc, sc])
    import("rogerquin-sv06-spool-holder-sunlu-barrel-adapter.stl", convexity=4);

    // Close part separation with a cone
    rr = 3;
    color("lightgreen", 0.5)
    translate([0, 0, barrel_base_lip_z])
    rotate_extrude(angle=360)
    difference() {
        offset(r=-rr)
        offset(delta=rr)
        union() {
            polygon(points=[[0, 0], [barrel_cone_r, 0], [0, barrel_cone_r]]);
            square([barrel_in_r, 500]);
        }
        square([barrel_in_r, 500]);
    }
}

module original_sunlu_nut() {
    // Original Sunlu-size nut
    color("lightgreen", 0.8)
    import("rogerquin-sv06-spool-holder-sunlu-nut.stl", convexity=4);
}

module sunlu_nut() {
    extend = Nut_Extra_Length;
    // Bottom
    intersection() {
        original_sunlu_nut();
        cylinder(sunlu_nut_lip_z, 200, 200);
    }

    // New extension
    slop = 0.01;
    color("lavender", 0.5)
    translate([0, 0, sunlu_nut_lip_z - slop])
    linear_extrude(height=extend + slop * 2)
    projection(cut=true)
    translate([0, 0, -sunlu_nut_lip_z])
    original_sunlu_nut();

    // Top
    translate([0, 0, extend])
    intersection() {
        original_sunlu_nut();
        translate([0, 0, sunlu_nut_lip_z])
        cylinder(200, 200, 200);
    }
}

module all_parts_preview() {
    rotate([90, 0, 90])
    translate([0, 0, -55]) {
        color("lightblue", 0.8)
        render(convexity=2)
        sunlu_combined_barrel();

        translate([0, 0, 100 + Nut_Extra_Length])
        rotate([180, 0, 0])
        color("lightgreen", 0.8)
        sunlu_nut();

        color("#aaa", 0.8)
        translate([0, 0, -30])
        import("rogerquin-sv06-spool-holder-barrel-fitting.stl", convexity=4);
    }
}

module main() {
    if (Part == "sunlu_combined_barrel") {
        color("lightblue", 0.8)
        render(convexity=2)
        sunlu_combined_barrel();
    } else if (Part == "sunlu_nut") {
        color("lightgreen", 0.8)
        sunlu_nut();
    } else if (Part == "preview") {
        all_parts_preview();
    }
}

main();
