/*
 * Bosch Custom Case clips and accessories
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Slots and Rows] */

Slots = 9; // [0:1:9]

Rows = 1; // [1: One, 2: Two]

// Bottom row slot type
Row_1_Slot_Type = "quick-change"; // [quick-change: Quick change bits, driver: Screwdriver insert bits, blank: Blank, custom: Custom -- fill in row_1_custom_slots in .scad file]

// Top row slot type (only if Rows is 2)
Row_2_Slot_Type = "driver"; // [quick-change: Quick change bits, driver: Screwdriver insert bits, blank: Blank, custom: Custom -- fill in row_2_custom_slots in .scad file]

// Optionally flip bit slots to face downward.
Slot_Orientation = "default"; // [default: Default, flipped: Flipped]

/* [Channel] */

Channel_Slots = 0; // [0:1:9]
Channel_Side = "right"; // [left: Left, right: Right]

/* [Options] */

Quick_Change_Grip = true;

module __end_customizer_options__() { }

// Constants //

// 5, 3, 5.5

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

wall_thickness = 1.6;

insert_x = 73.5;
insert_y = 24;
insert_z = 13;
insert_radius = 1;
insert_row_add_y = insert_y - wall_thickness * 7;
insert_row_add_z = insert_z * 0.65;

clip_fitting_x = 4;
clip_fitting_y = 18.6;
clip_fitting_z = 13;
clip_fitting_inner_x = 2;
clip_fitting_inner_y = 13;
clip_lip_z = 2;

left_tab_y = 11.5;
left_tab_diameter = 4;

bit_diagonal_short = 6.5;
bit_diagonal_long = (bit_diagonal_short * 2) / sqrt(3);
bit_separation = ((insert_x - Slots * bit_diagonal_short) / (Slots + 1));

bit_rest_grip_diameter = 0.5;

bit_slot_quick_change_grip_x = 0.5;
bit_slot_quick_change_grip_y = 3.5;

// Functions //

/*
 * Add an array of [count, type] for each set of bit slots to add to Row 1
 *
 * Example:
 *
 *    [4, "quick-change"],
 *    [5, "driver"],
 *
 * creates a row with 4 quick change bit slots and 5 driver bit slots, left to
 * right.
 */
function row_1_custom_slots() = [
];

/*
 * Add an array of [count, type] for each set of bit slots to add to Row 2
 *
 * See row_1_custom_slots() documentation for example
 */
function row_2_custom_slots() = [
];

function bit_slots_for_row(row=1) = (
    let (slot_type = (row == 1) ? Row_1_Slot_Type : Row_2_Slot_Type)
    let (custom_slots = (
        (slot_type == "custom")
            ? (row == 1 ? row_1_custom_slots() : row_2_custom_slots())
            : false)
    )
    custom_slots
        ? custom_slots
        : (
            (Channel_Side == "left")
                ? [[Channel_Slots, "blank"], [Slots - Channel_Slots, slot_type]]
                : [[Slots - Channel_Slots, slot_type], [Channel_Slots, "blank"]]
        )
);

function cut_blank_side_left() = (
    let (row_1_slots = bit_slots_for_row(1))
    let (row_2_slots = bit_slots_for_row(2))
    (Row_2_Slot_Type == "custom")
        ? (
            (row_1_slots[0][1] == "blank")
            || (row_2_slots[0][1] == "blank")
        )
        : (Channel_Slots > 0 && Channel_Side == "left")
);

function cut_blank_side_right() = (
    let (row_1_slots = bit_slots_for_row(1))
    let (row_2_slots = bit_slots_for_row(2))
    (Row_2_Slot_Type == "custom")
        ? (
            (row_1_slots[len(row_1_slots) - 1][1] == "blank")
            || (row_2_slots[len(row_2_slots) - 1][1] == "blank")
        )
        : (Channel_Slots > 0 && Channel_Side == "right")
);


function bit_slot_row_y_offset(row=1) = (
    insert_row_add_y * ((Slot_Orientation == "flipped") ? row - 1 : Rows - row)
);

