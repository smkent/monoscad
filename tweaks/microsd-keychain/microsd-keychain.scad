/*
 * MicroSD card holder keychain
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons (4.0 International License) Attribution-NonCommercial
 */

/* [Rendering Options] */

Part = "both"; // [both: Both parts, microsd_holder: Micro SD holder, cap: Cap]

/* [Options] */

Keychain_Loop_Part = "cap"; // [microsd_holder: Micro SD holder, cap: Cap side, none: No keychain loop]
Keychain_Loop_Thickness = 2; // [2:0.1:4]
Keychain_Loop_Height = 2; // [2:0.1:6]

Micro_SD_Side_Logo_Inset = "guido"; // [guido: Guido's logo, microsd: Micro SD logo, none: No logo]
Cap_Logo_Inset = "microsd"; // [guido: Guido's logo, microsd: Micro SD logo, none: No logo]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4 / 4;

// Modules //

module original_cap() {
    color("lightblue", 0.8)
    translate([0.83, -1.50, -0.017])
    render(convexity=4)
    difference() {
        import("Guido-microsd-keychain-bottom.stl", convexity=4);
        mirror([0, 0, 1])
        linear_extrude(height=50)
        square(50, center=true);
    }
}

module original_microsd_holder() {
    color("plum", 0.8)
    rotate(7.2)
    import("Guido-microsd-keychain-top.stl", convexity=4);
}

module keychain_loop_base_shape() {
    hull()
    for (tx = [15, 5])
    translate([tx, 0])
    circle(r=10);
}

module keychain_loop_base(edge_radius=0) {
    kl = Keychain_Loop_Thickness;
    kh = Keychain_Loop_Height;
    translate([0, 0, edge_radius])
    linear_extrude(height=kh - edge_radius * 2)
    offset(delta=-edge_radius)
    difference() {
        keychain_loop_base_shape();
        offset(delta=-kl)
        keychain_loop_base_shape();
        circle(r=9);
    }
}

module keychain_loop() {
    edge_radius = 0.7;
    rotate(-50)
    color("plum", 0.4)
    minkowski() {
        keychain_loop_base(edge_radius);
        sphere(r=edge_radius);
    }
}

module outer_edge() {
    render(convexity=2)
    for (rot = [0, 360/25*12])
    rotate(rot)
    intersection() {
        original_cap();
        linear_extrude(height=3)
        difference() {
            circle(r=14);
            circle(r=10.0);
            rotate(225)
            translate([-15, 3])
            square([30, 30]);
        }
    }
}

module logo_cut(logo="none") {
    render(convexity=4)
    difference() {
        union() {
            children();
            linear_extrude(height=0.5)
            circle(r=10);
        }
        linear_extrude(height=0.7, center=true)
        if (logo == "microsd") {
            microsd_logo_cut();
        } else if (logo == "guido") {
            guido_logo_cut();
        }
    }
}

module microsd_holder() {
    color("plum", 0.8)
    union() {
        logo_cut(Micro_SD_Side_Logo_Inset)
        original_microsd_holder();
        if (Keychain_Loop_Part == "microsd_holder") {
            keychain_loop();
        }
    }
}

module cap() {
    color("lightblue", 0.8)
    render(convexity=4)
    union() {
        logo_cut(Cap_Logo_Inset)
        union() {
            difference() {
                original_cap();
                linear_extrude(height=2.8 * 2, center=true)
                difference() {
                    circle(r=14 * 3);
                    circle(r=10.1);
                }
            }
            outer_edge();
        }
        if (Keychain_Loop_Part == "cap") {
            keychain_loop();
        }
    }
}

module microsd_logo_cut() {
    render(convexity=4)
    projection(cut=true)
    translate([0, 0, -0.1])
    difference() {
        linear_extrude(height=1)
        circle(r=9.8);
        original_cap();
    }
}

module guido_logo_cut() {
    render(convexity=4)
    projection(cut=true)
    translate([0, 0, -0.1])
    difference() {
        linear_extrude(height=1)
        circle(r=9.8);
        original_microsd_holder();
    }
}

module main() {
    if (Part == "both") {
        translate([-15, 0, 0])
        cap();
        translate([15, 0, 0])
        microsd_holder();
    } else if (Part == "microsd_holder") {
        microsd_holder();
    } else if (Part == "cap") {
        cap();
    }
}

main();
