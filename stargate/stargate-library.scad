/*
 * SG-1 Stargate with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4 : 2;
$fs = $preview ? $fs / 4 : 0.4;

outer_ring_outer_outer_radius = 106.64;
outer_ring_outer_inner_radius = 92.95;
outer_ring_inner_outer_radius = 80.84;
outer_ring_inner_inner_radius = 76.53;
symbols_count = 39;
chevrons_count = 9;

base_ring_thickness = 3;
inner_ring_depth = base_ring_thickness + 2;
outer_ring_depth = inner_ring_depth + 2;
symbols_height = 1;
symbols_depth = 0.6;

fudge = 0.1;
diameter_scale_factor = outer_ring_outer_outer_radius * 2; // (25.4 * 8.5);
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
    render(convexity=2)
    difference() {
        // Outer ring
        linear_extrude(height=outer_ring_depth)
        difference() {
            circle(r=outer_ring_outer_outer_radius);
            circle(r=outer_ring_inner_inner_radius);
        }
        // Subtract inner ring
        translate([0, 0, inner_ring_depth])
        linear_extrude(height=(outer_ring_depth - inner_ring_depth) + fudge)
        difference() {
            circle(r=outer_ring_outer_inner_radius);
            circle(r=outer_ring_inner_outer_radius);
        }
    }
}

module chevron_light_wedge_shape() {
    polygon(points=[
        [-1.0546, 98.16],
        [0.95798, 98.16],
        [4.085, 107.2],
        [-4.085, 107.2],
    ]);
}

module chevron_light_wedge_cut() {
    difference() {
        children();
        polygon([
            [5.2877, 107.9],
            [0, 105],
            [-5.2877, 107.9],
        ]);
    }
}

module chevron_highlight() {
    linear_extrude(height=outer_ring_depth + 1 - 0.4)
    chevron_light_wedge_cut()
    chevron_light_wedge_shape();
    linear_extrude(height=outer_ring_depth + fudge / 10)
    chevron_light_wedge_shape();
    // Lines
    linear_extrude(height=outer_ring_depth + 2)
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
    chevron_light_wedge_cut()
    difference() {
        union() {
            points = [
                for (y = [93.742, 107.89])
                for (xfac = [-1, 1])
                [xfac * (hl_sub_x(y) - 0.4), y]
            ];
            polygon(points=[for (i = [0, 1, 3, 2]) points[i]]);
        }
        chevron_light_wedge_shape();
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
    }

    // Wings
    for (mx = [0:1:1])
    mirror([mx, 0])
    intersection() {
        translate([6.2694, 103.25])
        rotate(-4.5)
        polygon([[0, 0], [21.75, 0], [19.75, 10], [4, 10]]);
        offset(delta=-0.2)
        circle(r=outer_ring_outer_outer_radius);
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

module stargate(
    diameter=75,
    rotate_symbols=4.5,
    symbols_style="raised",
    double_sided=false
) {
    for (mz = [0:1:(double_sided ? 1 : 0)])
    mirror([0, 0, mz])
    scale([1, 1, thickness_scale_factor])
    scale(diameter / diameter_scale_factor)
    add_symbols(rotate_symbols, symbols_style)
    union() {
        color("#abb", 0.8)
        ring();
        for_each_chevron()
        translate([0, 0.8, 0]) {
            color("coral", 0.8)
            chevron_highlight();
            color("#788", 0.8)
            linear_extrude(height=outer_ring_depth + 1)
            chevron();
        }
    }
}
