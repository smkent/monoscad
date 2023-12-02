/*
 * Sovol SV06 Plus extruder cable support
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */

Render_Mode = "print"; // [print: Print Orientation, normal: Installed orientation, model_preview: Preview of model installed on extruder]

/* [Extruder support options] */

Bend_Angle = 75; // [15:1:90]
Bend_Radius = 30; // [5:1:50]

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

gantry_depth = 28.262;

e_x = 77;
e_y = 19.5;
e_clip_x = 4.5;
e_clip_y = 4;
e_clip_z = 4;
e_clip_chamfer = 0.5;
e_clip_pos_x_inner = [26.25, 50.75];
e_clip_pos_x_outer = [24.32, 52.68];
e_clip_outer_x_size = e_clip_pos_x_outer[1] - e_clip_pos_x_outer[0];
e_clip_pos_z = 61;

e_part_y_pos = 0.6;
e_part_x = e_clip_outer_x_size + 4;
e_part_y = e_y + gantry_depth - e_part_y_pos;
e_part_z_top = 0.8;

chamfer = (e_clip_z - e_clip_chamfer) - e_part_z_top;
edge = e_part_z_top;

bend_angle = Bend_Angle;
bend_radius = Bend_Radius;

fit = 0.1;

// Modules //

module original_carriage_slider() {
    color("#94c5db", 0.4)
    import("sovol-sv06-plus-extruder-carriage-slider.stl", convexity=4);
}

module extruder_support_block_cut() {
    difference() {
        children();
        render(convexity=4)
        union() {
            // Extruder support body overlap
            translate([-(e_x - e_part_x) / 2, e_y, -e_clip_pos_z])
            original_carriage_slider();
            // Extruder body interior block
            mirror([0, 0, 1])
            translate([-(e_x - e_part_x) / 2, 0, 1])
            cube([e_x, e_y, chamfer * 4]);
            // Clip holes
            translate(-[(e_x - e_part_x) / 2, -e_y, 0])
            linear_extrude(height=e_clip_z * 4, center=true)
            offset(r=fit)
            mirror ([0, 1]) {
                clip_add = 0.2;
                for (xpos = [
                    e_clip_pos_x_outer[0],
                    e_clip_pos_x_outer[1] - e_clip_x
                ])
                translate([xpos, 0])
                square([e_clip_x, e_clip_y + clip_add]);
            }
        }
    }
}

module extruder_cable_support_shape(extend=0, double=0) {
    ch = chamfer + extend;
    offset(r=e_part_z_top*0.45*2)
    offset(r=-e_part_z_top*0.45*2)
    render(convexity=4)
    for (my = (double ? [0, 1] : [1]))
    mirror([0, my])
    union() {
        translate([0, -e_part_z_top])
        square([e_part_x, e_part_z_top * 2]);
        for (mx = [0, 1], my = [1])
        mirror([0, my])
        translate([0, -(ch + e_part_z_top)])
        translate(mx ? [e_part_x, 0] : [0, 0])
        mirror([mx, 0])
        polygon([[0, 0], [edge, 0], [edge + ch, ch], [0, ch]]);
    }
}

module extruder_cable_support_front() {
    offy = e_part_y_pos * 4;
    render(convexity=4)
    extruder_support_block_cut()
    rotate([90, 0, 0])
    mirror([0, 0, 1])
    translate([0, 0, e_part_y_pos])
    union() {
        translate([0, 0, e_y - e_part_y_pos])
        linear_extrude(height=e_part_y - e_y + e_part_y_pos)
        difference() {
            extruder_cable_support_shape(double=true);
            translate([0, e_part_z_top])
            square([e_part_x * 4, chamfer]);
        }
        difference() {
            linear_extrude(height=e_y - e_part_y_pos)
            extruder_cable_support_shape(double=true);
            translate([0, e_part_z_top, e_y - e_part_y_pos])
            rotate([-45, 0, 0])
            cube([e_part_x, chamfer * 2, chamfer * 2]);
        }
    }
}

module extruder_cable_support_bend() {
    translate([0, e_part_y + e_part_y_pos, 0])
    extruder_cable_support_holes(bend_ratio=0.25)
    translate([e_part_x, 0, e_part_z_top + chamfer])
    difference() {
        rotate([0, -90, 180])
        translate([bend_radius, 0, 0])
        rotate_extrude(angle=bend_angle)
        translate([-(chamfer + e_part_z_top) - bend_radius, 0])
        rotate(-90)
        extruder_cable_support_shape(double=true);
        translate([-e_part_x, 0, -chamfer])
        rotate([45, 0, 0])
        cube([e_part_x, chamfer * 2, chamfer * 2]);
    }
}

module extruder_cable_support_feet() {
    radius = 5;
    translate([0, e_y, 0])
    render(convexity=4)
    intersection() {
        rotate([0, 90, 0])
        linear_extrude(height=e_part_x)
        polygon([[0, 0], [0, radius * 4], [radius * 4, 0]]);
        union() {
            translate([0, 0, -radius])
            rotate([-45, 0, 0])
            linear_extrude(height=radius * 6, center=true)
            mirror([0, 1])
            extruder_cable_support_shape(extend=chamfer);

            rotate([0, 90, 0])
            linear_extrude(height=e_part_x)
            polygon([[0, 0], [0, radius], [radius, 0]]);
        }
    }
}

module extruder_cable_support_holes(yoff=0, bend_ratio=0) {
    difference() {
        children();

        translate([0, yoff, bend_radius])
        rotate([(bend_angle - 2.5) * bend_ratio, 0, 0])
        translate([0, 0, -bend_radius])

        render(convexity=4)
        linear_extrude(height=e_clip_pos_z * 2, center=true)
        offset(r=0.5)
        translate([e_part_x / 2, 0, 0])
        for (mx = [0:1:1])
        mirror([mx, 0])
        translate([e_x / 2 - e_clip_pos_x_inner[0], 0])
        square([e_clip_pos_x_inner[0] - e_clip_pos_x_outer[0], e_clip_y]);
    }
}

module extruder_cable_support() {
    color("#eef", 0.9) {
        extruder_cable_support_front();
        extruder_cable_support_bend();
        extruder_cable_support_feet();
    }
}

module main() {
    if (Render_Mode == "print") {
        translate([0, 0, e_part_x])
        rotate([0, 90, 0])
        extruder_cable_support();
    } else if (Render_Mode == "normal") {
        extruder_cable_support();
    } else if (Render_Mode == "model_preview") {
        translate([(e_x - e_part_x) / 2, -e_y, e_clip_pos_z])
        extruder_cable_support();
        if ($preview) {
            original_carriage_slider();
        }
    }
}

main();
