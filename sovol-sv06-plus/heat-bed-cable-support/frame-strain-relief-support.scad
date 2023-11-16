/*
 * Sovol SV06 Plus Heat Bed Cable Support Bundle for tight spaces
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Frame support model file -- only used for README image rendering
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 2 : 2;
$fs = $preview ? $fs / 3 : 0.4;

// Modules //

module main() {
    color("#94c5db", 0.8)
    rotate([-90, 0, 0])
    translate([-33.10 / 2, -46.19 / 2, -69.78 / 2])
    translate([4.49, 42.98, -2.975])
    import("frame-strain-relief-support.stl");
}

main();
