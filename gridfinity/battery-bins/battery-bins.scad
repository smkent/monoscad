/*
 * Gridfinity Battery Bins
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * MIT License (see LICENSE file)
 */

include <gridfinity-remix-openscad/gridfinity-rebuilt-utility.scad>;

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 2;
// number of bases along y-axis
gridy = 4;
// bin height. See bin height information and "gridz_define" below.
gridz = 3; // [2:1:9]

/* [Battery Holder Features] */
Battery_Type = "AA"; // [AA, AAA]

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
// only cut magnet/screw holes at the corners of the bin to save unneccesary print time
only_corners = false;

/* [Base] */
style_hole = 3; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0;

stacking_tabs = true;

module __end_customizer_options__() { }

// Constants //

h_cut_extra = 0;
d_wall = 3;

battery_table = [
    ["AA", [14.5, 50.5, 1, 4]],
    ["AAA", [10.5, 44.5, 2.25, 4]]
];

battery_spec = vsearch(battery_table, Battery_Type);
assert(battery_spec, str("Unknown battery size '", Battery_Type, "'"));

battery_d_base = battery_spec[0];
battery_len_base = battery_spec[1];
battery_separation = battery_spec[2];
min_z = (gridz - battery_spec[3]);

battery_fit = 0.2;
battery_d = battery_d_base + battery_fit;
battery_len = battery_len_base + battery_fit;

nozzle_thread_ht = 16;

hole_chamfer = 0.6;
grid_overlap = 1;
slop = 0.01;

// Functions //

function vsearch(vec, term) = (
    let (r = [for (i = vec) if (i[0] == term) i])
    len(r) == 1 ? r[0][1] : undef
);

function gf_height() = height(gridz, gridz_define, style_lip, enable_zsnap);

function battery_count(grid) = floor((((l_grid + grid_overlap) * grid) - d_wall2 * 2) / (battery_d + battery_separation));

// Modules //

module stubInit(gx, gy, h, h0 = 0, l = l_grid) {
    $gxx = gx;
    $gyy = gy;
    $dh = h;
    $dh0 = h0;
    children();
}

module wall_cut(num_grid) {
    dd = l_grid * 0.15;
    bh = min_z * 7;
    ht = (gridz - min_z) * 7 - h_lip - r_f2;
    radius = min(10, ht * 0.49);
    translate([l_grid * (num_grid / 2 - 0.5), 0, 0])
    for (x = [0:1:num_grid-1])
    translate([-x * l_grid, 0, 0])
    rotate([90, 0, 0])
    linear_extrude(height=l_grid * (max(gridx, gridy) + 1), center=true)
    translate([-l_grid / 2, 0])
    translate([dd, r_f2])
    union() {
        // square([l_grid - dd * 2, ht / 2]);
        offset(r=radius)
        offset(r=-radius)
        square([l_grid - dd * 2, ht]);
    }
}

module walls_cut() {
    translate([0, 0, min_z * 7]) {
        rotate(90)
        wall_cut(gridy);
        wall_cut(gridx);
    }
}

module battery_polygon() {
    mirror([0, 0, 1])
    cylinder(h=nozzle_thread_ht * 2, d=battery_d, center=true);
}

module battery_cut(grid_x, grid_y) {
    ch = hole_chamfer;
    ncx = battery_count(grid_x);
    ncy = battery_count(grid_y);
    cut_sz_x = (ncx - 1) * (battery_d + battery_separation);
    cut_sz_y = (ncy - 1) * (battery_d + battery_separation);
    translate([0, 0, $dh + h_base])
    mirror([0, 0, 1])
    for (nx = [0:1:ncx - 1], ny = [0:1:ncy - 1])
    translate([-cut_sz_x / 2, -cut_sz_y / 2, 0])
    translate([
        (battery_d + battery_separation) * nx + 0*battery_separation,
        (battery_d + battery_separation) * ny + 0*battery_separation,
        0
    ])
    render()
    union() {
        bbase = min(battery_len - ch, (gridz - min_z) * 7);
        cylinder(h=battery_len, d=battery_d);
        translate([0, 0, bbase])
        cylinder(h=ch, d1=battery_d + ch, d2=battery_d);
        cylinder(h=bbase, d=battery_d + ch);
    }
}

module text_cut() {
    depth = 1;
    translate([0, 0, (min_z * 7 + r_f2 + h_base) / 2])
    for (grid = [[gridx, 90], [gridy, 0]])
    rotate(grid[1])
    for (my = [0, 1])
    rotate(my ? 180 : 0)
    translate([0, grid[0] * l_grid / 2, 0])
    rotate(180)
    rotate([90, 0, 0])
    linear_extrude(height=depth * 2, center=true)
    text(str(Battery_Type), size=l_grid / 4, valign="center", halign="center");
}

module main() {
    ht = gf_height();
    color("mediumslateblue", 0.8) {
        difference() {
            union() {
                gridfinityInit(gridx, gridy, ht, height_internal, sl=style_lip) {
                    if (gridz > min_z) {
                        cut_height = height(min_z + 1, gridz_define, style_lip, enable_zsnap);
                        translate([0, 0, -(h_base + h_bot) + min_z * 7])
                        cut(0, 0, gridx, gridy, 5, s=0);
                    }
                }
                gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, style_hole, only_corners=only_corners);
            }
            stubInit(gridx, gridy, ht, height_internal) {
                battery_cut(gridx, gridy);
                walls_cut();
                text_cut();
            }
        }
    }
}

main();
