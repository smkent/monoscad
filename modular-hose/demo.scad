/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Models demo
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <mh-library.scad>;
use <segment.scad>;
use <magnetic-parts.scad>;
use <vacuum-attachment.scad>;

/* [Demo selection] */

Demo = "parts"; // [parts: Part assortment, measurement: Measurement example]

Enable_Plate_Knurling = false;

/* [Model options] */

Inner_Diameter = 100; // [20:1:100]

/* [Hidden] */

Measurement_Text = true;

module __end_customizer_options__() { }

// Constants

spacing = 100 * 1.5;

// Modules

module place_part(x, y) {
    translate([spacing * x, spacing * y, 0])
    children();
}

module center_demo(max_x, max_y) {
    translate([-spacing * max_x / 2, -spacing * max_y / 2, 0])
    children();
}

module stack_parts() {
    for (i = [0:1:1]) {
        mirror([0, 0, i])
        translate([0, 0, Inner_Diameter / 4])
        children(i);
    }
}

module mh_demo_parts() {
    id = Inner_Diameter;
    place_part(0, 0)
    mh_segment(id);

    place_part(-1, 0)
    rotate(180)
    mh(id)
    mh_segment(id, bend_angle=30);

    place_part(-0.5, 1)
    mh_vacuum_attachment(id, connector_type="female");

    place_part(1, 0)
    stack_parts() {
        mh_magnetic_part(id, model_type="grommet", plate_type="fan", grommet_diameter=101.6, magnet_holes=true, screw_holes=true, plate_knurled=Enable_Plate_Knurling);
        mh_magnetic_part(id, model_type="connector", connector_type="male", plate_type="fan", grommet_diameter=101.6, magnet_holes=true, screw_holes=false, plate_knurled=Enable_Plate_Knurling);
    }

    place_part(1, 1)
    stack_parts() {
        mh_magnetic_part(id, model_type="grommet", plate_type="round", grommet_diameter=101.6, magnet_holes=true, screw_holes=true, plate_knurled=Enable_Plate_Knurling);
        mh_magnetic_part(id, model_type="connector", connector_type="female", plate_type="round", grommet_diameter=101.6, magnet_holes=true, screw_holes=false, plate_knurled=Enable_Plate_Knurling);
    }
}

module mh_demo_measurement() {
    id = Inner_Diameter;
    line_height = id / 10;
    text_size = line_height * 0.9;
    mh_segment(inner_diameter=Inner_Diameter, render_mode="half");

    color("yellow", 0.2)
    linear_extrude(height=0.1)
    polygon(points=[
        [-id / 2, 0],
        [-id / 2 + line_height, line_height],
        [id / 2 - line_height, line_height],
        [id / 2, 0],
        [id / 2 - line_height, -line_height],
        [-id / 2 + line_height, -line_height],
    ]);

    color("mintcream", 1.0)
    linear_extrude(height=0.5) {
        text("Inner Diameter",
            halign="center",
            valign=(Measurement_Text ? "bottom" : "center"),
            size=text_size
        );
        if (Measurement_Text) {
            translate([0, -line_height])
            text(str("\u2190 ", id, "mm", " \u2192"),
                halign="center",
                size=text_size
            );
        }
    }
}

if (Demo == "parts") {
    mirror([1, 0, 0])
    center_demo(1, 1)
    mh_demo_parts();
} else if (Demo == "measurement") {
    mh_demo_measurement();
}
