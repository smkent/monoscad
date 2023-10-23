include <modules.scad>;
use <segment.scad>;
use <120mm-fan.scad>;
use <flange.scad>;

Inner_Diameter = 100; // [20:1:100]

module __end_customizer_options__() { }

// Constants

spacing = 100 * 1.5;

// Modules

module place_part(x, y) {
    translate([spacing * x, spacing * y, 0])
    children();
}

module center_demo(max_x, max_y) {
    translate([-spacing * max_x / 2, -spacing * max_y / 2, 0])
    children();
}

module modular_hose_demo(id) {
    place_part(0, 0)
    modular_hose_segment(id);

    place_part(0, 1)
    modular_hose_part(id)
    modular_hose_connector();

    place_part(1, 0)
    modular_hose_120mm_fan(id, model_type=0, connector_type=1);

    place_part(1, 1)
    modular_hose_flange(id, model_type=0, connector_type=2, magnet_holes=1, screw_holes=1);
}

center_demo(1, 1)
modular_hose_demo(Inner_Diameter);
