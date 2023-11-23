/*
 * SG-1 Stargate with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

include <stargate-library.scad>;

/* [Stargate options] */
// Approximate diameter in millimeters
Diameter = 75; // [20:1:300]

// Rotate the symbols this many degrees. The top chevron overlaps ᐰ at 0 degrees.
Rotate_Symbols = 4.5; // [0:0.5:360]

// Symbols raised or inset
Symbols_Style = "inset"; // [raised: Raised, inset: Inset]

/* [Modifiers] */

// Add a second Stargate face to the rear of the ring. This doubles the overall ring thickness.
Double_Sided = false;

// Add a hanging loop for use as an ornament
Hanging_Loop = false;

module __end_customizer_options__() { }

stargate(
    diameter=Diameter,
    rotate_symbols=Rotate_Symbols,
    symbols_style=Symbols_Style,
    double_sided=Double_Sided,
    hanging_loop=Hanging_Loop
);
