/*
 * Customizable and Parametric Rugged Storage Box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Parametric rugged storage box model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <rugged-box-library.scad>;
include <gridfinity-rebuilt-openscad/standard.scad>;
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-baseplate.scad>;
use <gridfinity-rebuilt-openscad/gridfinity-rebuilt-utility.scad>;

/* [Rendering] */
Part = "assembled_open"; // ["bottom": Bottom, "top": Top, "latch": Latch, "stacking-latch": Stacking latch, "handle": Handle, "side-by-side": Top and Bottom side-by-side, "assembled_open": Assembled open, "assembled_closed": Assembled closed]

/* [Dimensions] */
// Interior side-to-side size in 42mm Gridfinity units
Width = 4; // [1:1:10]

// Interior front-to-back size in 42mm Gridfinity units
Length = 2; // [1:1:10]

// Interior bottom height in 7mm Gridfinity units
Bottom_Height = 7; // [1:1:10]

// Interior top height in 7mm Gridfinity units
Top_Height = 2; // [1:1:10]

/* [Gridfinity Features] */
Gridfinity_Base_Style = "minimal"; // [minimal: No magnet holes with minimal thickness, thick: No magnet holes but with magnet hole base thickness, enabled: Magnet holes with skeletonized baseplate, enabled_full: Magnet holes with filled baseplate]

// Add Gridfinity base stacking plates to outside of box top and bottom. Requires supports to print.
Gridfinity_Stackable = false;

/* [Features] */
// Type or shape of seal to use, if desired
Lip_Seal_Type = "wedge"; // [none: None, wedge: Wedge ▽, square: Square □, "filament-1.75mm": 1.75mm Filament ○]

// Make the corners as thick as the box lip
Reinforced_Corners = true;

// Add a front grip to the box top (for boxes with two latches)
Top_Grip = true;

// Add stacking latches and attachment points to the sides of the box
Stacking_Latches = true;

// Latch style
Latch_Type = "draw"; // [clip: Clip, draw: Draw]

/* [Advanced Size Adjustments] */
// Base wall thickness in millimeters for most of the box
Wall_Thickness = 3.0; // [2.4:0.1:10]

// Thickness in millimeters to add to the wall thickness for the box lip
Lip_Thickness = 2.0; // [0.4:0.1:10]

// Base thickness in millimeters of the support ribs. The latch ribs are this thick, while the hinge and side ribs are twice this thick.
Rib_Width = 4; // [1:0.1:20]

// Latch width in millimeters
Latch_Width = 22; // [5:1:50]

// Distance in millimeters between the latch hinge and catch screws which determines the latch vertical size
Latch_Screw_Separation = 20; // [5:1:40]

// Size in millimeters added between hinges and latches for fit
Size_Tolerance = 0.05; // [0:0.01:1]

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

module gridfinity_base(hole=false, off=0) {
    gridfinityBase(
        Width,
        Length,
        l_grid,
        0,
        0,
        hole ? 1 : 0,
        off=off,
        only_corners=false
    );
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
        rbox_interior();
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

module gridfinity_top_base() {
    rbox_for_interior()
    intersection() {
        translate([0, 0, top_base_offset])
        translate([0, 0, h_base])
        mirror([0, 0, 1])
        gridfinity_base(off=-0.2);
        gridfinity_rectangle(adjust=1.6);
    }
}

module custom_top() {
    render()
    difference () {
        union() {
            rbox_body();
            render(convexity=4)
            if (Gridfinity_Stackable) {
                rbox_interior_base(height=stackable_plate_offset);
                translate([0, 0, stackable_plate_offset])
                gridfinity_top_base();
            } else {
                gridfinity_top_base();
            }
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
        latch_count=(Width <= 1 ? 1 : 2),
        top_grip=Top_Grip
    )
    rbox_size_adjustments(
        wall_thickness=Wall_Thickness,
        lip_thickness=Lip_Thickness,
        rib_width=Rib_Width,
        latch_width=Latch_Width,
        latch_screw_separation=Latch_Screw_Separation,
        size_tolerance=Size_Tolerance
    ) {
        rbox_part(Part) {
            _box_color()
            custom_bottom();
            _box_color()
            custom_top();
        };
    }
}

main();
