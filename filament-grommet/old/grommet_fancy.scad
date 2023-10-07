/* [Size] */
// All units in millimeters

Width = 100; // [10:10:500]
Height = 18.26; // [1:0.01:100]
Slot_Depth = 6.35; // [2:0.05:20]
Filament_Size = 1.75; // [1.75: 1.75mm, 3: 3mm]
Lip_Height = 2; // [1:1:10]
Grommet_Wall_Thickness = 1; // [1:1:10]

module __end_customizer_options__() { }

// Constants //

$fn = $preview ? 10 : 50;

// Modules //

module slot_shape(radius, width) {
    hull()
    for(m = [0:1]) {
        mirror([m, 0])
        translate([-Width/2, 0])
        circle(radius);
    }
}

module hull_stack(height, mirr=false, cut=false) {
    // Takes two children
    // Set the first child as the larger polygon
    slop = 0.001;
    translate([0, 0, mirr ? height : 0])
    mirror([0, 0, mirr ? 1 : 0])
    difference() {
        hull() 
        union() {
            translate([0, 0, -slop])
            linear_extrude(height=slop)
            children(0);

            translate([0, 0, height - slop])
            linear_extrude(height=slop)
            children(1);
        }
        if (!cut) {
            translate([0, 0, -slop])
            linear_extrude(height=slop)
            children(0);
        }
    }
    if (cut) {
        translate([0, 0, -slop])
        linear_extrude(height=slop)
        children(1);
    }
}

module grommet_interior_cut(top_radius, width, height) {
    curve_sz = top_radius * 2 - Filament_Size / 2;

    difference() {
        linear_extrude(height=height)
        slot_shape(top_radius, width);

        translate([-(width + top_radius * 2) / 2, -top_radius, height / 2])
        rotate([0, 90, 0])
        linear_extrude(height=width + top_radius * 2)
        scale([height / 2 / curve_sz, 1])
        circle(curve_sz);
    }
}


module part() {
    slot_top_radius = Slot_Depth / 2 - Grommet_Wall_Thickness;
    grommet_interior_cut(slot_top_radius, Width, Height);
}

module grommet() {
    ht = Lip_Height;
    fs = Filament_Size * 1.3;
    slot_top_radius = Slot_Depth / 2 - Grommet_Wall_Thickness;
    echo(Filament_Size, ht, slot_top_radius);

    difference() {
        union() {
            translate([0, 0, Height])
            hull_stack(ht, mirr=false) {
                slot_shape(Slot_Depth / 2 + ht * 2, Width);
                slot_shape(Slot_Depth / 2 + ht, Width);
            }
            difference() {
                linear_extrude(height=Height)
                slot_shape(Slot_Depth/2, Width);
                grommet_interior_cut(slot_top_radius, Width, Height);
            }
        }
        translate([0, 0, Height])
        hull_stack(ht, mirr=true, cut=true) {
            slot_shape(slot_top_radius + ht, Width);
            slot_shape(slot_top_radius, Width);
        }
    }
}

module main() {
    grommet();
    // part();
}

color("skyblue", 0.5)
main();
