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

Thickness = 4;

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
pcb_screw_inset = pcb_spec[2];

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

module pcb() {
    linear_extrude(height=1.6)
    difference() {
        square(pcb_size, center=true);
        at_pcb_screws()
        circle(d=pcb_screw_d);
    }
}

module box_base() {
    difference() {
        linear_extrude(height=Thickness + PCB_Bottom_Height)
        square(vec_add(pcb_size, pcb_screw_d * 2 + Thickness), center=true);
        translate([0, 0, Thickness])
        linear_extrude(height=PCB_Bottom_Height + slop) {
            offset(r=pcb_screw_d * 3)
            offset(r=-pcb_screw_d * 3)
            difference() {
                square(vec_add(pcb_size, pcb_screw_d * 2), center=true);
                at_pcb_screws()
                circle(d=pcb_screw_d * 3);
            }
            at_pcb_screws()
            circle(d=pcb_screw_d);
        }
        translate([0, 0, Thickness + PCB_Bottom_Height])
        linear_extrude(height=inner_height)
        square(vec_add(pcb_size, pcb_screw_d * 2), center=true);
    }
}

module box() {
    box_base();
    if(0)
    linear_extrude(height=outer_height)
    square(vec_add(pcb_size, pcb_screw_d * 2 + Thickness), center=true);
}

module main() {
    color("mintcream", 0.9)
    box();
    if (Show_PCB && $preview)
    translate([0, 0, PCB_Bottom_Height + Thickness])
    color("darkseagreen", 0.3)
    pcb();
}

main();
