/*
 * Sovol SV06 Plus Heat Bed Cable Support Bundle for tight spaces
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike
 */

/* [Rendering Options] */
// Orient the model for printing
Print_Orientation = true;

/* [Options] */
// Reduce the strain relief cover overlap by this many millimeters. Increase this value if the printed model's near edge needs to be further away from the heat bed.
Cut_Y = 1; // [0:0.1:4]

// Bend the curved cable guide upward this many millimeters. Modifying this value may affect print stability.
Curve_Bend = 4; // [0:0.1:10]

// Add extra cable tie holes at 45 degrees
Extra_Cable_Tie_Holes = true;

/* [Advanced Options] */
// Diameter in millimeters of the heat bed cable bundle
Bed_Cable_Diameter = 8.5; // [5:0.1:11]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 2 : 2;
$fs = $preview ? $fs / 3 : 0.4;

sr_x = 25.97;
sr_y = 36;
sr_z = 12.5;
sr_inset_x = 5.5;
sr_inset_y1 = 16;
sr_inset_y2 = 26;
sr_wingtip_y = 12.5;

sr_lid_z1 = 5.5;
sr_lid_z2 = 7;

cable_diameter = Bed_Cable_Diameter;
thick = 2;
cut_y = sr_wingtip_y + Cut_Y;
cut_z = 0.5;

squash = Curve_Bend;
outset = 5 + squash;
minoutset = 5 + max(3, squash);
extend = 9;

guide_x = sr_x - sr_inset_x * 2;
guide_y = sr_lid_z2 + thick - cut_z;
guide_bottom_radius = outset + guide_y;
guide_attach_z_adjust = -(
    guide_bottom_radius - sqrt(guide_bottom_radius^2 - squash^2)
);
base_interior_z = sr_lid_z2 - cut_z + thick;

groove_radius = 1;

// Modules //

module hull_stack(h) {
    slop = 0.001;
    hull() {
        linear_extrude(height=slop)
        children(0);
        translate([0, 0, h - slop])
        linear_extrude(height=slop)
        children(1);
    }
}

module sovol_strain_relief_cover_part() {
    translate([sr_x / 2, 0, 0])
    rotate([-90, 180, 0])
    translate([0, 0.001, 0])
    import("sovol-sv06plus-cover-repaired-notext.stl");
}

module rounded_groove_part(width=sr_x) {
    hull()
    for (mx = [0:1:1])
    mirror([mx, 0, 0])
    translate([width / 2, 0, 0]) {
        translate([thick, 0, 0])
        cylinder(groove_radius, groove_radius, groove_radius);
        translate([thick, 0, sr_lid_z1 + thick * 1.5])
        sphere(groove_radius);
    }
}

module strain_relief_outline_shape() {
    translate([-sr_x / 2, 0, 0])
    polygon(points=[
        [0, 0],
        [sr_x, 0],
        [sr_x, sr_inset_y1],
        [sr_x - sr_inset_x, sr_inset_y2],
        [sr_x - sr_inset_x, sr_y],
        [sr_inset_x, sr_y],
        [sr_inset_x, sr_inset_y2],
        [0, sr_inset_y1],
    ]);
}

module cover_cable_tie_holes() {
    difference() {
        translate([-sr_x / 4, 15, 0])
        square([sr_x / 2, 10]);
        projection(cut=true)
        translate([0, 0, -sr_lid_z1])
        sovol_strain_relief_cover_part();
    }
}

module cover_holes() {
    offset(delta=0.5)
    union() {
        cover_cable_tie_holes();
        projection(cut=true)
        translate([0, 0, -sr_lid_z2])
        sovol_strain_relief_cover_part();
    }
}

module cover_block() {
        linear_extrude(height=sr_lid_z2 + thick)
        offset(r=thick / 2)
        offset(r=-thick / 2)
        offset(delta=thick)
        strain_relief_outline_shape();
}

module cover_block_reduced() {
    render(convexity=2)
    difference() {
        union() {
            cover_block();

            translate([0, max(cut_y + groove_radius, sr_inset_y1 + (cut_y - sr_inset_y1) / 2), cut_z])
            rounded_groove_part();
        }

        linear_extrude(height=sr_z) {
            translate([-sr_x, sr_y])
            square([sr_x * 2, thick * 2]);
            square([sr_x * 2, cut_y * 2], center=true);
            cover_holes();
        }

        linear_extrude(height=sr_lid_z1)
        offset(delta=-0.5)
        union() {
            strain_relief_outline_shape();
            translate([-sr_x / 2 + sr_inset_x, sr_y])
            square([guide_x, sr_y]);
        }
    }
}

module cover_base() {
    color("lavender", 0.8)
    render(convexity=2)
    difference() {
        translate([0, 0, -cut_z])
        difference() {
            cover_block_reduced();
            sovol_strain_relief_cover_part();
        }
        translate([0, sr_y / 2, -sr_z])
        cube([sr_x * 2, sr_y * 2, sr_z * 2], center=true);
    }
}

module cable_guide_shape_basic() {
    projection(cut=true)
    rotate([90, 0, 0])
    translate([0, -sr_y, 0])
    cover_base();
}

