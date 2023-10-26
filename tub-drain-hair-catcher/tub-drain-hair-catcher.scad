/*
 * Tub drain hair filter (inspired by Tubshroom)
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Model Options] */
Top_Style = 2; // [0: Flat, 1: Rounded, 2: Winged]

Bottom_Style = 0; // [0: Flat, 1: Angled]

/* [Size] */
// All units in millimeters

// Diameter of drain
Drain_Diameter = 41;

// Depth of drain from top to interior support ring/beam
Drain_Depth = 27;

// Height of above-drain portion
Above_Drain_Height = 13;

// Diameter of the center hole on the top
Top_Screw_Hole_Diameter = 5; // [3:0.1:10]

/* [Advanced Options] */
Stagger_Body_Holes = true;

Top_Screw_Hole_Chamfer = true;

// Add riser feet on the bottom
Feet = false;

/* [Advanced Size Options] */
// Diameter of main body as a proportion of drain diameter
Body_Diameter_Proportion = 0.61; // [0.4:0.01:0.8]

// Diameter of above-drain top as a proportion of drain diameter
Top_Diameter_Proportion = 1.37; // [1.2:0.01:1.5]

// Top, bottom, and body thicknesses (mm)
Thickness = 4;

// Body hole diameter (mm)
Hole_Diameter = 5; // [1:0.1:10]

// Body hole spacing (mm)
Hole_Spacing = 1.6; // [0.8:0.1:5]

// Size of holes on the bottom as a proportion of available space
Bottom_Holes_Size_Proportion = 0.4; // [0.1:0.1:0.7]


/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

outer_height = Above_Drain_Height + Drain_Depth;
body_diameter = Drain_Diameter * Body_Diameter_Proportion;
body_radius = body_diameter / 2;
body_height = outer_height - Thickness * 2;
bottom_radius = Drain_Diameter / 2;
top_diameter = Drain_Diameter * Top_Diameter_Proportion;
top_height = outer_height - Drain_Depth;

// Functions

function how_many_fit(size, unit_size, unit_sep) = (
    (size + unit_sep) / (unit_size + unit_sep)
);

function how_big_fit(size, how_many, unit_sep) = (
    (size + unit_sep) / how_many - unit_sep
);

function how_many_fit_around(d, unit_size) = (
    let (circumference = 2 * PI * d / 2)
    floor(circumference / unit_size)
);

function body_max_holes_vertical() = (
    floor(how_many_fit(
        body_height - (
            Bottom_Style == 1
                ? (bottom_radius - body_radius)
                : 0
        ),
        Hole_Diameter,
        (Stagger_Body_Holes ? Hole_Spacing / 2 : Hole_Spacing)
    ))
);

function body_hole_vertical_adjust() = (
    let (mh = body_max_holes_vertical())
    (
        (
            body_height - Hole_Diameter * mh - (
                Stagger_Body_Holes
                    ? (Hole_Spacing / 2 * (mh - 1))
                    : (Hole_Spacing * (mh - 1))
            )
        )
        + (
            Bottom_Style == 1
                ? 1 * (bottom_radius - body_radius) - Thickness / 2
                : 0
        )
    ) / 2
);

function bottom_hole_placement() = (
    (body_radius + bottom_radius - Thickness / 2) / 2
);

// Modules //

module rounded_circular_grip_shape(radius, hole_radius=0) {
    hull() {
        translate([hole_radius, 0])
        square([Thickness, Thickness]);
        translate([radius - Thickness / 2, Thickness / 2])
        circle(Thickness / 2);
    }
}

module rounded_circular_grip(radius, hole_radius=0) {
    rotate_extrude(angle=360)
    rounded_circular_grip_shape(radius, hole_radius=0);
}

module raised_circular_grip(radius, hole_radius=0) {
    rotate_extrude(angle=360)
    difference() {
        hull() {
            square([Thickness / 2, Thickness / 2]);
            translate([0, Thickness / 2]) {
                scale([radius - Thickness/2, Thickness / 2 * 4])
                difference() {
                    circle(1);
                    translate([0, -0.5])
                    square([2, 1], center=true);
                    translate([-1, 0])
                    square([1, 1]);
                }

                translate([radius - Thickness / 2, 0])
                difference() {
                    circle(Thickness / 2);
                    translate([-Thickness / 2, 0])
                    square([Thickness, Thickness]);
                }
            }
        }
        if (hole_radius > 0) {
            square([hole_radius, Thickness]);
        }
    }
}

