/*
 * Logitech C920 low profile articulating camera mount adapter
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Options] */
// Articulating mount attachment type
Link_Type = "female"; // [none: None, blank: Blank, male: Male, male_flat: Male flat, female: Female, female_flipped: Female flipped]

// Add ball mount to the bottom. When using articulating mount link types, the resulting model will need supports to print.
Ball_Mount = false;

/* [Advanced Options] */
// The default hinge insert fit is snug. Increase this value for a looser fit.
Hinge_Insert_Size_Tolerance = 0.20; // [0:0.05:2]

// Mount body thickness in millimeters
Base_Thickness = 2.5; // [2:0.1:4]

// Enabling these will reduce print bed adhesion
Ball_Mount_Fillets = false;

// Removing the ball mount shroud decreases the part footprint, but increases print difficulty and/or requires supports.
Ball_Mount_Shroud = true;

// Increasing the number of grips produces smaller grips, which are harder to print
Ball_Mount_Grip_Count = 4; // [2:1:8]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4: 2;
$fs = $preview ? $fs / 4 : 0.4;

hinge_width = 40.3;
hinge_diameter = 7.8;

base_thickness = Base_Thickness;
base_hinge_to_curve = (hinge_diameter - base_thickness) / 8;
base_length = 13 + base_thickness + base_hinge_to_curve;

hinge_insert_diameter = 4.0;
hinge_insert_length = 6.8;
hinge_insert_size_tolerance = Hinge_Insert_Size_Tolerance;
hinge_housing_length = 7.6;
hinge_extra_vertical_offset = 1;

articulating_mount_height = 20;

