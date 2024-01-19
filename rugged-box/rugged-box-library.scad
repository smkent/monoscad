/*
 * Customizable and Parametric Rugged Storage Box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Rugged storage box library
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

module __end_customizer_options__() { }

// Constants

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs / 2 : 0.2;

// Attachment screw diameter
screw_diameter = 3; // M3

// Decrease screw hole diameter just slightly for better thread-forming fit
screw_hole_diameter_size_tolerance = -0.1;

// Widen angle of box plain ribs
plain_ribs_angle = 8;

// Extra space between box body and hinge for clearance
hinge_extra_setback = 0.2; // [0:0.1:2]

// Screw eyelet diameter as a proportion of screw diameter
screw_eyelet_size_proportion = 2.5; // [1.5:0.1:5]

// Depth and maximum width of lip grip
top_grip_depth = 6;
top_grip_width = 100;

// Stacking latch size
stacking_latch_catch_offset = 6;
stacking_latch_grip_length = 8;

// Handle size
handle_thickness = 10;
handle_min_height = 16;
handle_max_height = 35;
handle_radius = 5;

// Public modules

/*
 * Setup module
 *
 * Use this module to configure box sizing and features before rendering a part
 *
 * Arguments:
 *  - width: Interior side-to-side size
 *  - length: Interior front-to-back size
 *  - top_height: Interior top height
 *  - bottom_height: Interior bottom height
 *  - corner_radius: Interior corner radius (Reduces interior storage space)
 *  - edge_chamfer_proportion: Proportion of corner_radius to chamfer outer
 *    top/bottom edges (Reduces interior storage space)
 *  - lip_seal_type: Type of shape of seal to use, if desired:
 *      - "none": No seal
 *      - "wedge": Wedge-shaped seal
 *      - "square": Square-shaped seal
 *      - "filament-1.75mm": Seal cutout on both top and bottom for
 *          1.75mm filament
 *  - reinforced_corners: Make the corners as thick as the box lip
 *  - latch_count: Number of latches (1 or 2). The default of 0 determines the
 *    number of latches automatically.
 *
 * Example:
 *
 *      box(width=100, length=50, top_height=15, bottom_height=30) {
 *          // Render box top
 *          translate([120, 0, 0])
 *          rbox_top();
 *
 *          // Render box bottom
 *          rbox_bottom();
 *      }
 */
module rbox(
    width,
    length,
    bottom_height=0,
    top_height=0,
    corner_radius=5,
    edge_chamfer_proportion=0.4,
    lip_seal_type="wedge",
    reinforced_corners=false,
    latch_count=0,
    top_grip=false
) {
    // Set base dimensions
    $b_inner_width = width;
    $b_inner_length = length;
    $b_top_inner_height = top_height;
    $b_bottom_inner_height = bottom_height;
    $b_corner_radius = corner_radius;
    $b_edge_chamfer_proportion = edge_chamfer_proportion;
    $b_lip_seal_type = lip_seal_type;
    $b_reinforced_corners = reinforced_corners;
    $b_latch_count = latch_count;
    $b_top_grip = top_grip;
    // Set defaults
    rbox_size_adjustments()
    _box_rib_angle(0)
    // Render modules
    children();
}

/*
 * Advanced size adjustments setup module
 *
 * Use this module to configure advanced box sizing adjustments before rendering a part
 *
 * Arguments:
 *  - wall_thickness: Base wall thickness for most of the box
 *  - lip_thickness: Thickness to add to the wall thickness for the box lip
 *  - rib_width: Base thickness of the support ribs. The latch ribs are this
 *    thick, while the hinge and side ribs are twice this thick.
 *  - latch_width: Latch side-to-side width
 *  - latch_screw_separation: Distance between the latch hinge and catch screws
 *    which determines the latch vertical size
 *  - latch_amount_on_top: Vertical size of the latch measured from the latch
 *    hinge screw hole overlapping the top of the box, with the remainder
 *    overlapping the bottom. Set to 0 to determine automatically.
 *  - size_tolerance: Size added between hinges and latches for fit
 *
 * Example:
 *
 *      box(width=100, length=50, top_height=15, bottom_height=30) {
 *          rbox_size_adjustments(wall_thickness=3.0, lip_thickness=3.0) {
 *              // Render box top
 *              translate([120, 0, 0])
 *              rbox_top();
 *
 *              // Render box bottom
 *              rbox_bottom();
 *          }
 *      }
 */