module cable_guide_shape_edges() {
    difference() {
        hull()
        cable_guide_shape_basic();
        square([cable_diameter, guide_y * 2], center=true);
    }
}

module cable_channel_shape() {
    hull() {
        circle(cable_diameter / 2);
        translate([0, -cable_diameter / 4])
        circle(cable_diameter / 2);
    }
}

module cable_guide_shape() {
    difference() {
        translate([0, -guide_y / 2])
        square([guide_x + thick * 2, guide_y], center=true);
        cable_channel_shape();
    }
}

module cable_guide_foot_angled_cut() {
    cut_size = outset * sqrt(2);
    // Angled cut
    translate([0, sr_y + guide_y - (cut_size - outset) + squash, 0])
    rotate([0, -90, 0])
    linear_extrude(guide_x * 2, center=true)
    polygon([[0, -cut_size / 4], [0, cut_size], [cut_size, cut_size]]);
}

module cable_guide_foot() {
    difference() {
        // Square foot
        union() {
            translate([0, sr_y + outset + guide_y, 0])
            linear_extrude(height=outset + extend)
            cable_guide_shape_edges();

            translate([0, sr_y, 0])
            rotate([-90, 0, 0])
            linear_extrude(height=outset + guide_y)
            cable_guide_shape_edges();
        }

        // Bottom foot cut to expose upper curve half
        cube([sr_x * 2,  sr_y * 4, outset * sqrt(2) - squash], center=true);

        cable_guide_foot_angled_cut();
    }
}

module cable_guide_cable_tie_holes() {
    // Cable tie holes
    linear_extrude(height=sr_y, center=true, scale=1.5)
    translate([0, -20, 0])
    offset(delta=0.5)
    cover_cable_tie_holes();
}

module cable_guide_cable_tie_holes_smoothed() {
    // Basic holes
    cable_guide_cable_tie_holes();
    // Smooth cable guide tie hole overhangs for easier printing
    difference() {
        hull()
        cable_guide_cable_tie_holes();
        translate([0, 0, sr_y / 2 - thick * sqrt(2)])
        cube([sr_x, sr_z, sr_y], center=true);
    }
}

module cable_guide_channel_top() {
    linear_extrude(height=extend)
    cable_guide_shape();
    difference() {
        translate([0, 0, extend - groove_radius * 1.5])
        rotate([90, 0, 0])
        rounded_groove_part(guide_x);

        linear_extrude(height=extend)
        translate([0, -guide_y / 2])
        square([guide_x, guide_y], center=true);
    }
}

module cable_guide_channel() {
    // Curved channel
    translate([0, sr_y, base_interior_z + outset])
    rotate([0, 90, 0])
    rotate_extrude(angle=90)
    translate([base_interior_z + outset, 0])
    mirror([1, 0])
    rotate(90)
    cable_guide_shape();

    // Extended top
    translate([0, sr_y + base_interior_z + outset, base_interior_z + outset])
    cable_guide_channel_top();
}

module cable_guide_cable_tie_holes_cut() {
    difference() {
        children();

        // Cable tie holes at 90 degrees
        translate([
            0,
            sr_y + outset,
            (
                base_interior_z + guide_attach_z_adjust
                + outset + extend / (2 * sqrt(2))
            )
        ])
        rotate([90, 0, 0])
        translate([0, 0, squash])
        cable_guide_cable_tie_holes_smoothed();

        if (Extra_Cable_Tie_Holes) {
            // Cable tie holes at 45 degrees
            translate([
                0,
                sr_y + minoutset / sqrt(2),
                base_interior_z + guide_attach_z_adjust - cut_z * 2
            ])
            rotate([45, 0, 0])
            translate([0, 0, thick * sqrt(2) + squash / sqrt(2)])
            cable_guide_cable_tie_holes();
        }
    }
}

module outer_cable_tie_groove() {
    w = 3;

    difference() {
        translate([0, sr_inset_y2 + w, 0])
        for (yoffset = [-groove_radius, 3 + groove_radius])
        translate([0, yoffset, 0])
        rounded_groove_part(guide_x);

        linear_extrude(height=sr_lid_z2)
        strain_relief_outline_shape();
    }
}

module cable_guide() {
    color("lemonchiffon", 0.6)
    render(convexity=2)
    difference() {
        translate([0, -squash, guide_attach_z_adjust])
        union() {
            cable_guide_channel();
            cable_guide_foot();
        }
        // Subtract any part intersecting with the base interior
        cube([sr_x * 2, sr_y * 2, sr_lid_z2 * 2], center=true);
    }
}

module new_part() {
    color("#94c5db", 0.8)
    translate([0, -cut_y, 0]) {
        render(convexity=2)
        cable_guide_cable_tie_holes_cut() {
            cover_base();
            cable_guide();
            outer_cable_tie_groove();
        }
    }
}

module orient_part() {
    if (Print_Orientation) {
        ht = (sr_y - cut_y) + outset + guide_y - squash;
        translate([0, 0, ht])
        rotate([-90, 0, 0])
        children();
    } else {
        children();
    }
}

module main() {
    orient_part()
    new_part();
}

main();