ball_diameter = 15.9;
ball_mount_grip_radius = 3;
ball_mount_channel_radius = 1.6;
ball_mount_grip_count = Ball_Mount_Grip_Count;
ball_mount_grip_width = ball_mount_channel_radius;
ball_mount_fillets = Ball_Mount_Fillets ? 1 : 0;

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
    render()
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
    hull() {
        position_adjustment = (base_thickness - hinge_diameter) / 2;
        circle(d=hinge_diameter);
        translate([
            0,
            -(base_thickness + hinge_diameter) / 2 - hinge_extra_vertical_offset
        ]) {
            translate([-base_hinge_to_curve, 0])
            circle(d=base_thickness);
            translate([position_adjustment, 0])
            circle(d=base_thickness);
        }
        translate([-position_adjustment, position_adjustment])
        circle(d=base_thickness);
    }

    rad = hinge_insert_diameter * 0.5;
    translate([slop, 0])
    translate([
        -rad - hinge_diameter / 2,
        -hinge_diameter / 2 + rad - hinge_extra_vertical_offset
    ])
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
            square(
                [hinge_insert_diameter, hinge_insert_diameter / 2], center=true
            );
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
    mid_height = (Link_Type == "male_flat" ? 9.1 : articulating_mount_height);
    intersection() {
        children();

        linear_extrude(height=articulating_mount_height)
        mount_base_shape();

        rotate([90, 0, 0])
        translate([0, 0, -articulating_mount_height])
        linear_extrude(height=(
            articulating_mount_height + base_length + base_thickness + slop * 2
        ))
        translate([-hinge_width / 2, 0]) {
            r1 = 7;
            offset(r=r1)
            offset(r=-r1 * 2)
            offset(r=r1) {
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

        if (Link_Type != "none") {
            rotate([0, -90, 0])
            linear_extrude(height=hinge_width, center=true)
            attachment_profile_shape();
        }
    }
}

module mount_base() {
    color("lightblue", 0.8)
    mount_body();
    color("lightgreen", 0.8)
    if (is_male() || is_female()) {
        translate([0, base_thickness, 0])
        rotate([90, 0, 180])
        sneaks_articulating_camera_link();
    }
}

module ball_mount_curve_base() {
    intersection() {
        difference() {
            circle(d=ball_diameter + ball_mount_grip_radius * 2);
            circle(d=ball_diameter);
        }
        square(ball_diameter);
    }
}

module ball_mount_curve_half() {
    intersection() {
        ball_mount_curve_base();
        rotate(-45)
        square(ball_diameter);
    }
}

module ball_mount_curve_double() {
    render()
    offset(delta=-1)
    offset(delta=1)
    rotate(45)
    translate([ball_diameter + ball_mount_grip_radius, 0])
    mirror([1, 0])
    ball_mount_curve_half();
    ball_mount_curve_half();
}

module ball_mount_shape_base(ball=true) {
    for (my = [0:1])
    mirror([0, my]) {
        if (ball) {
            ball_mount_curve_base();
        }
        translate([ball_mount_grip_radius + ball_mount_channel_radius, 0])
        ball_mount_curve_double();
    }
}

module ball_shape_cut(ball=true) {
    color("lightgreen", 0.8)
    translate([0, ball_diameter / 2 * 0.4])
    render()
    difference() {
        intersection() {
            circle(d=(
                ball_diameter
                + ball_mount_grip_radius * 2
                + ball_mount_channel_radius * 2.5
            ));
            union() {
                translate([0, -ball_diameter * 0.2])
                square([ball_diameter * 10, ball_diameter * 0.5]);
                intersection() {
                    circle(d=ball_diameter);
                    square(ball_diameter / 2);
                }
            }
        }
        intersection() {
            ball_mount_shape_base(ball=ball);
            square([ball_diameter * 2, ball_diameter / 2]);
        }
        offset(r=ball_mount_fillets * 1)
        offset(r=ball_mount_fillets * -1)
        intersection() {
            ball_mount_shape_base(ball=ball);
            square(
                [ball_diameter * 2, ball_diameter / 2 * 0.8], center=true
            );
        }
    }
}

module ball_wings_cut() {
    render()
    difference() {
        children();

        color("lightblue", 0.8)
        intersection() {
            for (r = [0:360/ball_mount_grip_count:360-0.01])
            rotate(r) {
                rotate([90, 0, 0])
                linear_extrude(height=ball_diameter)
                translate([-ball_mount_grip_width / 2, 0])
                offset(r=-ball_mount_grip_width * 0.49)
                offset(r=ball_mount_grip_width * 0.49 * 2)
                offset(r=-ball_mount_grip_width * 0.49)
                union() {
                    square([ball_mount_grip_width, ball_diameter / 2]);
                    translate([ball_mount_grip_width / 2, -ball_diameter / 2])
                    square(
                        ball_mount_fillets
                            ? ball_diameter
                            : [ball_mount_grip_width, ball_diameter],
                        center=true
                    );
                }
            }
            rotate_extrude(angle=360)
            ball_shape_cut(ball=false);
        }
    }
}

module ball_mount_cut() {
    difference() {
        children();
        color("lightgreen", 0.8)
        rotate_extrude(angle=360)
        ball_shape_cut();
    }
}

module hull_sequence() {
    for (ch = [0:1:$children - 2])
    hull() {
        children(ch);
        children(ch + 1);
    }
}

module ball_mount_body() {
    body_diameter = (
        ball_diameter
        + ball_mount_grip_radius * 2
        + (Ball_Mount_Shroud
            ? ball_mount_channel_radius * 2 + base_thickness * 2
            : 0
        )
    );
    mid_height = ball_diameter * (Ball_Mount_Shroud ? 0.35 : 0.5);
    hull_sequence() {
        if (Ball_Mount_Shroud) {
            translate([0, 0, slop])
            rotate_extrude(angle=360) {
                offset(r=base_thickness * 0.45)
                offset(r=-base_thickness * 0.45)
                square([body_diameter / 2, mid_height]);
                if (!ball_mount_fillets) {
                    square([body_diameter / 2, mid_height / 2]);
                }
            }
        } else {
            translate([0, 0, mid_height])
            cylinder(h=slop, d=body_diameter - ball_mount_channel_radius * sqrt(2));
        }

        translate([0, 0, ball_diameter * 0.8 - slop])
        linear_extrude(height=slop)
        translate([0, (base_length - base_thickness) / 2])
        mount_base_shape();
    }
    if (!Ball_Mount_Shroud) {
        cylinder(d=body_diameter, h=mid_height);
    }
}

module ball_mount() {
    color("lemonchiffon", 0.5)
    render()
    ball_mount_cut()
    ball_wings_cut()
    ball_mount_body();
}

module c920_mount() {
    mirror([0, 1, 0])
    translate([0, base_length])
    color("lavender", 0.8)
    hinge_pair();
    mount_base();
    if (Ball_Mount) {
        translate([0, 0, -ball_diameter * 0.8])
        translate([0, -(base_length - base_thickness) / 2, 0])
        ball_mount();
    }
}

module main() {
    color("lightsalmon", 0.8)
    c920_mount();
}

main();
