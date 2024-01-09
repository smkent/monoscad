/*
 * Kirby 120mm Fume Extractor
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Rendering Options] */
Part = "preview"; // [preview: Assembled model preview, face: Face, back: Back, grill: Grill, inner-spacer: Inner spacer, feet-connector: Feet connector, left-foot: Left foot, right-foot: Right foot, pin: Pin, left-arm: Left arm, right-arm: Right arm, eye: Eye, eye-insert-white: White eye insert, eye-insert-blue: Blue eye insert]

/* [Fan size] */
Fan_Size = 120;
Fan_Thickness = 27;
Fan_Screw_Hole_Inset = 7.5;

/* [Fan attachment] */
Hole_Diameter = 4;
Fan_Attachment = "screws"; // [screws: Screws, inserts: Heat-set inserts]

/* [Advanced Options] */
Fan_Corner_Radius = 3;

Fit = 1;

// 0 means determine automatically
Scale_Factor = 0;

Widen_Fan_Bay = false;
Widen_Cable_Area = true;

USB_C_Decoy_Board_Slot = true;

/* [Development Toggles] */
Half_View = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

fan_d = Fan_Size + Fit;
fan_thick = Fan_Thickness + Fit;
fan_screw_pos = Fan_Screw_Hole_Inset;
scale_factor = Scale_Factor == 0 ? Fan_Size / 40 : Scale_Factor;
fan_attach = Fan_Attachment;
fan_attach_hole_d = Hole_Diameter;
fan_corner_radius = Fan_Corner_Radius;
widen_fan_bay = Widen_Fan_Bay;
widen_cable_area = Widen_Cable_Area;
usb_decoy_board_enabled = USB_C_Decoy_Board_Slot;
usb_decoy_board_size = [31, 20, 5] * 1.2;

// Modules //

module kirby_pink(r=false) {
    color("#e791bf", 0.8)
    if (r) {
        render(convexity=4)
        children();
    } else {
        children();
    }
}

module face() {
    kirby_pink()
    intersection() {
        rotate([90, 0, 0])
        translate([30, -10, 9.99] - [60, 22.6 * 0, 59.99] / 2)
        import("chrisborge-face.stl", convexity=4);
        linear_extrude(height=21.9)
        square(61, center=true);
    }
}

module back() {
    kirby_pink()
    translate([0, 0, -21.9])
    rotate([90, 0, 0])
    translate([30, 12, 9.85] - [60, 27 * 0, 59.84] / 2)
    import("chrisborge-back.stl", convexity=4);
}

module grill() {
    kirby_pink()
    translate([0, 0, 9])
    rotate([90, 0, 0])
    translate([0, 0, 0.39] - [0, 0, 40.78] / 2)
    import("chrisborge-grill.stl", convexity=4);
}

module inner_spacer() {
    color("gray", 0.8)
    rotate([90, 0, 0])
    translate([0, 0, 4] - [0, 0, 47.99] / 2)
    import("chrisborge-inner-spacer.stl", convexity=4);
}

module feet_connector() {
    color("gray", 0.8)
    rotate([90, 0, 0])
    translate([0, 0, 4] - [0, 0, 47.99] / 2)
    import("chrisborge-feet-connector.stl", convexity=4);
}

module left_foot() {
    color("red", 0.8)
    translate([0, 0, 40])
    translate([0, 0, 4] - [0, 0, 47.99] / 2)
    import("chrisborge-left-foot.stl", convexity=4);
}

module right_foot() {
    color("red", 0.8)
    translate([0, 0, 40])
    translate([0, 0, 4] - [0, 0, 47.99] / 2)
    import("chrisborge-right-foot.stl", convexity=4);
}

module pin() {
    color("#ccc", 0.8)
    import("chrisborge-pin.stl", convexity=4);
}

module left_arm() {
    kirby_pink()
    translate([0, 0, -94.79])
    import("chrisborge-left-arm.stl", convexity=4);
}

