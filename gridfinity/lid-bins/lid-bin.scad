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

Part = "both_closed"; // [bin: Bin, lid: Lid, both_closed: Both - lid closed, both_open: Both - lid open, bin_slice: Bin slice for print testing]

// number of bases along x-axis
gridx = 2;
// number of bases along y-axis
gridy = 2;
// bin height. See bin height information and "gridz_define" below.
gridz = 3;

/* [Bin and Lid Features] */
Interior_Style = "minimal"; // [minimal: Minimal, partial_raised: Partially raised]
Lip_Grips = "xy"; // [none: None, x: Along X axis, y: Along Y axis, xy: Along X and Y axes]
Lid_Orientation = "left"; // [up: Up, down: Down, left: Left, right: Right]

/* [Linear Compartments] */
div_pattern = "default"; // [default: Use divx & divy values, multisize: Multiple sizes with div_multiple as size multiplier, custom: Custom pattern -- modify gf_custom_pockets module in the source code]
// number of X Divisions (set to zero to have solid bin)
divx = 6;
// number of Y Divisions (set to zero to have solid bin)
divy = 6;
// Secondary compartment size multiplier (for use with div_pattern set to "Multiple sizes with div_multiple as size multiplier")
div_multiple = 2; // [1:.5:5]

/* [Height] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

module __end_customizer_options__() { }

// Constants //

d_wall = 1.60;

lid_wall_thickness = 1.2;
lid_thickness = 0.9;
lid_hfit_tolerance = 1.1;
lid_vfit_tolerance = 0.1;
lid_vpos_tolerance = 0.2;
lid_lip_fit_tolerance = min(0.1, lid_vfit_tolerance);

bin_separator_wall_thickness = 1.2;
interior_base_wall_adjust = 0.4;

bin_storage_height = height(gridz, gridz_define, 0, enable_zsnap);
bin_inner_height = bin_storage_height + h_base - d_wall;
bin_outer_height = bin_storage_height + h_base + h_lip;

// Functions //

function vec_add(vec, add) = [for (i = vec) i + add];

function key_to_val(data, key) = (
    let (matches = [for (v = data) if (v[0] == key) v])
    len(matches) == 1 ? matches[0][1] : undef
);

function lid_pos_multiple() = (
    let (orientation_data = [
        ["right", [1, 0]],
        ["left", [-1, 0]],
        ["up", [0, 1]],
        ["down", [0, -1]],
    ])
    key_to_val(orientation_data, Lid_Orientation)
);

function lid_pos(adjust=0) = (
    let (translate_multiple = lid_pos_multiple())
    [
        translate_multiple[0] * (l_grid * gridx + adjust),
        translate_multiple[1] * (l_grid * gridy + adjust),
    ]
);

function pocket_size(x_units, y_units) = (
    vec_add(
        [
            x_units*($gxx*l_grid+d_magic)/$gxx,
            y_units*($gyy*l_grid+d_magic)/$gyy
        ],
        -bin_separator_wall_thickness
    )
);

// Modules //

module gf_custom_pockets() {
    // Comment out or remove this module call
    gf_custom_pockets_default_notice();

    /*
     * Add custom pocket cuts here
     *
     * Example:
     *
     *     gf_cut_pocket(0, 0, 0.5, 1);
     *     gf_cut_pocket(0.5, 0, 0.5, 1);
     *     gf_cut_pocket(1, 0, 1, 1);
     *     gf_cut_pocket(0, 1, 1, 1);
     *     gf_cut_pocket(1, 1, 1, 1);
     */
}

