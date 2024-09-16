/*
 * Gridfinity Rebuilt Bins
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 *
 * Remix of Gridfinity Rebuilt in OpenSCAD by kennetek
 * https://github.com/kennetek/gridfinity-rebuilt-openscad
 * https://www.printables.com/model/274917-gridfinity-rebuilt-in-openscad
 */

include <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>

// [Default Value Overrides] */
// Tab size
d_tabh = 14.265; // [15.85: Default, 14.265: 90% -- for bridged tab angle, 13.4725: 85% -- for reduced tab angle, 12.68: 80%]
// Tab angle
a_tab = 20; // [36: Default, 30: Reduced, 20: Bridged]
// Outer wall thickness
d_wall = 0.95; // [0.95: Default, 1.2: 3 lines, 1.6: 4 lines, 2.6: Full thickness -- desk tray style]
// Divider wall thickness
d_div = 1.2; // [1.2: Default, 1.6: 4 lines, 2.1: 5 lines, 2.6: Full outer thickness]

/* [General Settings] */
Part = "both_closed"; // [bin: Bin, lid: Lid, both_closed: Both - lid closed, both_open: Both - lid open]

// number of bases along x-axis
gridx = 2; // [1:1:8]
// number of bases along y-axis
gridy = 2; // [1:1:8]
// bin height. See bin height information and "gridz_define" below.
gridz = 3; // [1:0.5:20]

/* [Remix Features] */
// generate tabs on the lid to help align stacked bins
Stacking_Tabs = true;
// Interior depth
h_cut_extra = 1.6; // [0: Default, 1.8: 2 bottom layers, 1.6: 3 bottom layers, 1.4: 4 bottom layers]
// Additional interior depth for single-grid pockets -- best used with h_cut_extra set to 2 bottom layers
h_cut_extra_single = 2.0; // [0: Default, 2.0: Most, 1.4: Some]

Compartment_Style = "default"; // [default: Default -- use compartment settings below, "default_multiple": Multiples of the compartment settings below, "6p": half and half half/single pockets, "3p": double and single pockets, "split1y": half full width, half divx pockets]

// For the above "Multiples of the compartment settings" option, what size multiple to use for the X axis
Div_Mult_X = 2; // [1:0.5:4]
// For the above "Multiples of the compartment settings" option, what size multiple to use for the Y axis
Div_Mult_Y = 2; // [1:0.5:4]

/* [Lid Bin Features] */
Lip_Grips = "xy"; // [none: None, x: Along X axis, y: Along Y axis, xy: Along X and Y axes]
Lid_Orientation = "left"; // [up: Up, down: Down, left: Left, right: Right]

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
// the type of tabs
style_tab = 1; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]
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

min_z = gridz;

lid_wall_thickness = 1.2;
lid_thickness = 0.9;
lid_hfit_tolerance = 1.1;
lid_vfit_tolerance = 0.1;
lid_vpos_tolerance = 0.2;
lid_lip_fit_tolerance = min(0.1, lid_vfit_tolerance);

// Functions //

function key_to_val(data, key) = (
    let (matches = [for (v = data) if (v[0] == key) v])
    len(matches) == 1 ? matches[0][1] : undef
);

function gf_height(z=gridz) = height(z, gridz_define, style_lip, enable_zsnap);