function cumulative_sum(v) = [
    for (
        now_sum = v[0], i = 1;
        i <= len(v);
        next_sum = (i == len(v) ? 0 : now_sum + v[i]),
            ni = i + 1, now_sum = next_sum, i = ni
    )
    now_sum
];

// Modules //

module rounded_square(dimensions, radius) {
    offset(radius)
    offset(-radius)
    square(dimensions);
}

module insert_body() {
    translate([
        0,
        (
            (Slot_Orientation == "flipped")
                ? (insert_y + insert_row_add_y * (Rows - 1))
                : 0
        ),
        0
    ])
    mirror([0, (Slot_Orientation == "flipped") ? 1 : 0, 0])
    mirror([1, 0, 0])
    rotate([0, -90, 0])
    linear_extrude(height=insert_x)
    offset(insert_radius)
    offset(-insert_radius * 2)
    offset(insert_radius)
    difference() {
        for (row = [1:1:Rows]) {
            translate([insert_row_add_z * (row - 1), 0])
            square([insert_z, insert_y + insert_row_add_y * (Rows - row)]);
        }
        // Shorten top of multi-row inserts a tad for better fit
        if (Rows > 1) {
            color("red", 0.5)
            translate([
                (
                    insert_z
                    + insert_row_add_z * (Rows - 1)
                    - bit_diagonal_long * 0.18
                ),
                0
            ])
            square([insert_z, insert_y]);
        }
    }
}

module insert_left_tab() {
    translate([-left_tab_diameter, (insert_y + left_tab_y) / 2, 0])
    translate([0, 0, left_tab_diameter / 2])
    rotate([0, -90, 90]) {
        translate([0, -left_tab_diameter / 2, 0])
        rotate_extrude(angle=180)
        difference() {
            translate([-left_tab_diameter / 2, 0])
            rounded_square([left_tab_diameter, left_tab_y], insert_radius / 2);
            mirror([1, 0])
            square([left_tab_diameter, left_tab_y * 2]);
        }
        rotate([0, 90, -90])
        translate([-left_tab_y, -left_tab_diameter / 2, left_tab_diameter / 2])
        linear_extrude(height=left_tab_diameter / 2)
        rounded_square([left_tab_y, left_tab_diameter], insert_radius / 2);
    }
}

module insert_clip_fitting() {
    render()
    translate([insert_x, (insert_y - clip_fitting_y) / 2, 0])
    difference() {
        linear_extrude(height=clip_fitting_z)
        translate([-wall_thickness / 2, 0])
        rounded_square(
            [clip_fitting_x + wall_thickness / 2, clip_fitting_y],
            insert_radius / 4
        );
        translate([0, (clip_fitting_y - clip_fitting_inner_y) / 2, 0]) {
            translate([0, 0, -clip_lip_z])
            hull() {
                linear_extrude(height=clip_fitting_z - clip_lip_z)
                rounded_square(
                    [clip_fitting_x, clip_fitting_inner_y],
                    insert_radius / 4
                );
                linear_extrude(height=clip_fitting_z)
                translate([clip_fitting_x - clip_fitting_inner_x, 0])
                rounded_square(
                    [clip_fitting_inner_x, clip_fitting_inner_y],
                    insert_radius / 4
                );
            }
            translate([0, 0, -clip_fitting_z / 2])
            linear_extrude(height=clip_fitting_z * 2)
            translate([clip_fitting_x - clip_fitting_inner_x, 0])
            offset(-insert_radius / 4)
            offset(insert_radius / 4)
            union() {
                square([clip_fitting_inner_x * 2, clip_fitting_inner_y]);
                translate([clip_fitting_inner_x, -clip_fitting_inner_y / 2])
                square([clip_fitting_inner_x * 2, clip_fitting_inner_y * 2]);
            }
        }
    }
}

module bit_slot_bit_rest() {
    translate([0, 0, insert_z - bit_diagonal_long / 2]) {
        translate([0, bit_diagonal_long / 2, 0])
        linear_extrude(height=insert_z)
        translate([-bit_diagonal_short / 2, 0])
        square([bit_diagonal_short, insert_y]);
        rotate([0, 90, 90])
        linear_extrude(height=insert_y)
        circle(bit_diagonal_long / 2, $fn=6);
    }
}

