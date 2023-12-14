/*
 * Ferris wheel base
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

Part = "all"; // [1: Axle 1, 2: Axle 2, "all": Both axles]

Insert = true;

Overlap = 10; // [3:0.5:10]

Flange_Length = 7.5; // [2:0.5:10]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 4 : 0.4;

slop = 0.001;
fit = 0.1;

flange_d = 10 - fit;
flange_h = Flange_Length;
barrel_1_d = 7;
barrel_2_d = 5;
screw_d = 3.0;
screw_fit_d = 3.5;
screw_head_d = 5.5;

ferris_wheel_width = 33 + 0.5;
barrel_overlap = Overlap;
barrel_len = ferris_wheel_width / 2 + barrel_overlap / 2;

insert_len = max(4, barrel_overlap);
insert_taper_len = 4;
insert_d = 4;
insert_barrel_d = 6;

// Modules //

module overlap_cut() {
    difference() {
        children();
        translate([0, 0, barrel_len - barrel_overlap])
        cylinder(d=(Insert ? insert_barrel_d : barrel_2_d) + fit, h=barrel_overlap + slop);
    }
}

module screw_cut() {
    difference() {
        reduce = screw_head_d - screw_fit_d;
        hh = (barrel_len - barrel_overlap - flange_h - reduce - slop);
        children();
        translate([0, 0, -hh * 6])
        cylinder(d=screw_head_d, h=hh * 8);
        translate([0, 0, barrel_len - barrel_overlap - reduce - flange_h - slop])
        cylinder(d1=screw_head_d, d2=screw_fit_d, h=(reduce + slop * 2));
    }
}

module insert_cut() {
    difference() {
        children();
        if (Insert) {
            translate([0, 0, barrel_len - insert_len])
            cylinder(d=insert_d + fit, h=insert_len + slop);
        }
    }
}

module rcyl(d, h) {
    rotate_extrude(angle=360)
    union() {
        offset(r=0.5)
        offset(r=-0.5)
        square([d / 2, h]);
        square([d / 2 / 2, h]);
    }
}

module axle_bits() {
    d1 = barrel_2_d / 2;
    dd = d1 + 1;
    n = 6;
    ww = 1;
    for (ang = [0:360/n:360-slop])
    rotate(ang)
    linear_extrude(height=4, scale=((d1 - slop) / dd))
    translate([0, -ww / 2])
    square([dd, ww]);
}

module axle_base(num=1) {
    difference() {
        union() {
            cylinder(d=num == 1 ? barrel_1_d : barrel_2_d, h=barrel_len);
            // Flange
            mirror([0, 0, 1])
            rcyl(d=flange_d, h=flange_h);
            if (Insert && num == 2) {
                translate([0, 0, barrel_len - insert_len - insert_taper_len])
                cylinder(d1=barrel_2_d, d2=insert_barrel_d, h=insert_taper_len);
                translate([0, 0, barrel_len - insert_len])
                cylinder(d=insert_barrel_d, h=insert_len);
            }
            if (num == 2) {
                axle_bits();
            }
        }
        cylinder(h=barrel_len * 4, d=(num == 1 ? screw_fit_d : (Insert ? screw_fit_d : screw_d)), center=true);
    }
}

module axle(num=1) {
    if (num == 1) {
        color("lightblue", 0.6)
        screw_cut()
        overlap_cut()
        axle_base(num=num);
    } else {
        color("plum", 0.6)
        insert_cut()
        axle_base(num=num);
    }
}

module main() {
    if (Part == "all") {
        translate([-10, 0, 0])
        axle(1);
        translate([10, 0, 0])
        axle(2);
    } else if (Part == 1) {
        axle(1);
    } else if (Part == 2) {
        axle(2);
    }
}

main();
