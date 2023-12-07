/*
 * IP6518 DC to 5V USB-A/C Buck Converter Case
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <honeycomb-openscad/honeycomb.scad>;

/* [Rendering Options] */
Print_Orientation = true;

Render_Top = true;
Render_Bottom = true;

/* [Size] */
// All units in millimeters

Thickness = 1.6; // [0:0.1:10]
Top_Bottom_Thickness = 1.6; // [0:0.1:10]

/* [Options] */

Enable_Honeycomb = true;
Chamfer_Case_Screw_Holes = true;
Mount_Holes = 1; // [0: None, 1: Side, 2: Sovol SV06/Plus PSU]

/* [Advanced Options] */

Size_Tolerance = 1; // [0:0.1:2]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

Width = 22.5;
Length = 55;
Height = 16;
Radius = 2; // [0:0.1:10]

board_thick = 1.65;
bottom_shell_height = 4;
screw_hole_diameter = 3.2;
screw_hole_sep_x = 16.5;
screw_hole_sep_y = 34.5;
screw_hole_offset_y = 7.5;
nut_height = 2.5;
usb_a_width = 14;
usb_c_width = 9;
dc_barrel_width = 10.1;
case_mount_screw_diameter = 3.9;
case_screw_diameter = 3.2;
case_screw_post_diameter = case_mount_screw_diameter * 2;
case_screw_post_height = 10;
body_width = Width + Size_Tolerance + Thickness * 2;
outer_width = body_width + (Mount_Holes == 1 ? case_screw_post_diameter * 2 : 0);
outer_length = Length + Size_Tolerance;
outer_height = Height + Size_Tolerance + Top_Bottom_Thickness;
top_height = outer_height - bottom_shell_height;
bottom_height = bottom_shell_height;
mount_holes_sv06_psu_diameter = 4.2;
mount_holes_sv06_psu_separation = 25;

// Modules //

module hc_grid(x, y, hex_size, separation) {
    translate([-x/2, -y/2])
    honeycomb(x, y, hex_size, separation, whole_only=true);
}

module rounded_square(x, y, r, center=false) {
    translate(center ? [0, 0] : [r, r])
    offset(r=r)
    square([x-r*2, y-r*2], center=center);

}

module case_screw_sink() {
    outer_r = case_screw_diameter * 1.1;
    r = case_screw_diameter / 2;
    ht = outer_height - case_screw_post_height;
    translate([0, 0, ht])
    rotate([0, 180, 0]) {
        if (Chamfer_Case_Screw_Holes) {
            linear_extrude(height=ht - r)
            circle(r=outer_r);
            translate([0, 0, ht - r])
            cylinder(r, outer_r, r);
        } else {
            linear_extrude(height=ht)
            circle(r=outer_r);
        }
    }
}

module case_shape_mount_holes_sv06_psu_add(r, copyx) {
    translate([(body_width + r * 2) / 2, outer_length + case_screw_post_diameter / 2 + r])
    mirror([copyx, 0]) {
        hull() {
            for (cx = [0:1:1]) {
                for (cy = [0:1:1]) {
                    translate([
                        (mount_holes_sv06_psu_separation + cx * (-usb_c_width + r * 2)) / 2,
                        cy * (-(usb_c_width - r) / 2)
                    ])
                    circle(mount_holes_sv06_psu_diameter + r);
                }
            }
        }
    }
}

module case_shape_mount_holes_sv06_psu_subtract(r, copyx) {
    translate([(body_width + r * 2) / 2, outer_length + case_screw_post_diameter / 2 + r])
    mirror([copyx, 0])
    translate([mount_holes_sv06_psu_separation / 2, 0])
    circle(mount_holes_sv06_psu_diameter / 2);
}

module case_shape(mount_holes=0, widen_case_screw_holes=false) {
    r = Radius;
    bw = body_width + r*2;
    bl = outer_length + r*2;
    translate([-r, -r])
    difference() {
        union() {
            offset(r=-r) {
                rounded_square(body_width+r*2, outer_length+r*2, r * 2);
                for (copyy = [0:1:1]) {
                    if (mount_holes == 1) {
                        translate([
                            -case_screw_post_diameter / 4,
                            copyy * (outer_length - case_screw_post_diameter)
                        ])
                        square([
                            body_width + r*2 + case_screw_post_diameter / 2,
                            (case_screw_post_diameter + r * 2) * 1
                        ]);
                    }
                    for (copyx = [0:1:1]) {
                        if (mount_holes == 1) {
                            translate([
                                copyx * (body_width + r*2 + case_screw_post_diameter / 2) - case_screw_post_diameter / 4,
                                copyy * (outer_length - case_screw_post_diameter) +
                                case_screw_post_diameter / 2 + r
                            ])
                            circle(case_screw_post_diameter / 2 + r);
                        } else if (mount_holes == 2) {
                            case_shape_mount_holes_sv06_psu_add(r, copyx);
                        }
                    }
                }
            }
        }

        for (copyy = [0:1:1]) {
            for (copyx = [0:1:1]) {
                if (mount_holes == 1) {
                    translate([
                        copyx * (body_width + r*2 + case_screw_post_diameter / 2) - case_screw_post_diameter / 4,
                        copyy * (outer_length - case_screw_post_diameter) +
                        case_screw_post_diameter / 2 + r
                    ])
                    circle(case_mount_screw_diameter / 2);
                } else if (mount_holes == 2) {
                    case_shape_mount_holes_sv06_psu_subtract(r, copyx);
                }
            }
        }
    }
}

