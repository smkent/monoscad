/*
 * Material Swatches rebuilt in OpenSCAD
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons CC0 1.0 Universal (Public Domain)
 */

/* [Options] */
Color = "lightcyan";
string1 = "PETG";
string2 = "Maker";
string3 = "";
Steps = true;
/* [Text parameters] */
text_lstart = 2.5; //[0:0.1:12]
// See Font List dialog
string1_font = "Orbitron:style=Bold";
string1_origin = 11; //[1:0.1:12]
string1_size = 4; //[1:1:10]
// 0 to use default height
string1_height = 0; //[0:0.2:10]
string2_font = "Orbitron:style=Bold";
string2_origin = 6; //[1:0.1:12]
string2_size = 4; //[1:1:10]
// 0 to use default height
string2_height = 0; //[0:0.2:10]
string3_font = "Orbitron:style=Bold";
string3_origin = 1.5; //[1:0.1:12]
string3_size = 3; //[1:1:10]
// 0 to use default height
string3_height = 0; //[0:0.2:10]

module __end_customizer_options__() { }

// Constants //

$fa = $preview ? $fa : 2;
$fs = $preview ? $fs : 0.4;

size = 31.75;
height_thin = 1.6;
height_thick = 3.2;
corner_radius = 2;
hole_diameter = 4.25;
hole_radius = hole_diameter / 2;
hole_inset = hole_radius * 2;
step_height = size / 4;
step_increment = 0.2;
step_min = 0.2;
step_count = 5;
step_width = 23.5 / step_count;

use <fonts/Orbitron/Orbitron-Regular.ttf>
use <fonts/Orbitron/Orbitron-Medium.ttf>
use <fonts/Orbitron/Orbitron-Bold.ttf>

// Modules //

module rounded_square(x, y, radius) {
    offset(radius)
    offset(-radius)
    square([x, y]);
}

module swatch() {
    difference() {
        union() {
            linear_extrude(height=height_thick)
            translate([0, size / 2])
            rounded_square(size, size / 2, corner_radius);
            linear_extrude(height=height_thin)
            rounded_square(size, size, corner_radius);
        }
        linear_extrude(height=height_thick)
        translate([hole_inset, size - hole_inset])
        circle(hole_radius);
        if (Steps) {
            for (i = [1:1:step_count]) {
                xoff = size - step_width * i;
                yoff = size - step_height;
                // echo("i", i, 0.2 * i, xoff, yoff);
                step_thickness = step_min + step_increment * i;
                translate([xoff, yoff, step_thickness])
                linear_extrude(height = height_thick - step_thickness)
                square([step_width + 0.01, step_height]);
            }
        }
    }
    translate([text_lstart, string1_origin, height_thin])
      linear_extrude(height=string1_height > 0? string1_height: height_thin)
      text(string1, font=string1_font, size=string1_size, spacing=0.95);
    translate([text_lstart, string2_origin, height_thin])
      linear_extrude(height=string2_height > 0? string2_height: height_thin)
      text(string2, font=string2_font, size=string2_size, spacing=0.95);
    translate([text_lstart, string3_origin, height_thin])
      linear_extrude(height=string3_height > 0? string3_height: height_thin)
      text(string3, font=string3_font, size=string3_size, spacing=0.95);
}

module main() {
    color(Color, 0.8)
    render()
    swatch();
}

main();
