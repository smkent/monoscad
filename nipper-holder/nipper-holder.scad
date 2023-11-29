/*
 * Nipper Cutter Holder
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

// Model options

Model_Variant = 2; // [1: No screw hole, 2: Screw hole]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 2 : 2;
$fs = $preview ? $fs / 2 : 0.4;

tipx = [-23.9813, 3.3765];

tip_x = -23.9813;
tip_y = 3.3765;

tip2_x = -15.9813;
tip2_y = 6.4353;

height = 12;

// Functions //

function xpt(y) = ((y - 12.537) / 0.382);
function ypt(x) = (0.382 * x + 12.537);

function tip_points(cut=0) = (
    let (x_attach = tipx[0] + 0.01)
    [
        [x_attach, ypt(x_attach)],
        [xpt(cut), cut],
        [xpt(cut), -cut],
        [x_attach, -ypt(x_attach)],
    ]
);

// Modules //

module original_model(variant=1) {
    color("lightsteelblue", 0.9)
    import(str("muh60-nch-", variant, "-v2.stl"), convexity=2);
}

module main() {
    original_model(variant=Model_Variant);

    color("lightgreen", 0.6)
    render(convexity=2)
    difference() {
        linear_extrude(height=height)
        hull() {
            cut=2.25;
            polygon(points=tip_points(cut=cut));
            translate([xpt(cut) + cut * 0.2, 0])
            circle(r=cut);
        }
        translate([0, 0, 2])
        linear_extrude(height=height - 4)
        hull() {
            translate([tipx[0] / 2, 0])
            square([tipx[0] * -1, 4], center=true);
            translate([4, 0])
            polygon(points=tip_points(cut=0.5));
        }
    }
}

main();
