/*
 * Material Swatches rebuilt in OpenSCAD
 * By smkent (GitHub) / bulbasaur0 (Printables)
 *
 * Licensed under Creative Commons CC0 1.0 Universal (Public Domain)
 */

/* [Options] */
Steps = true;
Text = "PLA";
Color = "lightcyan";

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
text_origin = 3.25;
text_size = 6;
step_height = size / 4;
step_increment = 0.2;
step_min = 0.2;
step_count = 5;
step_width = 23.5 / step_count;

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
    translate([text_origin * 0.8, text_origin, height_thin])
    linear_extrude(height=height_thin)
    text(Text, font="Liberation Sans", size=text_size, spacing=0.95);
}

module main() {
    color(Color, 0.8)
    render()
    swatch();
}

main();
