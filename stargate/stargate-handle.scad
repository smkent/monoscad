/*
 * SG-1 Stargate handle with symbols
 * by wtgibson on Thingiverse: https://www.thingiverse.com/thing:87691
 *
 * Modified by smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

include <stargate-library.scad>;

/* [Rendering Options] */
Part_Selection = "handle"; // [handle: Handle, drill-guide: Drill guide]

// Enable integrated print supports for the handle
Print_Supports = true;

/* [Handle Options] */

// Hole spacing, will be used to determine diameter
Hole_Spacing = 150; // [20:1:300]

Hole_Diameter = 2.8; // [2:0.1:10]
Hole_Depth = 8; // [2:0.1:20]

/* [Stargate options] */
// Rotate the symbols this many degrees. The top chevron overlaps ᐰ at 0 degrees.
Rotate_Symbols = 4.5; // [0:0.5:360]

// Symbols raised or inset
Symbols_Style = "inset"; // [raised: Raised, inset: Inset]

module __end_customizer_options__() { }

// Constants //

diameter = (
    Hole_Spacing
    + (
        (
            outer_ring_outer_outer_radius - outer_ring_outer_inner_radius
        )
        * (Hole_Spacing / diameter_scale_factor)
    )
);

layer_height = 0.2;
support_top_thickness = (
    rescale(outer_ring_depth * 2 * thickness_scale_factor) * 0.8
);
support_body_thickness = 0.4 * 8;
support_offset = layer_height;
support_arc_radius = rescale(outer_ring_inner_inner_radius);
support_arc_thickness = layer_height * 2;
support_arc_angle = 50;
support_body_radius = support_arc_radius - support_arc_thickness;
support_arc_width = support_body_radius * cos(90 - support_arc_angle) * 2;
support_arc_base_height = support_body_radius * sin(90 - support_arc_angle);

// Functions //

function rescale(value) = (value * (diameter / diameter_scale_factor));

// Modules //

module stargate_half() {
    difference() {
        stargate(
            diameter=diameter,
            rotate_symbols=Rotate_Symbols,
            symbols_style=Symbols_Style,
            double_sided=true
        );
        color("#abb", 0.8)
        render(convexity=8)
        mirror([0, 1, 0])
        translate([0, diameter * 2, 0])
        cube(diameter * 4, center=true);
    }
}

module handle_holes() {
    difference() {
        children();
        color("mintcream", 0.8)
        for (mx = [0:1:1])
        mirror([mx, 0, 0])
        translate([Hole_Spacing / 2, 0, 0])
        rotate([90, 0, 0])
        cylinder(h=Hole_Depth * 2, d=Hole_Diameter, center=true);
    }
}

module print_support_arc() {
    linear_extrude(height=support_top_thickness, center=true)
    intersection() {
        difference() {
            translate([-support_arc_radius, 0])
            square(support_arc_radius*2);
            for (mx = [0:1:1])
            mirror([mx, 0])
            rotate(support_arc_angle)
            mirror([1, 0])
            square(support_arc_radius*2);
        }
        union() {
            for (ang = [-180:support_offset * 6:180])
            rotate(ang)
            translate([0, support_arc_radius - support_offset * 1.5])
            circle(r=support_offset, $fn=12);
            difference() {
                circle(r=support_arc_radius - support_offset * 1.5);
                circle(r=support_arc_radius - support_arc_thickness);
            }
        }
    }
}

module print_support_body_shape(div_fac=1) {
    offset(delta=fudge)
    offset(delta=-fudge)
    difference() {
        xx = (
            (support_body_radius - support_arc_thickness * 3)
            * cos(90 - support_arc_angle + 2)
        );
        yy = (support_top_thickness - support_body_thickness) / div_fac;
        thickness_delta = (support_top_thickness - support_body_thickness) - yy;
        square([support_arc_width, support_top_thickness], center=true);
        for (my = [0:1:1])
        mirror([0, my])
        translate([0, support_body_thickness / 2 + thickness_delta / 2])
        polygon([
            [xx, 0],
            [-xx, 0],
            [-support_arc_width / 2, yy / 2],
            [support_arc_width / 2, yy / 2]
        ]);
    }
}

module print_support_body() {
    difference() {
        linear_extrude(height=support_top_thickness, center=true)
        intersection() {
            translate([-support_arc_width / 2, support_arc_base_height])
            square([support_arc_width, support_arc_base_height]);
            circle(r = support_body_radius);
        }
        for (mz = [0:1:1])
        mirror([0, 0, mz])
        translate([0, 0, support_body_thickness / 2])
        cylinder(
            h=(support_top_thickness - support_body_thickness) / 2 + fudge,
            r1=support_body_radius - support_arc_thickness * 3,
            r2=support_body_radius
        );
    }

    rotate([-90, 0, 0]) {
        linear_extrude(height=support_arc_base_height)
        print_support_body_shape(1);
        intersection() {
            linear_extrude(height=support_arc_base_height / 4)
            print_support_body_shape(2);

            rotate([90, 0, 90])
            linear_extrude(height=support_arc_width, center=true)
            polygon([
                [-support_top_thickness / 2, 0],
                [-support_body_thickness / 2, support_arc_base_height / 4],
                [support_body_thickness / 2, support_arc_base_height / 4],
                [support_top_thickness / 2, 0]
            ]);
        }
    }
}

module print_support_foot() {
    rotate([-90, 0, 0])
    linear_extrude(height=support_arc_thickness * 2)
    offset(r=-2)
    offset(r=6)
    union() {
        square([2 * support_arc_width / 3, support_body_thickness], center=true);
        for (mx = [0:1:1])
        mirror([mx, 0])
        translate([support_arc_width / (3 + 0.75), 0])
        square([support_arc_width / 12, support_arc_width / 3], center=true);
    }
}

module print_supports() {
    print_support_foot();
    difference() {
        union() {
            print_support_body();
            print_support_arc();
        }
        linear_extrude(height=support_top_thickness, center=true) {
            polygon([
                [0, (support_body_radius - support_arc_thickness * 4) * 0.8],
                [support_arc_width / 5, support_arc_thickness * 6],
                [-support_arc_width / 5, support_arc_thickness * 6]
            ]);
            for (mx = [0:1:1])
            mirror([mx, 0]) {
                polygon([
                    [support_arc_width / 3, 0],
                    [support_arc_width / 2, support_arc_base_height],
                    [support_arc_width / 2 + support_arc_thickness, 0]
                ]);
                translate([support_arc_width * 0.28, support_body_radius / 5])
                scale([1, 2.0])
                rotate(45)
                square(support_arc_width / 8);
            }
        }
    }
}

module add_print_supports() {
    children();
    color("plum", 0.6)
    if ($sgh_print_supports) {
        print_supports();
    }
}

module stargate_handle() {
    rotate([90, 0, 0])
    add_print_supports()
    handle_holes()
    stargate_half();
}

module stargate_handle_screw_guide() {
    $sgh_print_supports = false;
    color("#abb", 0.8)
    linear_extrude(height=layer_height * 4)
    projection(cut=true)
    stargate_handle();
    color("#788", 0.8)
    linear_extrude(height=layer_height * 4)
    square(
        [
            rescale(outer_ring_inner_inner_radius) * 2 + fudge,
            rescale(outer_ring_depth) * 2
        ],
        center=true
    );
}

module main() {
    $sgh_print_supports = Print_Supports;
    if (Part_Selection == "handle") {
        stargate_handle();
    } else if (Part_Selection == "drill-guide") {
        stargate_handle_screw_guide();
    }
}

main();