function lid_pos(adjust=0) = (
    let (translate_multiple = lid_pos_multiple())
    [
        translate_multiple[0] * (l_grid * gridx + adjust),
        translate_multiple[1] * (l_grid * gridy + adjust),
    ]
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

function div_multiple_step(remaining_steps, multiple) = (
    let (remainder = remaining_steps % multiple)
    multiple + remainder / (max(1, floor(remaining_steps / multiple)))
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
            intersection() {
                difference() {
                    $dh = $dh + (0*h_base - lid_thickness - lid_vpos_tolerance);
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

                if(0)
                #translate(
                    [0, 0, $dh + h_base - lid_thickness - lid_vpos_tolerance]
                )
                mirror([0, 0, 1])
                linear_extrude(height=$dh * 2)
                square([l_grid * gridx, l_grid * gridy], center=true);


            }
            difference() {
                union() {
                    block_wall($gxx, $gyy, $ll) {
                        gf_profile_wall_lid_lip(lid=false);
                        // if ($style_lip == 0) profile_wall();
                        // else profile_wall2();
                    }
                    gf_bin_lid_tabs();
                    if (Stacking_Tabs && $style_lip == 0)
                    intersection() {
                        generate_tabs();
                        translate([0, 0, $dh + h_base + h_lip * 0.25])
                        linear_extrude(height=$dh)
                        square([l_grid * gridx, l_grid * gridy], center=true);
                    }
                }
                gf_bin_lid_lip_mask();
                gf_bin_lid_grip_masks();
            }
        } else {
            children();
        }
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

module gf_bin_rounded_rect(height, add_size=0, r=r_fo1) {
    rounded_rectangle(
        gridx * l_grid + add_size + 0.005,
        gridy * l_grid + add_size + 0.005,
        height,
        r / 2 + 0.001
    );
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

// Override block_cutter for optional deeper bins
module block_cutter(x,y,w,h,t,s) {

    v_len_tab = d_tabh;
    v_len_lip = d_wall2-d_wall+1.2;
    v_cut_tab = d_tabh - (2*r_f1)/tan(a_tab);
    v_cut_lip = d_wall2-d_wall-d_clear;
    v_ang_tab = a_tab;
    v_ang_lip = 45;

    ycutfirst = y == 0 && $style_lip == 0;
    ycutlast = abs(y+h-$gyy)<0.001 && $style_lip == 0;
    xcutfirst = x == 0 && $style_lip == 0;
    xcutlast = abs(x+w-$gxx)<0.001 && $style_lip == 0;
    zsmall = ($dh+h_base)/7 < 2.8;

    ylen = h*($gyy*l_grid+d_magic)/$gyy-d_div;
    xlen = w*($gxx*l_grid+d_magic)/$gxx-d_div;

    cut_extra = h_cut_extra + (
        (
            floor(x) == floor(x + w - 0.0001)
            && floor(y) == floor(y + h - 0.0001)
        )
            ? h_cut_extra_single
            : 0
    );
    height = $dh + cut_extra;
    extent_size = d_wall2 - d_wall - d_clear;
    extent = (abs(s) > 0 && ycutfirst ? extent_size : 0);
    tab = (zsmall || t == 5) ? (ycutlast?v_len_lip:0) : v_len_tab;
    ang = (zsmall || t == 5) ? (ycutlast?v_ang_lip:0) : v_ang_tab;
    cut = (zsmall || t == 5) ? (ycutlast?v_cut_lip:0) : v_cut_tab;
    style = (t > 1 && t < 5) ? t-3 : (x == 0 ? -1 : xcutlast ? 1 : 0);

    translate([0,ylen/2,h_base + h_bot - cut_extra])
    rotate([90,0,-90]) {

    if (!zsmall && xlen - d_tabw > 4*r_f2 && (t != 0 && t != 5)) {
        fillet_cutter(3,"bisque")
        difference() {
            transform_tab(style, xlen, ((xcutfirst&&style==-1)||(xcutlast&&style==1))?v_cut_lip:0)
            translate([ycutlast?v_cut_lip:0,0])
            profile_cutter(height-h_bot, ylen/2, s);

            if (xcutfirst)
            translate([0,0,(xlen/2-r_f2)-v_cut_lip])
            cube([ylen,height,v_cut_lip*2]);

            if (xcutlast)
            translate([0,0,-(xlen/2-r_f2)-v_cut_lip])
            cube([ylen,height,v_cut_lip*2]);
        }
        if (t != 0 && t != 5)
        fillet_cutter(2,"indigo")
        difference() {
            transform_tab(style, xlen, ((xcutfirst&&style==-1)||(xcutlast&&style==1))?v_cut_lip:0)
            difference() {
                intersection() {
                    profile_cutter(height-h_bot, ylen-extent, s);
                    profile_cutter_tab(height-h_bot, v_len_tab, v_ang_tab);
                }
                if (ycutlast) profile_cutter_tab(height-h_bot, v_len_lip, 45);
            }

            if (xcutfirst)
            translate([ylen/2,0,xlen/2])
            rotate([0,90,0])
            transform_main(2*ylen)
            profile_cutter_tab(height-h_bot, v_len_lip, v_ang_lip);

            if (xcutlast)
            translate([ylen/2,0,-xlen/2])
            rotate([0,-90,0])
            transform_main(2*ylen)
            profile_cutter_tab(height-h_bot, v_len_lip, v_ang_lip);
        }
    }

    fillet_cutter(1,"seagreen")
    translate([0,0,xcutlast?v_cut_lip/2:0])
    translate([0,0,xcutfirst?-v_cut_lip/2:0])
    transform_main(xlen-(xcutfirst?v_cut_lip:0)-(xcutlast?v_cut_lip:0))
    translate([cut,0])
    profile_cutter(height-h_bot, ylen-extent-cut-(!s&&ycutfirst?v_cut_lip:0), s);

    fillet_cutter(0,"hotpink")
    difference() {
        transform_main(xlen)
        difference() {
            profile_cutter(height-h_bot, ylen-extent, s);

            if (!((zsmall || t == 5) && !ycutlast))
            profile_cutter_tab(height-h_bot, tab, ang);

            if (!(abs(s) > 0)&& y == 0)
            translate([ylen-extent,0,0])
            mirror([1,0,0])
            profile_cutter_tab(height-h_bot, v_len_lip, v_ang_lip);
        }

        if (xcutfirst)
        color("indigo")
        translate([ylen/2+0.001,0,xlen/2+0.001])
        rotate([0,90,0])
        transform_main(2*ylen)
        profile_cutter_tab(height-h_bot, v_len_lip, v_ang_lip);

        if (xcutlast)
        color("indigo")
        translate([ylen/2+0.001,0,-xlen/2+0.001])
        rotate([0,-90,0])
        transform_main(2*ylen)
        profile_cutter_tab(height-h_bot, v_len_lip, v_ang_lip);
    }

    }
}

module compartments_custom_3p() {
    for (x = [0:1:gridx/2-0.1], y = [0:2:gridy-0.1])
    cut(x, y, 1, 2, t=style_tab, s=scoop);
    for (x = [gridx/2:1:gridx-0.1], y = [0:1:gridy-0.1])
    cut(x, y, 1, 1, t=style_tab, s=scoop);
}

module compartments_custom_6p() {
    for (x = [0:1:gridx-0.1], y = [0:1:gridy/2-0.1])
    cut(x, y, 1, 1, t=style_tab, s=scoop);
    for (x = [0:0.5:gridx-0.1], y = [gridy/2:1:gridy-0.1])
    cut(x, y, 0.5, 1, t=style_tab, s=scoop);
}

module compartments_custom_split1y() {
    cut(0, gridy / 2, gridx, gridy / 2, t=5, s=scoop);
    for (y = [0:1:gridy/2-0.1], x = [0:gridx/divx:gridx-0.1])
    cut(x, y, gridx / divx, gridy / 2, t=style_tab, s=scoop);
}

module compartments_cut() {
    if (Compartment_Style == "default") {
        if (divx > 0 && divy > 0) {
            cutEqual(
                n_divx=divx,
                n_divy=divy,
                style_tab=style_tab,
                scoop_weight=scoop
            );
        } else if (cdivx > 0 && cdivy > 0) {
            cutCylinders(
                n_divx=cdivx,
                n_divy=cdivy,
                cylinder_diameter=cd,
                cylinder_height=ch,
                coutout_depth=c_depth,
                orientation=c_orientation
            );
        }
    } else if (Compartment_Style == "default_multiple") {
        if (divx > 0 && divy > 0) {
            for (x = [1:divx])
            for (y = [1:ceil(divy / 2)])
            cut(
                (x - 1) * gridx/divx, (y - 1) * gridy/divy,
                gridx/divx, gridy/divy,
                style_tab, scoop
            );

            m_step_x = div_multiple_step(divx, Div_Mult_X);
            m_step_y = div_multiple_step(divy - ceil(divy / 2), Div_Mult_Y);
            for (x = [1:m_step_x:divx])
            for (y = [ceil(divy / 2)+1:m_step_y:divy]) {
                cut(
                    (x - 1) * gridx/divx, (y - 1) * gridy/divy,
                    gridx/divx*m_step_x, gridy/divy*m_step_y,
                    style_tab, scoop
                );
            }
        } else if (cdivx > 0 && cdivy > 0) {
            cutCylinders(
                n_divx=cdivx,
                n_divy=cdivy,
                cylinder_diameter=cd,
                cylinder_height=ch,
                coutout_depth=c_depth,
                orientation=c_orientation
            );
        }
    } else if (Compartment_Style == "3p") {
        compartments_custom_3p();
    } else if (Compartment_Style == "6p") {
        compartments_custom_6p();
    } else if (Compartment_Style == "split1y") {
        compartments_custom_split1y();
    }
}

module wall_cut_grip_extrude(outer=true) {
    if (outer) {
        for (mz = [0, 1])
        mirror([0, 0, mz])
        translate([0, 0, gridy * l_grid / 2 - (d_wall * 2 / 2)])
        linear_extrude(height=d_wall * 2, center=true)
        children();
    } else {
        linear_extrude(height=gridy * l_grid - d_wall * 3, center=true)
        children();
    }
}

module wall_cut_grip(outer=true) {
    bot_h = h_base * 2 + 7 * 2;
    gx = gridx / 3 * l_grid;
    gz = gridz * 7 - bot_h + (outer ? h_lip + 0.1 : 0);
    gxbase = gx * 0.65;
    radius = gx / 5;
    translate([0, 0, bot_h])
    rotate([90, 0, 0])
    wall_cut_grip_extrude(outer=outer)
    offset(r=-radius)
    offset(r=radius * 2)
    offset(r=-radius)
    union() {
        polygon([
            [-gxbase / 2, 0],
            [gxbase / 2, 0],
            [gx / 2, gz],
            [-gx / 2, gz],
        ]);
        translate([-gx, gz])
        square([gx * 2, gz * 2]);
    }
}

// Main Module //

module gf_bin() {
    color("cornflowerblue", 0.8)
    render(convexity=4)
    gf_init(bin=true)
    compartments_cut();
}

module main() {
    if (Part == "bin") {
        gf_bin();
    } else if (Part == "lid") {
        gf_init() {
            translate([0, 0, -$dh - h_base + lid_thickness])
            gf_bin_lid();
        }
    } else if (Part == "both_closed" || Part == "both_open") {
        // Bin
        gf_bin();
        // Lid
        if ($preview)
        translate(Part == "both_open" ? lid_pos(-(h_lip * 2)) : [0, 0, 0])
        gf_init()
        gf_bin_lid();
    }
}

main();