module gf_custom_pockets_default_notice(font_size=3) {
    text_lines = [
        "For custom",
        "pockets, modify",
        "gf_custom_pockets",
        "in the source code"
    ];
    size = font_size * min(gridx, gridy);
    cut_move(x=0, y=0, w=gridx, h=gridy)
    mirror([0, 0, 1])
    translate([0, 0, lid_thickness + lid_vpos_tolerance + lid_vfit_tolerance])
    linear_extrude(height=bin_storage_height)
    translate([0, (size + 2) * (len(text_lines)-1) / 2])
    for (i = [0:1:len(text_lines)]) {
        translate([0, (size + 2) * -i])
        text(text_lines[i], size=size, valign="center", halign="center");
    }
}

module gf_setup_stub(gx, gy, h, h0 = 0, l = l_grid, sl = 0) {
    $gxx = gx;
    $gyy = gy;
    $dh = h;
    $dh0 = h0;
    $style_lip = sl;
    children();
}

module gf_setup() {
    gf_setup_stub(gridx, gridy, bin_storage_height, height_internal)
    children();
}

module gf_profile_wall_lid_lip(lid=false) {
    difference() {
        profile_wall();
        translate([r_base,0,0])
        mirror([1,0,0])
        translate([
            lid ? lid_hfit_tolerance : lid_wall_thickness,
            $dh - lid_thickness - lid_vfit_tolerance - lid_vpos_tolerance
        ])
        polygon([
            [0, 0],
            [0, lid_thickness + lid_vfit_tolerance],
            [d_wall2, lid_thickness + lid_vfit_tolerance + d_wall2],
            [d_wall2, 0],
        ]);
    }
}

module gf_bin_lid_lip_mask() {
    translate(concat(
        lid_pos(-(r_base + 0.5)),
        [$dh + h_base - lid_thickness - lid_vpos_tolerance]
    ))
    linear_extrude(height=h_lip * 10)
    square([l_grid * gridx, l_grid * gridy], center=true);
}

module gf_bin_lid_grip_mask_shape() {
    grip_w = l_grid / 2 - h_lip * 2 - 2;
    radius = 3;
    translate([-(grip_w - l_grid / 2) / 2, 0])
    intersection() {
        offset(r=-radius)
        offset(r=2 * radius)
        offset(r=-radius)
        union() {
            square([grip_w, h_lip * 10]);
            translate([-grip_w * 2, h_lip * 0.75])
            square([grip_w * 5, h_lip * 9]);
        }
        translate([-radius, 0])
        square([grip_w + radius * 2, h_lip]);
    }
}

module gf_bin_lid_grip_mask_set(num_grid) {
    rotate([90, 0, 90])
    translate([0, 0, l_grid * num_grid / 2])
    linear_extrude(height=l_grid / 2, center=true)
    gf_bin_lid_grip_mask_shape();
}

module gf_bin_lid_grip_mask() {
    translate([0, 0, $dh + h_base + h_lip * 0.25]) {
        if (Lip_Grips == "x" || Lip_Grips == "xy")
        pattern_linear(1, gridy, l_grid * gridx, l_grid)
        gf_bin_lid_grip_mask_set(gridx);
        if (Lip_Grips == "y" || Lip_Grips == "xy")
        pattern_linear(gridx, 1, l_grid, l_grid * gridy)
        rotate(90)
        gf_bin_lid_grip_mask_set(gridy);
    }
}

module gf_bin_lid_grip_masks() {
    if (Lip_Grips != "none")
    for (rot = [0, 180])
    rotate(rot)
    gf_bin_lid_grip_mask();
}

module gf_bin_lid() {
    color("mintcream", 0.5)
    render(convexity=4)
    union() {
        difference() {
            intersection() {
                block_wall(gridx, gridy, l_grid)
                profile_wall();
                gf_bin_lid_lip_mask();
            }
            gf_bin_lid_grip_masks();
        }


