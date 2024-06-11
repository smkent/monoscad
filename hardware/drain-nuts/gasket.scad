/*
 * Drain nuts
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Gasket Selection] */
Gasket_Type = "G1-1/4"; // [G1-1/4, Custom]

/* [Size] */
Height = 4.5; // [1:0.1:10]

Style = "square"; // [square: Square, ball-inset: Ball inset, round: Round]

/* [Custom Size] */

Outer_Diameter = 0;
Inner_Diameter = 0;

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

slop = 0.01;

// Functions //

gasket_table = [
    ["Custom", [Outer_Diameter, Inner_Diameter]],
    // https://www.ring-plug-thread-gages.com/PDChart/G-series-Fine-thread-data.html
    ["G1-1/4", [40, 31.6]]
];

function vsearch(vec, term) = (
    let (r = [for (i = vec) if (i[0] == term) i])
    len(r) == 1 ? r[0][1] : undef
);

gasket_spec = vsearch(gasket_table, Gasket_Type);

outer_d = gasket_spec[0];
inner_d = gasket_spec[1];

// Modules //

module gasket() {
    gw = (outer_d - inner_d) / 2;
    rr = min(Height, gw) * 0.1;
    rotate_extrude() {
        translate([inner_d / 2, 0])
        if (Style == "square") {
            offset(r=rr, $fn=1)
            offset(delta=-rr)
            square([gw, Height]);
        } else if (Style == "ball-inset") {
            offset(r=rr, $fn=1)
            offset(delta=-rr)
            union() {
                square([gw, Height / 2]);
                translate([0, Height / 2])
                intersection() {
                    square([gw, Height]);
                    scale([1, Height / gw])
                    circle(r=gw, $fn=50);
                }
            }
        } else if (Style == "round") {
            scale([gw / Height, 1])
            translate([Height / 2, Height / 2])
            circle(d=Height);
        }
    }
}

module main() {
    color("#cd5c5c", 0.8)
    gasket();
}

main();
