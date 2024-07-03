/*
 * Bicycle bottle cage mount riser
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Model Options] */
Zip_Ties = true;
Velcro = true;
Screw_Head_Inset = true;

/* [Size] */
Extension = 30; // [0:1:100]
Screw_Fit = 0.8; // [0:0.1:2]
Screw_Play = 1; // [0:1:8]
Thickness = 7; // [5:1:20]
Riser_Height = 4; // [0:1:10]
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
screw_d = 5;
screw_head_d = 9.5;
screw_head_height = 2;
riser_d = screw_d * 2.5;
riser_top_d = screw_d * 2;
rise = Riser_Height;
thick = Thickness;
slot_depth = 2;
zip_count = floor(Extension / (zip_len * 3));
layer_height = 0.2;
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

module screw_hole(diameter=screw_d + Screw_Fit, height=rise + thick, flip_y=false) {
    shr = rr / 2;
    translate([0, 0, -slop])
    linear_extrude(height=height + slop * 2)
    screw_play()
    circle(d=diameter);

    for (oy = [0, height])
    translate([0, 0, (oy > 0 ? height : 0) - slop])
    mirror([0, 0, (oy && !flip_y) ? 1 : 0])
    screw_play()
    cylinder(
        d1=diameter+ shr,
        d2=diameter,
        h=shr
    );
}

module screw_holes() {
    render()
    difference() {
        children();
        at_screws() {
            if (Screw_Head_Inset) {
                translate([0, 0, screw_head_height + rr / 2])
                screw_hole(height=(rise + thick) - screw_head_height - rr / 2);
                union() {
                    screw_hole(diameter=screw_head_d, height=screw_head_height, flip_y=true);
                    translate([0, 0, layer_height + rr / 2])
                    screw_play()
                    intersection() {
                        cylinder(d=screw_head_d, h=screw_head_height);
                        linear_extrude(height=screw_head_height)
                        square([screw_head_d, screw_d + Screw_Fit + rr / 2], center=true);
                    }
                }
            } else {
                screw_hole();
            }
        }
    }
}

module screw_risers() {
    radius = rr / 4;
    at_screws()
    translate([0, 0, thick])
    linear_extrude(height=rise - radius)
    screw_play()
    circle(d=riser_top_d - radius * 2);
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

module body() {
    translate([0, 0, rr])
    linear_extrude(height=thick - rr * 2)
    hull() {
        at_ends()
        screw_play()
        circle(d=riser_d - rr * 2);
    }
}

module riser() {
    screw_holes()
    render() {
        slots()
        round_3d()
        body();
        round_3d(radius = rr / 4)
        screw_risers();
    }
}

module main() {
    color("lightsteelblue", 0.8)
    riser();
}

main();
