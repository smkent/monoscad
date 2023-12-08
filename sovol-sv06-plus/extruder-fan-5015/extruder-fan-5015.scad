/*
 * Sovol SV06 (Plus) 5015 extruder fan duct
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial
 */

use <5015-mp1584-backpack.scad>;

/* [Rendering Options] */

Render_Mode = "print"; // [print: Print orientation, normal: Installation orientation, preview: Installed preview, preview_with_backpack: Installed preview with MP1584 backpack]

/* [Options] */

Eyelet_Type = "bolt"; // [bolt: M4 bolts, insert: M4 hot-melt threaded inserts w/ 5.2mm OD]

Eyelet_Support_Hole = true;

Second_Screw_Eyelet = true;

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa / 4 : 2;
$fs = $preview ? $fs : 0.4;

slop = 0.01;

origin_pos = [9, 3, 21];
eyelet_origin_pos = [53.105, 0, -15.0];

// Modules //

module original_model() {
    color("lightblue", 0.8)
    translate([0, 0, 0.026181])
    rotate(-90)
    import("leander-perez-blanco-extruder_cooling_fan_5015_V2-modified-duct.stl", convexity=4);
}

module original_model_with_patched_arm() {
    color("lightblue", 0.8)
    render(convexity=4) {
        rotate(-20)
        translate([-10, 0, -21])
        intersection() {
            translate([20, -1, 0])
            cube([10, 1.58 + 1, 10]);
            rotate(20)
            translate([0, 0, 21])
            original_model();
        }
        original_model();
    }
}

module original_model_plate_patch() {
    children();
    translate(-origin_pos)
    translate([10.5, 0, 1])
    cube([37, 3, 40]);
}

module original_4010_fan_plate() {
    color("plum", 0.6)
    rotate(-90)
    translate([-5 - 1, 0, -6.131])
    import("sovol-sv06-JXHSV06-08021-d fan installation plate.STL", convexity=4);
}

module fan_model_5015() {
    color("#ccc", 0.6)
    translate([25.4, 0, 28.5])
    rotate([0, -90, 0])
    import("FarmerKGBOfficer-5015-blower-fan.stl", convexity=4);
}

module move20(translation) {
    rotate(-20)
    translate(translation)
    rotate(20)
    children();
}

module original_4010_fan_plate_base() {
    render(convexity=4)
    intersection() {
        original_4010_fan_plate();
        cube(50);
    }
}

module fan_plate_profile_shape() {
    projection(cut=true)
    translate([0, 0, 30])
    rotate([0, 90, 0])
    original_4010_fan_plate_base();
}

module fan_plate_blank() {
    color("lightgreen", 0.6)
    render(convexity=4)
    intersection() {
        intersection() {
            hull()
            original_4010_fan_plate_base();
            translate([0, 0, 42.052273])
            mirror([0, 0, 1])
            hull()
            original_4010_fan_plate_base();
        }
        union() {
            original_4010_fan_plate_base();
            rotate([0, -90, 0])
            mirror([0, 0, 1])
            linear_extrude(height=10)
            fan_plate_profile_shape();
        }
    }
}

module plate_holes_cut() {
    difference() {
        children();
        translate(-origin_pos)
        difference() {
            translate([5, 0, 6])
            cube([30, 3, 30]);
            intersection() {
                translate([5, 0, 6])
                cube([30, 3, 30]);
                fan_plate_blank();
            }
        }
        // Upper hole extension
        translate([16 - 9, -3, 42.05 / 2 - 10])
        rotate([90, 0, 0])
        cylinder(d=7.0, h=10);
    }
}

module original_model_duct_assembly() {
    rotate(-20)
    intersection() {
        rotate(20)
        original_model_plate_patch()
        original_model_with_patched_arm();
        union() {
            translate([8, -20 + 1.58, -28.5])
            difference() {
                cube([60, 20, 30]);
                translate([1.6, 0, 14.6])
                translate([0, 0, -0.3])
                cube([10, 30, 40]);
            }
            translate([53.2, 0, -14.8])
            rotate([90, 0, 0])
            cylinder(d=10.3, h=20, center=true);
        }
    }
}

module original_model_fan_eyelet_shape() {
    projection(cut=true)
    translate(-eyelet_origin_pos)
    intersection() {
        rotate(20)
        original_model_plate_patch()
        original_model_with_patched_arm();
        union() {
            translate([53.2, 0, -14.8])
            rotate([90, 0, 0])
            intersection() {
                cylinder(d=14, h=20, center=true);
                rotate(20)
                translate([-1, -12, -12])
                cube(24);
            }
        }
    }
}

module original_model_fan_eyelet() {
    rotate(-20)
    translate(eyelet_origin_pos)
    rotate([0, 90, 90])
    rotate_extrude(angle=360)
    original_model_fan_eyelet_shape();
}

module scaled_eyelet() {
    rotate(-20)
    translate(eyelet_origin_pos)
    translate([0, -0.42, 0])
    scale([1, 1.5])
    translate([0, 0.42, 0])
    translate(-eyelet_origin_pos)
    rotate(20)
    original_model_fan_eyelet();
}

module original_model_fan_eyelet_hole(resize=1) {
    rotate(-20)
    translate(eyelet_origin_pos)
    rotate([0, 90, 90])
    rotate_extrude(angle=360)
    translate([0, -(resize - 1) * 4 / 4])
    scale([1, resize])
    difference() {
        translate([0, -0.42])
        square([2.05, 4]);
        original_model_fan_eyelet_shape();
    }
}

