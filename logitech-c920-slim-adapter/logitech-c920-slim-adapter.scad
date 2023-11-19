/*
 * Logitech C920 low profile articulating camera adapter
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Options] */
// Articulating mount attachment type
Link_Type = "female"; // [none: None, male: Male, male_flat: Male flat, female: Female, female_flipped: Female flipped]

// Mount body thickness in millimeters
Base_Thickness = 2.5; // [2:0.1:4]

// The default hinge insert fit is snug. Increase this value for a looser fit.
Hinge_Insert_Size_Tolerance = 0; // [0:0.05:2]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4: 2;
$fs = $preview ? $fs / 4 : 0.4;

hinge_width = 38.8;
hinge_diameter = 7;

base_thickness = Base_Thickness;
base_length = 13 + base_thickness;

hinge_insert_diameter = 4.0;
hinge_insert_length = 6.8;
hinge_insert_size_tolerance = Hinge_Insert_Size_Tolerance;
hinge_housing_length = 7.6;
hinge_extra_vertical_offset = 1;

articulating_mount_height = 20;

slop = 0.01;

// Functions //

function is_female() = (Link_Type == "female" || Link_Type == "female_flipped");

function is_male() = (Link_Type == "male" || Link_Type == "male_flat");

// Modules //

module sneaks_articulating_camera_link_stl() {
    import("sneaks-articulating-camera-mount-mflink.stl", convexity=4);
}

module sneaks_articulating_camera_link() {
    height = (Link_Type == "male_flat" ? 6.8 : 20);
    intersection() {
        translate([0, height / 2, 0])
        if (is_female()) {
            translate([0, 0, -3.5])
            mirror(Link_Type == "female_flipped" ? [1, 0, 0] : [0, 0, 0])
            mirror([0, 0, 1])
            sneaks_articulating_camera_link_stl();
        } else if (is_male()) {
            translate((Link_Type == "male_flat") ? [0, 0, -1] : [0, 0, 0])
            rotate((Link_Type == "male_flat") ? 90 : 0)
            sneaks_articulating_camera_link_stl();
        }
        linear_extrude(height=30)
        translate([-15, 0])
        square(30);
    }
}

module fillet(rad=base_thickness) {
    intersection() {
        difference() {
            square(rad * 2, center=true);
            circle(d=rad * 2);
        }
        square(rad);
    }
}

module hinge_base_shape() {
    hull()
    union() {
        dd = base_thickness - hinge_diameter;
        circle(d=hinge_diameter);
        for (xf = [0.5, 1])
        translate([xf * dd / 2, dd / 2 - base_thickness - hinge_extra_vertical_offset])
        circle(d=base_thickness);
    }

    rad = hinge_insert_diameter * 0.5;
    translate([slop, 0])
    translate([-rad - hinge_diameter / 2, -hinge_diameter / 2 + rad - hinge_extra_vertical_offset])
    rotate(270)
    fillet(rad);
}

module hinge_base() {
    render(convexity=2)
    difference() {
        linear_extrude(height=hinge_housing_length)
        difference() {
            hinge_base_shape();
            circle(d=hinge_insert_diameter / 2);
        }
        linear_extrude(height=hinge_insert_length)
        offset(r=hinge_insert_size_tolerance / 2)
        hull() {
            circle(d=hinge_insert_diameter);
            offset(r=hinge_insert_diameter / 8)
            offset(r=-hinge_insert_diameter / 8)
            translate([0, -hinge_insert_diameter / 4])
            square([hinge_insert_diameter, hinge_insert_diameter / 2], center=true);
        }
    }
}

module hinge_pair() {
    translate([
        0,
        hinge_diameter / 2 - base_thickness,
        hinge_diameter / 2 + base_thickness
    ])
    rotate([90, 0, 90])
    for (mz = [0:1:1])
    mirror([0, 0, mz])
    translate([0, hinge_extra_vertical_offset, -hinge_width / 2])
    hinge_base();
}

module mount_base_shape() {
    y = base_length + base_thickness;
    translate([0, base_thickness, 0])
    mirror([0, 1])
    translate([-hinge_width / 2, 0]) {
        offset(r=7)
        offset(r=-7)
        square([hinge_width, y]);
        translate([0, y / 2])
        square([hinge_width, y / 2]);
    }
}

module attachment_profile_shape() {
    translate([base_thickness, 0])
    square([articulating_mount_height - base_thickness, base_thickness * 2]);

    rad = hinge_diameter / 2;
    translate([rad + base_thickness, -rad])
    rotate(90)
    translate([0, -rad])
    scale([1, 2])
    fillet(rad);
}

module attachment_height_cut() {
    mid_width = articulating_mount_height + (is_female() ? -1 : 0);
    mid_height = (Link_Type == "male_flat" ? 7.1 + 2 : articulating_mount_height);
    intersection() {
        children();

        linear_extrude(height=articulating_mount_height)
        mount_base_shape();

        rotate([90, 0, 0])
        translate([0, 0, -articulating_mount_height])
        linear_extrude(height=articulating_mount_height + base_length + base_thickness + slop * 2)
        translate([-hinge_width / 2, 0])
        union() {
            r1 = 7;
            offset(r=r1)
            offset(r=-r1 * 2)
            offset(r=r1)
            union() {
                translate([(hinge_width - mid_width) / 2, base_thickness])
                square([mid_width, mid_height - base_thickness]);
                mirror([0, 1])
                translate([0, -base_thickness])
                translate([-hinge_width / 2, 0])
                square([hinge_width * 2, hinge_width]);
            }
            if (is_female()) {
                r2 = 0.5;
                offset(r=r2)
                offset(r=-r2)
                translate([(hinge_width - mid_width) / 2, base_thickness])
                square([mid_width, articulating_mount_height - base_thickness]);
            }
        }
    }
}

module mount_body() {
    render(convexity=2)
    attachment_height_cut() {
        linear_extrude(height=base_thickness)
        mount_base_shape();

        rotate([0, -90, 0])
        linear_extrude(height=hinge_width, center=true)
        attachment_profile_shape();
    }
}

module mount_base() {
    color("lightblue", 0.8)
    mount_body();
    color("lightgreen", 0.8)
    if (Link_Type != "none") {
        translate([0, base_thickness, 0])
        rotate([90, 0, 180])
        sneaks_articulating_camera_link();
    }
}

module c920_mount() {
    mirror([0, 1, 0])
    translate([0, base_length])
    color("lavender", 0.8)
    hinge_pair();
    mount_base();
}

module main() {
    color("lightsalmon", 0.8)
    c920_mount();
}

main();
