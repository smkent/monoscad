/*
 * ESPHome 40x40mm PCB mount
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

pcb_grid = 40;
pcb_grid_sep = 2;
corner_radius = 3;
hole_inset = 3;
pcb_hole_d = 3.2;
pcb_hole_clearance = 2.495 + 0.5;

edge_outset = 2;
hole_to_edge = edge_outset + hole_inset;

pcb_thick = 1.6;

slop = 0.001;

// Functions //

function pcb40_dimensions() = [
    $p_x * pcb_grid + ($p_x - 1) * pcb_grid_sep,
    $p_y * pcb_grid + ($p_y - 1) * pcb_grid_sep,
];

// Public Modules //

module pcb40(
    x=1,
    y=1,
    height=6,
    edge_radius=0.5,
    screw_insert_diameter=4.5,
    pcb_support_chamfer=1.5,
    inner_holes=true
) {
    $p_x = x;
    $p_y = y;
    $p_height = height;
    $p_edge_radius = edge_radius;
    $p_screw_insert_diameter = screw_insert_diameter;
    $p_pcb_support_chamfer = pcb_support_chamfer;
    $p_inner_holes = inner_holes;
    children();
}

module pcb40_round_3d(radius=$p_edge_radius) {
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

module pcb40_supports(add_radius=true, cut=true) {
    intersection() {
        if (cut) {
            linear_extrude(height=$p_height * 2)
            pcb40_perimeter_shape();
        }
        translate([0, 0, $p_edge_radius])
        _at_pcb40_grid_corners()
        _pcb40_hull_pair($p_height - $p_edge_radius * 2) {
            offset(r=$p_pcb_support_chamfer)
            _pcb40_support_quad_shape();
            _pcb40_support_quad_shape();
        }
    }
}

module pcb40_screw_holes(chamfer_bottom=true) {
    _at_pcb40_holes() {
        translate([0, 0, -slop])
        cylinder(d=$p_screw_insert_diameter, h=$p_height + slop * 2);
        translate([0, 0, $p_height - $p_edge_radius])
        cylinder(d1=$p_screw_insert_diameter, d2=$p_screw_insert_diameter + 2 * $p_edge_radius, h=$p_edge_radius + slop);
        if (chamfer_bottom)
        translate([0, 0, -slop])
        cylinder(d1=$p_screw_insert_diameter + 2 * $p_edge_radius, d2=$p_screw_insert_diameter, h=$p_edge_radius + slop);
    }
}

module pcb40_perimeter_shape() {
    size = pcb40_dimensions();
    offset(r=-$p_edge_radius)
    offset(r=hole_to_edge)
    offset(r=-hole_to_edge)
    square([size[0] + edge_outset * 2, size[1] + edge_outset * 2], center=true);
}

module pcb40_pcb() {
    color("darkseagreen", 0.5)
    linear_extrude(height=pcb_thick)
    difference() {
        $fs = $preview ? ($fs / 4) : $fs;
        offset(r=corner_radius)
        offset(r=-corner_radius)
        square(pcb40_dimensions(), center=true);
        _at_pcb40_holes()
        circle(d=pcb_hole_d);
    }
}

// Internal Modules //

module _pcb40_hull_pair(height) {
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

module _at_pcb40_grid() {
    translate([
        -($p_x - 1) / 2 * (pcb_grid_sep + pcb_grid),
        -($p_y - 1) / 2 * (pcb_grid_sep + pcb_grid),
    ])
    for (px = [0:1:$p_x - 1], py = [0:1:$p_y - 1])
    translate([px * (pcb_grid + pcb_grid_sep), py * (pcb_grid + pcb_grid_sep)])
    union() {
        $p_grid_x = px;
        $p_grid_y = py;
        children();
    }
}

module _at_pcb40_grid_corners() {
    translate([
        -$p_x / 2 * (pcb_grid + pcb_grid_sep),
        -$p_y / 2 * (pcb_grid + pcb_grid_sep)
    ])
    for (px = [0:1:$p_x], py = [0:1:$p_y]) {
        inner = (px > 0 && px < $p_x) && (py > 0 && py < $p_y);
        if (!inner || ($p_inner_holes && inner))
        translate([
            px * (pcb_grid + pcb_grid_sep),
            py * (pcb_grid + pcb_grid_sep)
        ])
        children();
    }
}

module _at_pcb40_holes() {
    _at_pcb40_grid()
    union() {
        px = $p_grid_x;
        py = $p_grid_y;
        for (hx = [0, 1], hy = [0, 1]) {
            edge_x0 = (px == 0 && hx == 0);
            edge_x1 = (px == ($p_x - 1) && hx == 1);
            edge_y0 = (py == 0 && hy == 0);
            edge_y1 = (py == ($p_y - 1) && hy == 1);
            inner_x = !(edge_x0 || edge_x1);
            inner_y = !(edge_y0 || edge_y1);
            inner = (inner_x && inner_y);
            if (!inner || ($p_inner_holes && inner))
            mirror([1 - hx, 0])
            mirror([0, 1 - hy])
            translate([pcb_grid / 2 - hole_inset, pcb_grid / 2 - hole_inset])
            children();
        }
    }
}

module _pcb40_support_quad_shape() {
    offset(r=3)
    offset(r=-3)
    square((hole_inset + pcb_hole_clearance) * 2 + pcb_grid_sep, center=true);
}
