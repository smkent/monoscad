/*
 * qr-coasters
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Model Options] */
QR_Code = "rick-roll"; // [doge: Doge, bouncing-dvd-logo: DVD Logo, nyan-cat: Nyan Cat, one-square-minesweeper: One Square Minesweeper, potato-tomato: Potato or Tomato, rick-roll: Rick Roll, rotating-sandwiches: Rotating Sandwiches, zombo: Zombo.com]

/* [Size] */
// All units in millimeters

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;


// Modules //

module main() {
    linear_extrude(height=5)
    import(str("qr-", QR_Code, ".svg"), center=true);
}

main();