module bit_slot_bit_grip() {
    foot_height = (insert_y - bit_diagonal_long * 2.25) + Rows * insert_z;
    translate([0, 0, wall_thickness])
    linear_extrude(height=insert_y)
    translate([0, bit_diagonal_long / 2 + wall_thickness, wall_thickness])
    rotate([0, 0, 90])
    circle(bit_diagonal_long / 2, $fn=6);
    translate([0, 0, -(Rows * insert_z + 0.1)])
    linear_extrude(height=foot_height + 0.1)
    translate([-bit_diagonal_short / 2, 0])
    difference() {
        square([bit_diagonal_short, bit_diagonal_long / 2]);
        translate([
            bit_diagonal_short / 2,
            bit_diagonal_long / 2 + wall_thickness
        ])
        rotate([0, 0, 90])
        circle(bit_diagonal_long / 2, $fn=6);
    }
}

module bit_slot_quick_change_grip() {
    translate([
        0,
        bit_diagonal_long + bit_diagonal_short / 4 + 0.5,
        insert_z - bit_diagonal_short / 2 * 1.5 - bit_diagonal_long / 4
    ])
    for (mx = [0:1]) {
        mirror([mx, 0, 0])
        translate([-bit_diagonal_short / 2, 0, 0])
        translate([0, 0, bit_slot_quick_change_grip_y / 2])
        scale([
            bit_slot_quick_change_grip_x / (bit_slot_quick_change_grip_y / 2),
            1
        ])
        rotate([0, 0, -90])
        rotate_extrude(angle=180)
        difference() {
            circle(bit_slot_quick_change_grip_y / 2);
            translate([
                -bit_slot_quick_change_grip_y * 2,
                -bit_slot_quick_change_grip_y
            ])
            square(bit_slot_quick_change_grip_y * 2);
        }
    }
}

module bit_slot_bit_rest_grip() {
    translate([
        0,
        bit_diagonal_long * 1.25,
        insert_z - bit_diagonal_long / 4 + bit_rest_grip_diameter / 2
    ])
    rotate([-90, 0, 0])
    linear_extrude(height=insert_y)
    for (mx = [0:1:1]) {
        mirror([mx, 0])
        translate([bit_diagonal_short / 2, 0])
        circle(bit_rest_grip_diameter / 2, $fn=20);
    }
}

module bit_slot_base() {
    difference() {
        union() {
            translate([0, 0, -bit_diagonal_long / 4])
            bit_slot_bit_rest();
            bit_slot_bit_grip();
        }
        translate([0, 0, -bit_diagonal_long / 4])
        bit_slot_bit_rest_grip();
    }
}

module bit_slot_driver_wall_cut() {
    stacked_row_y_offset = (
        insert_row_add_y
        + wall_thickness
        - bit_diagonal_long * 1.75
        );
    stacked_row_z_offset = ($s_row == Rows ? -bit_diagonal_long / 8 : 0);
    translate([
        (
            bit_diagonal_short / 2
            + ($s_bit_separation + bit_slot_quick_change_grip_x)
        ),
        bit_diagonal_long * 2,
        insert_z - bit_diagonal_long
    ])
    rotate([0, -90, 0])
    linear_extrude(height=(
        bit_diagonal_short
        + ($s_bit_separation + bit_slot_quick_change_grip_x) * 2 + 0.01
    ))
    offset(-insert_radius)
    offset(insert_radius * 2)
    offset(-insert_radius)
    translate([$s_row > 1 ? stacked_row_z_offset : 0, 0])
    difference() {
        union() {
            square([insert_z, insert_y]);
            translate([$s_row > 1 ? stacked_row_z_offset / 2 : 0, 0])
            translate([bit_diagonal_long, -insert_radius * 2])
            square([insert_z, insert_y + insert_radius * 2]);
        }
        if ($s_row > 1) {
            curve_cut_len = stacked_row_y_offset * 1.7;
            polygon(points=[[0, 0], [curve_cut_len, 0], [0, curve_cut_len]]);
        }
    }
}

