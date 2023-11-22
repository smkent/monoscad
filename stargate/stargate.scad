/*
 * SG-1 Stargate with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Stargate options] */
// Approximate diameter in millimeters
Diameter = 75; // [20:1:300]

// Approximate ring thickness in millimeters. The full thickness with chevrons is about 1mm greater than this value.
Ring_Thickness = 3; // [0.1:0.1:20]

// Rotate the symbols this many degrees. The top chevron overlaps ᐰ at 0 degrees.
Rotate_Symbols = 4.5; // [0:0.5:360]

// Symbols raised or inset
Symbols_Style = "inset"; // [raised: Raised, inset: Inset]

/* [Modifiers] */

// Add a second Stargate face to the rear of the ring. This doubles the overall ring thickness.
Double_Sided = false;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4 : 2;
$fs = $preview ? $fs / 4 : 0.4;

outer_ring_radius = 106.64;
symbols_count = 39;
chevrons_count = 9;

inner_ring_depth = Ring_Thickness + 2;
outer_ring_depth = inner_ring_depth + 2;
symbols_height = 1;
symbols_depth = 0.6;

fudge = 0.1;
diameter_scale_factor = (25.4 * 8.5);
thickness_scale_factor = 1.233;

// Functions

function hl_sub_x(y) = ( (y - 86.728) / 2.897 );

function ch_sub_x(y) = ( (y - 83.296) / 1.886 );

// Modules

module for_each_chevron() {
    for (ang = [0:360/chevrons_count:360-fudge])
    rotate(ang)
    children();
}

module ring() {
    render()
    difference() {
        // Outer ring
        linear_extrude(height=outer_ring_depth)
        difference() {
            circle(r=outer_ring_radius);
            circle(r=76.53);
        }
        // Subtract inner ring
        translate([0, 0, inner_ring_depth])
        linear_extrude(height=(outer_ring_depth - inner_ring_depth) + fudge)
        difference() {
            circle(r=92.95);
            circle(r=80.84);
        }
    }
}

module chevron_highlight() {
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

module chevron() {
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

module symbols() {
    // Import symbols SVG
    scale(0.75)
    import("stargate-symbols.svg", center=true);

}

module symbol_dividers() {
    // Symbol dividers
    for (ang = [0:360/symbols_count:360-fudge])
    rotate(ang + 360 / symbols_count * (0.5 + 0.05)) {
        translate([0, 0, inner_ring_depth])
        linear_extrude(height=1)
        translate([0, 80.84])
        square([0.8, (92.95 - 80.84)]);
    }

}

module add_symbols(rotate_symbols, symbols_style="raised") {
    if (symbols_style == "inset") {
        difference() {
            children();
            color("#dee", 0.8)
            render(convexity=2)
            rotate(rotate_symbols)
            translate([0, 0, inner_ring_depth - symbols_depth])
            linear_extrude(height=symbols_depth * 1.2)
            symbols();
        }
    } else {
        color("mintcream", 0.8)
        rotate(rotate_symbols)
        translate([0, 0, inner_ring_depth])
        linear_extrude(height=symbols_height)
        symbols();
        children();
    }

    color("mintcream", 0.8)
    rotate(rotate_symbols)
    symbol_dividers();
}

module for_each_side(double_sided=false) {
    if (double_sided) {
        for (mz = [0:1:1])
        mirror([0, 0, mz])
        children();
    } else {
        children();
    }
}

module stargate(
    diameter=75,
    ring_thickness=3,
    rotate_symbols=4.5,
    symbols_style="raised",
    double_sided=false
) {
    for_each_side(double_sided)
    scale([1, 1, thickness_scale_factor])
    scale(diameter / diameter_scale_factor)
    add_symbols(rotate_symbols, symbols_style)
    union() {
        color("#abb", 0.8)
        ring();
        for_each_chevron()
        translate([0, 0.8, 0]) {
            color("coral", 0.8)
            linear_extrude(height=outer_ring_depth + 2)
            chevron_highlight();
            color("#788", 0.8)
            linear_extrude(height=outer_ring_depth + 1)
            chevron();
        }
    }
}

stargate(
    diameter=Diameter,
    ring_thickness=Ring_Thickness,
    rotate_symbols=Rotate_Symbols,
    symbols_style=Symbols_Style,
    double_sided=Double_Sided
);
