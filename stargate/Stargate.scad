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
use <Symbols.scad>

/* [Size] */
// Approximate diameter in inches
Diameter = 3; // [1:0.1:20]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4 : 2;
$fs = $preview ? $fs / 4 : 0.4;

fudge = 0.1;

module ring() {
    render()
    difference() {
        // Outer ring
        linear_extrude(height=7)
        difference() {
            circle(r=106.64);
            circle(r=76.53);
        }
        // Subtract inner ring
        translate([0, 0, 5])
        linear_extrude(height=2 + fudge)
        difference() {
            circle(r=92.95);
            circle(r=80.84);
        }
    }
}

module Stargate(diameter=8.5)
{
    scaleFactor = diameter / 8.5;
    scale([scaleFactor,scaleFactor,scaleFactor*25.4/2/10])
    union() {
        color("darkgray", 0.8)
        ring();

        color("mintcream", 0.8)
        scale([1,1,1.2])
        symbols();

        color("coral", 0.8)
        scale([1,1,1.8])
        translate([0,2,0])
        highlights();

        color("lightgray", 0.8)
        scale([1,1,1.6])
        chevrons();
    }
}

Stargate(diameter=Diameter);
