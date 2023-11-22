/*
 * SG-1 Stargate with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

use <Chevrons.scad>
use <Highlights.scad>
use <OuterRing.scad>
use <Symbols.scad>
use <InnerRing.scad>

/* [Size] */
// Approximate diameter in inches
Diameter = 3; // [1:0.1:20]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;


module Stargate(approximateRadius__inches=8.5)
{
    scaleFactor = approximateRadius__inches / 8.5;
    scale([scaleFactor,scaleFactor,scaleFactor*25.4/2/10]) {
        color("darkgray", 0.8)
        scale([1,1,1])
        innerRing();

        color("mintcream", 0.8)
        scale([1,1,1.2])
        symbols();

        color("darkgray", 0.8)
        scale([1,1,1.4])
        outerRing();

        color("coral", 0.8)
        scale([1,1,1.8])
        translate([0,2,0])
        highlights();

        color("lightgray", 0.8)
        scale([1,1,1.6])
        chevrons();
    }
}

Stargate(approximateRadius__inches=Diameter);
