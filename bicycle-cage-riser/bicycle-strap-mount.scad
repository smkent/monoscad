/*
 * Bicycle bottle cage mount riser
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
// Render in print orientation (upside down)
Print_Orientation = true;

/* [Model Options] */
Zip_Ties = true;
Velcro = true;

/* [Size] */
Extension = 30; // [0:1:100]
Screw_Play = 1; // [0:1:8]
Thickness = 7; // [5:1:20]
Round_Radius = 1; // [0:0.1:2]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Constants //

zip_len = 4;
velcro_len = 22;
screw_spacing = 64;
riser_d = 12.5;
tube_d = 35;
thick = Thickness;
slot_depth = 2.4;
zip_count = floor(Extension / (zip_len * 3));
rr = Round_Radius;
slop = 0.001;

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

module at_screws() {
    translate([-screw_spacing / 2, 0, 0])
    for (ox = [0, screw_spacing])
    translate([ox, 0, 0])
    children();
}

module at_ends() {
    at_screws()
    children();
    if (Extension) {
        translate([screw_spacing / 2 + Extension, 0])
        children();
    }
}

module screw_play() {
    hull()
    for (tx = [-0.5, 0.5])
    translate([tx * Screw_Play, 0, 0])
    children();
}

module round_3d(radius = rr) {
    if (radius == 0) {
        children();
    } else {
        render()
        minkowski() {
            children();
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=radius, r2=0, h=radius);
        }
    }
}

module slot(length) {
    translate([0, 0, thick - slot_depth])
    hull() {
        linear_extrude(height=slop)
        square([length, riser_d + slop * 2], center=true);
        translate([0, 0, slot_depth])
        linear_extrude(height=slop)
        square([length + slot_depth / 2, riser_d + slop * 2], center=true);
    }
}

module tie_slot() {
    slot(velcro_len);
}

module zip_slot() {
    slot(zip_len);
}

module zip_slots() {
    start_x = riser_d + zip_len * 2;
    space = Extension - start_x;
    translate([start_x * 0.75, 0, 0])
    for (i = [0:space / (zip_count - 1):space]) {
        translate([i, 0, 0])
        zip_slot();
    }
}

module slots() {
    difference() {
        children();
        if (Velcro)
        tie_slot();
        if (Zip_Ties) {
            if (Extension > zip_len * (zip_count + 1))
            translate([screw_spacing / 2, 0, 0])
            zip_slots();
            for (tx = [-0.5, 0.5])
            translate([tx * (zip_len * 4 + velcro_len), 0, 0])
            zip_slot();
        }
    }
}


module tube_curve() {
    td = tube_d + rr * 2;
    tt = ((td / 2) - sqrt((td / 2) ^ 2 - (riser_d / 2) ^ 2));
    difference() {
        children();
        translate([0, 0, tt])
        rotate([0, 90, 0])
        linear_extrude(height=screw_spacing * 4, center=true)
        translate([tube_d / 2, 0])
        circle(d=td);
    }
}

module tube_zip_slot() {
    tie_d = tube_d + slot_depth * 3;
    rotate([0, 90, 0])
    linear_extrude(height=zip_len, center=true)
    translate([tube_d / 2, 0])
    difference() {
        circle(d=tie_d + rr * 2);
        circle(d=tie_d + rr * 2 - slot_depth);
    }
}

module tube_zip_slots() {
    difference() {
        children();
        tube_zip_slot();
        at_ends()
        tube_zip_slot();
    }
}

module body() {
    translate([0, 0, rr])
    tube_curve()
    linear_extrude(height=thick - rr * 2)
    hull() {
        at_ends()
        screw_play()
        circle(d=riser_d - rr * 2);
    }
}

module riser() {
    render() {
        slots()
        tube_zip_slots()
        round_3d()
        body();
    }
}

module orient_model() {
    if (Print_Orientation) {
        translate([0, 0, thick])
        rotate([180, 0, 0])
        children();
    } else {
        children();
    }
}

module main() {
    orient_model()
    color("lemonchiffon", 0.8)
    riser();
}

main();