module rbox_size_adjustments(
    wall_thickness=2.4,
    lip_thickness=2.0,
    rib_width=4.0,
    latch_width=22,
    latch_screw_separation=20,
    latch_amount_on_top=0,
    size_tolerance=0.05
) {
    $b_wall_thickness = wall_thickness;
    $b_lip_thickness = lip_thickness;
    $b_rib_width = rib_width;
    $b_size_tolerance = size_tolerance;
    $b_latch_width = latch_width;
    $b_latch_screw_separation = latch_screw_separation;
    $b_latch_amount_on_top = _init_latch_amount_on_top(latch_amount_on_top);
    // Set computed values
    $b_total_lip_thickness = wall_thickness + lip_thickness;
    $b_lip_height = lip_thickness * 2;
    $b_edge_radius = wall_thickness / 5;
    // Set dependent values
    $b_top_outer_height = $b_top_inner_height + wall_thickness;
    $b_bottom_outer_height = $b_bottom_inner_height + wall_thickness;
    $b_outer_width = $b_inner_width + $b_total_lip_thickness * 2;
    $b_outer_length = $b_inner_length + $b_total_lip_thickness * 2;
    $b_curved_inner_width = $b_inner_width + $b_edge_radius * 2;
    $b_curved_inner_length = $b_inner_length + $b_edge_radius * 2;
    $b_outer_chamfer_horizontal = $b_edge_chamfer_proportion * $b_corner_radius;
    $b_outer_chamfer_vertical = $b_outer_chamfer_horizontal * 1.5;
    $b_hinge_screw_offset = _attachment_screw_offset();
    $b_latch_screw_offset = _attachment_screw_offset();
    children();
}

// Part modules

module rbox_top() { _box_part_setup("top") { rbox_body(); children(); } }
module rbox_bottom() { _box_part_setup("bottom") { rbox_body(); children(); } }

module rbox_for_top() { _box_part_setup("top") children(); }
module rbox_for_bottom() { _box_part_setup("bottom") children(); }

module rbox_for_interior() { translate([0, 0, $b_wall_thickness]) children(); }

module rbox_latch(placement="print") { _latch(placement); }

module rbox_stacking_latch(placement="print") { _stacking_latch(placement); }

module rbox_handle(placement="print") { _handle(placement); }

module rbox_body() {
    _box_color()
    _box_body();
}

module rbox_interior() {
    _box_color()
    render(convexity=4) {
        _box_extrude()
        _box_interior_shape();
        rbox_for_interior()
        _box_center_base($b_inner_height);
    }
}

module rbox_part(part) {
    module _place_apart(x_amount) {
        for (ch = [0:1:1]) {
            mirror([ch, 0, 0])
            translate([x_amount, 0, 0])
            children(ch);
        }
    }

    if (part == "side-by-side") {
        _place_apart($b_inner_width / 2 + $b_wall_thickness * 8) {
            if ($children > 0) { rbox_for_bottom() children(0); } else { rbox_bottom(); };
            if ($children > 1) { rbox_for_top() children(1); } else { rbox_top(); };
        }
    } else if (part == "assembled_open") {
        if ($children > 0) { rbox_for_bottom() children(0); } else { rbox_bottom(); };
        rbox_for_bottom() {
            rbox_handle(placement="box-preview-open");
            _box_stacking_latch_ribs_placement()
            translate([0, 0, $b_latch_screw_separation * 0.5])
            translate([0, -$b_latch_screw_offset, 0])
            rotate([180, 0, 0])
            rbox_stacking_latch(placement="box-preview");
        }
        translate([
            0,
            $b_inner_length / 2 + $b_hinge_screw_offset,
            $b_bottom_outer_height
        ])
        rotate([270, 0, 0])
        translate([
            0,
            -($b_inner_length / 2 + $b_hinge_screw_offset),
            $b_top_outer_height
        ])
        mirror([0, 0, 1]) {
            if ($children > 1) { rbox_for_top() children(1); } else { rbox_top(); };
            rbox_for_top() {
                translate([
                    0,
                    -$b_latch_screw_offset,
                    $b_outer_height - $b_latch_amount_on_top
                ])
                mirror([0, 1, 0])
                _box_attachment_placement()
                rotate([-135, 0, 0])
                rbox_latch(placement="box-preview");
            }
        }
    } else if (part == "assembled_closed") {
        if ($children > 0) { rbox_for_bottom() children(0); } else { rbox_bottom(); };
        rbox_for_bottom() {
            rbox_handle(placement="box-preview");
            _box_stacking_latch_ribs_placement()
            translate([0, 0, $b_latch_screw_separation * 0.5])
            translate([0, -$b_latch_screw_offset, 0])
            rbox_stacking_latch(placement="box-preview");
        }
        translate([0, 0, $b_top_outer_height + $b_bottom_outer_height])
        mirror([0, 0, 1]) {
            if ($children > 1) { rbox_for_top() children(1); } else { rbox_top(); };
            rbox_for_top() {
                translate([
                    0,
                    -$b_latch_screw_offset,
                    $b_outer_height - $b_latch_amount_on_top
                ])
                mirror([0, 1, 0])
                _box_attachment_placement()
                rbox_latch(placement="box-preview");
            }
        }
    } else if (part == "bottom") {
        if ($children > 0) { rbox_for_bottom() children(0); } else { rbox_bottom(); };
    } else if (part == "top") {
        if ($children > 1) { rbox_for_top() children(1); } else { rbox_top(); };
    } else if (part == "latch") {
        rbox_latch(placement="print");
    } else if (part == "stacking-latch") {
        rbox_stacking_latch(placement="print");
    } else if (part == "handle") {
        rbox_handle(placement="print");
    }
}

// Overrideable functions and modules

