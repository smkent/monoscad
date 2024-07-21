/*
 * PCB Project Case
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;
Show_PCB = true;

/* [Model Options] */
PCB_Type = "3x7"; // [3x7: 3x7 cm]

/* [Size] */
PCB_Top_Height = 25; // [10:1:50]

PCB_Bottom_Height = 5; // [0:0.1:50]

// If 0, use the board's screw diameter
PCB_Screw_Hole_Diameter = 3.2; // [0:0.1:10]

Mount_Screw_Hole_Diameter = 4; // [1:0.1:10]

Thickness = 3; // [1:0.1:10]

Border = 1.6; // [0:0.1:10]

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

slop = 0.001;

pcb_thickness = 1.6;
inner_height = pcb_thickness + PCB_Bottom_Height + PCB_Top_Height;
outer_height = Thickness * 2 + inner_height;

pcb_table = [
    ["3x7", [[70, 30], 2, 2]],
];

pcb_spec = vsearch(pcb_table, PCB_Type);
assert(pcb_spec, str("Unknown pcb type '", PCB_Type, "'"));

pcb_size = pcb_spec[0];
pcb_screw_d = pcb_spec[1];
pcb_screw_hole_d = (
    PCB_Screw_Hole_Diameter > 0 ? PCB_Screw_Hole_Diameter : pcb_screw_d
);
pcb_screw_inset = pcb_spec[2];

base_screw_hole_d = Mount_Screw_Hole_Diameter;

// Functions //

function vec_add(vector, add) = [for (v = vector) v + add];

function vsearch(vec, term) = (
    let (r = [for (i = vec) if (i[0] == term) i])
    len(r) == 1 ? r[0][1] : undef
);

// Modules //

module at_pcb_screws() {
    for (mx = [0, 1])
    for (my = [0, 1])
    mirror([mx, 0])
    mirror([0, my])
    translate(vec_add(pcb_size / 2, -pcb_screw_inset))
    children();
}

module at_mount_screws() {
    for (mx = [0, 1])
    mirror([mx, 0])
    translate([pcb_size.x / 2 + Border * 2 + base_screw_hole_d / 2, 0])
    children();
}

module pcb() {
    linear_extrude(height=1.6)
    difference() {
        square(pcb_size, center=true);
        at_pcb_screws()
        circle(d=pcb_screw_d);
    }
}

module base_plate() {
    linear_extrude(height=Thickness)
    difference() {
        hull() {
            offset(r=pcb_screw_d * 2)
            offset(r=-pcb_screw_d * 2)
            square(vec_add(pcb_size, pcb_screw_d * 2 + Border * 2), center=true);
            at_mount_screws()
            circle(d=base_screw_hole_d * 3);
        }
        at_mount_screws()
        circle(d=base_screw_hole_d);
    }
}

module pcb_screw_risers() {
    translate([0, 0, Thickness])
    at_pcb_screws()
    difference() {
        cylinder(
            h=PCB_Bottom_Height,
            d1=pcb_screw_d * 4 + min(PCB_Bottom_Height, Border * 2),
            d2=pcb_screw_d * 4,
        );
        cylinder(h=PCB_Bottom_Height + slop, d=pcb_screw_hole_d);
    }
}

module base() {
    base_plate();
    pcb_screw_risers();
}

module main() {
    color("mintcream", 0.9)
    base();
    if (Show_PCB && $preview)
    translate([0, 0, PCB_Bottom_Height + Thickness])
    color("darkseagreen", 0.3)
    pcb();
}

main();
