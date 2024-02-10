/*
 * Gridfinity Breadboard Bins
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 *
 * Remix of Gridfinity Rebuilt in OpenSCAD by kennetek
 * https://github.com/kennetek/gridfinity-rebuilt-openscad
 * https://www.printables.com/model/274917-gridfinity-rebuilt-in-openscad
 */

include <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>

/* [General Settings] */
// number of bases along x-axis
gridx = 2; // [1:1:8]
// number of bases along y-axis
gridy = 4; // [2:1:6]
// bin height. See bin height information and "gridz_define" below.
gridz = 3; // [2.5:0.5:9]

/* [Remix Features] */
// generate tabs on the lid to help align stacked bins
Stacking_Tabs = true;

/* [Breadboard Bin Features] */
// Width without tabs or power rail, Length, Thickness. Include bottom pad in thickness if desired.
Breadboard_Dimensions = [35.5, 165, 9.5]; // [5:0.1:300]
// Tab size added to breadboard width, tab height
Breadboard_Power_Rail_Width = 9.5; // [5:0.1:15]
Breadboard_Tab_Dimensions = [1.8, 6.2]; // [0:0.1:10]
Breadboard_Count = 1; // [0:1:5]
Breadboard_Power_Rail_Count = 2; // [0:1:10]
Breadboard_Double_Sided_Tabs = true;

// Optional bin lip chamfer
Lip_Chamfer = false;
// Raised wall openings for sufficiently tall bins
Wall_Openings = true;

/* [Linear Compartments] */
// number of X Divisions (set to zero to have solid bin)
divx = 1;
// number of Y Divisions (set to zero to have solid bin)
divy = 1;

/* [Cylindrical Compartments] */
// number of cylindrical X Divisions (mutually exclusive to Linear Compartments)
cdivx = 0;
// number of cylindrical Y Divisions (mutually exclusive to Linear Compartments)
cdivy = 0;
// orientation
c_orientation = 2; // [0: x direction, 1: y direction, 2: z direction]
// diameter of cylindrical cut outs
cd = 10;
// cylinder height
ch = 1;
// spacing to lid
c_depth = 1;

/* [Height] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

/* [Features] */
// how should the top lip act
style_lip = 0; //[0: Regular lip, 1:remove lip subtractively, 2: remove lip and retain height]
// scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop.
scoop = 1; //[0:0.1:1]
// only cut magnet/screw holes at the corners of the bin to save uneccesary print time
only_corners = false;

/* [Base] */
style_hole = 0; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit, 4: Gridfinity Refined hole - no glue needed]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

min_z = 2.00 + ((0.5 + 0.8) / 7);

// Gridfinity constants
d_wall = 1.6;
style_tab = 5;

// Breadboard

bb_size = Breadboard_Dimensions;
bb_tabs = Breadboard_Tab_Dimensions + [Breadboard_Dimensions[0], 0];
bb_count = Breadboard_Count;
bb_power_width = Breadboard_Power_Rail_Width;
bb_power_count = Breadboard_Power_Rail_Count;
retaining_lip = 1.2;

// Functions //

function vec_slice(v, n) = [for (i = [0:1:n - 1]) v[i]];

function vec_reverse(v) = [for (i = [len(v) - 1:-1:0]) v[i]];

function gf_height(z=gridz) = height(z, gridz_define, style_lip, enable_zsnap);

function bb_points(bb_count, extra_height=0, lip_cut=false, lip_chamfer=false) = (
    let (bb_tab_ch_ht = bb_tabs[1] + (bb_tabs[0] - bb_size[0]))
    let (sz_x = (bb_size[0] * bb_count + bb_power_width * bb_power_count) / 2)
    let (basepts = [
        [sz_x, 0],
        [sz_x + (bb_tabs[0] - bb_size[0]), 0],
        [sz_x + (bb_tabs[0] - bb_size[0]), bb_tabs[1]],
        [sz_x, bb_tab_ch_ht],
        [sz_x, bb_size[2] + extra_height],
    ])
    let (pts = concat(
        basepts,
        lip_cut
            ? [
                [sz_x, bb_size[2] + extra_height + $bindepth],
                [
                    sz_x + (lip_chamfer ? h_lip : 0),
                    bb_size[2] + extra_height + h_lip + $bindepth
                ]
            ]
            : []
    ))
    concat(pts, [for (pt = vec_reverse(pts)) [-pt[0], pt[1]]])
);

// Modules //

module gf_init_stub(gx=gridx, gy=gridy, h=-1, h0=0, l=l_grid, sl=style_lip) {
    $gxx = gx;
    $gyy = gy;
    $dh = (h == -1) ? gf_height() : h;
    $dh0 = h0;
    $ll = l;
    $style_lip = sl;
    children();
}

module gf_init(bin=false) {
    cut_height = gf_height(min_z + 1);
    $dh = gf_height();
    gf_init_stub() {
        $cuttop = (gridz > min_z) ? min_z * 7 + 0.25 : h_base + $dh;
        $bindepth = (gridz > min_z) ? (gridz - min_z) * 7 : 0;
        if (bin) {
            difference() {
                union() {
                    block_bottom($dh0 == 0 ? $dh - 0.1 : $dh0, $gxx, $gyy, $ll);
                    gridfinityBase(
                        $gxx, $gyy, $ll,
                        div_base_x, div_base_y,
                        style_hole, only_corners=only_corners
                    );
                }
                if (gridz > min_z) {
                    translate([0, 0, -(h_base + h_bot) + cut_height])
                    cut(0, 0, gridx, gridy, 5, s=0);
                }
                children();
            }
            block_wall($gxx, $gyy, $ll) {
                if ($style_lip == 0) profile_wall();
                else profile_wall2();
            }
            if (Stacking_Tabs && $style_lip == 0)
            generate_tabs();
        } else {
            children();
        }
    }
}

