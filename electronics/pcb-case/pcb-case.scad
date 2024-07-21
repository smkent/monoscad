/*
 * PCB Project Case
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

/* [Rendering Options] */
Print_Orientation = true;

/* [Model Options] */
PCB_Type = "3x7"; // [3x7: 3x7 cm]

/* [Size] */
// All units in millimeters

/* [Advanced Options] */

/* [Development Toggles] */

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

pcb_table = [
    ["3x7", [[30, 70], 2, 2]],
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

module main() {
    color("darkseagreen", 0.9)
    pcb();
}

main();