module right_arm() {
    kirby_pink()
    translate([0, 0, -94.79])
    import("chrisborge-right-arm.stl", convexity=4);
}

module eye() {
    color("#333", 0.8)
    translate([0, 0, 28])
    import("chrisborge-eye.stl", convexity=4);
}

module eye_insert_white() {
    color("white", 0.8)
    translate([-122.56, -101.62, 0])
    import("josteing-eye-white-part.stl", convexity=4);
}

module eye_insert_blue() {
    color("skyblue", 0.8)
    translate([-122.56, -101.62, 0])
    import("josteing-eye-blue-part.stl", convexity=4);
}

module back_patched() {
    kirby_pink(r=true)
    union() {
        // Original back
        back();
        mirror([0, 0, 1])
        intersection() {
            // Limit patches at outer surface
            translate([-30, -30, 0])
            cube([60, 60, 21.9]);
            sphere(d=59.79);
            union() {
                // Patch fan screw holes
                translate([0, 0, 22 - 15 - 0.10])
                linear_extrude(height=15.10)
                difference() {
                    d = 4;
                    for (mx = [0, 1], my = [0, 1])
                    mirror([mx, 0])
                    mirror([0, my])
                    translate([32, 32] / 2)
                    circle(d=d);
                }
                // Patch fan insert
                linear_extrude(height=6.9)
                difference() {
                    square(40.5 + 0.5, center=true);
                    circle(r=18.27);
                    translate([-3 / 2, 0])
                    square([3, 50]);
                    translate([-32 / 2, 0])
                    square([32, 40.5 + 1.75]);
                }
            }
        }
    }
}

module back_120mm() {
    kirby_pink(r=true)
    difference() {
        scale(scale_factor)
        back_patched();

        // Fan bay
        mirror([0, 0, 1])
        linear_extrude(height=fan_thick)
        union() {
            offset(r=fan_corner_radius)
            offset(r=-fan_corner_radius)
            square([fan_d, fan_d], center=true);
            scale(scale_factor)
            translate([-32 / 2, 20])
            square([32, 2.20]);
        }

        // Below fan bay
        if (usb_decoy_board_enabled) {
            mirror([0, 0, 1])
            translate([0, 0, fan_thick * 0.8])
            linear_extrude(height=usb_decoy_board_size[0])
            translate([0, 22.2] * scale_factor - [0, usb_decoy_board_size[2]])
            translate([-usb_decoy_board_size[1] / 2, 0])
            square([usb_decoy_board_size[1], usb_decoy_board_size[2]]);
        }

        // Below fan
        if (widen_cable_area) {
            intersection() {
                scale(scale_factor)
                sphere(r=26);
                translate([0, 0, -fan_thick])
                linear_extrude(height=fan_thick)
                scale(scale_factor)
                translate([-15, 20])
                square([30, 30]);
            }
        }

        // Widen cavity behind fan bay
        if (widen_fan_bay) {
            intersection() {
                sphere(r=(30 - 5.5) * scale_factor);
                mirror([0, 0, 1])
                linear_extrude(height=21.9 * scale_factor)
                offset(r=fan_corner_radius)
                offset(r=-fan_corner_radius)
                square([fan_d, fan_d], center=true);
            }
        }

        // Screw holes
        for (mx = [0, 1], my = [0, 1]) {
            mirror([mx, 0])
            mirror([0, my])
            mirror([0, 0, 1])
            linear_extrude(height=((fan_attach == "screws" ? 21.9 : (19 - fan_attach_hole_d)) * scale_factor))
            translate([fan_d / 2 - fan_screw_pos, fan_d / 2 - fan_screw_pos])
            circle(d=fan_attach_hole_d);
        }
    }
}

module face_120mm() {
    kirby_pink(r=true)
    scale(scale_factor)
    face();
}

module grill_120mm() {
    kirby_pink(r=true)
    scale(scale_factor)
    grill();
}

module inner_spacer_120mm() {
    scale(scale_factor)
    inner_spacer();
}

module feet_connector_120mm() {
    scale(scale_factor)
    feet_connector();
}

