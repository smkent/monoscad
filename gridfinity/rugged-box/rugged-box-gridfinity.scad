/*
 * Gridfinity Rugged Storage Box, Parametric and Customizable
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <rugged-box-library.scad>;
include <gridfinity-rebuilt-openscad/standard.scad>;
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-baseplate.scad>;
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>;

/* [Rendering] */
// Part selection. Note: Assembled box previews show latches without chamfers for performance reasons.
Part = "assembled_open"; // ["bottom": Bottom, "top": Top, "latch": Latch, "stacking_latch": Stacking latch, "handle": Handle, "label": Label, "side-by-side": Top and Bottom side-by-side, "assembled_open": Assembled open, "assembled_closed": Assembled closed, "bottom_modifier": Bottom print modifier volume for attachment ribs, "top_modifier": Top print modifier volume for attachment ribs, "top_grid_modifier": Top print modifier volume for Gridfinity lid]

/* [Dimensions] */
// Interior side-to-side size in 42mm Gridfinity units
Width = 4; // [1:1:10]

// Interior front-to-back size in 42mm Gridfinity units
Length = 2; // [1:1:10]

// Interior bottom height in 7mm Gridfinity units
Bottom_Height = 7; // [1:1:30]

// Interior top height in 7mm Gridfinity units
Top_Height = 2; // [1:1:10]

/* [Gridfinity Features] */
Gridfinity_Base_Style = "minimal"; // [minimal: No magnet holes with minimal thickness, thick: No magnet holes but with magnet hole base thickness, enabled: Magnet holes with skeletonized baseplate, enabled_full: Magnet holes with filled baseplate]

// Add Gridfinity base stacking plates to outside of box top and bottom. Requires supports to print.
Gridfinity_Stackable = true;

/* [Features] */
// Type or shape of seal to use, if desired
Lip_Seal_Type = "wedge"; // [none: None, wedge: Wedge ▽, square: Square □, "filament-1.75mm": 1.75mm Filament ○]

// Make the corners as thick as the box lip
Reinforced_Corners = true;

// Add a front grip to the box top (for boxes with two latches)
Top_Grip = true;

// Add end stops to the hinges on the box bottom
Hinge_End_Stops = true;

// Add stacking latches and attachment points to the sides of the box
Stacking_Latches = true;

// Latch style
Latch_Type = "draw"; // [clip: Clip, draw: Draw]

// Add a third hinge for boxes 5U or wider
Third_Hinge = true;

// Optional handle for sufficiently wide boxes
Handle = true;

// Optional label for sufficiently wide boxes
Label = true;

// Custom text for optional label
Label_Text = "Label";

// Approximate height of text for optional label in millimeters
Label_Text_Size = 10; // [5:0.1:25]

/* [Advanced Size Adjustments] */
// Base wall thickness in millimeters for most of the box
Wall_Thickness = 3.0; // [2.4:0.1:10]

// Thickness in millimeters to add to the wall thickness for the box lip
Lip_Thickness = 3.0; // [0.4:0.1:10]

// Base thickness in millimeters of the support ribs. The latch ribs are this thick, while the hinge and side ribs are twice this thick.
Rib_Width = 6; // [1:0.1:20]

// Latch width in millimeters
Latch_Width = 28; // [5:1:50]

// Distance in millimeters between the latch hinge and catch screws which determines the latch vertical size
Latch_Screw_Separation = 16; // [5:1:40]

// Width in millimeters subtracted from latches for fit
Size_Tolerance = 0.20; // [0:0.01:1]

module __end_customizer_options__() { }

// Constants

edge_chamfer_proportion = 0.95;

border = 5;
gridfinity_height_increment = 7;

width = Width * l_grid + border;
length = Length * l_grid + border;
bottom_height = (
    Bottom_Height * gridfinity_height_increment
    + gridfinity_base_extra_height(hole=true)
);
top_height = Top_Height * gridfinity_height_increment + h_lip;

corner_radius = r_base;

stackable_plate_offset = 3.4;
stackable_top_plate_offset = -0.8;
stackable_bottom_base_offset = -0.6;
top_base_offset = -(h_base - h_lip);

stacking_separation = Gridfinity_Stackable ? 1.6 : 0;

// Library overrides

function rb_color(part) = (part == "top" ? "LightSteelBlue" : "SteelBlue");

function rb_side_rib_positions() = [
    for (j = [for (i = [0:1:Length - 1]) i * l_grid])
    j - (l_grid * (Length / 2 - 0.5))
];

function rb_rear_rib_positions() = [
    for (j = [for (i = [1:1:Width - 2]) i * l_grid])
    j - (l_grid * (Width / 2 - 0.5))
];

function rb_latch_hinge_position() = (l_grid * (Width / 2 - 0.5));

function rb_stacking_latch_positions() = (
    Stacking_Latches
    ? [
        let (points = [
            each for (j = [
                for (i = [0:2:Length / 2 - 1]) i
            ]) (j == Length - 2 - j) ? [j] : [j, Length - 2 - j]
        ])
        for (j = [for (i = points) (i + 0.5) * l_grid])
        j - (l_grid * (Length / 2 - 0.5))
    ]
    : []
);

// Functions

function gridfinity_base_plate_magnets_enabled() = (
    (Gridfinity_Base_Style != "minimal" && Gridfinity_Base_Style != "thick")
);

function gridfinity_base_plate_magnet_height() = (Gridfinity_Base_Style != "minimal");

function gridfinity_base_plate_style() = (
    Gridfinity_Base_Style == "minimal"
        ? 0
        : Gridfinity_Base_Style == "thick"
            ? 1
            : Gridfinity_Base_Style == "enabled"
                // Use full plate instead of skeletonized for stackable top baseplate
                ? ($b_part == "top" ? 1 : 2)
                : Gridfinity_Base_Style == "enabled_full"
                    ? 1
                    : 0
);

