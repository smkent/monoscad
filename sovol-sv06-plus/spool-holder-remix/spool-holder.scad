/*
 * Spool Holder remix for Sovol SV06 and SV06 Plus
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

/* [Options] */
Part = "barrel"; // [preview: Preview of all model parts, barrel: Sunlu-size barrel adapter, nut: Sunlu-size nut]

/* [Nut Options] */
Nut_Extra_Length = 15; // [0:0.1:30]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

barrel_cone_r = 39.685 + 0.4;
barrel_in_r = 22.9; // reduce a bit
barrel_base_lip_z = 5.11971;

nut_id = 46.4;
nut_base_edge_radius = 1;
nut_thread_z = [4.125, 7.675, 10.125, 13.675, 16.125, 19.675];
nut_thread_loop_z = nut_thread_z[2] - nut_thread_z[0];
nut_new_thread_base = Nut_Extra_Length + nut_thread_z[0] - nut_base_edge_radius;

sunlu_nut_lip_z = 2.41422;

slop = 0.01;

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

module sunlu_nut_threads() {
    intersection() {
        original_sunlu_nut();
        translate([0, 0, nut_thread_z[0]])
        cylinder(
            h=nut_thread_z[len(nut_thread_z) - 1] - nut_thread_z[0],
            d=nut_id + slop * 2
        );
    }
}

module sunlu_nut() {
    extend = Nut_Extra_Length;
    // Bottom
    intersection() {
        original_sunlu_nut();
        cylinder(sunlu_nut_lip_z, 200, 200);
    }

    // Extend threads
    translate([0, 0, extend])
    for (z = [0:-nut_thread_loop_z:-nut_new_thread_base])
    translate([0, 0, z])
    sunlu_nut_threads();

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
    if (Part == "barrel") {
        color("lightblue", 0.8)
        render(convexity=2)
        sunlu_combined_barrel();
    } else if (Part == "nut") {
        color("lightgreen", 0.8)
        sunlu_nut();
    } else if (Part == "preview") {
        all_parts_preview();
    }
}

main();
