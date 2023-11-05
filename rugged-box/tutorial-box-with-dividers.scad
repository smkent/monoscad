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
Tutorial_Step = 7; // [1: 1 - Rugged box initialization, 2: 2 - Divider module, 3: 3 - Rounded divider module, 4: 4 - Two dividers, 5: 5 - Rugged box interior shape, 6: 6 - Fit dividers to interior shape, 7: 7 - Complete box bottom, 8: 8 - Complete parts set]

module tutorial_step_2() {

    module divider() {
        divider_length = $b_curved_inner_width;
        rbox_for_interior()
        translate([0, 0, $b_inner_height / 2])
        cube([divider_length, $b_wall_thickness, $b_inner_height], center=true);
    }

    rbox(60, 40, 30, 10)
    rbox_for_bottom() {
        color("yellow")
        divider();
    }

}

module tutorial_step_3() {

    module divider() {
        divider_length = $b_curved_inner_width;
        rotate([90, 0, 90])
        translate([0, 0, -divider_length / 2])
        linear_extrude(height=divider_length)
        offset($b_edge_radius)
        offset(-$b_edge_radius)
        translate([0, $b_outer_height / 2])
        square([$b_wall_thickness, $b_outer_height], center=true);
    }

    rbox(60, 40, 30, 10)
    rbox_for_bottom() {
        color("yellow")
        divider();
    }

}

module tutorial_step_4() {

    module divider() {
        divider_length = max($b_curved_inner_length, $b_curved_inner_width);
        rotate([90, 0, 90])
        translate([0, 0, -divider_length / 2])
        linear_extrude(height=divider_length)
        offset($b_edge_radius)
        offset(-$b_edge_radius)
        translate([0, $b_outer_height / 2])
        square([$b_wall_thickness, $b_outer_height], center=true);
    }

    rbox(60, 40, 30, 10)
    rbox_for_bottom() {
        color("yellow")
        for (rot = [0:1:1]) {
            rotate([0, 0, rot ? 90 : 0])
            divider();
        }
    }

}

module tutorial_step_6() {

    module divider() {
        divider_length = max($b_curved_inner_length, $b_curved_inner_width);
        rotate([90, 0, 90])
        translate([0, 0, -divider_length / 2])
        linear_extrude(height=divider_length)
        offset($b_edge_radius)
        offset(-$b_edge_radius)
        translate([0, $b_outer_height / 2])
        square([$b_wall_thickness, $b_outer_height], center=true);
    }

    rbox(60, 40, 30, 10)
    rbox_for_bottom() {
        color("yellow")
        intersection() {
            rbox_interior();
            for (rot = [0:1:1]) {
                rotate([0, 0, rot ? 90 : 0])
                divider();
            }
        }
    }

}

module tutorial_step_7() {

    module divider() {
        divider_length = max($b_curved_inner_length, $b_curved_inner_width);
        rotate([90, 0, 90])
        translate([0, 0, -divider_length / 2])
        linear_extrude(height=divider_length)
        offset($b_edge_radius)
        offset(-$b_edge_radius)
        translate([0, $b_outer_height / 2])
        square([$b_wall_thickness, $b_outer_height], center=true);
    }

    rbox(60, 40, 30, 10)
    rbox_bottom() {
        color("yellow")
        render()
        intersection() {
            rbox_interior();
            for (rot = [0:1:1]) {
                rotate([0, 0, rot ? 90 : 0])
                divider();
            }
        }
    }

}

module tutorial_step_8() {

    module divider() {
        divider_length = max($b_curved_inner_length, $b_curved_inner_width);
        rotate([90, 0, 90])
        translate([0, 0, -divider_length / 2])
        linear_extrude(height=divider_length)
        offset($b_edge_radius)
        offset(-$b_edge_radius)
        translate([0, $b_outer_height / 2])
        square([$b_wall_thickness, $b_outer_height], center=true);
    }

    rbox(60, 40, 30, 10) {
        rbox_bottom() {
            color("yellow")
            render()
            intersection() {
                rbox_interior();
                for (rot = [0:1:1]) {
                    rotate([0, 0, rot ? 90 : 0])
                    divider();
                }
            }
        }

        translate([80, 0, 0])
        rbox_top();

        translate([-80, 0, 0])
        rbox_latch();
    }

}


if (Tutorial_Step == 1) {

    rbox(60, 40, 30)
    rbox_bottom();

} else if (Tutorial_Step == 2) {

    tutorial_step_2();

} else if (Tutorial_Step == 3) {

    tutorial_step_3();

} else if (Tutorial_Step == 4) {

    tutorial_step_4();

} else if (Tutorial_Step == 5) {

    rbox(60, 40, 30)
    rbox_for_bottom() {
        rbox_interior();
    }

} else if (Tutorial_Step == 6) {

    tutorial_step_6();

} else if (Tutorial_Step == 7) {

    tutorial_step_7();

} else if (Tutorial_Step == 8) {

    tutorial_step_8();

}
