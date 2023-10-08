/*
 * Segmented Modular Hose
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Hose segment model
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <modules.scad>;

/* [Model Options] */

// Render a full segment or just one of the connector ends
Connector_Type = 0; // [0: Both, 1: Male, 2: Female]

// Inner diameter at the center (connector attachment point)
Inner_Diameter = 100;

// Optional extra hose length to add between the segment connectors
Extra_Segment_Length = 0; // [0:1:200]

/* [Advanced Size Adjustment] */
// All units in millimeters

// Wall thickness, a multiple of nozzle size is recommended
Thickness = 0.8; // [0.2:0.1:5]

// Increase the female connector diameter this much to adjust fit
Size_Tolerance = 0.0; // [0:0.1:2]

/* [Development Options] */
Render_Mode = 0; // [0: Normal, 1: Half, 2: 2D shape]

module __end_customizer_options__() { }

// Modules

module main() {
    modular_hose_init(Inner_Diameter, Thickness, Size_Tolerance, Render_Mode) {
        rotate([0, -90, 0]) {
            if (Connector_Type == 0 || Connector_Type == 1) {
                translate([Connector_Type == 0 ? Extra_Segment_Length / 2 : 0, 0, 0])
                connector(female=false);
            }
            if (Connector_Type == 0 || Connector_Type == 2) {
                mirror([1, 0, 0])
                translate([Connector_Type == 0 ? Extra_Segment_Length / 2 : 0, 0, 0])
                connector(female=true);
            }
        }
        color("slategray", 0.8)
        if (Extra_Segment_Length) {
            mirror([(Connector_Type == 2 ? 1 : 0), 0, 0])
            translate([0, 0, -Extra_Segment_Length / (Connector_Type == 0 ? 2 : 1)])
            linear_extrude(height=Extra_Segment_Length)
            difference() {
                circle(Inner_Diameter / 2 + Thickness);
                circle(Inner_Diameter / 2);
            }
        }
    }
}

main();