module bit_slot_driver() {
    bit_slot_base();
    bit_slot_driver_wall_cut();
}

module bit_slot_quick_change() {
    difference() {
        bit_slot_base();
        if (Quick_Change_Grip) {
            bit_slot_quick_change_grip();
        }
    }
}

module bit_slot_blank() {
    cut_x = (!$s_first ? $s_bit_separation : 0) + 0.01;
    square_y = (insert_y + Rows * insert_row_add_y);
    translate([0, 0, wall_thickness * 2])
    linear_extrude(height=insert_z * (Rows + 1))
    translate([-bit_diagonal_short / 2 - cut_x, -square_y / 2])
    square([
        bit_diagonal_short + cut_x,
        (insert_y + Rows * insert_row_add_y) * 2]
    );
}

module bit_slot(type=Row_1_Slot_Type) {
    bit_slot_orientation()
    translate([bit_diagonal_short / 2, wall_thickness, 0])
    if (type == "quick-change") {
        bit_slot_quick_change();
    } else if (type == "driver") {
        bit_slot_driver();
    } else if (type == "blank") {
        bit_slot_blank();
    }
}

module bit_slot_orientation() {
    if (Slot_Orientation == "flipped") {
        translate([0, insert_y, 0])
        mirror([0, 1, 0])
        children();
    } else {
        children();
    }
}

module insert_bit_slots_group(span=Slots, type=Row_1_Slot_Type) {
    for (i = [1:$s_span]) {
        $s_first = (i == 1);
        translate([($s_bit_separation + bit_diagonal_short) * (i - 1), 0, 0])
        bit_slot(type=type);
    }
}

module insert_bit_slots(row=1) {
    $s_row = row;
    bit_slots = bit_slots_for_row(row);
    spanstotal = cumulative_sum(bit_slots);
    slots = spanstotal[len(spanstotal)-1][0];
    $s_bit_separation = ((insert_x - slots * bit_diagonal_short) / (slots + 1));
    slots_width = (
        $s_bit_separation + slots * ($s_bit_separation + bit_diagonal_short)
    );
    translate([max(0, (insert_x - slots_width) / 2), 0, 0])
    translate([$s_bit_separation, 0, 0])
    for (i = [0:1:len(bit_slots)-1]) {
        $s_span = bit_slots[i][0];
        if ($s_span > 0) {
            translate([(
                i > 0
                    ? spanstotal[i-1][0]
                    : 0
            ) * ($s_bit_separation + bit_diagonal_short), 0, 0])
            insert_bit_slots_group(span=bit_slots[i][0], type=bit_slots[i][1]);
        }
    }
}

module insert_bit_rows() {
    for (row = [1:Rows]) {
        translate([0, bit_slot_row_y_offset(row), insert_row_add_z * (row - 1)])
        insert_bit_slots(row=row);
    }
}

module custom_case_bits_insert(bit_slots=[[Slots, Row_1_Slot_Type]]) {
    difference() {
        color("crimson", 1.0)
        render(convexity=2)
        insert_body();
        color("crimson", 0.5)
        insert_bit_rows();
        color("crimson", 1.0)
        for (cuts = [
            ["left", cut_blank_side_left()],
            ["right", cut_blank_side_right()],
        ]) {
            side = cuts[0];
            enabled = cuts[1];
            if (enabled) {
                translate([
                    (side == "right") ? insert_x - wall_thickness : 0, 0, 0
                ])
                translate([-wall_thickness / 2, -0.01, insert_z])
                linear_extrude(height = insert_z * Rows)
                square([wall_thickness * 2, insert_y * Rows]);
            }
        }
    }
    color("crimson", 0.8)
    translate([
        0,
        (Slot_Orientation == "flipped") ? (Rows - 1) * insert_row_add_y : 0,
        0
    ]) {
        insert_clip_fitting();
        insert_left_tab();
    }
}

module main() {
    translate([left_tab_diameter, 0, 0])
    custom_case_bits_insert();
}

main();
