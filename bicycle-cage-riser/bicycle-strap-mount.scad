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
Velcro = false;

/* [Size] */
Width = 6; // [5:0.1:20]
Extension = 30; // [0:1:100]
Screw_Play = 1; // [0:1:8]
Thickness = 13; // [5:1:20]
Round_Radius = 0.2; // [0:0.1:2]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

// Constants //

zip_len = 4;
velcro_len = 22;
screw_spacing = 64;
riser_d = Width;
top_width = riser_d * 2.5;
tube_d = 35;
thick = Thickness;
slot_offset = 3;
slot_depth = 2;
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
    edge_r = slot_depth * 0.25;
    translate([0, 0, thick - slot_depth - slot_offset / 2])
    rotate([90, 0, 0])
    linear_extrude(height=riser_d * 10 + slop * 2, center=true)
    offset(r=edge_r)
    offset(r=-edge_r)
    square([length, slot_depth]);
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
            if (!Velcro) {
                zip_slot();
            }
        }
    }
}


module tube_curve() {
    td = tube_d + rr * 2;
    tw = top_width;
    tt = ((td / 2) - max(0, sqrt((td / 2) ^ 2 - (tw / 2) ^ 2)));
    tx = min(tt, slot_offset / 2);
    difference() {
        children();
        translate([0, 0, tx])
        rotate([0, 90, 0])
        linear_extrude(height=screw_spacing * 4, center=true)
        translate([tube_d / 2, 0])
        circle(d=td);
    }
}

module tube_zip_slot() {
    tie_d = tube_d + slot_depth * 2 + slot_offset * 2;
    rotate([0, 90, 0])
    linear_extrude(height=zip_len, center=true)
    translate([tube_d / 2, 0])
    difference() {
        circle(d=tie_d + rr * 2);
        circle(d=tie_d + rr * 2 - slot_depth * 2);
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

module body_base_shape(width=riser_d) {
    rad = 12.5;
    hull() {
        at_ends()
        screw_play()
        scale([rad/width, 1])
        circle(d=width - rr * 2);
    }
}

module body_base() {
    linear_extrude(height=thick - rr * 2)
    body_base_shape();

    for (cz = [0, 1])
    translate([0, 0, cz ? (thick - rr * 2) : 0])
    mirror([0, 0, cz])
    hull() {
        translate([0, 0, slot_offset - slop])
        linear_extrude(height=slop)
        body_base_shape();
        linear_extrude(height=slop)
        body_base_shape(top_width);
    }
}

module body() {
    translate([0, 0, rr])
    tube_curve()
    body_base();
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
