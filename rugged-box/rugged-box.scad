/*
 * Customizable and Parametric Rugged Storage Box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Parametric rugged storage box model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <rugged-box-library.scad>;

/* [Rendering] */
Part = "assembled_open"; // ["bottom": Bottom, "top": Top, "latch": Latch, "handle": Handle, "side-by-side": Top and Bottom side-by-side, "assembled_open": Top and Bottom assembled open, "assembled_closed": Top and Bottom assembled closed]

/* [Dimensions] */
// All units in millimeters

// Interior side-to-side size in millimeters
Width = 120; // [20:1:300]

// Interior front-to-back size in millimeters
Length = 60; // [20:1:300]

// Interior bottom height in millimeters
Bottom_Height = 25; // [0:1:300]

// Interior top height in millimeters
Top_Height = 7; // [0:1:300]

// Interior corner radius in millimeters. Reduces interior storage space.
Corner_Radius = 5; // [0:0.1:20]

// Proportion of Corner Radius to chamfer outer top and bottom edges. Reduces interior storage space.
Edge_Chamfer_Proportion = 0.4; // [0:0.1:1]

/* [Features] */
// Type or shape of seal to use, if desired
Lip_Seal_Type = "wedge"; // [none: None, wedge: Wedge ▽, square: Square □, "filament-1.75mm": 1.75mm Filament ○]

// Make the corners as thick as the box lip
Reinforced_Corners = false;

// Add a front grip to the box top (for boxes with two latches)
Top_Grip = false;

/* [Advanced Size Adjustments] */
// Base wall thickness in millimeters for most of the box
Wall_Thickness = 2.4; // [0.4:0.1:10]

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

// Modules

rbox(
    Width,
    Length,
    Bottom_Height,
    Top_Height,
    corner_radius=Corner_Radius,
    edge_chamfer_proportion=Edge_Chamfer_Proportion,
    lip_seal_type=Lip_Seal_Type,
    reinforced_corners=Reinforced_Corners,
    top_grip=Top_Grip
)
rbox_size_adjustments(
    wall_thickness=Wall_Thickness,
    lip_thickness=Lip_Thickness,
    rib_width=Rib_Width,
    latch_width=Latch_Width,
    latch_screw_separation=Latch_Screw_Separation,
    size_tolerance=Size_Tolerance
)
rbox_part(Part);
