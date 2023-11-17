/*
 * Sovol SV06 (Plus) 90-degree dual spool holder
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Options] */
Gantry_Fitting_Size = 30.25; // [24:0.005:40]

module __end_customizer_options__() { }

/* [Hidden] */

Image_Render = 0;

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

outer_x = 45;

gantry_fitting_y = Gantry_Fitting_Size;
gantry_fitting_z = 10;

foot_z = 23.5;
foot_y = 8.9;

hole_d = 5.5;
hole_x = 30 / 2;
hole_pos_y = 16.7;

stem_rot = 9.5;
stem_z = 130;
stem_y = 19;
stem_nut_z = 1.5;
stem_round_radius = 16;

nut_d = 38;
nut_inner_d = 31;

original_nut_z = 9.2;

round_radius = 1;
slop = 0.01;

// Modules //

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
    rr = round_radius / 2;
    module hole_rounding_overhang() {
        mirror([0, 1])
        square([hole_d + rr * 2, rr * 2]);
        translate([0, gantry_fitting_z])
        square([hole_d + rr * 2, rr * 2]);
    }

    rotate_extrude(angle=360)
    difference() {
        offset(r=-rr)
        offset(delta=rr)
        union() {
            translate([0, -slop])
            square([hole_d / 2, gantry_fitting_z + slop * 2]);
            translate([0, 5])
            offset(r=rr)
            offset(r=-rr)
            square([hole_d, gantry_fitting_z - 5 + slop]);
            hole_rounding_overhang();
        }
        hole_rounding_overhang();
    }
}

module screw_holes_cut() {
    difference() {
        children();

        for (x = [-hole_x, hole_x])
        translate([x, -hole_pos_y, 0])
        screw_hole();
    }
}

module new_gantry_fitting() {
    translate([0, -gantry_fitting_y, -foot_z])
    color("lemonchiffon", 0.6)
    rotate([90, 0, 90])
    translate([0, 0, round_radius])
    linear_extrude(height=outer_x - round_radius * 2)
    offset(delta=-round_radius)
    square([foot_y + gantry_fitting_y, foot_z + gantry_fitting_z]);
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
            offset(r=round_radius)
            offset(r=-round_radius * 2)
            offset(r=round_radius)
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

module new_nut() {
    translate([outer_x / 2, 0, 0])
    mirror([1, 0, 0])
    rotate([stem_rot, 0, 0])
    rotate([0, 90, 0])
    extended_nut();
}

module new_stem_part() {
    mirror([0, 1, 0])
    rotate([90, 0, 90])
    translate([0, 0, round_radius])
    linear_extrude(height=outer_x - round_radius * 2) {
        offset(delta=-round_radius)
        difference() {
            offset(r=-stem_round_radius)
            offset(delta=stem_round_radius)
            union() {
                square([stem_y, stem_z]);
                translate([(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
                circle(d=nut_d - 3);
            }
            translate([(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
            circle(d=nut_inner_d);
        }
    }
}

module place_stem() {
    translate([0, foot_y, -foot_z])
    rotate([-stem_rot, 0, 0])
    children();
}

module new_stem() {
    place_stem()
    new_stem_part();
}

module new_stem_nut() {
    place_stem()
    translate([0, -(nut_d - stem_y) / 2, stem_z + nut_d / 2 - stem_nut_z])
    new_nut();
}

module gantry_cut() {
    difference() {
        children();

        translate([0, round_radius, round_radius])
        translate([0, -gantry_fitting_y - foot_y - slop, -foot_z])
        translate([-slop, foot_y, -slop])
        cube([outer_x + slop * 2, gantry_fitting_y + slop, foot_z + slop]);
    }
}

module new_part() {
    color("#caf", 0.8)
    maybe_render()
    screw_holes_cut()
    translate([-outer_x / 2, 0, 0]) {
        minkowski() {
            render(convexity=2)
            gantry_cut() {
                union() {
                    new_gantry_fitting();
                    new_stem();
                }
            }
            sphere(r=round_radius);
        }
        new_stem_nut();
    }
}

module orient_part() {
    if (Print_Orientation) {
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

module main() {
    orient_part()
    new_part();
}

main();
