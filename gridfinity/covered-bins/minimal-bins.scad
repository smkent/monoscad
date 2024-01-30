/*
 * Gridfinity Bins with Lids
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

include <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>;

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */

// number of bases along x-axis
gridx = 3;
// number of bases along y-axis
gridy = 2;
// bin height. See bin height information and "gridz_define" below.
gridz = 6;

/* [Linear Compartments] */
// number of X Divisions (set to zero to have solid bin)
divx = 0;
// number of Y Divisions (set to zero to have solid bin)
divy = 0;

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

module __end_customizer_options__() { }

// Constants //

module gf_setup_stub(gx, gy, h, h0 = 0, l = l_grid, sl = 0) {
    $gxx = gx;
    $gyy = gy;
    $dh = h;
    $dh0 = h0;
    $style_lip = sl;
    children();
}

module gf_setup() {
    gf_setup_stub(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, sl=style_lip)
    children();
}

module gf_bin_solid() {
    color("mediumpurple", 0.8)
    render(convexity=4)
    gf_setup() {
        render(convexity=4)
        block_wall(gridx, gridy, l_grid)
        if ($style_lip == 0) {
            profile_wall();
        } else {
            profile_wall2();
        }

        render(convexity=4)
        difference() {
            union() {
                block_bottom(
                    ($dh0==0?$dh-0.1:$dh0),
                    gridx,
                    gridy,
                    l_grid
                );
                gf_base_grid_interior();
            }
            children();
        }

        render(convexity=4)
        intersection() {
            translate([0, 0, -1])
            gf_bin_rounded_rect(h_base + h_bot / 2 * 10, add_x=-0.5, add_y=-0.5);
            difference() {
                union() {
                    gf_base_grid();
                    translate([0, 0, h_base + h_bot / 2 - d_wall])
                    gf_bin_rounded_rect(d_wall, add_x=-d_wall, add_y=-d_wall);
                }
                gf_base_grid_interior();
            }
        }
    }
}

module gf_base_grid_interior() {
    translate([0, 0, d_wall])
    gf_base_grid(-d_wall);
}

module gf_base_grid(size_offset=0) {
    pattern_linear(gridx, gridy, l_grid, l_grid)
    intersection() {
        block_base_solid(1, 1, l_grid, size_offset);
        linear_extrude(height=h_base + h_bot / 2 + size_offset)
        square([gridx * l_grid, gridy * l_grid], center=true);
    }
}

module gf_bin_rounded_rect(height, add_x=0, add_y=0, r=r_fo1) {
    rounded_rectangle(
        gridx * l_grid + add_x + 0.005,
        gridy * l_grid + add_y + 0.005,
        height,
        r / 2 + 0.001
    );
}

module gf_cut_pockets() {
    if (divx > 0 && divy > 0)
    cut_move(x=0, y=0, w=gridx, h=gridy)
    pattern_linear(
        x=divx,
        y=divy,
        sx=gridx * l_grid / divx,
        sy=gridy * l_grid / divy
    )
    translate([0, 0, -$dh - h_base])
    linear_extrude(height=gridz * 7)
    square([
        gridx * l_grid / divx - d_wall,
        gridy * l_grid / divy - d_wall,
    ], center=true);
}

module gf_bin() {
    gf_bin_solid()
    gf_cut_pockets();
}

module main() {
    gf_bin();
}

main();