module left_foot_120mm() {
    scale(scale_factor)
    left_foot();
}

module right_foot_120mm() {
    scale(scale_factor)
    right_foot();
}

module pin_120mm() {
    scale(scale_factor)
    pin();
}

module left_arm_120mm() {
    scale(scale_factor)
    left_arm();
}

module right_arm_120mm() {
    scale(scale_factor)
    right_arm();
}

module eye_120mm() {
    scale(scale_factor)
    eye();
}

module eye_insert_white_120mm() {
    scale(scale_factor)
    eye_insert_white();
}

module eye_insert_blue_120mm() {
    scale(scale_factor)
    eye_insert_blue();
}

module main() {
    if (Part == "preview") {
        rotate([10, 0, 0])
        rotate(180)
        rotate([-90, 0, 0]) {
            face_120mm();
            back_120mm();
            translate([0, 0, -19 * scale_factor])
            grill_120mm();
            translate([0, 0, -10 * scale_factor])
            inner_spacer_120mm();
            rotate([10, 0, 0])
            translate([0, 0, 4 * scale_factor])
            union() {
                translate([0, 0, -20 * scale_factor])
                feet_connector_120mm();
                translate([0, 40 * scale_factor, -19 * scale_factor])
                rotate([90, 0, 0])
                union() {
                    left_foot_120mm();
                    right_foot_120mm();
                }
            }
            rotate([90, 0, 0])
            for (mx = [0, 1])
            mirror([mx, 0])
            translate([8, 11, 25] * scale_factor)
            rotate([-24, 15, 0])
            rotate([0, 0, 22])
            translate([-5, -48, 0] * scale_factor)
            eye_120mm();

            rotate([90, 0, 0])
            for (mx = [0, 1])
            mirror([mx, 0])
            translate([6, 13, 25.5] * scale_factor)
            rotate([-24, 15, -3])
            union() {
                eye_insert_blue_120mm();
                translate([-1, -25, 0])
                eye_insert_white_120mm();
            }

            for (mx = [0, 1])
            mirror([mx, 0])
            translate([16, -7.75, -25] * scale_factor)
            rotate([20, 0, 64])
            pin_120mm();

            for (arm = [-1, 1])
            rotate([30, 0, 18 * arm])
            translate([-4 * arm, -20, -3] * scale_factor)
            if (arm == -1) {
                left_arm_120mm();
            } else {
                right_arm_120mm();
            }
        }
    } else if (Part == "face") {
        translate([0, 0, 21.9 * scale_factor])
        rotate([180, 0, 0])
        face_120mm();
    } else if (Part == "back") {
        translate([0, 0, 21.9 * scale_factor])
        back_120mm();
    } else if (Part == "grill") {
        rotate([180, 0, 0])
        grill_120mm();
    } else if (Part == "inner-spacer") {
        translate([0, 0, 16 * scale_factor])
        rotate([180, 0, 0])
        inner_spacer_120mm();
    } else if (Part == "feet-connector") {
        translate([0, 0, 10 * scale_factor])
        rotate([180, 0, 0])
        feet_connector_120mm();
    } else if (Part == "left-foot") {
        left_foot_120mm();
    } else if (Part == "right-foot") {
        right_foot_120mm();
    } else if (Part == "pin") {
        translate([0, 0, 12] * scale_factor)
        rotate([90, 0, 0])
        pin_120mm();
    } else if (Part == "left-arm") {
        left_arm_120mm();
    } else if (Part == "right-arm") {
        right_arm_120mm();
    } else if (Part == "eye") {
        color("#ccc", 0.8)
        eye_120mm();
    } else if (Part == "eye-insert-white") {
        eye_insert_white_120mm();
    } else if (Part == "eye-insert-blue") {
        eye_insert_blue_120mm();
    }
}

intersection() {
    if (Half_View) {
        mirror([1, 0, 0])
        translate([0, -50 * scale_factor, -50 * scale_factor])
        cube(100 * scale_factor);
    }
    main();
}
