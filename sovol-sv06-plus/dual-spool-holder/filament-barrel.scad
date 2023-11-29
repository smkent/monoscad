/*
 * Sovol SV06 (Plus) 90-degree dual spool holder
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */

module __end_customizer_options__() { }

/* [Hidden] */

Image_Render = 0;

// Constants //

$fa = $preview ? $fa / 4 : 2 / 4;
$fs = $preview ? $fs / 2 : 0.4;

barrel_d = 30;
lower_lip_z = [11.8, 16];
lower_lip_thick = lower_lip_z[1] - lower_lip_z[0];
upper_lip_z = [106, 110];
upper_lip_thick = upper_lip_z[1] - upper_lip_z[0];
upper_lip_d = [26, 28, 35, 36]; // inside, top of inner fillet, top of outer fillet, outside
channel_d = [25, 30]; // inner, outer
channel_z = [3, 7]; // approximate, the channel rises slightly as it curves around the filament barrel
channel_thick = channel_z[1] - channel_z[0];
slop = 0.01;
bigslop = 0.1;

chamfer_ht = 1.45;

// Modules //

module original_sv06_filament_barrel() {
    color("#eef", 0.8)
    import("sovol-sv06-filament-barrel-rotated.stl", convexity=4);
}

module chamfer_cut(z=0, h=chamfer_ht, od=upper_lip_d[3], id=barrel_d) {
    color("lemonchiffon", 0.8)
    translate([0, 0, z - slop])
    difference() {
        cylinder(h=h, d=od + bigslop * 4);
        if (id > 0) {
            cylinder(h=h * 2, d=id, center=true);
        }
        cylinder(h=h + slop * 2, d1=id, d2=od);
        if ($children > 0) {
            linear_extrude(height=h * 2, center=true)
            children();
        }
    }
}

// Sovol's filament barrel model has few enough faces that the polygons are
// visible on a print. Replacing the body length with a new cylinder allows the
// body to be rendered with more polygons.
module replace_barrel_body() {
    localslop = bigslop * 10;
    body_length = upper_lip_z[0] - lower_lip_z[1];
    color("#eef", 0.8)
    union() {
        difference() {
            children();
            render(convexity=4)
            translate([0, 0, lower_lip_z[1]])
            linear_extrude(height=body_length)
            difference() {
                circle(d=barrel_d + 1);
                circle(d=barrel_d - localslop);
            }
        }
        render(convexity=4)
        translate([0, 0, lower_lip_z[1]])
        linear_extrude(height=body_length)
        difference() {
            circle(d=barrel_d);
            circle(d=barrel_d - localslop * 2);
        }
    }
}

module filament_barrel() {
    difference() {
        replace_barrel_body()
        original_sv06_filament_barrel();
        chamfer_cut(z=upper_lip_z[0]);
        chamfer_cut(z=lower_lip_z[0]);
        difference() {
            z = channel_z[1];
            chamfer_cut(z=z, od=channel_d[1], id=channel_d[0]) {
                projection(cut=true)
                translate([0, 0, -(channel_z[0] + channel_thick / 2)])
                original_sv06_filament_barrel();
            }
        }
    }
}

filament_barrel();
