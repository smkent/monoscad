/*
 * Gridfinity Material Swatches Holder V2
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * MIT License (see LICENSE file)
 *
 * Material Swatches by Ryan:
 * https://www.printables.com/model/2256-material-swatches
 */

include <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>;

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 2;
// number of bases along y-axis
gridy = 4;
// bin height. See bin height information and "gridz_define" below.
gridz = 3; // [2:1:6]

/* [Swatch Holder Features] */
Separator_Style = 1; // [0: Full Height, 1: Reduced Height, 2: Sides Only]

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

module __end_customizer_options__() { }

// Constants //

swatch_length = 31.75;
swatch_width = 31.75;
swatch_thickness = 3.17;

swatch_tolerance = 0.4;
swatch_separation = 1.0;

sw_l = swatch_length + swatch_tolerance;
sw_w = swatch_width + swatch_tolerance;
sw_t = 4.0; // swatch_thickness + swatch_tolerance;

// Modules //

function gf_height() = height(gridz, gridz_define, style_lip, enable_zsnap);

function swatch_row_count(grid_y) = floor(((l_grid * grid_y) - d_wall2 * 2) / (sw_t + swatch_separation));

module swatch_shape() {
    rad = 1.0;
    hull() {
        translate([rad, rad])
        circle(rad);
        translate([rad, sw_w - rad])
        circle(rad);
        translate([sw_l - rad, 0])
        square([rad, sw_w]);
    }
}

module swatch_polygon() {
    translate([0, -sw_l / 2, -sw_w / 2])
    rotate([0, 270, 0])
    translate([0, 0, -sw_t])
    linear_extrude(height=sw_t)
    swatch_shape();
}

module swatch_cut(grid_x, grid_y) {
    ht = gf_height();
    swatch_count = swatch_row_count(grid_y);
    all_swatches_depth = sw_t * swatch_count + swatch_separation * (swatch_count - 1);
    translate([0, 0, h_bot - ht])
    union() {
        rotate([0, 0, 90])
        translate([-all_swatches_depth/2, 0, sw_w / 2])
        for (i = [0:1:swatch_count-1]) {
            translate([(sw_t + swatch_separation) * i, 0, 0])
            swatch_polygon();
        }

        if (Separator_Style > 0) {
            round_out_ratio = 0.75;
            translate([0, all_swatches_depth / 2, sw_w / 2])
            union() {
                scale([round_out_ratio, 1, round_out_ratio])
                rotate([90, 0, 0])
                linear_extrude(height=all_swatches_depth)
                circle(sw_w / 2, $fn=6);
                if (Separator_Style == 2) {
                    cw = (sw_w / 2) * round_out_ratio;
                    translate([-cw / 2, -all_swatches_depth, -sw_w / 2])
                    cube([cw, all_swatches_depth, sw_w / 2]);
                }
            }
        }
    }
}

module main() {
    ht = gf_height();
    color("lightsteelblue") {
        gridfinityInit(gridx, gridy, ht, height_internal) {
            if (gridz > 3) {
                cut_height = height(4, gridz_define, style_lip, enable_zsnap);
                translate([0, 0, cut_height / 2 + h_bot])
                cut(0, 0, gridx, gridy, 5, 0);
            }
            for (x = [0:1:gridx - 1]) {
                cut_move(x, 0, 1, gridy) {
                    swatch_cut(1, gridy);
                }
            }
        }
        gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, style_hole, only_corners=only_corners);
    }
    echo(
        str(
            gridx, "x", gridy, " bin capacity: ", gridx * swatch_row_count(gridy),
            " swatches (",  swatch_row_count(gridy), " per column)"
        )
    );
}

main();