/*
 * Part colors
 *
 * Override this function to control the box colors in the preview render
 *
 * Arguments:
 *  - part: Part being rendered. Possible values: "top", "bottom"
 *
 * Example:
 *
 *      function rb_color(part) = (part == "top" ? "yellow" : "orange");
 */

function rb_color(part) = (part == "top" ? "YellowGreen" : "OliveDrab");

function rb_side_rib_positions() = [for (i = [-1/4, 1/4]) i * $b_inner_length];

function rb_rear_rib_positions() = [];

function rb_latch_hinge_position() = (
    ($b_inner_width - $b_corner_radius + $b_wall_thickness) / 2 - $b_latch_width
);

function rb_stacking_latch_positions() = [];

// Internal constants

screw_hole_diameter = screw_diameter;
screw_eyelet_radius = screw_hole_diameter * screw_eyelet_size_proportion / 2;

// For _box_extrude and _box_corners_extrude
corners_data = [
    // Rotate angle, X direction, Y direction
    [0, -1, -1],
    [90, 1, -1],
    [180, 1, 1],
    [270, -1, 1],
];

// Functions

function _cumulative_sum(v) = [
    for (
        now_sum = v[0], i = 1;
        i <= len(v) - 1;
        next_sum = now_sum + v[i], ni = i + 1, now_sum = next_sum, i = ni
    )
    now_sum
];

function _attachment_screw_offset() = (
    $b_total_lip_thickness + screw_eyelet_radius + hinge_extra_setback
);

function _compute_latch_count(latch_count) = (
    let (outer_radius = $b_corner_radius + $b_wall_thickness)
    ($b_latch_count == 1 || $b_latch_count == 2)
        ? $b_latch_count
        : (($b_inner_width >= (outer_radius * 2 + $b_latch_width * 4))
            ? 2
            : 1
        )
);

function _init_latch_amount_on_top(latch_amount_on_top) = (
    latch_amount_on_top > 0
        ? latch_amount_on_top
        : min(
            ($b_top_inner_height + $b_wall_thickness) / 2,
            min(
                screw_eyelet_radius * 2.0,
                $b_latch_screw_separation / 2
            )
        )
);

function _latch_offset_from_base() = (
    $b_outer_height - (
        $b_part == "top"
            ? $b_latch_amount_on_top
            : $b_latch_screw_separation - $b_latch_amount_on_top
    )
);

// Basic shape modules

module _round_shape(radius) {
    offset(-radius)
    offset(radius * 2)
    offset(-radius)
    children();
}

module _rounded_square(dimensions, radius, center=false) {
    offset(radius)
    offset(-radius)
    square(dimensions, center=center);
}

module _rounded_cylinder(h, r1, r2=0, angle=360, center=false) {
    r = $b_edge_radius;
    translate([0, 0, center ? -h / 2 : 0])
    rotate_extrude(angle=angle)
    difference() {
        _round_shape(r)
        polygon(points=[
            [-r * 2, 0],
            [r1, 0],
            [r2 > 0 ? r2 : r1, h],
            [-r * 2, h],
        ]);
        translate([-r * 4, -h / 2])
        square([r * 4, h * 2]);
    }
}

module _chamfer_edges(r) {
    minkowski() {
        children();
        if (r > 0)
        for (mz = [0:1:1])
        mirror([0, 0, mz])
        cylinder(d1=r, d2=0, h=r/2, $fn=4);
    }
}