function gridfinity_base_extra_height(hole) = (
    gridfinity_base_plate_magnet_height() ? (hole ? h_hole : 0) : 0
);

// Modules

module gridfinity_rectangle(adjust=0, height=h_base * 2) {
    rounded_rectangle(width + adjust, length + adjust, height, r_base);
}

module gridfinity_baseplate(expand=false) {
    extra_depth = gridfinity_base_extra_height(hole=true);
    render(convexity=4)
    intersection() {
        linear_extrude(height=l_grid + extra_depth)
        square([(Width + 1) * l_grid, (Length + 1) * l_grid], center=true);
        translate([0, 0, extra_depth])
        gridfinityBaseplate(
            Width,
            Length,
            l_grid,
            expand ? ((Width + 1) * l_grid) : 0,
            expand ? ((Length + 1) * l_grid) : 0,
            gridfinity_base_plate_style(),
            gridfinity_base_plate_magnets_enabled(),
            0,
            0,
            0
        );
    }
}

module gridfinity_base(w=Width, l=Length, hole=false, off=0) {
    gridfinityBase(w, l, l_grid, 0, 0, hole ? 1 : 0, off=off);
}

module gridfinity_bottom_base(hole=false) {
    intersection() {
        translate([0, 0, h_base])
        mirror([0, 0, 1])
        gridfinity_base(hole=hole);
        gridfinity_rectangle(adjust=1.6);
    }
}

module rbox_interior_base(height = h_base * 2) {
    intersection() {
        rbox_interior(cut_height=height);
        rbox_for_interior()
        linear_extrude(height=height)
        square([width * 2, length * 2], center=true);
    }
}

module gridfinity_baseplate_cut() {
    render()
    difference() {
        rbox_interior_base();
        rbox_for_interior()
        gridfinity_baseplate(expand=true);
    }
}

module custom_bottom() {
    render()
    if (Gridfinity_Stackable) {
        difference() {
            union() {
                rbox_body();
                rbox_for_interior()
                gridfinity_rectangle(
                    height=9 - stackable_plate_offset,
                    adjust=$b_wall_thickness / 2
                );
                mirror([0, 0, 1])
                gridfinity_bottom_base(
                    hole=gridfinity_base_plate_magnets_enabled()
                );
            }
            translate([0, 0, -stackable_plate_offset])
            gridfinity_baseplate_cut();
        }
    } else {
        rbox_body();
        rbox_for_interior() {
            gridfinity_baseplate();
        }
    }
}

module gridfinity_top_base_strip(i) {
    module _strip() {
        gridfinity_base(l=1, off=-0.2);
    }

    trim = (i >= (Length - 1) / 2 ? 3 : 1);
    if (trim > 0) {
        for (hx = [-1, 1])
        translate([0, hx == 1 ? -trim : 0, 0])
        intersection() {
            _strip();
            translate([0, hx * l_grid / 2, 0])
            cube([l_grid * (Width + 1), l_grid, l_grid], center=true);
        }
    } else {
        _strip();
    }
}

module gridfinity_top_base() {
    rbox_for_interior()
    intersection() {
        translate([0, 0, top_base_offset])
        translate([0, 0, h_base])
        mirror([0, 0, 1])
        for (i = [0:1:Length - 1])
        translate([0, (i - Length / 2 + 0.5) * l_grid, 0])
        gridfinity_top_base_strip(i);
        linear_extrude(height=h_base * 2)
        square([width + 1.6, length + 1.6], center=true);
    }
}

module custom_top_interior_grid(interior_base=true) {
    if (Gridfinity_Stackable) {
        if (interior_base) {
            rbox_interior_base(height=stackable_plate_offset);
        }
        translate([0, 0, stackable_plate_offset])
        gridfinity_top_base();
    } else {
        gridfinity_top_base();
    }
}

module custom_top() {
    render()
    difference () {
        union() {
            rbox_body();
            custom_top_interior_grid();
        }
        if (Gridfinity_Stackable) {
            extra_depth = gridfinity_base_extra_height(hole=true);
            translate([0, 0, stackable_top_plate_offset])
            translate([0, 0, stackable_bottom_base_offset])
            translate([0, 0, h_base + extra_depth])
            rbox_for_interior()
            mirror([0, 0, 1])
            gridfinity_baseplate_cut();
        }
    }
}

module gridfinity_box_part() {
    if (Part == "top_grid_modifier") {
        rbox_for_top()
        custom_top_interior_grid(interior_base=false);
    } else {
        children();
    }
}

module main() {
    rbox(
        width,
        length,
        bottom_height,
        top_height,
        corner_radius=corner_radius,
        edge_chamfer_proportion=edge_chamfer_proportion,
        lip_seal_type=Lip_Seal_Type,
        reinforced_corners=Reinforced_Corners,
        latch_type=Latch_Type,
        latch_count=(Width <= 2 ? 1 : 2),
        top_grip=Top_Grip,
        hinge_end_stops=Hinge_End_Stops,
        handle=Handle,
        label=Label,
        label_text=Label_Text,
        label_text_size=Label_Text_Size
    )
    rbox_size_adjustments(
        wall_thickness=Wall_Thickness,
        lip_thickness=Lip_Thickness,
        rib_width=Rib_Width,
        latch_width=Latch_Width,
        latch_screw_separation=Latch_Screw_Separation,
        third_hinge_width=Third_Hinge ? (l_grid * 5) : 0,
        stacking_separation=stacking_separation,
        size_tolerance=Size_Tolerance
    ) {
        gridfinity_box_part()
        rbox_part(Part) {
            _box_color()
            custom_bottom();
            _box_color()
            custom_top();
        };
    }
}

main();
