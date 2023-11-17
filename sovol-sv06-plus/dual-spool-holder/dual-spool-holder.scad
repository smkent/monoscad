/*
 * Sovol SV06 (Plus) 90-degree dual spool holder
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Render_Mode = "print"; // [print: Print Orientation, normal: Upright installed orientation, model_preview: Preview of model installed on gantry]

/* [Options] */
Base_Type = "gantry"; // [gantry: Gantry support, flat: Flat]

/* [Advanced Options] */
Width = 45; // [45:0.1:65]
Tilt_Angle = 9.5; // [0:0.5:45]

module __end_customizer_options__() { }

/* [Hidden] */

Image_Render = 0;

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

outer_x = Width;

gantry_fitting_y = 25.7;
gantry_fitting_z = 10;

foot_z = 32.8;
foot_y = 8.9;

hole_d = 5.5;
hole_x = 30 / 2;
hole_pos_y = 16.7 - 0.5;
hole_inner_z = 5.5;

stem_rot = Tilt_Angle;
stem_z = 106.5 + foot_z;
stem_y = 19;
stem_nut_z = 1.5;
stem_round_radius = 16;

nut_d = 38;
nut_inner_d = 31;

original_nut_z = 9.2;

round_radius = 1;
slop = 0.01;

// Modules //

module round_shape(r) {
    offset(r=r)
    offset(r=-r * 2)
    offset(r=r)
    children();
}

module original_sv06_barrel_nut() {
    translate([0, -0.11, 10.40] - [36, 39.6, 0] / 2)
    rotate([-90, 0, 0])
    import("sovol-sv06-JXHSV06-07003-d Barrel nut.STL", convexity=4);
}

module updated_original_sv06_barrel_nut() {
    original_sv06_barrel_nut();
    // Fill in surface indents
    translate([0, 0, original_nut_z - 2])
    for(rot = [129, 309])
    rotate(rot)
    rotate_extrude(angle=10)
    translate([nut_inner_d / 2, 0])
    square([(nut_d - 3 - nut_inner_d) / 2, 2]);
}

module screw_hole() {
    rotate_extrude(angle=360)
    translate([0, hole_inner_z]) {
        mirror([0, 1])
        square([hole_d * 0.5 + round_radius, gantry_fitting_z * 5]);
        square([hole_d * 0.9 + round_radius, gantry_fitting_z * 5]);
    }
}

module screw_holes_cut() {
    difference() {
        children();

        translate([outer_x / 2, 0, 0])
        for (x = [-hole_x, hole_x])
        translate([x, -hole_pos_y, 0])
        screw_hole();
    }
}

module extended_nut() {
    cut_z = 1;
    middle_z = outer_x - (original_nut_z - cut_z) * 2 + slop * 2;

    for (flipz = [0:1:1])
    rotate([flipz ? 0 : 180, 0, 0])
    translate([0, 0, outer_x / 2 - original_nut_z])
    updated_original_sv06_barrel_nut();

    linear_extrude(height=outer_x - (original_nut_z - cut_z - slop) * 2, center=true)
    union() {
        projection(cut=true)
        translate([0, 0, -cut_z])
        updated_original_sv06_barrel_nut();
    }

    rotate_extrude(angle=360) {
        ribx = 2;
        midz = middle_z + 4;
        translate([(nut_d - 2.125) / 2, -midz / 2])
        difference() {
            round_shape(round_radius)
            polygon(points=[
                [-ribx, -ribx * 3],
                [0, -ribx * 3],
                [0, -ribx * 1.5],
                [ribx, 0],
                [ribx, midz],
                [0, midz + ribx * 1.5],
                [0, midz + ribx * 3],
                [-ribx, midz + ribx * 3],
                [-ribx, midz + ribx * 1.5],
            ]);
            translate([-ribx, 0])
            square([ribx * 2, (midz + ribx * 2) * 2], center=true);
        }
    }
}

module nut() {
    translate([outer_x / 2, 0, 0])
    mirror([1, 0, 0])
    rotate([stem_rot, 0, 0])
    rotate([0, 90, 0])
    extended_nut();
}

