/*
 * SG-1 Stargate with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Size] */
// Approximate diameter in inches
Diameter = 3; // [1:0.1:20]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4 : 2;
$fs = $preview ? $fs / 4 : 0.4;

outer_ring_radius = 106.64;

fudge = 0.1;

module ring() {
    render()
    difference() {
        // Outer ring
        linear_extrude(height=7)
        difference() {
            circle(r=outer_ring_radius);
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

// y = 2.897x + 86.945
// y = -2.89x + 86.728
function hl_sub_x(y) = ( (y - 86.728) / 2.897 );

module highlight() {
    // Chevron wedge
    polygon(points=[
        [-1.0546, 98.16],
        [0.95798, 98.16],
        [4.3094, 107.87],
        [-4.406, 107.87],
    ]);
    // Lines
    difference() {
        polygon(points=[
            [-6.4396, 95.721],
            [6.3469, 95.721],
            [9.7756, 102.22],
            [-9.8682, 102.22],
        ]);

        points = [
            for (y = [94, 103])
            for (xfac = [-1, 1])
            [xfac * hl_sub_x(y), y]
        ];
        polygon(points=[for (i = [0, 1, 3, 2]) points[i]]);

        inc = (102.22 - 95.721) / 11;
        for (i = [1:2:11]) {
            translate([-20, 95.721 + i * inc])
            square([40, inc]);
        }
    }
}

module highlights_new() {
    highlight();
}

function ch_sub_x(y) = ( (y - 83.296) / 1.886 );

module chevrons_new() {
    // Lower wedge
    difference() {
        union() {
            points = [
                for (y = [87.374, 102.37])
                for (xfac = [-1, 1])
                [xfac * (ch_sub_x(y)), y]
            ];
            polygon(points=[for (i = [0, 1, 3, 2]) points[i]]);
        }
        union() {
            points = [
                for (y = [92.01, 102.37])
                for (xfac = [-1, 1])
                [xfac * (hl_sub_x(y) + 0.2), y]
            ];
            polygon(points=[for (i = [0, 1, 3, 2]) points[i]]);
        }
    }

    // Upper wedge
    difference() {
        union() {
            points = [
                for (y = [93.742, 107.89])
                for (xfac = [-1, 1])
                [xfac * (hl_sub_x(y) - 0.4), y]
            ];
            polygon(points=[for (i = [0, 1, 3, 2]) points[i]]);
        }
        // Cut outer corners
        for (mx = [0:1:1])
        mirror([mx, 0])
        polygon(
            concat(
                [
                    for (y = [107.67 - 0.6, 108])
                    [(hl_sub_x(y)), y],
                ],
                [
                    for (y = [108])
                    [(hl_sub_x(y) - 0.6), y],
                ]
            )
        );
        // Inner cut
        polygon([
            [5.2877, 107.9],
            [4.1188, 107.32],
            [-4.1188, 107.32],
            [-5.2877, 107.9],
        ]);
    }

    // Wings
    for (mx = [0:1:1])
    mirror([mx, 0])
    intersection() {
        translate([6.2694, 103.25])
        rotate(-4.5)
        polygon([[0, 0], [21.75, 0], [19.75, 10], [4, 10]]);
        offset(delta=-0.2)
        circle(r=outer_ring_radius);
    }
}

module multiply_chevrons() {
    for (ang = [0:360/9:360-fudge])
    rotate(ang)
    children();
}

module symbols_svg() {
    sc = 0.75;
    linear_extrude(height=6)
    scale(sc)
    import("stargate-symbols.svg", center=true);
}

module Stargate(diameter=8.5)
{
    scaleFactor = diameter / 8.5;
    scale([scaleFactor,scaleFactor,scaleFactor*25.4/2/10])
    union() {
        color("darkgray", 0.8)
        ring();

        color("mintcream", 0.8)
        symbols_svg();

        multiply_chevrons() {
            color("coral", 0.8)
            linear_extrude(height=9)
            highlights_new();
            color("lightgray", 0.8)
            linear_extrude(height=8)
            chevrons_new();
        }
    }
}

Stargate(diameter=Diameter);