module rounded_foot(x=10, y=5, z=4) {
    r = x * 0.1;
    inset = x * 0.2;
    hull() {
        translate([0, 0, z - r])
        for (mx = [0:1:1], my=[0:1:1]) {
            mirror([0, my, 0])
            mirror([mx, 0, 0])
            translate([x / 2 - r - inset, y / 2 - r - inset / 2, 0])
            sphere(r);
        }
        linear_extrude(height=0.1)
        offset(r)
        offset(-r)
        square([x, y], center=true);
    }
}

module hole_cut(radius, depth) {
    translate([0, 0, -depth])
    linear_extrude(height=depth * 2)
    circle(radius);
}

module body_holes() {
    body_hole_count_raw = how_many_fit_around(body_diameter, Hole_Diameter + Hole_Spacing);
    body_hole_count = body_hole_count_raw + (body_hole_count_raw % 2 == 0 ? 0 : 1);
    translate([0, 0, body_hole_vertical_adjust()])
    for (i = [1:1:body_max_holes_vertical()]) {
        rotate([0, 0, (Stagger_Body_Holes && i % 2 == 1) ? (360 / body_hole_count / 2) : 0])
        for (ang = [0:360 / body_hole_count:180 - 0.1]) {
            rotate([0, 0, ang])
            translate([0, 0, Stagger_Body_Holes == true
                ? Hole_Spacing / 2 * (i - 1)
                : Hole_Spacing * (i - 1)])
            translate([0, 0, Hole_Diameter * i])
            translate([0, 0, Hole_Diameter / 2 + Thickness - Hole_Diameter])
            rotate([90, 0, 0])
            hole_cut(Hole_Diameter / 2, body_diameter + Thickness * 2);
        }
    }
}

module body() {
    render()
    difference() {
        linear_extrude(height=outer_height)
        difference() {
            circle(body_radius);
            circle(body_radius - Thickness);
        }
        body_holes();
    }
}

module top_holes() {
    available_diameter = body_diameter - Thickness * 2 - Top_Screw_Hole_Diameter;
    top_hole_radius = how_big_fit(available_diameter, 2, Top_Screw_Hole_Diameter) / 2;
    ring_hole_count = how_many_fit_around(
        (body_diameter - Thickness * 2) / 2 - top_hole_radius * 1.8, top_hole_radius * 1
    );
    // Top screw hole
    hole_cut(Top_Screw_Hole_Diameter / 2 * 1.1, Thickness * 4);
    if (Top_Screw_Hole_Chamfer) {
        translate([0, 0, Thickness - Thickness / 2])
        cylinder(
            Thickness / 2 + 0.01,
            Top_Screw_Hole_Diameter / 2,
            Top_Screw_Hole_Diameter
        );
    }
    if (top_hole_radius > 0.5) {
        // Surrounding holes
        for (rot = [0:360 / ring_hole_count:360 - 0.1]) {
            rotate([0, 0, rot])
            translate([(body_diameter - Thickness * 2) / 2 - top_hole_radius, 0, 0])
            hole_cut(top_hole_radius, Thickness * 4);
        }
    }
}

module top_mushroom_shape() {
    r = top_diameter / 2 - Thickness;
    rr = (top_diameter - body_diameter) / 2 - Thickness;
    th = top_height - Thickness;
    union() {
        square([body_diameter / 2, Thickness]);
        translate([body_diameter / 2, 0])
        intersection() {
            difference() {
                translate([0, -top_height + Thickness])
                scale([1, top_height / ((top_diameter - body_diameter) / 2)])
                circle((top_diameter - body_diameter) / 2);

                translate([0, -th])
                scale([1, th / rr])
                circle(rr);
            }
            translate([0, -top_height + Thickness])
            square([(top_diameter - body_diameter) / 2, top_height]);
        }
    }
}