module original_model_duct_cut() {
    difference() {
        children();
        difference() {
            rotate(-20)
            mirror([0, 1, 0]) {
                translate([10, -1.58, -30])
                cube([60, 20, 60]);
                translate([48, -10, -30])
                cube([60, 40, 60]);
            }
            translate([0, -8, -50])
            cube(100);
        }
    }
}

module duct_profile_shape() {
    projection(cut=true)
    rotate([0, -90, 0])
    translate(-origin_pos)
    rotate(20)
    original_model_duct_assembly();
}

module extended_duct_assembly(length=0) {
    difference() {
        union() {
            move20([length, 0, 0])
            original_model_duct_assembly();
            if (length > 0) {
                rotate(-20)
                translate(origin_pos)
                rotate([0, 90, 0])
                linear_extrude(height=length + slop)
                duct_profile_shape();
            }
        }
        // Widen fan exhaust insert fitting
        inlet_dimensions = [15 + 0.2, 20];
        rotate(-20)
        translate([9, -0.42494 * 1.2, 0])
        rotate([-90, 0, -90])
        translate(inlet_dimensions / 2)
        linear_extrude(height=3.1, scale=[(15 + 0.2) / 15, (20 + 0.2) / 20])
        square(inlet_dimensions, center=true);
    }
}

module second_5015_fan_eyelet() {
    move20([-38, 0, 43])
    move20([2.4, 0, 0])
    if (Eyelet_Type == "insert") {
        scaled_eyelet();
    } else {
        original_model_fan_eyelet();
    }
}

module second_5015_fan_eyelet_base() {
    intersection() {
        second_5015_fan_eyelet();
        rotate(-20)
        translate([0, 1.5751, 0])
        mirror([0, 1, 0])
        cube([100, 2, 100]);
    }
}

module plate_y_cut() {
    difference() {
        children();
        union() {
            translate([-100, 0, -100])
            cube(200);
        }
    }
}

module second_5015_fan_eyelet_support() {
    fold_x = 2 / tan(20);
    mv = 9;
    second_5015_fan_eyelet();
    difference() {
        union() {
            hull() {
                move20([-mv, 0, -mv])
                second_5015_fan_eyelet_base();
                second_5015_fan_eyelet_base();
            }
            hull() {
                rotate(-20)
                rotate([90, 0, 0])
                translate([0, 0, -1.5751])
                translate([0, 0, 0.1])
                linear_extrude(height=2 - 0.2)
                translate([12.4, 0] - [fold_x, 0])
                polygon(points=[
                    [0, 21],
                    [0, 11],
                    [fold_x + 0, 21],
                ]);
                move20([-mv, 0, -mv])
                second_5015_fan_eyelet_base();
                translate([0, -1, 20.026])
                mirror([0, 1, 0])
                cube([15, 2, 1]);
            }
        }
        move20([-38, 0, 43])
        move20([2.4, 0, 0])
        original_model_fan_eyelet_hole(resize=1.1);
    }
}

module eyelet_support_base_hole() {
    difference() {
        children();
        if (Eyelet_Support_Hole)
        linear_extrude(height=100, center=true) {
            ww = 23;
            offset(delta=0.5)
            offset(r=1)
            offset(r=-1)
            difference() {
                mirror([0, 1])
                translate([17, 3.5])
                polygon(points=[
                    [0, 0], [ww, 0], [ww, ww * tan(20)]
                ]);
                translate([45, -5, 0])
                circle(d=20);
            }
        }
    }
}

module bolt_eyelet_holes() {
    if (Eyelet_Type == "insert") {
        difference() {
            union() {
                children();
                move20([2.4, 0, 0])
                scaled_eyelet();
            }
            for (mv = [[2.4, 0, 0], [-38 + 2.4, 0, 43]])
            move20(mv)
            rotate(-20)
            translate(eyelet_origin_pos)
            rotate([90, 0, 0])
            cylinder(h=20, d=5.2, center=true);
        }
    } else {
        children();
    }
}

module extruder_fan_duct_construction() {
    bolt_eyelet_holes() {
        eyelet_support_base_hole()
        original_model_plate_patch()
        original_model_duct_cut()
        original_model();
        extended_duct_assembly(length=2.4);
        if (Second_Screw_Eyelet) {
            plate_y_cut()
            second_5015_fan_eyelet_support();
        }
    }
}

module extruder_fan_duct() {
    color("lightblue", 0.8)
    render(convexity=4)
    plate_holes_cut()
    mirror([0, 0, 1])
    difference() {
        extruder_fan_duct_construction();
        // Remove slight bend overhang from Blender edit
        translate([-100 - 9 + slop, 0, 0])
        cube(200, center=true);
    }
}

module fan_5015_placed() {
    if ($preview)
    rotate(-20)
    translate([10.15, -15, 0])
    translate([2.4, 15, 20.5])
    rotate([180, 0, 0])
    fan_model_5015();
}

module main() {
    if (Render_Mode == "print") {
        rotate([180, 0, 0])
        extruder_fan_duct();
    } else {
        extruder_fan_duct();
        if ($preview)
        rotate(Render_Mode == "preview_with_backpack" ? [-1*0, 0, -1] : 0)
        if (Render_Mode == "preview" || Render_Mode == "preview_with_backpack") {
            fan_5015_placed();
            if (Render_Mode == "preview_with_backpack") {
                rotate(-20)
                translate([38, 0, -8])
                rotate([90, 0, 180])
                rotate(0.5)
                mp1584_5015_backpack();
            }
        }
    }
}

main();
