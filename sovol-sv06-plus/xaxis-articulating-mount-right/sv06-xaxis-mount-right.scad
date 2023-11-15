/*
 * Articulating Camera X-Axis Right-Side Mount for Sovol SV06 and SV06 Plus
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution
 */

/* [Options] */

Printer = "sv06plus"; // [sv06: Sovol SV06, sv06plus: Sovol SV06 Plus]

Link_Type = "female"; // [none: X-Axis fitting only, blank: Blank slab, male: Male, female: Female, female_flipped: Female flipped]

Position_Shift_Percent = 0; // [0:1:100]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

// Modules //

x = 41.49;
y = 43.70;
z = 60.65;

ymin = 34.613;
ymax = 43.7;

sx = 53.05;
sy = 9.08;
sz = 30;

newx = 51 - 4;
newy = 4;

slop = 0.1;
x1 = 9.5;
x2 = 57.5;
xdelta = x2 - x1;

cutoff = (Printer == "sv06plus" ? 6 : 2);

module original_part_slice() {
    color("cyan", 1.0)
    translate([200, 200, -0.15])
    if (Printer == "sv06plus") {
        import("sovol-sv06plus-x-axis-tensioning-mount-slice.stl");
    } else if (Printer == "sv06") {
        import("sovol-sv06-x-axis-tensioning-mount-slice.stl");
    }
}

module bounding_box() {
    linear_extrude(height=z)
    translate([0, ymin])
    square([x - 0.5, ymax - ymin + 0.5]);
}

module slice_box() {
    translate([0, 0, 0])
    cube([sx, sy, sz - cutoff]);
}

module more_slice() {
    translate([51.5 - 0.5, 0, 0])
    rotate([0, -3, 0])
    cube([x, y, z]);

    translate([4, 0, 0])
    mirror([1, 0, 0])
    rotate([0, -3, 0])
    cube([x, y, z]);

    translate([0, 7, sz - cutoff - 2])
    rotate([45, 0, 0])
    cube([x * 2, 10, 10]);
}

module part() {
    difference() {
        slice_box();

        translate([53.05, 0, 0])
        rotate([0, -90, 0])
        original_part_slice();

        more_slice();
    }
}

module links() {
    translate([0, 0, -28])
    translate([-19.05 / 2, -20 / 2, 0])
    translate([-2.02, 6.85, -0.35])
    import("sneaks-articulating-camera-mount-mflink-90.stl");
}

module mlink() {
    render()
    rotate([0, 0, 90])
    intersection() {
        translate([0, 0, -0.1])
        links();
        translate([-25, -25, 0])
        cube([50, 50, 50]);
    }
}

module flink() {
    render()
    intersection() {
        translate([0, 0, -3.5])
        mirror([0, 0, 1])
        intersection() {
            links();
            mirror([0, 0, 1])
            translate([-25, -25, 0])
            cube([50, 50, 50]);
        }
        translate([0, 0, 25])
        cube([50, 50, 50], center=true);
    }
}

module mlink_attach() {
    rotate_adj = (19.05 - 7.10) / 2;
    rr = 2.5 + rotate_adj * 2;
    linkx = 7.10 + rr;
    translate([rr/2, 0, 0])
    translate([(newx - linkx) * (Position_Shift_Percent / 100), 0, 0])
    translate([8 - 4.45, 0, 0])
    translate([0, 0, 19.05 / 2])
    rotate([90, 0, 0])
    mlink();
}

module flink_attach(flipped=false) {
    rr = 2.5;
    linkx = 19.05 + rr;
    translate([rr/2, 0, 0])
    translate([(newx - linkx) * (Position_Shift_Percent / 100), 0, 0])
    translate([12 - 2.475, 0, 20 / 2])
    rotate([90, 0, 0])
    rotate([0, 0, flipped ? 180 : 0])
    flink();
}

module part_base() {
    translate([-4.1, 0, 0])
    render(convexity=10)
    intersection() {
        translate([0, 0, -2])
        part();
        translate([0, -2.17, 0])
        union() {
            ends = 1;
            translate([(slop + ends) / 2, 0, 0])
            cube([sx - slop - ends, sy - slop, 8]);
            cut = 4;
            translate([0, cut, 8])
            cube([xdelta + ends * 4, sy - cut, sz - 10]);
        }
    }
}

module new_part_slab() {
    zr = 10;
    xx = newx;
    yy = newy;
    zz = (sz - 10) + zr;
    rr = zr / 4;
    intersection() {
        rd = rr / 4;
        adj = 0;
        r3 = rr / 2;
        hull() {
            for (pts = [
                [rr - adj, zz - zr - rr / 2],
                [xx - rr + adj, zz - zr - rr / 2],
                [rr + zr - rr / 2 - adj, zz - rr],
                [xx - zr - rr / 2 + adj, zz - rr],
            ]) {
                translate(concat(pts, [0]))
                rounded_cylinder(yy, rr, rd);
            }
            for (pts = [
                [0, 0],
                [xx - rr, 0],
            ]) {
                translate(concat(pts, [0]))
                cube([rr, rr, yy]);
            }
        }
    }
}

module rounded_cylinder(h, r, radius) {
    rotate_extrude(angle=360)
    union() {
        offset(r=radius)
        offset(delta=-radius)
        square([r, h]);
        square([r / 2, h]);
    }
}

module new_part() {
    if (Link_Type != "none") {
        rotate([90, 0, 0])
        new_part_slab();
        translate([0, -newy, 0])
        if (Link_Type == "male") {
            mlink_attach();
        } else if (Link_Type == "female") {
            flink_attach();
        } else if (Link_Type == "female_flipped") {
            flink_attach(flipped=true);
        }
    }
}

module main() {
    color("cyan", 0.8)
    part_base();
    color("mintcream", 0.6)
    new_part();
}

main();