module case_body(h, base=false, sink_screws=false, mount_holes=0, widen_case_screw_holes=false) {
    r = Radius;
    hcw = outer_length - case_screw_post_diameter * 4;
    hch = h;
    thick = Thickness;
    difference() {
        union() {
            linear_extrude(height=Top_Bottom_Thickness)
            case_shape(mount_holes=mount_holes, widen_case_screw_holes=widen_case_screw_holes);
            translate([0, 0, Top_Bottom_Thickness])
            linear_extrude(height=h - Top_Bottom_Thickness)
            case_shape(mount_holes=0, widen_case_screw_holes=widen_case_screw_holes);
        }
        translate([-r, -r]) {
            if (sink_screws) {
                translate([0, 0, case_screw_post_height - bottom_shell_height]) {
                    for (copyy = [0:1:1]) {
                        for (copyx = [0:1:1]) {
                            translate([
                                copyx * (body_width + r*2 + case_screw_post_diameter / 2) - case_screw_post_diameter / 4,
                                copyy * (outer_length - case_screw_post_diameter * 3) +
                                case_screw_post_diameter * 1.5 + r
                            ])
                            case_screw_sink();
                        }
                    }
                }
            }
            if (base && Chamfer_Case_Screw_Holes) {
                for (copyy = [0:1:1]) {
                    for (copyx = [0:1:1]) {
                        translate([
                            copyx * (body_width + r*2 + case_screw_post_diameter / 2) - case_screw_post_diameter / 4,
                            copyy * (outer_length - case_screw_post_diameter) +
                            case_screw_post_diameter / 2 + r
                        ])
                        translate([0, 0, h - r])
                        cylinder(r, r, case_screw_diameter);
                    }
                }
            }
        }
        if (!base && Enable_Honeycomb) {
            translate([-thick / 2, (outer_length-hcw)/2, 0])
            for (copyx = [0:1:1]) {
                translate([copyx ? (body_width - thick) : 0, 0, 0])
                rotate([90, 0, 90])
                linear_extrude(height=thick*2)
                difference() {
                    square([hcw, hch]);
                    translate([hcw/2, hch/2])
                    hc_grid(hcw, hch, 5, 1.6);
                }
            }
        }
    }
}

module pin_cap() {
    r = screw_hole_diameter / 2;
    top_h = Height + Size_Tolerance - bottom_shell_height;
    tbthick = Top_Bottom_Thickness;
    translate([0, 0, -tbthick])
    linear_extrude(height=tbthick)
    circle(r * 3);

    cylinder(nut_height, r * 3, r * 2);

    translate([0, 0, nut_height])
    linear_extrude(height=top_h - nut_height)
    circle(r * 2);
}


module pin_post() {
    r = screw_hole_diameter / 2;
    tbthick = Top_Bottom_Thickness;

    translate([0, 0, nut_height - tbthick])
    cylinder(tbthick + bottom_shell_height - board_thick - nut_height, r * 3, r * 2);

    translate([0, 0, -tbthick])
    linear_extrude(height=nut_height)
    circle(r * 3);
}

module pin_holes(screw=false, nut=false) {
    r = Radius;
    w = Width + Size_Tolerance;
    thick = Thickness;
    tbthick = Top_Bottom_Thickness;

    translate([(w - screw_hole_sep_x) / 2 + thick, screw_hole_offset_y, 0])
    for(sh_x = [0:1:1]) {
        for(sh_y = [0:1:1]) {
            translate([screw_hole_sep_x * sh_x, screw_hole_sep_y * sh_y]) {
                linear_extrude(height=outer_height)
                circle(screw_hole_diameter / 2);
                if (nut || screw) {
                    translate([0, 0, screw ? top_height - nut_height : 0])
                    linear_extrude(height=nut_height)
                    circle(screw_hole_diameter, $fn=(nut ? 6 : $fn));
                    if (nut) {
                        translate([0, 0, nut_height * 1])
                        cylinder(nut_height, screw_hole_diameter, screw_hole_diameter / 3, $fn=6);
                    } else if (screw) {
                        translate([0, 0, top_height - nut_height * 2])
                        cylinder(nut_height, screw_hole_diameter / 2, screw_hole_diameter);
                    }
                }
            }
        }
    }
}