        difference() {
            sz = 0.5 + lid_hfit_tolerance * 3;
            union() {
                translate([
                    0, 0, $dh + h_base - lid_thickness - lid_vpos_tolerance
                ])
                gf_bin_rounded_rect(lid_thickness, add_size=-sz, r=r_fo1-sz);

                intersection() {
                    translate([
                        0, 0, $dh + h_base - lid_thickness - lid_vpos_tolerance
                    ])
                    gf_bin_rounded_rect(
                        h_lip + lid_thickness, add_size=-sz, r=r_fo1-sz
                    );

                    block_wall(gridx, gridy, l_grid)
                    difference() {
                        color("yellow", 0.8)
                        profile_wall();
                        union() {
                            square([r_base, $dh - lid_vpos_tolerance]);
                            translate([r_base, 0])
                            square([r_base, $dh + h_lip]);
                        }
                        offset(delta=0.30)
                        gf_profile_wall_lid_lip(lid=true);
                    }
                }
            }

            gf_bin_lid_tabs(adjust=true);
        }
    }
}

module gf_bin_lid_tabs(adjust=false) {
    adj = adjust ? -lid_hfit_tolerance * 1.5 + lid_wall_thickness: 0;
    cr = 0.6;
    multiple = lid_pos_multiple();
    tab_pos = [
        multiple[0] * (-(l_grid * gridx - 0.5) / 2 + r_base + cr),
        multiple[1] * (-(l_grid * gridy - 0.5) / 2 + r_base + cr)
    ];
    tab_sep_pos = [
        abs(multiple[1]) * (gridx * l_grid / 2 - 0.5 / 2 - lid_wall_thickness + adj),
        abs(multiple[0]) * (gridy * l_grid / 2 - 0.5 / 2 - lid_wall_thickness + adj),
    ];
    // Tabs
    translate(concat(
        tab_pos,
        [$dh + h_base - lid_thickness - lid_lip_fit_tolerance / 2 - 0.001]
    ))
    for (ml = [0, 1])
    mirror(multiple[0] != 0 ? [0, ml] : [ml, 0])
    translate([
        tab_sep_pos[0],
        tab_sep_pos[1],
        -lid_vfit_tolerance - lid_vpos_tolerance
    ])
    rotate(multiple[0] != 0 ? 0 : 270)
    linear_extrude(height=lid_lip_fit_tolerance * 2 + lid_thickness + 2)
    intersection() {
        $fs = $fs / 4;
        offset(r=-(cr * 0.5))
        offset(r=(cr * 0.5))
        union() {
            circle(r=cr);
            translate([0, cr * 4])
            square(cr * 8, center=true);
        }
        square([cr * 3, cr * 2], center=true);
    }
}

module gf_bin_solid() {
    color("darkseagreen", 0.8)
    render(convexity=4)
    gf_setup() {
        render(convexity=4)
        difference() {
            union() {
                block_wall(gridx, gridy, l_grid)
                gf_profile_wall_lid_lip(lid=false);
                gf_bin_lid_tabs();
            }
            translate([-lid_lip_fit_tolerance, 0, -lid_lip_fit_tolerance])
            gf_bin_lid_lip_mask();
            gf_bin_lid_grip_masks();
        }

        render(convexity=4)
        difference() {
            union() {
                block_bottom(
                    (
                        ($dh0==0?$dh-0.1:$dh0)
                        - lid_thickness
                        - lid_vfit_tolerance
                        - lid_vpos_tolerance
                    ),
                    gridx,
                    gridy,
                    l_grid
                );
                gf_base_grid_interior();
            }
            intersection() {
                aa = -(0.500 + d_wall * 1.25 + bin_separator_wall_thickness / 4);
                color("lightblue", 0.2)
                translate([0, 0, d_wall])
                gf_bin_rounded_rect(bin_inner_height, add_size=aa, r_base*2);
                children();
            }
        }

        render(convexity=4)
        intersection() {
            translate([0, 0, -1])
            gf_bin_rounded_rect(h_base + h_bot / 2 * 10, add_size=-0.5);
            difference() {
                union() {
                    gf_base_grid();
                    translate([0, 0, h_base])
                    gf_bin_rounded_rect(h_bot / 2, add_size=-0.5);
                }
                intersection() {
                    if (Interior_Style == "partial_raised") {
                        translate([0, 0, h_bot + h_base - r_c2 + 0.1])
                        linear_extrude(height=h_base - r_c2)
                        square([l_grid * gridx, l_grid * gridy], center=true);
                    }
                    gf_base_grid_interior();
                }
            }
        }
    }
}

