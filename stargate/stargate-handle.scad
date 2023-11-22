/*
 * SG-1 Stargate handle with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

include <stargate-library.scad>;

/* [Handle Options] */

// Hole spacing, will be used to determine diameter
Hole_Spacing = 150; // [20:1:300]

Hole_Diameter = 4; // [2:0.1:10]
Hole_Depth = 8; // [2:0.1:20]

/* [Stargate options] */
// Rotate the symbols this many degrees. The top chevron overlaps ᐰ at 0 degrees.
Rotate_Symbols = 4.5; // [0:0.5:360]

// Symbols raised or inset
Symbols_Style = "inset"; // [raised: Raised, inset: Inset]

module __end_customizer_options__() { }

// Constants //

diameter = (
    Hole_Spacing
    + (
        (
         outer_ring_outer_outer_radius - outer_ring_outer_inner_radius
        )
        * (Hole_Spacing / diameter_scale_factor)
    )
);

module stargate_half() {
    intersection() {
        stargate(
            diameter=diameter,
            rotate_symbols=Rotate_Symbols,
            symbols_style=Symbols_Style,
            double_sided=true
        );
        color("#abb", 0.8)
        render(convexity=8)
        translate([0, diameter * 2, 0])
        cube(diameter * 4, center=true);
    }
}

module handle_holes() {
    difference() {
        children();
        color("mintcream", 0.8)
        for (mx = [0:1:1])
        mirror([mx, 0, 0])
        translate([Hole_Spacing / 2, 0, 0])
        rotate([90, 0, 0])
        cylinder(h=Hole_Depth * 2, d=Hole_Diameter, center=true);
    }
}

module stargate_handle() {
    handle_holes()
    stargate_half();
}

stargate_handle();
