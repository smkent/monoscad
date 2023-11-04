/*
 * Customizable and Parametric Rugged Storage Box
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Rugged storage box tutorial example
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-ShareAlike
 */

include <rugged-box-library.scad>;

/* [Tutorial] */
Tutorial_Step = 5; // [1: 1 - Battery shape, 2: 2 - Battery cutouts, 3: 3 - Rugged box initialization, 4: 4 - Solid box interior, 5: 5 - Finished example]

module tutorial_step_2() {

    module battery_holes() {
        battery_diameter = 15;
        for (mirror_x = [0:1:1], mirror_y = [0:1:1]) {
            mirror([0, mirror_y, 0])
            mirror([mirror_x, 0, 0])
            translate([
                battery_diameter / 2 + 1,
                battery_diameter / 2 + 1,
                0
            ])
            cylinder(50, battery_diameter / 2, battery_diameter / 2);
        }
    }

    color("lightblue")
    battery_holes();

}

module tutorial_step_5() {

    module battery_holes() {
        battery_diameter = 15;
        for (mirror_x = [0:1:1], mirror_y = [0:1:1]) {
            mirror([0, mirror_y, 0])
            mirror([mirror_x, 0, 0])
            translate([
                battery_diameter / 2 + 1,
                battery_diameter / 2 + 1,
                0
            ])
            cylinder(50, battery_diameter / 2, battery_diameter / 2);
        }
    }

    rbox(40, 40, 40)
    rbox_bottom() {
        difference() {
            rbox_interior();
            color("lightblue")
            battery_holes();
        }
    }

}

if (Tutorial_Step == 1) {

    battery_diameter = 15;
    color("lightblue")
    cylinder(50, battery_diameter / 2, battery_diameter / 2);

} else if (Tutorial_Step == 2) {

    tutorial_step_2();

} else if (Tutorial_Step == 3) {

    rbox(40, 40, 40)
    rbox_bottom();

} else if (Tutorial_Step == 4) {

    rbox(40, 40, 40)
    rbox_bottom() {
        rbox_interior();
    }

} else if (Tutorial_Step == 5) {

    tutorial_step_5();

}
