/*
 * Electronics project box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <honeycomb-openscad/honeycomb.scad>;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 4 : 0.4;

slop = 0.001;
preview_render = false;

// Functions //

function _eyelet_thickness() = $e_thickness * 2;

function _mounting_screw_xpos() = $e_thickness + $e_mounting_screw_diameter * 1.125;

function _mounting_screw_eyelet_d() = $e_mounting_screw_diameter * 1.125;

function _mounting_screw_count(distance) = max(1, floor(distance / $e_mounting_screw_sep));

// Public Modules //

module ebox(
    dimensions,
    thickness=2.4,
    lid_height=3.9,
    screw_diameter=3,
    insert_diameter=4.5,
    insert_depth=10,
    screw_style="flag",
    mounting_screws_x=true,
    mounting_screws_y=true,
    mounting_screw_diameter=4,
    mounting_screw_style="flat",
    pattern_lid=0,
    pattern_bottom=0,
    pattern_walls=[0, 0, 0, 0]
) {
    $e_dimensions = dimensions;
    $e_width = dimensions[0];
    $e_length = dimensions[1];
    $e_height = dimensions[2];
    $e_thickness = thickness;
    $e_lid_height = lid_height;
    $e_screw_diameter = screw_diameter;
    $e_insert_diameter = insert_diameter;
    $e_insert_depth = insert_depth;
    $e_screw_style = screw_style;
    $e_mounting_screws_x = mounting_screws_x;
    $e_mounting_screws_y = mounting_screws_y;
    $e_mounting_screw_diameter = mounting_screw_diameter;
    $e_mounting_screw_style = mounting_screw_style;
    $e_pattern_lid = pattern_lid;
    $e_pattern_bottom = pattern_bottom;
    $e_pattern_walls = pattern_walls;
    ebox_adjustments()
    children();
}

module ebox_adjustments(
    print_orientation=true,
    screw_inset=4,
    corner_radius=3,
    edge_radius=1.5,
    screw_count=4,
    screw_fit=0.4,
    mounting_screw_sep=40
) {
    $e_print_orientation = print_orientation;
    $e_screw_inset = screw_inset;
    $e_corner_radius = corner_radius;
    $e_edge_radius = edge_radius;
    $e_screw_count = screw_count;
    $e_screw_fit = screw_fit;
    $e_mounting_screw_sep = mounting_screw_sep;
    children();
}

module ebox_part(part) {
    if (Part == "preview") {
        _box();
        translate([0, 0, slop])
        _lid();
    } else if (Part == "all") {
        sep = $e_width / 2 + $e_thickness * 2 + $e_mounting_screw_diameter * 2;
        translate([sep, 0, 0])
        _box();
        translate([-sep, 0, 0])
        if ($e_print_orientation) {
            rotate([180, 0, 0])
            translate([0, 0, -($e_height + $e_thickness * 2)])
            _lid();
        } else {
            translate([0, 0, -($e_height - $e_lid_height) - $e_thickness * 2])
            _lid();
        }
    } else if (Part == "box") {
        _box();
    } else if (Part == "lid") {
        if ($e_print_orientation) {
            rotate([180, 0, 0])
            translate([0, 0, -($e_height + $e_thickness * 2)])
            _lid();
        } else {
            translate([0, 0, -($e_height + $e_thickness)])
            _lid();
        }
    }
}

module ebox_cutouts() {
}

module ebox_interior() {
}

module ebox_extras() {
}

// Internal Modules //

module _render() {
    if (preview_render) {
        render()
        children();
    } else {
        children();
    }
}

module _hc_pattern(x, y, hex_size=10, separation=2.2, height=$e_thickness * 1.1) {
    translate([0, 0, -slop * 5])
    linear_extrude(height=height + slop * 10)
    difference() {
        square([x, y], center=true);
        translate([-x/2, -y/2])
        honeycomb(x, y, hex_size, separation, whole_only=true);
    }
}

module _hull_pair(height) {
    slop = 0.001;
    hull() {
        for (child_obj = [
            // Child index, height offset
            [0, 0],
            [1, height - slop]
        ]) {
            translate([0, 0, child_obj[1]])
            linear_extrude(height=slop)
            children(child_obj[0]);
        }
    }
}

module _round_3d(radius = $e_edge_radius) {
    if (radius == 0) {
        children();
    } else {
        _render()
        minkowski() {
            children();
            for (mz = [0, 1])
            mirror([0, 0, mz])
            cylinder(r1=radius, r2=0, h=radius);
        }
    }
}

module _screw_hole(d, h, fit=0, style="flat", print_upside_down=false) {
    inset_min_h = (style == "inset") ? max((h - d), 2) - (h - d) : 0;
    translate([0, 0, -slop])
    cylinder(d=(d + fit), h=h + slop * 2);
    if (style == "countersink" || style == "inset") {
        translate([0, 0, h + inset_min_h + slop * 2])
        mirror([0, 0, 1])
        cylinder(d1=d * 2, d2=d * (style == "inset" ? 2 : 1), h=d);
    }
    if (style == "inset" && print_upside_down) {
        layer_height = 0.2;
        translate([0, 0, (h + inset_min_h) - d - layer_height])
        linear_extrude(height=layer_height + slop * 2)
        intersection() {
            square([d * 2, d + fit], center=true);
            circle(d=d*2);
        }
    }
}

module _at_screws() {
    if ($e_screw_count == 2) {
        for (m = [0, 1])
        mirror([m, 0])
        mirror([0, m])
        translate([$e_width / 2 - $e_screw_inset, $e_length / 2 - $e_screw_inset])
        children();
    } else {
        for (mx = [0, 1], my = [0, 1])
        mirror([mx, 0])
        mirror([0, my])
        translate([$e_width / 2 - $e_screw_inset, $e_length / 2 - $e_screw_inset])
        children();
    }
}

module _at_box_screws(enable_x=true, enable_y=true) {
    if (enable_x && $e_mounting_screws_x) {
        screw_count = _mounting_screw_count($e_width);
        for (my = [0, 1])
        mirror([0, my])
        translate([-((screw_count - 1) * $e_mounting_screw_sep) / 2, 0])
        for (sn = [0:1:screw_count - 1])
        translate([sn * $e_mounting_screw_sep, $e_length / 2 + _mounting_screw_xpos()])
        children();
    }
    if (enable_y && $e_mounting_screws_y) {
        screw_count = _mounting_screw_count($e_length);
        for (mx = [0, 1])
        mirror([mx, 0])
        translate([0, -((screw_count - 1) * $e_mounting_screw_sep) / 2])
        for (sn = [0:1:screw_count - 1])
        translate([$e_width / 2 + _mounting_screw_xpos(), sn * $e_mounting_screw_sep])
        children();
    }
}

module _box_shape(radius=$e_corner_radius, add=0) {
    offset(r=radius)
    offset(r=-radius)
    square([$e_width + add * 2, $e_length + add * 2], center=true);
}

module _box_interior_base() {
    render()
    union() {
        screw_corner = $e_insert_diameter + $e_screw_inset;
        start_ht = $e_height - $e_lid_height + $e_insert_diameter * 0.40;
        interior_corner_radius = max(0.5, ($e_corner_radius - $e_thickness));

        // Interior shape
        color("mintcream", 0.8)
        translate([0, 0, $e_thickness])
        _round_3d()
        translate([0, 0, $e_edge_radius])
        union() {
            linear_extrude(height=(start_ht - $e_insert_depth - screw_corner) - $e_edge_radius * 2)
            _box_shape(add=-$e_edge_radius);

            linear_extrude(height=(
                $e_height - $e_edge_radius * 2
                + ($e_part == "box" ? Thickness * 2 : 0)
            ))
            offset(r=interior_corner_radius)
            offset(r=-interior_corner_radius)
            difference() {
                _box_shape(add=-$e_edge_radius);
                _at_screws()
                union() {
                    r = $e_insert_diameter + $e_edge_radius;
                    circle(r=r);
                    for (tr = [[0, -r], [-r, 0]])
                    translate(tr)
                    square([r, r]);
                }
            }
        }

        // Interior screw support chamfer
        color("mediumpurple", 0.8)
        translate([0, 0, (start_ht - $e_insert_depth - screw_corner) + $e_thickness])
        union() {
            _hull_pair(screw_corner) {
                offset(r=interior_corner_radius)
                offset(r=-interior_corner_radius)
                _box_shape(radius=$e_corner_radius + $e_edge_radius);
                _box_shape(radius=$e_corner_radius + $e_edge_radius, add=-screw_corner);
            }
            if ($e_edge_radius > 0) {
                translate([0, 0, -$e_edge_radius + slop])
                linear_extrude(height=$e_edge_radius + slop)
                _box_shape(radius=$e_corner_radius + $e_edge_radius);
            }
        }
    }
}

module _box_body() {
    translate([0, 0, $e_edge_radius])
    _round_3d()
    linear_extrude(height=$e_height + $e_thickness * 2 - $e_edge_radius * 2)
    _box_shape(add=$e_thickness - $e_edge_radius);
}

module _box_screw_eyelets() {
    eyelet_round = _mounting_screw_xpos() * 2;
    if ($e_mounting_screws_x || $e_mounting_screws_y)
    _round_3d()
    translate([0, 0, $e_edge_radius])
    linear_extrude(height=_eyelet_thickness() - $e_edge_radius * 2)
    offset(r=-$e_edge_radius)
    offset(r=$e_thickness)
    offset(r=-eyelet_round)
    offset(r=eyelet_round)
    union() {
        _box_shape();
        for (enable_x = [0, 1])
        hull()
        union() {
            d = _mounting_screw_eyelet_d();
            offset(r=-d * 2)
            _box_shape();
            _at_box_screws(enable_x=enable_x, enable_y=!enable_x)
            circle(d=d * 2);
        }
    }
}

module _box_screws() {
    _at_box_screws()
    _screw_hole(
        d=$e_mounting_screw_diameter,
        fit=$e_screw_fit,
        h=_eyelet_thickness() + slop * 2,
        style=$e_mounting_screw_style
    );
}

module _box_patterns() {
    if ($e_pattern_bottom)
    _hc_pattern($e_width - $e_screw_inset * 2, $e_length - $e_screw_inset * 2);
    for (fw = [0:1:3]) {
        if ($e_pattern_walls[fw] > 0) {
            pattern_x = (((fw % 2) == 0) ? $e_width : $e_length) - $e_insert_diameter * 2 * 2;
            pos_y = ((fw % 2) == 0) ? $e_length : $e_width;
            mirror([fw == 3 ? 1 : 0, fw == 2 ? 1 : 0])
            rotate((fw % 2) != 0 ? 90 : 0)
            translate([0, pos_y / 2 + $e_thickness, ($e_height - $e_lid_height) / 2 + $e_thickness])
            rotate([90, 0, 0])
            _hc_pattern(pattern_x - $e_screw_inset * 2, ($e_height - $e_lid_height) - $e_thickness * 2);
        }
    }
}

module _box_interior() {
    difference() {
        _box_interior_base();
        ebox_interior();
    }
}

module _box() {
    $e_part = "box";
    color("mintcream", 0.8)
    _render()
    union() {
        difference() {
            intersection() {
                union() {
                    _box_body();
                    _box_screw_eyelets();
                }
                linear_extrude(height=$e_height + $e_thickness * 2 - $e_lid_height)
                _box_shape(add=$e_thickness + $e_edge_radius + $e_mounting_screw_diameter * 4, radius=0);
            }
            _box_interior();
            _at_screws()
            translate([0, 0, ($e_height + $e_thickness) - $e_lid_height - $e_insert_depth])
            _screw_hole(d=$e_insert_diameter, fit=$e_screw_fit, h=$e_insert_depth + $e_thickness);
            _box_screws();
            _box_patterns();
            ebox_cutouts();
        }
    }
    ebox_extras();
}

module _lid() {
    $e_part = "lid";
    color("lightsteelblue", (Part == "preview" ? 0.4 : 0.8))
    _render()
    difference() {
        intersection() {
            _box_body();
            translate([0, 0, $e_height + $e_thickness * 2 - $e_lid_height])
            linear_extrude(height=$e_lid_height)
            _box_shape(add=$e_thickness + $e_edge_radius, radius=0);
        }
        _box_interior();
        _at_screws()
        translate([0, 0, $e_height + $e_thickness * 2 - $e_lid_height])
        _screw_hole(
            d=$e_screw_diameter,
            fit=$e_screw_fit,
            h=$e_lid_height,
            style=$e_screw_style,
            print_upside_down=true
        );
        if ($e_pattern_lid)
        translate([0, 0, $e_height + $e_thickness])
        _hc_pattern($e_width - $e_screw_inset * 2, $e_length - $e_screw_inset * 2);
        ebox_cutouts();
    }
}