module _hull_in_order() {
    for (ch = [0:1:$children - 2])
    hull() {
        children(ch);
        children(ch + 1);
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

module _hull_stack(heights=[]) {
    cheights = _cumulative_sum(heights);
    for (ch = [1:1:len(heights)]) {
        hi = ch - 1;
        if (ch < $children) {
            translate([0, 0, hi > 0 ? cheights[hi - 1] : 0])
            _hull_pair(heights[hi]) {
                children(ch - 1);
                children(ch);
            }
        } else {
            echo("Warning: ignoring extra height value at index", ch);
        }
    }
}

// Box body modules

module _box_color() {
    color(rb_color($b_part), 0.8)
    children();
}

module _box_part_setup(part) {
    $b_part = part;
    $b_inner_height = (
        ($b_part == "top") ? $b_top_inner_height : $b_bottom_inner_height
    );
    $b_outer_height = (
        ($b_part == "top") ? $b_top_outer_height : $b_bottom_outer_height
    );
    children();
}

module _box_body() {
    _box_add_seal() {
        render(convexity=4) {
            _box_sides();
            _box_center_base(min($b_outer_height, $b_wall_thickness));
        }
        _box_ribs();
        _box_latch_ribs();
        _box_hinge_ribs();
        _box_stacking_latch_ribs();
        _box_top_grip();
    }
}

module _box_corners_extrude_linear_extension(length) {
    rotate([90, 0, 90])
    linear_extrude(height=length)
    _box_wall_shape(reinforced=true);
}

module _box_corners_extrude(
    width=$b_inner_width,
    length=$b_inner_length,
    radius=$b_corner_radius,
    extend=false
) {
    for (i = [0:1:len(corners_data) - 1]) {
        translate([
            corners_data[i][1] * (width - radius * 2) / 2,
            corners_data[i][2] * (length - radius * 2) / 2,
            0
        ])
        rotate([0, 0, 180 + corners_data[i][0]])
        union() {
            rotate_extrude(angle=90)
            children();
            if (extend) {
                for (rz = [0:1:1]) {
                    mirror([rz, 0, 0])
                    rotate([0, 0, rz ? 0 : -90])
                    if (_compute_latch_count() == 2 && ((i % 2) != rz)) {
                        // Front/rear extensions to attachments
                        is_rear = (i == 2 || i == 3);
                        _box_corners_extrude_linear_extension(
                            (
                                ($b_inner_width - $b_corner_radius * 2)
                                - ($b_latch_width + $b_rib_width)
                            ) / 2
                            - rb_latch_hinge_position()
                            // On the box top hinge, extension needs to rear
                            // the inner hinge position
                            + (
                                $b_part == "top" && is_rear
                                    ? $b_rib_width * 2
                                    : 0
                            )
                        );
                    } else if (_compute_latch_count() == 2 && len(rb_side_rib_positions()) >= 2 && ((i % 2) == rz)) {
                        // Side extensions to ribs
                        idx = ((i == 0 || i == 1) ? 0 : len(rb_side_rib_positions()) - 1);
                        // idx is 0 for front-side, or last rib index for rear-side
                        _box_corners_extrude_linear_extension(
                            (
                                ($b_inner_length - $b_corner_radius * 2)
                                - ($b_rib_width * (2 - 1))
                            ) / 2
                            + rb_side_rib_positions()[idx] * (idx == 0 ? 1 : -1)
                        );
                    } else {
                        difference() {
                            scale([
                                (tan(15) * $b_corner_radius) / $b_corner_radius,
                                1
                            ])
                            rotate_extrude(angle=90)
                            children();
                            translate([0, 0, $b_wall_thickness])
                            linear_extrude(height=$b_outer_height)
                            square($b_corner_radius + $b_wall_thickness / 2);
                        }
                    }
                }
            }
        }
    }
}

module _box_extrude(size_offset=0) {
    width = $b_inner_width + size_offset;
    length = $b_inner_length + size_offset;
    radius = $b_corner_radius + size_offset / 2;
    // Corners
    _box_corners_extrude(width, length, radius)
    children();
    // Sides
    for (i = [0:1:len(corners_data) - 1]) {
        extrude_length = (
            (corners_data[i][0] % 180 == 0 ? width : length) - radius * 2
        );
        translate([
            corners_data[i][1] * (width - radius * 2) / 2,
            corners_data[i][2] * (length - radius * 2) / 2,
            0
        ])
        rotate([0, 0, corners_data[i][0]])
        translate([extrude_length, 0, 0])
        rotate([90, 0, -90])
        linear_extrude(height=extrude_length)
        children();
    }
}

module _box_wall_inner_chamfer_shape() {
    translate([-$b_wall_thickness, 0])
    difference() {
        translate([0, $b_wall_thickness])
        square([$b_corner_radius + $b_wall_thickness, $b_outer_height]);
        translate([0, $b_wall_thickness * 0.1])
        _box_wall_outer_chamfer_shape();
    }
}

module _box_wall_outer_chamfer_shape() {
    vertical_chamfer = $b_outer_chamfer_vertical;
    horizontal_chamfer = $b_outer_chamfer_horizontal;
    translate([
        $b_corner_radius + $b_wall_thickness - horizontal_chamfer,
        -(vertical_chamfer - min(
            vertical_chamfer,
            $b_outer_height - $b_lip_height - $b_lip_thickness * 1.5
        ))
    ])
    polygon(points=[
        [0, 0],
        [horizontal_chamfer, 0],
        [horizontal_chamfer, vertical_chamfer]
    ]);
}

module _box_wall_interior_shape() {
    translate([-$b_wall_thickness, 0])
    difference() {
        translate([0, $b_wall_thickness])
        square([$b_corner_radius + $b_wall_thickness, $b_outer_height]);
        translate([0, $b_wall_thickness * 0.1])
        _box_wall_outer_chamfer_shape();
    }
}

module _box_wall_shape(reinforced=false) {
    _round_shape($b_edge_radius)
    difference() {
        square([$b_corner_radius + $b_total_lip_thickness, $b_outer_height]);
        translate([reinforced ? $b_lip_thickness : 0, 0, 0]) {
            translate([$b_corner_radius, 0])
            polygon(points=[
                [$b_wall_thickness, $b_outer_height - $b_lip_thickness * 3.5],
                [$b_wall_thickness, 0],
                [$b_total_lip_thickness, 0],
                [$b_total_lip_thickness, $b_outer_height - $b_lip_height],
            ]);
            _box_wall_outer_chamfer_shape();
        }
        _box_wall_interior_shape();
    }
    // Square inner floor edge
    square([$b_wall_thickness * 2/3, min($b_outer_height, $b_wall_thickness)]);
}

module _box_interior_shape() {
    intersection() {
        difference() {
            translate([$b_wall_thickness / 2, -$b_wall_thickness / 2])
            _box_wall_inner_chamfer_shape();
            _box_wall_shape(reinforced=true);
        }
        translate([0, $b_wall_thickness])
        square([
            $b_corner_radius + $b_edge_radius * 2,
            $b_outer_height - $b_wall_thickness
        ]);
    }
}

module _box_center_base(height) {
    radius_inset = $b_corner_radius * 2;
    linear_extrude(height=height)
    square(
        [
            $b_inner_width - radius_inset,
            $b_inner_length - radius_inset
        ],
        center=true
    );
}

module _box_seal_shape() {
    seal_thickness = (
        $b_lip_seal_type == "filament-1.75mm"
            ? 1.75
            : $b_total_lip_thickness / 3
    );
    translate([$b_corner_radius + $b_total_lip_thickness / 2, 0]) {
        if ($b_lip_seal_type == "filament-1.75mm") {
            circle(seal_thickness / 2);
        } else if ($b_lip_seal_type == "square") {
            translate([0, -seal_thickness / 2])
            square(seal_thickness, center=true);
        } else if ($b_lip_seal_type == "wedge") {
            translate([0, -seal_thickness])
            polygon(points=[
                [-seal_thickness / 4, 0],
                [seal_thickness / 4, 0],
                [seal_thickness / 2, seal_thickness],
                [-seal_thickness / 2, seal_thickness],
            ]);
        }
    }
}

module _box_seal() {
    translate([0, 0, $b_outer_height])
    mirror([0, 0, $b_part == "top" ? 1 : 0])
    // Improve seal / lip overlap preview rendering
    translate([0, 0, $preview ? 0.01 : 0])
    scale([1, 1, $preview ? 1.01 : 1])
    _box_extrude(size_offset=$b_total_lip_thickness)
    _box_seal_shape();
}

module _box_add_seal() {
    is_seal_top_inset = (
        $b_lip_seal_type == "filament-1.75mm" ? true : false
    );
    difference() {
        union() {
            children();
            if (
                $b_lip_seal_type != "none"
                && ($b_part == "top" && !is_seal_top_inset)
            ) {
                _box_seal();
            }
        }
        if (
            $b_lip_seal_type != "none"
            && ($b_part == "bottom" || is_seal_top_inset)
        ) {
            _box_seal();
        }
    }
}

module _box_sides() {
    _box_extrude()
    _box_wall_shape();
    if ($b_reinforced_corners) {
        _box_corners_extrude(extend=true)
        _box_wall_shape(reinforced=true);
    }
}

// Box ribs

module _box_rib_angle(ang=0) {
    $br_angle = ang;
    children();
}

module _box_rib_shape(x=$b_total_lip_thickness, y=$b_rib_width) {
    x0 = $b_edge_radius;
    angle_add = tan($br_angle) * y;
    _round_shape(x0)
    for (my = [0:1:1]) {
        mirror([0, my])
        polygon(points=[
            [x0, 0],
            [x, 0],
            [x, y / 2],
            [x0, y / 2 + angle_add],
        ]);
    }
}

module _box_rib(width=$b_rib_width) {
    lip_position = $b_outer_height - $b_lip_height;
    vertical_chamfer = min(
        $b_outer_chamfer_vertical,
        max(0, lip_position - $b_lip_thickness - $b_wall_thickness)
    );
    horizontal_chamfer = vertical_chamfer * 2/3;
    // Bottom angled part
    if (vertical_chamfer > 0) {
        _hull_stack([vertical_chamfer]) {
            translate([-horizontal_chamfer, 0])
            _box_rib_shape(y=width);
            _box_rib_shape(y=width);
        }
    }
    if (lip_position > 0) {
        // Vertical rib body
        translate([0, 0, vertical_chamfer])
        linear_extrude(height=(
            $b_outer_height - vertical_chamfer - $b_edge_radius * 1.5
        ))
        _box_rib_shape(y=width);
    }
}

module _box_plain_rib() {
    _box_rib_angle(plain_ribs_angle)
    _box_rib($b_rib_width * 2);
}

module _box_ribs() {
    // Side ribs
    for (mx = [0:1:1], py = rb_side_rib_positions()) {
        mirror([mx, 0, 0])
        translate([$b_inner_width / 2, py, 0])
        _box_plain_rib();
    }
    // Rear ribs
    for (px = rb_rear_rib_positions()) {
        translate([px, $b_inner_length / 2, 0])
        rotate([0, 0, 90])
        _box_plain_rib();
    }
}

// Box attachments (latch and hinge ribs)

module _box_attachment_rib_cut(width=0) {
    translate([-$b_corner_radius, 0, 0])
    rotate([90, 0, 0])
    translate([0, 0, -width])
    linear_extrude(height=width * 2)
    difference() {
        for (mx = [0:1:1]) {
            x = ($b_corner_radius + $b_wall_thickness) * 2;
            translate([-x / 2, $b_wall_thickness])
            square([x, $b_outer_height]);
        }
        translate([0, $b_wall_thickness * 0.1])
        _box_wall_outer_chamfer_shape();
    }
    mirror([0, 0, 1])
    linear_extrude(height=$b_outer_height + 50)
    square($b_latch_width * 6, center=true);
}

module _box_attachment_rib_pair(inner=false) {
    for (mx = [0:1:1]) {
        mirror([mx, 0, 0])
        translate([inner ? 0 : $b_size_tolerance, 0])
        translate([($b_latch_width + $b_rib_width) / 2, 0, 0])
        children();
    }
}

module _box_attachment_placement() {
    latch_count = _compute_latch_count();
    latch_offset = rb_latch_hinge_position();
    translate([0, $b_inner_length / 2, 0])
    if (latch_count == 2) {
        for (mx = [0:1:1]) {
            mirror([mx, 0, 0])
            translate([latch_offset, 0, 0])
            children();
        }
    } else {
        children();
    }
}

module _box_screw_eyelet_body(width=0, angle=360) {
    rotate([90, 0, 0])
    translate([0, 0, -width / 2])
    _rounded_cylinder(width, screw_eyelet_radius, angle=angle);
}

module _box_screw_hole(width, increase_screw_diameter=false) {
    screw_radius = 1/2 * (
        increase_screw_diameter
            ? screw_hole_diameter * 1.1
            : screw_hole_diameter + screw_hole_diameter_size_tolerance
    );
    rotate([90, 0, 0])
    translate([0, 0, -width])
    cylinder(width * 2, screw_radius, screw_radius);
}

// Box latch attachments

module _box_latch_rib_base(
    width=$b_rib_width,
    latch_position=_latch_offset_from_base()
) {
    _box_rib();
    difference() {
        intersection() {
            translate([-$b_corner_radius, -width / 2, 0])
            cube([
                $b_corner_radius + $b_latch_screw_offset * 4,
                width,
                $b_outer_height
            ]);
            hull() {
                difference() {
                    latch_attachment_height = (
                        screw_eyelet_radius * 6 + $b_corner_radius * 2
                    );
                    translate([
                        -$b_corner_radius,
                        0,
                        latch_position - latch_attachment_height / 2
                    ])
                    _hull_stack([latch_attachment_height]) {
                        _box_rib_shape();
                        _box_rib_shape();
                    }
                }
                translate([0, 0, latch_position])
                translate([$b_latch_screw_offset, 0, 0])
                for (mz = [0:1:1]) {
                    mirror([0, 0, mz])
                    translate([0, 0, screw_eyelet_radius / 2])
                    _box_screw_eyelet_body(width);
                }
            }
        }
        _box_attachment_rib_cut(width);
    }
}

module _box_latch_rib() {
    rotate([0, 0, 90])
    difference() {
        _box_latch_rib_base();
        // Screw hole
        translate([$b_latch_screw_offset, 0, 0])
        translate([0, 0, _latch_offset_from_base()])
        _box_screw_hole(width=$b_rib_width);
    }
}

module _box_latch_ribs() {
    mirror([0, 1, 0])
    _box_attachment_placement()
    _box_attachment_rib_pair()
    _box_latch_rib();
}

// Box stacking latch attachments

module _box_stacking_latch_rib() {
    sep_positions = [
        for(seps=[
            [$b_latch_screw_separation * 0.5],
            ($b_outer_height > $b_latch_screw_separation * 2)
                ? [
                    $b_latch_screw_separation * 1.5
                    + stacking_latch_catch_offset
                ]
                : []

        ], pos=seps) pos
    ];
    rotate([0, 0, 90])
    difference() {
        union() {
            for (sep = sep_positions)
            _box_latch_rib_base(latch_position=sep);
            hull()
            for (sep = sep_positions)
            translate([0, 0, sep])
            translate([$b_latch_screw_offset, 0, 0])
            _box_screw_eyelet_body($b_rib_width);
        }
        // Screw hole
        for (sep = sep_positions)
        translate([$b_latch_screw_offset, 0, 0])
        translate([0, 0, sep])
        _box_screw_hole(width=$b_rib_width);
    }
}

module _box_stacking_latch_ribs_placement() {
    for (mx = [0:1:1])
    mirror([mx, 0, 0])
    for (py = rb_stacking_latch_positions()) {
        translate([$b_inner_width / 2, py, 0])
        rotate([0, 0, 90])
        children();
    }
}

module _box_stacking_latch_ribs() {
    _box_stacking_latch_ribs_placement()
    mirror([0, 1, 0])
    _box_attachment_rib_pair()
    _box_stacking_latch_rib();
}

// Box hinge attachments

module _box_hinge_rib_body(width=0, inner=false) {
    rib_hull_height = (
        screw_eyelet_radius * (inner ? 2 : 3)
        + 2 * ($b_wall_thickness + $b_rib_width)
        + $b_corner_radius * 1.5
    );
    difference() {
        translate([0, 0, $b_outer_height]) {
            hull() {
                mirror([0, 0, 1])
                linear_extrude(height=rib_hull_height)
                translate([-$b_corner_radius - $b_wall_thickness, 0])
                _box_rib_shape(x=$b_wall_thickness, y=width);
                if (!inner) {
                    translate([0, 0, -screw_eyelet_radius])
                    _box_hinge_screw_eyelet_body(width, angle=-180);
                }
                _box_hinge_screw_eyelet_body(width, angle=-180);
            }
            _box_hinge_screw_eyelet_body(width, angle=360);
        }
        _box_attachment_rib_cut(width);
    }
}

module _box_hinge_screw_eyelet_body(width=0, angle=360) {
    translate([$b_hinge_screw_offset, 0, 0])
    _box_screw_eyelet_body(width, angle);
}

module _box_hinge_ribs_top() {
    hinge_rib_width = $b_rib_width * 2;
    if ($b_latch_width - $b_rib_width * 2 - hinge_rib_width > 0) {
        _box_attachment_rib_pair(inner=true)
        rotate([0, 0, 90])
        translate([0, hinge_rib_width, 0]) {
            _box_hinge_rib_body($b_rib_width);
            _box_rib();
        }
        // Solid hinge middle
        rotate([0, 0, 90])
        _box_hinge_rib_body($b_latch_width - hinge_rib_width, inner=true);
    } else {
        // Single module hinge
        remaining_width = $b_latch_width - hinge_rib_width;
        assert(remaining_width > 0, "No width available for top hinge");
        rotate([0, 0, 90]) {
            _box_rib(remaining_width);
            _box_hinge_rib_body(remaining_width);
        }
    }
}

module _box_hinge_rib_bottom(width=0) {
    translate([-$b_rib_width / 2, 0, 0])
    rotate([0, 0, 90]) {
        _box_rib(width);
        _box_hinge_rib_body(width);
    }
}

module _box_hinge_ribs() {
    _box_attachment_placement()
    difference() {
        union() {
            if ($b_part == "bottom") {
                _box_attachment_rib_pair()
                _box_hinge_rib_bottom(width=$b_rib_width * 2);
            } else if ($b_part == "top") {
                _box_hinge_ribs_top();
            }
        }
        // Screw hole
        rotate([0, 0, 90])
        translate([$b_hinge_screw_offset, 0, $b_outer_height])
        _box_screw_hole(
            $b_latch_width,
            increase_screw_diameter = ($b_part == "top" ? true : false)
        );
    }
}

module _box_top_grip_shape() {
    outset = (
        $b_lip_thickness - $b_wall_thickness - $b_edge_radius + top_grip_depth
    );
    polygon(points=[
        [
            -$b_edge_radius,
            max($b_outer_height - outset * 3.5, $b_outer_chamfer_vertical)
        ],
        [$b_wall_thickness + outset, $b_outer_height],
        [-$b_edge_radius, $b_outer_height],
    ]);
}

module _box_top_grip() {
    if ($b_top_grip && $b_part == "top" && _compute_latch_count() == 2) {
        lip_position = $b_corner_radius + $b_total_lip_thickness - $b_lip_thickness - $b_edge_radius;
        latch_offset = rb_latch_hinge_position();
        grip_half_length = min(
            top_grip_width / 2, latch_offset - ($b_latch_width / 2) - $b_rib_width
        );
        end_caps_visible = (
            latch_offset - ($b_latch_width + $b_rib_width) / 2
            > top_grip_width / 2 + 2 * $b_lip_thickness
        );
        render(convexity=2)
        mirror([0, 1, 0])
        translate([0, $b_inner_length / 2 - $b_corner_radius, 0])
        rotate([90, 0, 90])
        for (mz = [0:1:1])
        mirror([0, 0, mz])
        translate([lip_position, 0]) {
            // Grip
            linear_extrude(height=grip_half_length)
            _round_shape($b_edge_radius)
            _box_top_grip_shape();
            // End caps
            translate([0, 0, grip_half_length])
            translate([-$b_edge_radius, 0, 0])
            scale([1, 1, end_caps_visible ? 1 : ($b_rib_width / top_grip_depth / 2)])
            rotate([270, 270, 0])
            rotate_extrude(angle=90)
            translate([$b_edge_radius, 0])
            _round_shape($b_edge_radius)
            _box_top_grip_shape();
        }
    }
}

// Latches

module _latch_shape() {
    bw = screw_eyelet_radius - screw_hole_diameter / 2;
    shd = screw_hole_diameter + screw_hole_diameter_size_tolerance;
    _round_shape($b_edge_radius)
    difference() {
        union() {
            // Catch eyelets
            translate([0, $b_latch_screw_separation])
            circle(r=screw_eyelet_radius);
            // Hinge eyelet and main body
            hull() {
                circle(r=screw_eyelet_radius);
                translate([-screw_eyelet_radius, 0])
                square([bw, $b_latch_screw_separation]);
            }
            translate([-screw_eyelet_radius, 0])
            square([bw, $b_latch_screw_separation + screw_eyelet_radius * 2.5]);
        }
        // Hinge hole
        circle(d=shd);
        // Catch hole
        translate([0, $b_latch_screw_separation])
        hull()
        union() {
            circle(d=shd);
            translate([
                screw_eyelet_radius + bw / 1.6,
                -$b_latch_screw_separation
            ])
            circle(d=shd);
            translate([(shd + bw) * 2, -(shd + bw)])
            circle(d=shd);
        }
    }
}

module _latch_part() {
    color("mintcream", 0.8)
    union() {
        rr = 0.8;
        _chamfer_edges(r=rr)
        union() {
            rotate([90, 0, 0])
            linear_extrude(height=$b_latch_width, center=true)
            offset(r=-rr / 2)
            _latch_shape();
        }
    }
}

module _latch(placement="default") {
    if (placement == "print") {
        rotate([90, 0, 0])
        _latch_part();
    } else if (placement == "box-preview") {
        rotate([0, 0, 270])
        _latch_part();
    } else {
        _latch_part();
    }
}

// Stacking latches

module _stacking_latch_shape() {
    bw = screw_eyelet_radius - screw_hole_diameter / 2;
    slcatch = $b_latch_screw_separation + stacking_latch_catch_offset;
    shd = screw_hole_diameter + screw_hole_diameter_size_tolerance;
    _round_shape($b_edge_radius)
    difference() {
        union() {
            // Catch eyelets
            _hull_in_order() {
                translate([0, $b_latch_screw_separation])
                circle(r=screw_eyelet_radius);
                translate([0, slcatch])
                circle(r=screw_eyelet_radius);
                translate([
                    0,
                    slcatch + stacking_latch_grip_length + bw / 2
                ])
                circle(d=bw);
            }
            // Hinge eyelet and main body
            hull() {
                circle(r=screw_eyelet_radius);
                translate([-screw_eyelet_radius, 0])
                square([bw, $b_latch_screw_separation]);
            }
        }
        // Hinge hole
        circle(d=shd);
        // Catch hole
        translate([0, $b_latch_screw_separation])
        hull()
        union() {
            circle(d=shd);
            translate([
                screw_eyelet_radius + bw / 1.6,
                -$b_latch_screw_separation
            ])
            circle(d=shd);
            translate([(shd + bw) * 2, -(shd + bw)])
            circle(d=shd);
        }
        // Stacking catch
        translate([0, slcatch])
        hull()
        union() {
            circle(d=shd);
            translate([-(shd + bw) * 2, -(shd + bw) * 0.75])
            circle(d=shd);
            translate([-(shd + bw) * 2, -(shd + bw)])
            circle(d=shd);
        }
    }
}

module _stacking_latch_part() {
    color("mintcream", 0.8)
    union() {
        rr = 0.8;
        _chamfer_edges(r=rr)
        union() {
            rotate([90, 0, 0])
            linear_extrude(height=$b_latch_width, center=true)
            offset(r=-rr / 2)
            _stacking_latch_shape();
        }
    }
}

module _stacking_latch(placement="default") {
    if (placement == "print") {
        rotate([90, 0, 0])
        _stacking_latch_part();
    } else if (placement == "box-preview") {
        rotate([180, 0, 90])
        _stacking_latch_part();
    } else {
        _stacking_latch_part();
    }
}

// Handle

module _handle_part() {
    width = (
        rb_latch_hinge_position() * 2
        - ($b_latch_width + ($b_rib_width + $b_size_tolerance) * 2)
    );
    height = min(
        handle_max_height,
        _latch_offset_from_base() - handle_thickness - 2
    );
    thick = handle_thickness;
    radius = handle_radius;
    // Ensure minimum size
    if (_compute_latch_count() == 2 && width > ((thick + radius) * 2 * 1.75))
    if (height >= handle_min_height)
    color("mintcream", 0.8)
    render(convexity=2)
    difference() {
        union() {
            // Sides
            for (mx = [0:1:1])
            mirror([mx, 0, 0])
            translate([(width - thick) / 2, 0, 0])
            union() {
                rotate([90, 0, 0])
                linear_extrude(height=height - radius)
                _rounded_square([thick, thick], $b_edge_radius, center=true);
                rotate([0, 90, 0])
                _rounded_cylinder(h=thick, r1=thick / 2, center=true);
            }
            // Grip
            translate([0, -(thick / 2 + height), 0])
            union() {
                rotate([0, 90, 0])
                linear_extrude(height=width - (thick + radius) * 2, center=true)
                _rounded_square([thick, thick], $b_edge_radius, center=true);
            }
            // Corners
            union() {
                for (mx = [0:1:1])
                mirror([mx, 0, 0])
                translate([width / 2 - thick - radius, -height + radius, 0])
                rotate(270)
                rotate_extrude(angle=90)
                translate([radius, -thick / 2])
                _rounded_square([thick, thick], $b_edge_radius);
            }
        }
        // Screw holes
        for (mx = [0:1:1])
        mirror([mx, 0, 0])
        translate([width / 2, 0, 0])
        rotate([0, 0, 90])
        _box_screw_hole(thick * 4 , increase_screw_diameter=true);
    }
}

module _handle(placement="default") {
    if (placement == "print") {
        _handle_part();
    } else if (placement == "box-preview" || placement == "box-preview-open") {
        translate([0, -$b_outer_length / 2, 0])
        translate([0, -$b_latch_screw_offset / 2, 0])
        translate([0, 0, _latch_offset_from_base()])
        rotate([(placement == "box-preview") ? 90 : 0, 0, 0])
        _handle_part();
    } else {
        _handle_part();
    }
}