module gf_bin() {
    gf_init(bin=true)
    children();
}

// Feature Modules //

// Stacking tabs by @rpedde
// https://github.com/kennetek/gridfinity-rebuilt-openscad/pull/122
module generate_tabs() {

    module lip_tab(x, y) {
        //Calculate rotation of lip based on which edge it is on
        rot = (x == $gxx) ? 0 : ((x == 0) ? 180 : ((y == $gyy) ? 90 : 270));
        wall_thickness = r_base-r_c2+d_clear*2;

        translate(
            [(x * l_grid) - ((l_grid * $gxx / 2)),
             (y * l_grid) - ((l_grid * $gyy / 2)),
             $dh+h_base]) {
            rotate([0, 0, rot])
            translate([-r_base-d_clear,-r_base,0]) {
                //Extrude the wall profile in circle; same as you would at a corner of bin
                //Intersection - limit it to the section where the lip would not interfere with the base
                intersection() {
                    translate([wall_thickness, -r_base*1.5, 0]) cube([wall_thickness, r_base*5, (h_lip)*5]);
                    translate([0,0,-$dh]) union() {
                        rotate_extrude(angle=90) profile_wall();
                        translate([0, r_base*2, 0]) rotate_extrude(angle=-90) profile_wall();
                    }
                }
                //Fill the gap between rotational extrusions (think of it as the gap between bins, if this was multiple bins instead of tabs)
                difference() {
                    translate([wall_thickness, 0, -h_lip*0.5]) cube([(r_base-wall_thickness)-r_f1, r_base*2, h_lip*1.5]);
                    cylinder(h=h_lip*3, r=r_base-r_f1, center=true);
                    translate([0, r_base*2, 0]) cylinder(h=h_lip*3, r=r_base-r_f1, center=true);
                }
            }
        }
    }

    if ($gxx > 1) {
        for (xtab=[1:$gxx-1]) {
            lip_tab(xtab, 0);
            lip_tab(xtab, $gyy);
        }
    }

    if ($gyy > 1) {
        for (ytab=[1:$gyy-1]) {
            lip_tab(0, ytab);
            lip_tab($gxx, ytab);
        }
    }
}

module wall_cut(num_grid) {
    dd = l_grid * 0.15;
    bh = min_z * 7;
    ht = (gridz - min_z) * 7 - h_lip - r_f2;
    radius = min(10, ht * 0.49);
    if (ht >= 3.5)
    translate([l_grid * (num_grid / 2 - 0.5), 0, 0])
    for (x = [0:1:num_grid-1])
    translate([-x * l_grid, 0, 0])
    rotate([90, 0, 0])
    linear_extrude(height=l_grid * (max(gridx, gridy) + 1), center=true)
    translate([-l_grid / 2, 0])
    translate([dd, r_f2])
    union() {
        offset(r=radius)
        offset(r=-radius)
        square([l_grid - dd * 2, ht]);
    }
}

module walls_cut() {
    if (Wall_Openings)
    translate([0, 0, min_z * 7]) {
        rotate(90)
        wall_cut(gridy);
        translate([0, max(gridx, gridy) * l_grid / 2])
        wall_cut(gridx);
    }
}

module breadboard(lip_cut=false, add_length=0) {
    rotate([90, 0, 180])
    color("mintcream", 0.4)
    render(convexity=4)
    for (lip_cut_each = concat([false], lip_cut ? [true] : [])) {
        extrudelen = (bb_size[1] + add_length) / (lip_cut_each ? 2 : 1);
        translate([0, 0, -(l_grid * gridy - extrudelen) / 2])
        linear_extrude(height=extrudelen, center=true)
        polygon(bb_points(
            bb_count,
            extra_height=((lip_cut && !lip_cut_each) ? r_f2: 0),
            lip_cut=lip_cut_each,
            lip_chamfer=Lip_Chamfer
        ));
    }
}

module retaining_lip_cut() {
    translate([0, -(gridy * l_grid - 0.5) / 2 + retaining_lip / 2])
    rotate([0, 90, 0])
    linear_extrude(height=(gridx * l_grid - 0.5) - r_f2 * 2, center=true)
    circle(d=retaining_lip, $fn=50);
}

module breadboard_cut() {
    breadboard(lip_cut=true, add_length=retaining_lip);
    rotate([90, 0, 0]) {
        blen = (bb_size[0] + bb_power_width * 2) / 6;
        bfill_len = min(
            l_grid * gridx - d_wall * 4,
            (bb_size[0] * bb_count + bb_power_width * bb_power_count)
        );
        bnum = floor(bfill_len / blen / 2);
        linear_extrude(height=l_grid * gridy, center=true)
        translate([-(bnum - 1) * blen, bb_tabs[1] / 2])
        for (n = [0:1:bnum-0.01])
        translate([blen * 2 * n, 0]) {
            offset(r=2)
            offset(r=-2)
            square([blen, bb_tabs[1]], center=true);
            translate([0, -bb_tabs[1] / 4])
            square([blen, bb_tabs[1] / 2], center=true);
        }
    }
}

// Main Module //

module main() {
    gf_init() {
        color("cadetblue", 0.8)
        render(convexity=4)
        difference() {
            gf_bin();
            difference() {
                union() {
                    translate([0, 0, $cuttop - bb_size[2]])
                    breadboard_cut();
                    walls_cut();
                }
                translate([0, 0, $cuttop - bb_size[2]])
                retaining_lip_cut();
            }
        }
        if ($preview) {
            translate([0, retaining_lip - 0.001, $cuttop - bb_size[2] + 0.001])
            breadboard();
        }
    }
}

main();