module gf_base_grid_interior() {
    translate([0, 0, d_wall])
    gf_base_grid(-d_wall - interior_base_wall_adjust);
}

module gf_base_grid(size_offset=0) {
    pattern_linear(gridx, gridy, l_grid, l_grid)
    intersection() {
        block_base_solid(1, 1, l_grid, size_offset);
        linear_extrude(height=h_base + h_bot / 2)
        square([gridx * l_grid, gridy * l_grid], center=true);
    }
}

module gf_bin_rounded_rect(height, add_size=0, r=r_fo1) {
    rounded_rectangle(
        gridx * l_grid + add_size + 0.005,
        gridy * l_grid + add_size + 0.005,
        height,
        r / 2 + 0.001
    );
}

module gf_cut_pocket_interior(dimensions) {
    translate([0, 0, -$dh - h_base + d_wall])
    linear_extrude(height=(
        bin_inner_height
        - lid_thickness - lid_vfit_tolerance - lid_vpos_tolerance + 0.001
    ))
    square(dimensions, center=true);
}

module gf_cut_pocket(x, y, w, h) {
    cut_move(x=x, y=y, w=w, h=h)
    gf_cut_pocket_interior(pocket_size(w, h));
}

module gf_cut_pockets() {
    if (div_pattern == "default" && divx > 0 && divy > 0) {
        for (x=[1:1:divx], y=[1:1:divy])
        gf_cut_pocket(x=(x-1)*gridx/divx, y=(y-1)*gridy/divy, w=gridx/divx, h=gridy/divy);
    } else if (div_pattern == "multisize") {
        w = gridx / divx;
        h = gridy / divy;
        off_divx = ceil(divx / 2);
        rem_gridx = w * (divx - off_divx);
        off_gridx = gridx - rem_gridx;
        rem_divx = max(1, floor(rem_gridx / (w * div_multiple)));
        rem_divy = max(1, floor(divy / div_multiple));
        for (x=[1:1:off_divx], y=[1:1:divy])
        gf_cut_pocket(x=(x-1)*w, y=(y-1)*h, w=w, h=h);
        for (x=[1:1:rem_divx], y=[1:1:rem_divy])
        gf_cut_pocket(x=off_gridx+(x-1)*rem_gridx/rem_divx, y=(y-1)*gridy/rem_divy, w=rem_gridx/rem_divx, h=gridy/rem_divy);
    } else if (div_pattern == "custom") {
        gf_custom_pockets();
    }
}

module gf_bin(pockets=true) {
    gf_bin_solid()
    if (pockets)
    gf_cut_pockets();
}

module main() {
    if (Part == "bin") {
        gf_bin();
    } else if (Part == "lid") {
        gf_setup() {
            translate([0, 0, -$dh - h_base + lid_thickness])
            gf_bin_lid();
        }
    } else if (Part == "both_closed" || Part == "both_open") {
        // Bin
        gf_bin();
        // Lid
        if ($preview)
        translate(Part == "both_open" ? lid_pos(-(h_lip * 2)) : [0, 0, 0])
        gf_setup()
        gf_bin_lid();
    } else if (Part == "bin_slice") {
        color("darkseagreen", 0.8)
        render()
        intersection() {
            gf_setup() {
                bh = $dh + h_base - lid_thickness * 2;
                translate([0, 0, -bh])
                gf_bin(pockets=false);
            }
            linear_extrude(height=h_lip * 3)
            square([l_grid * gridx, l_grid * gridy], center=true);
        }
    }
}

main();
