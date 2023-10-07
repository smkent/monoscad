/* [Rendering Options] */
// Render in print orientation (upside down)
Print_Orientation = true;

/* [Size] */
// All units in millimeters

// Thickness of surface the grommet will pass through
Height = 18.26; // [1:0.01:100]
// Horizontal width of the grommet cutout, without the rounded ends (Set to 0 for a circular grommet)
Width = 100; // [0:1500]
// Horizontal depth of the grommet cutout
Depth = 6.35; // [2:0.05:20]

Filament_Size = 1.75; // [1.75: 1.75mm, 3: 3mm]

/* [Advanced Options] */

// Height of top lip of grommet that sits above the surface
Lip_Height = 2; // [1:1:10]

// Width of the filament channel; may be less then or equal to the grommet width (Set to -1 to use Width)
Opening_Width = -1; // [-1:1:500]

// Make the filament channel this percentage wider than the filament size
Filament_Diameter_Tolerance_Percent = 30; // [0:1:100]

module __end_customizer_options__() { }

// Constants //

$fn = $preview ? 10 : 50;

// Modules //

module cutout_shape(radius, width) {
    hull()
    for(m = [0:1]) {
        mirror([m, 0])
        translate([-width/2, 0])
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


module grommet() {
    fs = Filament_Size * (1 + Filament_Diameter_Tolerance_Percent / 100);
    ow = Opening_Width == -1 ? Width : min(Width, Opening_Width);

    difference() {
        union() {
            translate([0, 0, Height])
            hull_stack(Lip_Height, mirr=false) {
                cutout_shape(Depth / 2 + Lip_Height * 2, Width);
                cutout_shape(Depth / 2 + Lip_Height * 1.5, Width);
            }
            linear_extrude(height=Height)
            cutout_shape(Depth/2, Width);
        }
        translate([0, 0, Height])
        hull_stack(Lip_Height, mirr=true, cut=true) {
            cutout_shape((Depth / 2 + Lip_Height) - max(1, Lip_Height / 2), Width);
            cutout_shape(Depth / 2 - 1, Width);
        }
        translate([0, 0, Height / 2])
        hull_stack(Height / 2, mirr=true, cut=true) {
            cutout_shape(Depth / 2 - 1, Width);
            cutout_shape(fs / 2, ow);
        }
        hull_stack(Height / 2, cut=true) {
            cutout_shape((Depth / 2) - 0.3, Width);
            cutout_shape(fs / 2, ow);
        }
    }
}

module main() {
    color("skyblue")
    translate([0, 0, Print_Orientation ? Height + Lip_Height : 0])
    rotate([0, Print_Orientation ? 180 : 0, 0])
    grommet();
}

main();