module stem_part() {
    mirror([0, 1, 0])
    rotate([90, 0, 90])
    translate([0, 0, round_radius])
    linear_extrude(height=outer_x - round_radius * 2) {
        offset(delta=-round_radius)
        difference() {
            offset(r=-stem_round_radius)
            offset(delta=stem_round_radius)
            union() {
                translate([0, stem_z / 3])
                square([stem_y, stem_z * (2 / 3)]);
                translate([(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
                circle(d=nut_d - 3);
            }
            translate([(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
            circle(d=nut_inner_d);
        }
    }
}

module place_stem(dimensions=3) {
    translate(dimensions == 3 ? [0, foot_y, -foot_z] : [foot_y, -foot_z])
    rotate(dimensions == 3 ? [-stem_rot, 0, 0] : -stem_rot)
    children();
}

module stem() {
    place_stem()
    stem_part();
}

module stem_nut() {
    place_stem()
    translate([0, -(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
    nut();
}

module base_shape(exaggerate_multiple=1) {
    translate([gantry_fitting_y, foot_z])
    place_stem(dimensions=2)
    translate([-stem_y, 0])
    offset(delta=-round_radius)
    square([stem_y * exaggerate_multiple, stem_z / 2 * exaggerate_multiple]);

    offset(delta=-round_radius)
    translate([-(foot_y + gantry_fitting_y) * (exaggerate_multiple - 1), -(foot_z + gantry_fitting_z) * (exaggerate_multiple - 1)])
    square([(foot_y + gantry_fitting_y) * exaggerate_multiple, (foot_z + gantry_fitting_z) * exaggerate_multiple]);
}

module gantry_fitting() {
    translate([0, -gantry_fitting_y, -foot_z])
    color("lemonchiffon", 0.6)
    rotate([90, 0, 90])
    translate([0, 0, round_radius])
    linear_extrude(height=outer_x - round_radius * 2)
    round_shape(stem_y / 3)
    union() {
        color("yellow")
        render()
        intersection() {
            round_shape(stem_y * 1.5)
            union() {
                base_shape(exaggerate_multiple=5);

                xx = foot_y + (foot_z * tan(stem_rot));
                zz = stem_z / 2;
                color("lightgreen", 0.6)
                translate([gantry_fitting_y / 2, gantry_fitting_z + foot_z - round_radius])
                polygon(points=[
                    [0, 0],
                    [(xx + zz * tan(stem_rot)) * 0.5, zz * 0.25],
                    [xx + zz * tan(stem_rot), zz],
                    [xx, 0]
                ]);
            }
            color("yellow", 0.6)
            hull() {
                base_shape();
                translate([0, stem_z / 2])
                base_shape();
            }
        }
        base_shape();
    }
}

module gantry_cut() {
    difference() {
        children();

        translate(Base_Type == "flat" ? [0, gantry_fitting_y, 0] : [0, 0, 0])
        translate([-slop, round_radius - slop, -foot_z + round_radius - slop])
        mirror([0, 1, 0])
        cube([outer_x + slop * 2, gantry_fitting_y * 2 + slop, foot_z + slop]);
    }
}

module dual_spool_holder() {
    color("#94c5db", 0.8)
    maybe_render()
    translate([-outer_x / 2, 0, 0])
    union() {
        minkowski() {
            render(convexity=2)
            screw_holes_cut()
            gantry_cut() {
                union() {
                    gantry_fitting();
                    stem();
                }
            }
            sphere(r=round_radius);
        }
        stem_nut();
    }
}

module orient_model() {
    if (Render_Mode == "print") {
        translate([-stem_z / 2, 0, outer_x / 2])
        rotate([0, 90, 0])
        children();
    } else {
        children();
    }
}

module maybe_render() {
    if (Image_Render) {
        render(convexity=4)
        children();
    } else {
        children();
    }
}

module preview_filament_spool() {
    w = 80;
    translate([98.2 / 2 + outer_x / 2, 0, 0])
    color("#778", 0.2)
    render(convexity=10)
    rotate([90, 0, 90])
    translate([0, 0, -w / 2])
    difference() {
        union() {
            for (z = [0, w - 5])
            translate([0, 0, z])
            cylinder(h=5, d=200);
            cylinder(h=w, d=100);
        }
        cylinder(h=w * 2, d=50, center=true);
    }
}

module preview_filament_barrel() {
    translate([outer_x / 2, 0, 0] - [11.8, 0, 0])
    color("mintcream", 0.6)
    mirror([1, 0, 0])
    rotate(90)
    translate([-0.11, 0.005, 0] - [36, 0, 36] / 2)
    import("sovol-sv06-JXHSV06-07002-d Filament Barrel.STL", convexity=4);
}

module preview_spool_parts() {
    for (ch = [0:1:$children-1])
    for (mx = [0:1:1])
    mirror([mx, 0, 0])
    place_stem()
    translate([0, -(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
    children(ch);
}

module preview_gantry() {
    color("#aab", 0.9)
    translate([-380 / 2, 1.5453 / 2, -37.4])
    rotate([90, 0, 0])
    import("sovol-sv06-JXHSV06-02005-d Gantry beam.STL");
}

module main() {
    if ($preview && Render_Mode == "model_preview") {
        dual_spool_holder();
        preview_gantry();
        preview_spool_parts() {
            preview_filament_barrel();
            preview_filament_spool();
        }
    } else {
        orient_model()
        dual_spool_holder();
    }
}

main();