module usb_c() {
    r = 1;
    linear_extrude(height=10)
    rounded_square(usb_c_width, bottom_shell_height * 2, 1);
}

module dc_barrel() {
    linear_extrude(height=10)
    square([10.1, 9 - board_thick]);
}

module usb_a() {
    linear_extrude(height=10)
    square([14, 8.2 - board_thick]);
}

module case_top() {
    r = Radius;
    w = Width + Size_Tolerance;
    l = Length + Size_Tolerance;
    h = Height + Size_Tolerance;
    thick = Thickness;
    tbthick = Top_Bottom_Thickness;
    top_h = h - bottom_shell_height;

    translate([Mount_Holes == 1 ? case_screw_post_diameter : 0, 0, 0]) {
        difference() {
            union() {
                difference() {
                    case_body(top_h + tbthick, sink_screws=true, widen_case_screw_holes=true);

                    translate([thick, thick, 0])
                    linear_extrude(height=top_h)
                    rounded_square(w, l - thick * 2, r);

                    if (Enable_Honeycomb) {
                        translate([thick, thick, top_h])
                        linear_extrude(height=tbthick)
                        difference() {
                            rounded_square(w, l - thick * 2, r);
                            translate([w/2, (l-thick*2)/2])
                            hc_grid(w, l-thick*2, 7, 1.6);
                        }
                    }

                    translate([(w - dc_barrel_width) / 2 + thick, thick, 0])
                    rotate([90, 0, 0])
                    dc_barrel();

                    translate([(w - usb_a_width) / 2 + thick, l - thick + 10, 0])
                    rotate([90, 0, 0])
                    usb_a();
                }

                translate([(w - screw_hole_sep_x) / 2 + thick, screw_hole_offset_y, top_h])
                for(sh_x = [0:1:1]) {
                    for(sh_y = [0:1:1]) {
                        translate([screw_hole_sep_x * sh_x, screw_hole_sep_y * sh_y])
                        mirror([0, 0, 1])
                        pin_cap();
                    }
                }
            }
            pin_holes(screw=true);
        }
    }
}

module case_bottom() {
    r = Radius;
    w = Width + Size_Tolerance;
    l = Length + Size_Tolerance;
    h = Height + Size_Tolerance;
    thick = Thickness;
    tbthick = Top_Bottom_Thickness;
    under_ht = bottom_shell_height - board_thick;

    translate([Mount_Holes == 1 ? case_screw_post_diameter : 0, 0, 0]) {
        difference() {
            union() {
                difference() {
                    union() {
                        case_body(bottom_shell_height + tbthick, base=true, mount_holes=Mount_Holes);
                    }

                    translate([thick, 0, tbthick + bottom_shell_height - board_thick])
                    linear_extrude(height=board_thick)
                    rounded_square(w, l, r);

                    if (Enable_Honeycomb) {
                        translate([thick, thick, 0])
                        linear_extrude(height=tbthick)
                        difference() {
                            rounded_square(w, l - thick * 2, r);
                            translate([w/2, (l-thick*2)/2])
                            hc_grid(w, l-thick*2, 7, 1.6);
                        }
                    }

                    translate([thick, thick, tbthick])
                    linear_extrude(height=h)
                    rounded_square(w, l - thick * 2, r);

                    translate([(w - usb_c_width) / 2 + thick, l - thick + 10, tbthick])
                    rotate([90, 0, 0])
                    usb_c();
                }

                translate([(w - screw_hole_sep_x) / 2 + thick, screw_hole_offset_y, 0])
                for(sh_x = [0:1:1]) {
                    for(sh_y = [0:1:1]) {
                        translate([screw_hole_sep_x * sh_x, screw_hole_sep_y * sh_y, tbthick])
                        pin_post();
                    }
                }
            }
            pin_holes(nut=true);
        }
    }
}

module main() {
    color("violet", 0.6) {
        if (Render_Bottom) {
            case_bottom();
        }
        if (Render_Top) {
            if (Print_Orientation) {
                translate([Render_Bottom ? outer_width * 2 + Size_Tolerance * 4 : outer_width, 0, top_height])
                rotate([0, 180, 0])
                case_top();
            } else {
                translate([Render_Bottom ? outer_width + Size_Tolerance * 4 : 0, 0, 0])
                case_top();
            }
        }
    }
}

main();
