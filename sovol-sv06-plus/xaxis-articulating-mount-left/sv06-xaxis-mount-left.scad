/*
 * Articulating Camera X-Axis Left-Side Mount for Sovol SV06 and SV06 Plus
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Options] */

Link_Type = "female"; // [none: X-Axis fitting only, male: Male, female: Female, female_flipped: Female flipped]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

blank_block_width = 29.34;
block_top_z = 25.005;
articulated_mount_width = 19.05;
articulated_mount_attach_height = 17;

raise_slop = 0.75;
attach_extend = 3;

// Modules //

module blank_xaxis_block_part() {
    translate([-1.14, -1.48, 0])
    import("x-axis-left-mount-block-blank.stl");
}

module articulated_mount_base_part() {
    if (Link_Type == "male") {
        translate([0, -27.5, 0])
        translate([27, -47, 0.001])
        import("sneaks-mount-base-slice-m.stl");
    } else if (Link_Type == "female" || Link_Type == "female_flipped") {
        translate([0, -26, 0])
        translate([57, -75, 0.001])
        import("sneaks-mount-base-slice-f.stl");
    }
}

module articulated_mount_raised() {
    linear_extrude(height=(
        block_top_z - articulated_mount_attach_height + raise_slop
    ))
    projection(cut=true)
    translate([0, 0, -raise_slop])
    articulated_mount_base_part();

    translate([0, 0, block_top_z - articulated_mount_attach_height])
    articulated_mount_base_part();
}

module articulated_mount_assembled() {
    color("yellow", 0.8)
    articulated_mount_raised();

    color("lavender", 0.6)
    translate([0, -raise_slop, 0])
    mirror([0, 1, 0])
    rotate([90, 0, 0])
    linear_extrude(height=attach_extend + raise_slop)
    projection(cut=true)
    translate([0, 0, -raise_slop])
    rotate([-90, 0, 0])
    articulated_mount_raised();
}

module articulated_mount() {
    flipped = (Link_Type == "female_flipped");
    translate([(blank_block_width - articulated_mount_width) / 2, 0, 0])
    translate([flipped ? articulated_mount_width : 0, 0, 0])
    mirror([flipped ? 1 : 0, 0, 0])
    articulated_mount_assembled();
}

module main() {
    color("cyan", 0.8) {
        blank_xaxis_block_part();
        if (Link_Type != "none") {
            articulated_mount();
        }
    }
}

main();