module top_wing_cut(radius, cut_depth) {
    translate([radius - cut_depth * 0.75, 0, -top_height + Thickness])
    rotate([0, 90, 0])
    linear_extrude(height=cut_depth)
    offset(-radius / 8)
    offset(radius / 8)
    union() {
        circle(radius / 4);
        translate([radius / 4, 0])
        square([radius / 2, radius], center=true);
    }
}

module top_winged() {
    wing_count = 8;
    difference() {
        rotate_extrude(angle=360)
        top_mushroom_shape();

        for (rot = [0:360 / wing_count:360 - 0.1]) {
            rotate([0, 0, rot])
            top_wing_cut(top_diameter / 2, Thickness * 8);
        }
    }
}


module top() {
    translate([0, 0, outer_height - Thickness])
    difference() {
        if (Top_Style == 0) {
            rounded_circular_grip(top_diameter / 2);
        } else if (Top_Style == 1) {
            raised_circular_grip(top_diameter / 2);
        } else if (Top_Style == 2) {
            top_winged();
        }
        top_holes();
    }
    if (Top_Style != 2) {
        foot_height = (body_height + Thickness) - Drain_Depth;
        if (foot_height > 0.1) {
            foot_size = 5;
            foot_count = how_many_fit_around(top_diameter, foot_size + (Hole_Diameter * 2));
            ang_step = 360 / (foot_count - 1);
            for (ang = [0:ang_step:360 - 0.1]) {
                rotate([0, 0, ang])
                translate([top_diameter / 2 - foot_size, 0, outer_height - Thickness])
                mirror([0, 0, 1])
                rotate([0, 0, 90])
                rounded_foot(foot_size, foot_size, foot_height);
            }
        }
    }
}

module bottom_holes() {
    bottom_hole_radius = (
        how_big_fit((Drain_Diameter - body_diameter) / 2, 1, 0) * Bottom_Holes_Size_Proportion
    ) / 2;
    bottom_hole_count = how_many_fit_around(bottom_hole_placement() * 2, bottom_hole_radius * 2 + Hole_Spacing);
    for (ang = [0:360 / (bottom_hole_count - 1):360 - 0.1]) {
        rotate([0, 0, ang])
        translate([bottom_hole_placement(), 0, 0]) {
            if (Bottom_Style == 1) {
                translate([0, 0, Thickness])
                rotate([90, 0, 0])
                translate([0, 0, -bottom_hole_radius])
                linear_extrude(height=bottom_hole_radius*2)
                square(bottom_radius);
            }
            hole_cut(bottom_hole_radius, bottom_radius);
        }
    }
}

module feet() {
    bottom_hole_radius = (how_big_fit((Drain_Diameter - body_diameter) / 2, 1, 0) * 0.3) / 2;
    bottom_hole_count = how_many_fit_around(bottom_hole_placement() * 2, bottom_hole_radius * 2 + Hole_Spacing);
    ang_step = 360 / (bottom_hole_count - 1);
    for (ang = [0:ang_step:360 - 0.1]) {
        rotate([0, 0, ang + ang_step * (0.5 - 0.1)])
        translate([bottom_hole_placement() - bottom_hole_radius, 0, 0])
        linear_extrude(height=Thickness)
        square([bottom_hole_radius * 2, Hole_Spacing]);
    }
}

module bottom_shape() {
    rotate_extrude(angle=360)
    if (Bottom_Style == 0) {
            rounded_circular_grip_shape(bottom_radius, body_radius);
    } else {
        difference() {
            hull() {
                rounded_circular_grip_shape(bottom_radius, 0);
                translate([0, Thickness * 1.25])
                polygon(points=[
                    [0, 0], [bottom_radius - Thickness, 0], [0, bottom_radius - Thickness]
                ]);
            }
            square([body_radius, bottom_radius * 2]);
        }
    }
}

module bottom() {
    difference() {
        bottom_shape();
        bottom_holes();
    }
    if (Feet) {
        mirror([0, 0, 1])
        feet();
    }
}

module tub_drain_hair_catcher() {
    union() {
        body();
        top();
        bottom();
    }
}

module orient_model() {
    if (Print_Orientation) {
        mirror([0, 0, 1])
        translate([0, 0, -outer_height])
        children();
    } else {
        children();
    }
}

module main() {
    orient_model()
    tub_drain_hair_catcher();
}

color("greenyellow", 0.8)
main();